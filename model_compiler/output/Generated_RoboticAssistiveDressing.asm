//Auto-generated from SLEEC DSL

asm Generated_RoboticAssistiveDressing

import ../../libraries/StandardLibrary
import ../../libraries/CTLLibrary
import ../../libraries/SLEECLibrary
import Generated_RoboticAssistiveDressingHeader

signature:

definitions:

	/* DOMAIN-SPECIFIC CONTROL RULES */
		rule r_checkForandObtainProxy = r_setObligation[checkForandObtainProxy]
		rule r_closeCurtains = r_setObligation[closeCurtains]
		rule r_curtainsOpenedWithin50Seconds = r_setObligation[curtainsOpened,WITHIN,50,SEC,doNothing]
		rule r_curtainsOpenedWithin60Seconds = r_setObligation[curtainsOpened,WITHIN,60,SEC,doNothing]
		rule r_dressingCompleteWithin2Minutes = r_setObligation[dressingComplete,WITHIN,2,MINUTE,doNothing]
		rule r_dressingCompleteWithin60Seconds = r_setObligation[dressingComplete,WITHIN,60,SEC,doNothing]
		rule r_dressingCompleteWithin90Seconds = r_setObligation[dressingComplete,WITHIN,90,SEC,doNothing]
		rule r_dressingSuccessful = r_setObligation[dressingSuccessful]
		rule r_dressinginClotingX = r_setObligation[dressinginClotingX]
		rule r_healthCheckedWithin30SecondsOtherwiseSupportCalled = r_setObligation[healthChecked,WITHIN,30,SEC,supportCalled]
		rule r_informUser = r_setObligation[informUser]
		rule r_informUserThisIsAgentnotHuman = r_setObligation[informUserThisIsAgentnotHuman]
		rule r_informUserandandReferToHumanCarer = r_setObligation[informUserandandReferToHumanCarer]
		rule r_obtainAssent = r_setObligation[obtainAssent]
		rule r_provideInfo = r_setObligation[provideInfo]
		rule r_refuseRequestWithin30Seconds = r_setObligation[refuseRequest,WITHIN,30,SEC,doNothing]
		rule r_stopActivity = r_setObligation[stopActivity]
		rule r_storeMinInfo = r_setObligation[storeMinInfo]
		rule r_supportCalled = r_setObligation[supportCalled]
		rule r_supportCalledWithin1Minutes = r_setObligation[supportCalled,WITHIN,1,MINUTE,doNothing]

	//SLEEC rules
	rule r_Rule2 =
	  r_SLEEC[dressingStarted, <<r_closeCurtains>>,
	           medicalEmergency, <<r_skip>>,
	           buildingFloor >= 5, <<r_skip>>,
	           roomDark and notVisible, <<r_skip>>,
	           not userAssent, <<r_skip>>
	  ]

	rule r_Rule3 =
	  r_SLEEC[emotionRecognitionDetected and userDistressed = SHIGH, <<r_informUser>>,
	           consentGrantedwithinXmonths, <<r_skip>>,
	           not competentIndicatorRequired or not competentToGrantConsent, <<r_skip>>
	  ]

	rule r_Rule4 =
	  r_SLEEC[dressingStarted and dressPreferenceTypeA and genderTypeB, <<r_dressinginClotingX>>,
	           userAdvices, <<r_skip>>,
	           medicalEmergency, <<r_skip>>,
	           clothingItemNotFound, <<r_informUser>>
	  ]

	rule r_Rule5 =
	  r_SLEEC[interactionStarted, <<r_informUserThisIsAgentnotHuman>>,
	           medicalEmergency, <<r_skip>>,
	           not userConfused, <<r_skip>>,
	           theUserHasBeenInformed, <<r_skip>>
	  ]

	rule r_Rule6 =
	  r_SLEEC[userRequestInfo, <<r_provideInfo>>,
	           not informationAvailable, <<r_informUserandandReferToHumanCarer>>,
	           informationDisclosureNotPermitted, <<r_informUserandandReferToHumanCarer>>
	  ]

	rule r_Rule7 =
	  r_SLEEC[dressingStarted and admininisteringMedication, <<r_obtainAssent>>,
	           userCompetenceIndicator = 5, <<r_checkForandObtainProxy>>,
	           medicalEmergency, <<r_skip>>,
	           withholdingActivityPhysicalHarm = MODERATE or withholdingActivityPhysicalHarm = SEVERE, <<r_skip>>,
	           consentGranted, <<r_skip>>,
	           not consentIndicatorRequired, <<r_skip>>,
	           consentIndicatorisWithdrawn or consentIndicatorisRevoked, <<r_stopActivity>>
	  ]

	rule r_Rule8 =
	  r_SLEEC[collectionStarted, <<r_storeMinInfo>>
	  ]

	rule r_Rule12 =
	  r_SLEEC[dressingStarted and userUnderDressed, <<r_dressingCompleteWithin2Minutes>>,
	           roomTemperature < 19, <<r_dressingCompleteWithin90Seconds>>,
	           roomTemperature < 17, <<r_dressingCompleteWithin60Seconds>>
	  ]

	rule r_Rule22 =
	  r_SLEEC[curtainOpenRqt, <<r_curtainsOpenedWithin60Seconds>>,
	           userUnderDressed, <<r_refuseRequestWithin30Seconds>>,
	           userDistressed = SHIGH, <<r_curtainsOpenedWithin50Seconds>>
	  ]

	rule r_Rule32 =
	  r_SLEEC[userFallen, <<r_supportCalledWithin1Minutes>>,
	           not assentToSupportCalls, <<r_skip>>,
	           emergency, <<r_skip>>
	  ]

	rule r_Rule52 =
	  r_SLEEC[dressingStarted and roomTemperature >= 19, <<r_dressingCompleteWithin2Minutes>>
	  ]

	rule r_Rule13 =
	  r_SLEEC[dressingStarted, <<r_dressingSuccessful>>
	  ]

	rule r_Rule23 =
	  r_SLEEC[fallAssessed and userUnresponsive, <<r_supportCalled>>
	  ]

	rule r_Rule63 =
	  r_SLEEC[userFallen, <<r_healthCheckedWithin30SecondsOtherwiseSupportCalled>>
	  ]

	rule r_Rule73 =
	  r_SLEEC[openCurtainsRequested, <<r_curtainsOpenedWithin60Seconds>>
	  ]

		rule r_Reset =
		forall $c in Capability do 
			par
				outConstraint(id($c)) := undef
				outObligation(id($c)) := undef
			endpar


	main rule r_Main =
		seq
			r_Reset[]
			par
				r_Rule2[]
				r_Rule3[]
				r_Rule4[]
				r_Rule5[]
				r_Rule6[]
				r_Rule7[]
				r_Rule8[]
				r_Rule12[]
				r_Rule22[]
				r_Rule32[]
				r_Rule52[]
				r_Rule13[]
				r_Rule23[]
				r_Rule63[]
				r_Rule73[]
			endpar
		endseq

default init s0:
