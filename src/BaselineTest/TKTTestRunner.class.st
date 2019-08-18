Class {
	#name : #TKTTestRunner,
	#superclass : #TestRunner,
	#instVars : [
		'runningHandler',
		'ongoing',
		'started'
	],
	#category : #BaselineTest
}

{ #category : #'instance creation' }
TKTTestRunner class >> menuCommandOn: aBuilder [
	<worldMenu>
	(aBuilder item: #'Forkable Test Runner')
		parent: #Tools;
		action: [ self new open ];
		order: 20;
		keyText: 'o, a';
		help: 'Let you run and debug SUnit tests.';
		icon: self taskbarIcon.
	aBuilder withSeparatorAfter
]

{ #category : #'instance creation' }
TKTTestRunner class >> open [
	<script>
	
	^ self new open
]

{ #category : #api }
TKTTestRunner >> buttons [
	^ 
		
			#(('Archetyped run' #runSelectedClassesInArchetype 'Run all selected tests on a given archetype ' #hasRunnable) 
			 ('Forked run' #runSelectedClassesInCurrentImageCopy 'Run all selected tests on a given archetype ' #hasRunnable)), super buttons
]

{ #category : #api }
TKTTestRunner >> classMenu: aMenu [
	^ (super classMenu: aMenu)
		add: 'Run selected on Archetype'
			selector: #runSelectedClassesInArchetype;
		add: 'Run selected on Current image copy'
			selector: #runSelectedClassesInCurrentImageCopy;
		yourself
]

{ #category : #'forked running' }
TKTTestRunner >> handleError: anError [
	anError debug
]

{ #category : #updating }
TKTTestRunner >> informTestHasFinished: aTestResult [
	| errors partials | 
	partials := aTestResult first.
	errors := aTestResult second.
	
	result registerPartialResult: partials.
	self updateResults.
	self saveResultInHistory.
	errors ifNotEmpty: [ self halt ]
]

{ #category : #'forked running' }
TKTTestRunner >> noteAllHasFinished [
	duration := started - DateAndTime now.
	self halt: duration asString
]

{ #category : #'forked running' }
TKTTestRunner >> noteFinishedScheduling: future [

]

{ #category : #'forked running' }
TKTTestRunner >> runSelectedClassesInArchetype: aTKTArchetype [
	started := DateAndTime now.
	self resetResult.
	^ self
		tryToExecute: [ self runningHandler
				handle:
					(classesSelected asOrderedCollection
						reject: [ :c | 
							(c isAbstract or: [ c isVariable ])
								or: [ c package name beginsWith: 'TaskIt' ] ])
				for: aTKTArchetype
				updating: self ]
]

{ #category : #'forked processing' }
TKTTestRunner >> runSelectedClassesInCurrentImageCopy [
	self runSelectedClassesInArchetype: TKTArchetype pharoCurrent
]

{ #category : #accessing }
TKTTestRunner >> runningHandler [
	^ runningHandler
		ifNil: [ runningHandler := TKTTestRunnerHandler new.
			runningHandler setUp ]
]

{ #category : #'forked running' }
TKTTestRunner >> tryToExecute: aBlock [
	aBlock value.
		"
	ongoing
		ifNotNil: [ ongoing isFinished
				ifFalse: [ ^ self
						error:
							'Remote scheduling on going. Please wait before scheduling more tests ' ] ].
	ongoing := aBlock future.
	ongoing onSuccessDo: [ :v | self noteFinishedScheduling: ongoing ].
	ongoing
		onFailureDo: [ :v | 
			self noteFinishedScheduling: ongoing.
			self handleError: v ]"
]
