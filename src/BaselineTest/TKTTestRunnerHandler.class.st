Class {
	#name : #TKTTestRunnerHandler,
	#superclass : #Object,
	#instVars : [
		'pool',
		'futures',
		'partitions'
	],
	#category : #BaselineTest
}

{ #category : #initialization }
TKTTestRunnerHandler >> doPreparePartitions: aCollectionOfTestCases for: anArchetype [
	| basicSize rest stream deploy |
	deploy := anArchetype deploy.
	partitions := OrderedCollection new: 10.
	basicSize := aCollectionOfTestCases size // 10.
	rest := aCollectionOfTestCases size \\ 10.
	stream := aCollectionOfTestCases readStream.
	
	partitions
		add:
			(TKTTestPartition new
				cases: (stream next: basicSize + rest);
				backend: deploy clone;
				yourself).
	9
		timesRepeat: [ partitions
				add:
					(TKTTestPartition new
						cases: (stream next: basicSize);
						backend: deploy clone;
						yourself) ].
	self assert: stream atEnd.
	^ partitions.
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
TKTTestRunnerHandler >> handle: aCollectionOfTestCases for: anArchetype updating: aTKTTestRunner [
	| newPartitions |
	partitions isEmptyOrNil
		ifFalse: [ ^ self error: ' already working ' ].
	TKTConfiguration runner poolMaxSize: 0.
	newPartitions := self
		doPreparePartitions: aCollectionOfTestCases
		for: anArchetype.
	newPartitions
		do: [ :partition | 
			partition
				registerFuturesToGo:
					(partition cases
						collect: [ :c | 
							| future |
							future := self
								futureForExecutingTestCase: c
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
										partition: partition ] ]).
			2 seconds wait ].
	TKTConfiguration runner poolMaxSize: 10.
	



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
TKTTestRunnerHandler >> registerFuturesToGo: someFutures on: partition [
	futures
		at: partition
		ifPresent: [ :b | b addAll: someFutures ]
		ifAbsent: [ futures at: partition put: someFutures asOrderedCollection ]
]

{ #category : #initialization }
TKTTestRunnerHandler >> setUp [
	pool := TKTArchetypeAwarePool createDefaultWithPool: TKTConfiguration runner .
	futures := Dictionary new.
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
