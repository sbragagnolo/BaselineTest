Class {
	#name : #TKTTestRunnerHandler,
	#superclass : #Object,
	#instVars : [
		'pool',
		'futures'
	],
	#category : #BaselineTest
}

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
	| backend stream partitionSize partition bkndsize backends |
	stream := aCollectionOfTestCases readStream.
	TKTConfiguration runner poolMaxSize: 10.
	bkndsize := 0.
	partitionSize := 300.
	"	backends := (1 to: 5)
		collect: [ :i | self workingOnArchetype: anArchetype ].
	self halt."
	[ stream atEnd ]
		whileFalse: [ bkndsize := bkndsize + 1.
			partition := (stream next: partitionSize) reject: #isNil.
			backend := self workingOnArchetype: anArchetype.
			self
				registerFuturesToGo:
					(partition
						collect: [ :c | 
							| future |
							future := self
								futureForExecutingTestCase: c
								forcingBackend: backend.
							future
								onSuccessDo: [ :partialResult | 
									self
										noteMapIsFinished: future
										updating: aTKTTestRunner
										backend: backend ];
								onFailureDo:
										[ :e | self noteMapIsError: future updating: aTKTTestRunner backend: backend ] ])
				on: backend.
			2 seconds wait ].
	self logCr: ' splitted into ' , bkndsize asString , ' bkends'
]

{ #category : #resulting }
TKTTestRunnerHandler >> handleRemoteError: e [
	e debug
]

{ #category : #resulting }
TKTTestRunnerHandler >> noteFinishedFuture: aFuture backend: aBackend [
	| association |
	association := futures associations
		detect: [ :a | a value includes: aFuture ].
	association value remove: aFuture.
	association value isEmpty
		ifTrue: [ association key stopAndDelete.
			futures removeKey: association key ]
]

{ #category : #resulting }
TKTTestRunnerHandler >> noteMapIsError: aFuture updating: aTKTTestRunner backend: aBackend [
	self noteFinishedFuture: aFuture backend: aBackend.
	[ aFuture synchronizeTimeout: 1 second ]
		on: Error
		do: [ :e | self handleRemoteError: e ]
]

{ #category : #resulting }
TKTTestRunnerHandler >> noteMapIsFinished: aFuture updating: aTKTTestRunner backend: aBackend [
	self noteFinishedFuture: aFuture backend: aBackend.
	aTKTTestRunner
		informTestHasFinished: (aFuture synchronizeTimeout: 1 second)
]

{ #category : #initialization }
TKTTestRunnerHandler >> registerFuturesToGo: someFutures on: backend [
	futures
		at: backend
		ifPresent: [ :b | b addAll: someFutures ]
		ifAbsent: [ futures at: backend put: someFutures asOrderedCollection ]
]

{ #category : #initialization }
TKTTestRunnerHandler >> setUp [
	pool := TKTArchetypeAwarePool createDefaultWithPool: TKTConfiguration runner .
	futures := Dictionary new.
]

{ #category : #initialization }
TKTTestRunnerHandler >> tearDown [
	pool stopAndDelete
]

{ #category : #convenience }
TKTTestRunnerHandler >> workingOnArchetype: aTKTArchetype [
	^ pool spawnNewBackendFor: aTKTArchetype
]
