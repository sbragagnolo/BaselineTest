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
BaselineTestBaselineBaselineCase >> testRemoteArchitecture [
	self assert: self remoteArchitecture equals: archetype architectureSelector 
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testRemoteBackendLoadedBaselinePackage [
	self
		remoteAssert: [ RPackageOrganizer default includesPackageNamed: #BaselineTest ]
		timeout: 20 seconds
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testRemoteImageVersion [
	self assert: self remoteImageVersion equals: archetype imageSelector  
	
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testRemoteLoadedPackages [
	| packages |
	packages := self remoteLoadedPackages.
	self assert: (packages includesPackageNamed: #BaselineTest).
	self assert: (packages includesPackageNamed: #TaskIt).
	self assert: (packages includesPackageNamed: #TaskItShell).
	self assert: (packages includesPackageNamed: #TaskItForkIt)
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testRemoteVmVersion [
	self assert: self remoteVmVersion equals: archetype vmSelector 
	
	
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testSomething [
	true
		ifTrue: [ ^ self skip ].
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
	self assert: self allRemoteTestsExecution timeout: 3412 seconds.
	self assert: self distributedTestExecution timeout: 3412 seconds
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testTaskitFutureTestsArePassing [
	| testExecution |
	testExecution := self
		remoteExecuteTestsClassNamed: #TKTFutureTests
		timeout: 5 minutes.
	self
		assert: (testExecution at: #errors) isEmpty
		description: 'There are errors on the execution of tests'.
	self
		assert: (testExecution at: #failures) isEmpty
		description: 'There are failures on the execution of tests'.
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testTaskitFutureTestsArePassingInManyBackends [
	| testExecution |
	testExecution := self
		allRemoteExecuteTestsClassNamed: #TKTFutureTests
		timeout: 5 minutes.
	self
		assert: (testExecution at: #errors) isEmpty
		description: 'There are errors on the execution of tests'.
	self
		assert: (testExecution at: #failures) isEmpty
		description: 'There are failures on the execution of tests'
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testTaskitTestsArePassing [
	| testExecution |
	testExecution := self
		remoteExecuteTestsOnPackageNamed: 'Collections-Tests'
		timeout: 5 minutes.
	self
		assert: (testExecution at: #errors) isEmpty
		description: 'There are errors on the execution of tests'.
	self
		assert: (testExecution at: #failures) isEmpty
		description: 'There are failures on the execution of tests'.
]

{ #category : #accessing }
BaselineTestBaselineBaselineCase >> testTaskitTestsArePassingInManyBackends [
	| testExecution |
	testExecution := self
		allRemoteExecuteTestsOnPackageNamed: 'Collections-Tests'
		timeout: 5 minutes.
	self
		assert: (testExecution at: #errors) isEmpty
		description: 'There are errors on the execution of tests'.
	self
		assert: (testExecution at: #failures) isEmpty
		description: 'There are failures on the execution of tests'
]
