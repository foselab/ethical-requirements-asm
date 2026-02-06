// Sample SLEEC rules for a Assistive Dressing Robot
//CAREBOT-integrated-changed.sleec

asm dressingrobot

import ../libraries/StandardLibrary
import ../libraries/CTLLibrary
import ../libraries/SLEECLibrary
import dressingrobotHeader

signature: 

definitions:
	
	 
    //default: no obligation to do
	rule r_doNothing = r_setObligation[doNothing]
	
	rule r_completeDressingWithinTwoMinutes = r_setObligation[completeDressing,WITHIN,2,MINUTE,doNothing]
	
	rule r_completeDressingWithinNinetySeconds = r_setObligation[completeDressing,WITHIN,90,SEC,doNothing]
	
	rule r_completeDressingWithinSixtySeconds = r_setObligation[completeDressing,WITHIN,60,SEC,doNothing]
	
	rule r_openCurtains = r_setObligation[openCurtains]
	
	rule r_closeCurtains = r_setObligation[closeCurtains]
			
	rule r_openCurtainsWithinMaxResponseTime = r_setObligation[openCurtains,WITHIN,max_response_time,SEC,doNothing]
	
	rule r_provideInfo = r_setObligation[provideInfo]
	
	rule r_refuseRequest = r_setObligation[refuseRequest]
	
	rule r_refuseRequestWithinThirtySec = r_setObligation[refuseRequest,WITHIN,30,SEC,doNothing]
	
	rule r_callSupportWithinOneMinute = r_setObligation[callSupport,WITHIN,1,MINUTE,doNothing]
	
	rule r_informUser = r_setObligation[informUser]
	
	rule r_informUserThisIsAgentnotHuman = r_setObligation[informUserThisIsAgentnotHuman]
	
	rule r_referToHumanCarer = r_setObligation[referToHumanCarer]
	
	rule r_informUserAndReferToHumanCarer = par r_setObligation[informUser] r_setObligation[referToHumanCarer] endpar //r_setObligation[informUserAndReferToHumanCarer]
	
	rule r_dressingInClotingX = r_setObligation[dressingInClotingX]
	
	rule r_obtainAssent = r_setObligation[obtainAssent]
	
	rule r_checkForandObtainProxy = r_setObligation[checkForAndObtainProxy]
	
	rule r_stopActivity = r_setObligation[stopActivity]
	
	rule r_storeMinInfo = r_setObligation [storeMinInfo]
	
	rule r_agreeRetryWithinThreeMinutes = r_setObligation[agreeRetry,true,WITHIN,3,MINUTE,callSupport,not assentToSupportCalls]
	/*	 	otherwise SupportCalled 
		  	unless not assentToSupportCalls //guarded alternative capability 
	*/
	
	rule r_healthCheckWithin30Sec = r_setObligation[healthCheck,WITHIN,60,SEC,callSupport] //otherwise SupportCalled within MAX_RESPONSE_TIME seconds
	
	rule r_dressingSuccessful = r_setObligation[dressingSuccessful]
	
	rule r_callSupport = r_setObligation[callSupport]
	
	rule r_notCurtainsOpenedWithin60Seconds = r_setObligation[openCurtains, false, WITHIN, 60, SEC, doNothing] 
	
	
	//Cultural, empathetic 
