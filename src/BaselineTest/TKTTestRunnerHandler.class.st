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
	| basicSize rest stream amount |
	amount := 5.
	partitions := OrderedCollection new: amount.
	basicSize := aCollectionOfTestCases size // amount.
	rest := aCollectionOfTestCases size \\ amount.
	stream := aCollectionOfTestCases readStream.
	partitions
		add:
			(TKTTestPartition new
				cases: (stream next: basicSize + rest);
				archetype: anArchetype;
				yourself).
	amount - 1
		timesRepeat: [ partitions
				add:
					(TKTTestPartition new
						cases: (stream next: basicSize);
						archetype: anArchetype;
						yourself) ].
	self assert: stream atEnd.
	^ partitions
]

{ #category : #initialization }
TKTTestRunnerHandler >> futureForExecutingTestCases: aCollectionOfCases archetype: archetype [
	| block |
	block := self class
		evaluate:
			('
		[ |  result errors  |
	errors := OrderedCollection new. 
	result := TestResult new .
	{1} do: [ : classSymbol |  [ result registerPartialResult: classSymbol asClass buildSuiteFromSelectors run ] on: Error do: [ : e | errors add:\{classSymbol . e messageText \} .e resume ] ].	
	\{ result . errors \}]
			'
				format: {(aCollectionOfCases collect: [ :c | c name asSymbol ]) asArray}).
				
	^ (block asArchetypedTaskOn: archetype) future: pool
]

{ #category : #initialization }
TKTTestRunnerHandler >> handle: aCollectionOfTestCases for: anArchetype updating: aTKTTestRunner [
	| newPartitions |
	newPartitions := self
		doPreparePartitions: aCollectionOfTestCases
		for: anArchetype.
	newPartitions
		do: [ :partition | 
			| future |
			future := self
				futureForExecutingTestCases: partition cases
				archetype: partition archetype. 
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
