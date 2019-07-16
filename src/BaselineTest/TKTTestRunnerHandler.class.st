Class {
	#name : #TKTTestRunnerHandler,
	#superclass : #Object,
	#instVars : [
		'pool',
		'partitions'
	],
	#category : #BaselineTest
}

{ #category : #initialization }
TKTTestRunnerHandler >> doPreparePartitions: aCollectionOfTestCases for: anArchetype [
	| basicSize rest stream deploy amount |
	deploy := anArchetype deploy.
	amount := 10.
	partitions := OrderedCollection new: amount.
	basicSize := aCollectionOfTestCases size // amount.
	rest := aCollectionOfTestCases size \\ amount.
	stream := aCollectionOfTestCases readStream.
	partitions
		add:
			(TKTTestPartition new
				cases: (stream next: basicSize + rest);
				backend: (self workingOnArchetype: deploy clone);
				yourself).
	amount - 1
		timesRepeat: [ partitions
				add:
					(TKTTestPartition new
						cases: (stream next: basicSize);
						backend: (self workingOnArchetype: deploy clone);
						yourself) ].
	self assert: stream atEnd.
	^ partitions
]

{ #category : #executing }
TKTTestRunnerHandler >> futureForExecutingTestCase: aClass forcingBackend: aTKTForkedBackend [
	| block |
	block := self class
		evaluate: ('[ ''{1}'' asClass buildSuiteFromSelectors run ]' format: {aClass}).
	^ pool
		futureArchetypedTask: (block asArchetypedTaskOn: aTKTForkedBackend archetype)
		backend: aTKTForkedBackend
]

{ #category : #initialization }
TKTTestRunnerHandler >> futureForExecutingTestCases: aCollectionOfCases forcingBackend: aBackend [
	| block |
	block := self class
		evaluate:
			('
		[ 	| suit cases |
			cases := {1} collect: [ : classSymbol | classSymbol asClass buildSuiteFromSelectors ].
			suit := TestSuite named: ''ForkedSuit''. 
			suit addTests: cases.
			suit run. ]'
				format: {(aCollectionOfCases collect: [ :c | c name asSymbol ]) asArray}).
	^ pool
		futureArchetypedTask: (block asArchetypedTaskOn: aBackend archetype)
		backend: aBackend
]

{ #category : #initialization }
TKTTestRunnerHandler >> handle: aCollectionOfTestCases for: anArchetype updating: aTKTTestRunner [
	| newPartitions |
	partitions isEmptyOrNil
		ifFalse: [ ^ self error: ' already working ' ].
	TKTConfiguration runner poolMaxSize: 2.
	newPartitions := self
		doPreparePartitions: aCollectionOfTestCases
		for: anArchetype.
	TKTConfiguration runner poolMaxSize: 0.
	newPartitions
		do: [ :partition | 
			| future |
			future := self
				futureForExecutingTestCases: partition cases
				forcingBackend: partition backend.
			future
				onSuccessDo: [ :partialResult | 
					self
						noteMapIsFinished: future
						updating: aTKTTestRunner
						partition: partition ];
				onFailureDo: [ :e | 
					self
						noteMapIsError: future
						updating: aTKTTestRunner
						partition: partition ].
			partition registerFuturesToGo: {future}.
			2 seconds wait ].
	TKTConfiguration runner poolMaxSize: 10
]

{ #category : #resulting }
TKTTestRunnerHandler >> handleRemoteError: e [
	e debug
]

{ #category : #resulting }
TKTTestRunnerHandler >> noteMapIsError: aFuture updating: aTKTTestRunner partition: aPartition [
	aPartition noteFinishedFuture: aFuture.
	[ aFuture synchronizeTimeout: 1 second ]
		on: Error
		do: [ :e | self handleRemoteError: e ]
]

{ #category : #resulting }
TKTTestRunnerHandler >> noteMapIsFinished: aFuture updating: aTKTTestRunner partition: aPartition [
	aPartition noteFinishedFuture: aFuture.
	aTKTTestRunner
		informTestHasFinished: (aFuture synchronizeTimeout: 1 second)
]

{ #category : #initialization }
TKTTestRunnerHandler >> setUp [
	pool := TKTArchetypeAwarePool createDefaultWithPool: TKTConfiguration runner .
	
]

{ #category : #initialization }
TKTTestRunnerHandler >> tearDown [
	self halt.
	pool stopAndDelete
]

{ #category : #convenience }
TKTTestRunnerHandler >> workingOnArchetype: aTKTArchetype [
	^ pool spawnNewBackendFor: aTKTArchetype
]
