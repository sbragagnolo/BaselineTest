Class {
	#name : #BaselineTestPoolResource,
	#superclass : #TestResource,
	#instVars : [
		'pool'
	],
	#category : #BaselineTest
}

{ #category : #accessing }
BaselineTestPoolResource >> pool [
	^ pool
]

{ #category : #accessing }
BaselineTestPoolResource >> setUp [
	super setUp.
	pool := TKTArchetypeAwarePool createDefault
]

{ #category : #accessing }
BaselineTestPoolResource >> tearDown [
	pool stopAndDelete. 
]
