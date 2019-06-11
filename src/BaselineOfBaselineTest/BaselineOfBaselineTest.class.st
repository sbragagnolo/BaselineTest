Class {
	#name : #BaselineOfBaselineTest,
	#superclass : #BaselineOf,
	#category : #BaselineOfBaselineTest
}

{ #category : #baselines }
BaselineOfBaselineTest >> baseline: spec [
	<baseline>
	self taskit: spec.
	spec package: #BaselineTest with: [ spec requires: #(TaskIt) ]
]

{ #category : #baselines }
BaselineOfBaselineTest >> taskit: spec [
	spec
		baseline: 'TaskItShell'
		with: [ spec repository: 'git@github.com:sbragagnolo/taskit.git' ]
]
