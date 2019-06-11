Class {
	#name : #BaselineTest,
	#superclass : #Object,
	#category : #BaselineTest
}

{ #category : #tests }
BaselineTest >> loadAndTestGroup: group [
	| suits project result |
	project := (self package name copyReplaceAll: #BaselineOf with: '')
		asString.
	Metacello new
		baseline: project;
		repository: self packageRepositoryURL;
		load: group asSymbol.
	suits := (Smalltalk packages
		select: [ :package | package name beginsWith: project ])
		flatCollect: [ :package | 
			package classes
				select:
					[ :class | (class inheritsFrom: TestCase) and: [ class isAbstract not ] ]
				thenCollect: [ :testCase | testCase buildSuiteFromSelectors ] ].
	result := (TestSuite named: group , '-Testing')
		addTests: suits;
		run.
	^ self transformResultIntoMap: result
]

{ #category : #tests }
BaselineTest >> loadAndTestGroupInWorker: group [
	#ImageWorker asClass do: [ self loadAndTestGroup: group ]
]

{ #category : #tests }
BaselineTest >> mapTestResult: aTestResult [
	| map |
	map := Dictionary new.
	map at: #class put: aTestResult class name asSymbol.
	map
		at: #test
		put:
			((aTestResult class allSlots detect: [ :s | s name = #testSelector ])
				read: aTestResult).
	^ map
]

{ #category : #tests }
BaselineTest >> packageRepositoryURL [
	^ super packageRepositoryURL
		ifEmpty: [ | packageName |
			packageName := self class package name.
			'tonel://' , (IceRepository registry detect: [ :repo | repo workingCopy packageNames includes: packageName ] ifFound: [ :repo | repo location pathString , '/' , repo subdirectory ] ifNone: [ '' ]) ]
]

{ #category : #tests }
BaselineTest >> testAllGroups [
	"protocol: #tests"

	| results semaphore session |
	"Metacello new
		baseline: #ImageWorker;
		repository: 'github://pharo-contributions/ImageWorker/source';
		load."
	results := Array new: self version groups size.
	semaphore := Semaphore new.
	session := Smalltalk session.
	(self version groups collect: #name)
		doWithIndex: [ :group :id | 
			session = Smalltalk session
				ifTrue: [ [ [ [ results at: id put: (self loadAndTestGroupInWorker: group) ]
						on: Error
						do: [ :e | results at: id put: e ] ]
						ensure: [ semaphore signal ] ] forkNamed: 'Group-' , group ] ].
	1 to: self version groups size do: [ :i | 
		semaphore wait: 20 minutes.
		(results allSatisfy: #isNotNil)
			ifTrue: [ ^ results ] ].
	(results allSatisfy: #isNotNil)
		ifTrue: [ ^ results ].
	self error: 'Unexpected finalization'
]

{ #category : #tests }
BaselineTest >> transformResultIntoMap: aREsult [
	| map |
	map := Dictionary new.
	map
		at: #errors
		put: (aREsult errors collect: [ :e | self mapTestResult: e ]).
	map
		at: #failures
		put: (aREsult failures collect: [ :e | self mapTestResult: e ]).
	map
		at: #passed
		put: (aREsult passed collect: [ :e | self mapTestResult: e ]).
	map
		at: #skipped
		put: (aREsult skipped collect: [ :e | self mapTestResult: e ]).
	^ map
]
