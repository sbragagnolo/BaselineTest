Class {
	#name : #TKTTestPartition,
	#superclass : #Object,
	#instVars : [
		'cases',
		'backend',
		'futures'
	],
	#category : #BaselineTest
}

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
	^ cases
]

{ #category : #accessing }
TKTTestPartition >> cases: aCollection [
	cases := aCollection
]

{ #category : #accessing }
TKTTestPartition >> futures: aCollection [
	futures := aCollection
]

{ #category : #accessing }
TKTTestPartition >> noteFinishedFuture: aFuture [
	self assert: (futures includes: aFuture).
	(futures allSatisfy: #isFinished)
		ifTrue: [ backend stopAndDelete ]
]

{ #category : #accessing }
TKTTestPartition >> registerFuturesToGo: aCollection [
	self futures: aCollection 
]
