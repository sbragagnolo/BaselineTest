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
	amount := 100.
	
	
	partitions := OrderedCollection new: amount.
	basicSize := aCollectionOfTestCases size // amount.
	rest := aCollectionOfTestCases size \\ amount.
	partitions inspect.
	
	
	
	self inform: ' Scheduling Test cases: ' , aCollectionOfTestCases size asString.
	self inform: ' Scheduling Batch size: ' , basicSize asString.
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
TKTTestRunnerHandler >> futureForExecutingTestCases: aGroupOfTestCases archetype: archetype [
	| block code suites |
	suites := aGroupOfTestCases keys
		collect: [ :aClass | 
			' {1} do: [ : testSelector | suite addTest: ({2} selector: testSelector) ].'
				format:
					{(aGroupOfTestCases at: aClass) asArray.
					aClass name} ].
	code := '
		[ |  result errors  suite |
	errors := OrderedCollection new. 
	result := TestResult new.
	suite := TestSuite new.
	{1}.
	{2}]'
		format:
			{(OSPlatform current lineEnding join: suites).
			'[ result registerPartialResult: suite run ] on: Error do: [ : e | errors add:{  e messageText } .e resume ]'.
			'{ result . errors }]'}.
	block := self class evaluate: code.
	^ (block asArchetypedTaskOn: archetype) future: self pool
]

{ #category : #initialization }
TKTTestRunnerHandler >> handle: aCollectionOfTests for: anArchetype updating: aTKTTestRunner [
	| newPartitions testsCases |
	testsCases := aCollectionOfTests
		flatCollect: [ :class | class allTestSelectors collect: [ :s | class -> s ] ].
	newPartitions := self
		doPreparePartitions: testsCases
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
			partition registerFuturesToGo: {future} ]
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
		informTestHasFinished: (aFuture synchronizeTimeout: 1 second).
	(partitions allSatisfy: #hasFinished)
		ifTrue: [ aTKTTestRunner noteAllHasFinished ]
]

{ #category : #initialization }
TKTTestRunnerHandler >> pool [
	^ pool
		ifNil: [ self setUp.
			pool ]
]

{ #category : #initialization }
TKTTestRunnerHandler >> setUp [
	pool := TKTArchetypeAwarePool createDefaultWithPool: TKTConfiguration runner .
	
]

{ #category : #initialization }
TKTTestRunnerHandler >> tearDown [
	pool stopAndDelete
]