/* 	rule r_Rule1 =
		r_SLEEC[curtainOpenRqt, <<r_openCurtains>>,
				userUnderDressed, <<r_refuseRequest>>,
				userDistressed = SHIGH,  <<r_openCurtains>> //irrelevant
		]
*/	//See Rule12
	
	
    rule r_Rule2 =
		r_SLEEC[dressingStarted, <<r_closeCurtains>>,
				medicalEmergency, <<r_skip>>,
				buildingFloor >= 5, <<r_skip>>,
				roomDark and notVisible, <<r_skip>>,
				not userAssent , <<r_skip>> //irrelevant
		]
			   
			   
	rule r_Rule3 =
	r_SLEEC[emotionRecognitionDetected and userDistressed = SHIGH, <<r_informUser>>,
		consentGrantedwithinXmonths, <<r_skip>>,
		not competentIndicatorRequired or not competentToGrantConsent, <<r_skip>> // irrelevant
	]
	  

	rule r_Rule4 =
		r_SLEEC[dressingStarted and dressPreferenceTypeA and genderTypeB, <<r_dressingInClotingX>>,
				userAdvices, <<r_skip>>,
				medicalEmergency, <<r_skip>>,
				clothingItemNotFound, <<r_informUser>> // irrelevant  
		]
		
	
	
	rule r_Rule5 =
		r_SLEEC[interactionStarted, <<r_informUserThisIsAgentnotHuman>>,
				medicalEmergency, <<r_skip>>,
				not userConfused, <<r_skip>>,
				theUserHasBeenInformed, <<r_skip>> // irrelevant
		]
		
		
	//legal, ethical 
	rule r_Rule6 =
		r_SLEEC[userRequestInfo, <<r_provideInfo>>,
				not informationAvailable, <<r_informUserAndReferToHumanCarer>>,
				informationDisclosureNotPermitted, <<r_informUserAndReferToHumanCarer>> // irrelevant
		]
		
	
	//obtain consent/assent before dressing/administering medication
	rule r_Rule7 =
		r_SLEEC[dressingStarted and admininisteringMedication, <<r_obtainAssent>>,
				userCompetenceIndicator = n, <<r_checkForandObtainProxy>>,
				medicalEmergency, <<r_skip>>,
				withholdingActivityPhysicalHarm = MODERATE or withholdingActivityPhysicalHarm = SEVERE, <<r_skip>>,
				consentGranted, <<r_skip>>,
				not consentIndicatorRequired, <<r_skip>>,
				consentIndicatorisWithdrawn or consentIndicatorisRevoked, <<r_stopActivity>> // irrelevant
		]
	  	
	rule r_Rule8 = r_SLEEC[collectionStarted, <<r_storeMinInfo>>] // irrelevant
	
		
	//second version (like in the JSS J. paper)	
	//empathetic, ethical. & IMPLICATION: promotes and supports user well-being
	rule r_Rule12 =
		r_SLEEC[dressingStarted and userUnderDressed, <<r_completeDressingWithinTwoMinutes>>,
				roomTemperature < 19, <<r_completeDressingWithinNinetySeconds>>,
				roomTemperature < 17, <<r_completeDressingWithinSixtySeconds>> //relevant
		]
		
	//cultural, empathetic & IMPLICATION: respect for privacy and cultural sensivity	
	rule r_Rule22 =
		r_SLEEC[curtainOpenRqt, <<r_openCurtainsWithinMaxResponseTime>>,
				userUnderDressed, <<r_refuseRequestWithinThirtySec>>,
				userDistressed = SHIGH,  <<r_openCurtainsWithinMaxResponseTime>> //relevant
		]
	

   	//legal, ethical, social. & IMPLICATION: respect for autonomy and preventing harm
	rule r_Rule32 =
			r_SLEEC[userFallen , <<r_callSupportWithinOneMinute>>,
				not assentToSupportCalls, <<r_skip>>,
				emergency,  <<r_skip>> //irrelevant
		]
		 
		 
	//legal, ethical. & IMPLICATION: promoting user beneficence and respecting autonomy
	rule r_Rule42 =
		r_SLEEC[dressingAbandoned , <<r_agreeRetryWithinThreeMinutes>>] //relevant
		
		
	rule r_Rule52 =
		r_SLEEC[dressingStarted and roomTemperature > 19, <<r_completeDressingWithinTwoMinutes>>] //relevant
		
	
	//third version

    rule r_Rule13 =
		r_SLEEC[dressingStarted , <<r_dressingSuccessful>>]//relevant
	
	/*
	rule r_Rule33 =
		r_SLEEC[openCurtainsRequested and userUndressed, <<r_notCurtainsOpenedWithin60Seconds>>] //irrelevant

	rule r_Rule43 =
		r_SLEEC[userFallen, <<r_callSupport>>] //relevant
 
	rule r_Rule53 =
		r_SLEEC[userFallen, <<r_callSupportWithinOneMinute>>] //relevant
		
	rule r_Rule83 =
		r_SLEEC[openCurtainsRequested, <<r_openCurtainsWithinMaxResponseTime>>,
			userUndressed, <<r_refuseRequestWithinThirtySec>>,
			userDistressedHigh, <<r_openCurtainsWithinMaxResponseTime>>
		] //both irrelevant and relevant
    */	 

	
		rule r_Rule23 =
		r_SLEEC[fallAssessed and userUnresponsive, <<r_callSupport>>]//irrelevant
		
		rule r_Rule63 =
		r_SLEEC[userFallen, <<r_healthCheckWithin30Sec>> //relevant
			
		] 
		
		rule r_Rule73 =
		r_SLEEC[curtainOpenRqt, <<r_openCurtainsWithinMaxResponseTime>>] //irrelevant
		
	  	
	/* CONSTANT (DOMAIN-GENERIC) RULES*/
	
	
	//reset of all locations that contribute to the out location output
	rule r_Reset =
	 	forall $c in Capability do 
	 		par
				outConstraint(id($c)) := undef 
				outObligation(id($c)) := undef 
			endpar
			
	//Semantic conflicts: some examples
	invariant inv_I1 over outObligation: not  (outObligation(OPENCURTAINS)=true and outObligation(CLOSECURTAINS)=true) //never both true
	invariant inv_I1 over outObligation: not  (outObligation(OPENCURTAINS)=true and outObligation(CLOSECURTAINS)=true) //never both true
	
	
	
	/* DOMAIN-SPECIFIC RULES*/
		
	main rule r_Main = 
		seq	
			r_Reset[] //reset of out locations in sequential order, otherwise the function resetting updates will not be visible to the other rules in one machine step
			par //Run of a sample of SLEEC rules 
			r_Rule12[]
			r_Rule22[]
			r_Rule32[]
			r_Rule42[]
			r_Rule6[]
			r_Rule4[]
			endpar
		endseq 

default init s0:


