Class {
	#name : #BaselineTestCase,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'archetype',
		'project',
		'pool'
	],
	#classInstVars : [
		'pool'
	],
	#category : #BaselineTest
}

{ #category : #accessing }
BaselineTestCase class >> pool [
	^ pool ifNil: [ pool := TKTArchetypeAwarePool createDefault ]
]

{ #category : #'building suites' }
BaselineTestCase class >> projectPerGroup [
	^ self subclassResponsibility
]

{ #category : #'building suites' }
BaselineTestCase class >> testParameters [
	^ ParametrizedTestMatrix new
		forSelector: #archetype addOptions: {TKTArchetype pharo80};
		forSelector: #project addOptions: self projectPerGroup;
		yourself
]

{ #category : #accessing }
BaselineTestCase >> allRemotesAssert: aBlock [
	^ self allRemotesAssert: aBlock timeout: self defaultTimeout
]

{ #category : #accessing }
BaselineTestCase >> allRemotesAssert: aBlock timeout: aTimeout [
	| futures |
	futures := self privateAllBackendsCollect: aBlock.
	self assert: futures isNotEmpty.
	futures
		do: [ :f | 
			[ f synchronizeTimeout: aTimeout ]
				on: Error
				do: [ :e | e ] ].
	futures do: [ :f | self assert: (f synchronizeTimeout: aTimeout) ]
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
	pool := self class pool.
	self amountBackendsToUse - (pool backendsFor: archetype) size
		timesRepeat: [ pool spawnNewBackendFor: archetype ]
]

{ #category : #accessing }
BaselineTestCase >> privateAllBackendsCollect: aBlock [
	^ pool allBackendsCollect: (aBlock asArchetypedTaskOn: archetype)
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
	self initializePool.
	archetype := archetype + project
]

{ #category : #accessing }
BaselineTestCase >> tearDown [
	super tearDown.
	"Clean up images"
]
