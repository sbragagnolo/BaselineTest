Class {
	#name : #TKTTestPartition,
	#superclass : #Object,
	#instVars : [
		'cases',
		'backend',
		'futures',
		'archetype',
		'finished',
		'testsSize',
		'finishedAt'
	],
	#category : #BaselineTest
}

{ #category : #avccessing }
TKTTestPartition >> archetype [
	^ archetype
]

{ #category : #accessing }
TKTTestPartition >> archetype: aTKTArchetype [ 
	archetype := aTKTArchetype 
]

{ #category : #accessing }
TKTTestPartition >> backend [
	^ backend
]

{ #category : #accessing }
TKTTestPartition >> backend: aBackend [
	backend := aBackend 
]

{ #category : #accessing }
TKTTestPartition >> cases [
	^ (cases groupedBy: #key) collect: [ :assoc | assoc collect: #value ]
]

{ #category : #accessing }
TKTTestPartition >> cases: aCollection [
	cases := aCollection
]

{ #category : #accessing }
TKTTestPartition >> finishedAt [
	^ finishedAt
]

{ #category : #accessing }
TKTTestPartition >> futures: aCollection [
	futures := aCollection
]

{ #category : #accessing }
TKTTestPartition >> hasFinished [
	^ finished ifNil: [ ^ false ]
]

{ #category : #accessing }
TKTTestPartition >> noteFinishedFuture: aFuture [
	self assert: (futures includes: aFuture).
	(futures allSatisfy: #isFinished)
		ifTrue: [ self noteHasFinished ]
]

{ #category : #accessing }
TKTTestPartition >> noteHasFinished [
	finished := true.
]

{ #category : #accessing }
TKTTestPartition >> printOn: aStream [
	('Partition(Size: {1} Finished: {2}))'
		format:
			{self testsSize asString.
			(self hasFinished
				ifTrue: [ 'TRUE']
				ifFalse: [ 'FALSE' ])}) printOn: aStream
]

{ #category : #accessing }
TKTTestPartition >> registerFuturesToGo: aCollection [
	self futures: aCollection 
]

{ #category : #accessing }
TKTTestPartition >> testsSize [
	^ cases size
]
