Class {
	#name : #BaselineTestCase,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'archetype',
		'project',
		'pool'
	],
	#category : #BaselineTest
}

{ #category : #accessing }
BaselineTestCase class >> isAbstract [
	^ true
]

{ #category : #'building suites' }
BaselineTestCase class >> projectPerGroup [
	^ self subclassResponsibility
]

{ #category : #accessing }
BaselineTestCase class >> resources [
	^ Array with: BaselineTestPoolResource 
]

{ #category : #'building suites' }
BaselineTestCase class >> testParameters [
	^ ParametrizedTestMatrix new
		forSelector: #archetype addOptions: {TKTArchetype pharo80 . TKTArchetype pharo70};
		forSelector: #project addOptions: self projectPerGroup;
		yourself
]

{ #category : #accessing }
BaselineTestCase >> allRemotesAssert: aBlock [
	^ self allRemotesAssert: aBlock timeout: self defaultTimeout
]

{ #category : #accessing }
BaselineTestCase >> amountBackendsToUse [
	^ 1
]

{ #category : #accessing }
BaselineTestCase >> archetype: anArchetype [
	archetype := anArchetype
]

{ #category : #accessing }
BaselineTestCase >> defaultTimeout [
	^ 1 minute
]

{ #category : #accessing }
BaselineTestCase >> executeBlockAsArchetypedTask: aBlock [
	^ (aBlock asArchetypedTaskOn: archetype) future: pool
]

{ #category : #accessing }
BaselineTestCase >> initializePool [
	pool := BaselineTestPoolResource current pool.
	self amountBackendsToUse - (pool backendsFor: archetype) size
		timesRepeat: [ pool spawnNewBackendFor: archetype ]
]

{ #category : #accessing }
BaselineTestCase >> privateTestingBlockForPackage: aPackageName [
	^ self class
		evaluate:
			('[ BaselineTest new testPackageNameStartingWith: ''{1}'' ]'
				format: {aPackageName})
]

{ #category : #accessing }
BaselineTestCase >> privateTestingBlockForTestClassNamed: aClassName [
	^ self class
		evaluate:
			('[ BaselineTest new testClass: ''{1}'' asClass ]'
				format: {aClassName})
]

{ #category : #accessing }
BaselineTestCase >> project: aProject [
	project := aProject
]

{ #category : #accessing }
BaselineTestCase >> remoteArchitecture [
	^ (self
		executeBlockAsArchetypedTask: [ Smalltalk vm is32bit
				ifTrue: [ 32 ]
				ifFalse: [ 64 ] ]) synchronizeTimeout: self defaultTimeout
]

{ #category : #accessing }
BaselineTestCase >> remoteAssert: aBlock [
	^ self remoteAssert: aBlock timeout: self defaultTimeout
]

{ #category : #accessing }
BaselineTestCase >> remoteAssert: aBlock equals: aValue [
	^ self
		remoteAssert: aBlock
		equals: aValue
		timeout: self defaultTimeout
]

{ #category : #accessing }
BaselineTestCase >> remoteAssert: aBlock equals: aValue timeout: aTimeout [
	self
		assert:
			((self executeBlockAsArchetypedTask: aBlock)
				synchronizeTimeout: aTimeout)
		equals: aValue
]

{ #category : #accessing }
BaselineTestCase >> remoteAssert: aBlock timeout: aTimeout [
	self
		assert:
			((self executeBlockAsArchetypedTask: aBlock)
				synchronizeTimeout: aTimeout)
]

{ #category : #accessing }
BaselineTestCase >> remoteExecuteTestsClassNamed: aClassName timeout: aTimeout [
	^ (self
		executeBlockAsArchetypedTask: (self privateTestingBlockForTestClassNamed: aClassName))
		synchronizeTimeout: aTimeout
]

{ #category : #accessing }
BaselineTestCase >> remoteExecuteTestsOnPackageNamed: aPackageName [
	^ self
		remoteExecuteTestsOnPackageNamed: aPackageName
		timeout: self defaultTimeout
]

{ #category : #accessing }
BaselineTestCase >> remoteExecuteTestsOnPackageNamed: aPackageName timeout: aTimeout [
	^ (self
		executeBlockAsArchetypedTask: (self privateTestingBlockForPackage: aPackageName))
		synchronizeTimeout: aTimeout
]

{ #category : #accessing }
BaselineTestCase >> remoteImageVersion [
	^ (self executeBlockAsArchetypedTask: [ Smalltalk version ])
		synchronizeTimeout: self defaultTimeout
]

{ #category : #accessing }
BaselineTestCase >> remoteLoadedPackages [
	^ (self
		executeBlockAsArchetypedTask: [ RPackageOrganizer default packages ])
		synchronizeTimeout: self defaultTimeout
]

{ #category : #accessing }
BaselineTestCase >> remoteVmVersion [
	^ (self executeBlockAsArchetypedTask: [ Smalltalk vm version ])
		synchronizeTimeout: self defaultTimeout
]

{ #category : #accessing }
BaselineTestCase >> runCaseManaged [
	^ self runCase
]

{ #category : #accessing }
BaselineTestCase >> setUp [
	super setUp.
	archetype := archetype + project.
	self initializePool
]

{ #category : #accessing }
BaselineTestCase >> tearDown [
	super tearDown.
	"Clean up images"
]
