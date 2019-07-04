Class {
	#name : #BaselineOfBaselineTest,
	#superclass : #BaselineOf,
	#category : #BaselineOfBaselineTest
}

{ #category : #baselines }
BaselineOfBaselineTest >> baseline: spec [
	<baseline>
	self forkit: spec.
	spec package: #BaselineTest with: [ spec requires: #(ForkIt) ]
]

{ #category : #baselines }
BaselineOfBaselineTest >> forkit: spec [
	spec
		baseline: 'ForkIt'
		with: [ spec repository: 'github://sbragagnolo/taskit:ForkIt' ]
]
