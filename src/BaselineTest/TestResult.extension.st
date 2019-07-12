Extension { #name : #TestResult }

{ #category : #'*BaselineTest' }
TestResult >> registerPartialResult: aTestResult [
	errors addAll: aTestResult errors.
	failures addAll: aTestResult failures.
	skipped addAll: aTestResult skipped.
	passed addAll: aTestResult passed.
	timeStamp < aTestResult timeStamp
		ifTrue: [ timeStamp := aTestResult timeStamp ]
]
