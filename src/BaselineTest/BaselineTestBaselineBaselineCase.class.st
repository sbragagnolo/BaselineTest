Class {
	#name : #BaselineTestBaselineBaselineCase,
	#superclass : #BaselineTestCase,
	#category : #BaselineTest
}

{ #category : #'building suites' }
BaselineTestBaselineBaselineCase class >> projectPerGroup [
	^ {(TKTProject new
		name: #BaselineTest;
		kind: #BaselineOf;
		repository: 'github://sbragagnolo/BaselineTest';
		yourself)}
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testLoadsForkIt [
	self
		remoteAssert:
			[ RPackageOrganizer default includesPackageNamed: #TaskItForkIt ]
		timeout: 20 seconds
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testLoadsTaskit [
	self
		remoteAssert: [ 
			RPackageOrganizer default includesPackageNamed: #TaskIt 
			 ]
		timeout: 20 seconds
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testRemoteBackendLoadedBaselinePackage [
	self
		remoteAssert: [ RPackageOrganizer default includesPackageNamed: #BaselineTest ]
		timeout: 20 seconds
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testSomething [

	self
		remoteAssert: [ " code to execute in the image " ]
		timeout: 20 seconds.
	self allRemotesAssert: [ " code to execute in the image " ].
	self remoteAssert: [ " code to execute in the image " ].
	self
		remoteAssert: [ " code to execute in the image " ]
		equals: '" value " '.
	self
		remoteAssert: [ " code to execute in the image " ]
		equals: '" value " '
		timeout: 3412 seconds.
	self remoteArchitecture.
	self remoteVmVersion.
	self remoteImageVersion.
	self remoteLoadedPackages.
	self assert: self remoteTestsExecution timeout: 3412 seconds.
	self assert: self allRemoteTestsExecution timeout: 3412 seconds.
	self assert: self distributedTestExecution timeout: 3412 seconds
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testTaskitFutureTestsArePassing [
	| testExecution |
	testExecution := self
		remoteExecuteTestsOnPackageNamed: 'TaskIt-Tests'
		timeout: 5 minutes.
	self
		assert: (testExecution at: #errors) isEmpty
		description: 'There are errors on the execution of tests'.
	self
		assert: (testExecution at: #failures) isEmpty
		description: 'There are failures on the execution of tests'.
]
