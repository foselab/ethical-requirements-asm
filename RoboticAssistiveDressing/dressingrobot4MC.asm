// Sample SLEEC rules for a Assistive Dressing Robot
//CAREBOT-integrated-changed.sleec

asm dressingrobot4MC

import ../libraries/StandardLibrary
import ../libraries/CTLLibrary
//import ../libraries/SLEECLibrary
import dressingrobotHeader4MC

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
    rule r_Rule1 =
		/*r_SLEEC[curtainOpenRqt, <<r_openCurtains>>,
				userUnderDressed, <<r_refuseRequest>>,
				userDistressed = SHIGH,  <<r_openCurtains>> //irrelevant
		]*/
	    if curtainOpenRqt and not userUnderDressed then r_openCurtains[]
    	else if curtainOpenRqt and userUnderDressed and not (userDistressed = SHIGH) then r_refuseRequest[]
    	else if curtainOpenRqt and userUnderDressed and (userDistressed = SHIGH) then r_openCurtains[] //irrelevant
    	endif endif endif
	
    rule r_Rule2 =
		/*r_SLEEC[dressingStarted, <<r_closeCurtains>>,
				medicalEmergency, <<r_skip>>,
				buildingFloor >= 5, <<r_skip>>,
				roomDark and notVisible, <<r_skip>>,
				not userAssent , <<r_skip>> //irrelevant
		]*/
		if dressingStarted and not medicalEmergency then r_closeCurtains[]
    	else if dressingStarted and medicalEmergency and not (buildingFloor >= 5) then r_skip[]
    	else if dressingStarted and medicalEmergency and (buildingFloor >= 5) and not (roomDark and notVisible) then r_skip[]
    	else if dressingStarted and medicalEmergency and (buildingFloor >= 5) and (roomDark and notVisible) and userAssent then r_skip[]
    	else if dressingStarted and medicalEmergency and (buildingFloor >= 5) and (roomDark and notVisible) and (not userAssent) then r_skip[] //irrelevant
    	endif endif endif endif endif
			   
			   
	rule r_Rule3 =
	/*r_SLEEC[emotionRecognitionDetected and userDistressed = SHIGH, <<r_informUser>>,
		consentGrantedwithinXmonths, <<r_skip>>,
		not competentIndicatorRequired or not competentToGrantConsent, <<r_skip>> // irrelevant
	]*/
		if (emotionRecognitionDetected and userDistressed = SHIGH) and not consentGrantedwithinXmonths then r_informUser[]
    	else if (emotionRecognitionDetected and userDistressed = SHIGH) and consentGrantedwithinXmonths
        	    and not (not competentIndicatorRequired or not competentToGrantConsent) then r_skip[]
    	else if (emotionRecognitionDetected and userDistressed = SHIGH) and consentGrantedwithinXmonths
        	    and (not competentIndicatorRequired or not competentToGrantConsent) then r_skip[] // irrelevant
    	endif endif endif 

	rule r_Rule4 =
		/*r_SLEEC[dressingStarted and dressPreferenceTypeA and genderTypeB, <<r_dressingInClotingX>>,
				userAdvices, <<r_skip>>,
				medicalEmergency, <<r_skip>>,
				clothingItemNotFound, <<r_informUser>> // irrelevant  
		]*/
		 if (dressingStarted and dressPreferenceTypeA and genderTypeB) and not userAdvices then r_dressingInClotingX[]
    	 else if (dressingStarted and dressPreferenceTypeA and genderTypeB) and userAdvices and not medicalEmergency then r_skip[]
    	 else if (dressingStarted and dressPreferenceTypeA and genderTypeB) and userAdvices and medicalEmergency
            and not clothingItemNotFound then r_skip[]
    	 else if (dressingStarted and dressPreferenceTypeA and genderTypeB) and userAdvices and medicalEmergency
            and clothingItemNotFound then r_informUser[] // irrelevant
    	 endif endif endif endif
	
	
	rule r_Rule5 =
		/*r_SLEEC[interactionStarted, <<r_informUserThisIsAgentnotHuman>>,
				medicalEmergency, <<r_skip>>,
				not userConfused, <<r_skip>>,
				theUserHasBeenInformed, <<r_skip>> // irrelevant
		]*/
		// Schema equivalente (espansione di r_SLEEC con 4 condizioni)
    if interactionStarted and not medicalEmergency then r_informUserThisIsAgentnotHuman[]
    else if interactionStarted and medicalEmergency and not (not userConfused) then r_skip[]
    else if interactionStarted and medicalEmergency and (not userConfused) and not theUserHasBeenInformed then r_skip[]
    else if interactionStarted and medicalEmergency and (not userConfused) and theUserHasBeenInformed then r_skip[] // irrelevant
    endif endif endif endif
		
		
	//legal, ethical 
	rule r_Rule6 =
		/*r_SLEEC[userRequestInfo, <<r_provideInfo>>,
				not informationAvailable, <<r_informUserAndReferToHumanCarer>>,
				informationDisclosureNotPermitted, <<r_informUserAndReferToHumanCarer>> // irrelevant
		]*/
    if userRequestInfo and not (not informationAvailable) then r_provideInfo[]
    else if userRequestInfo and (not informationAvailable) and not informationDisclosureNotPermitted then r_informUserAndReferToHumanCarer[]
    else if userRequestInfo and (not informationAvailable) and informationDisclosureNotPermitted then r_informUserAndReferToHumanCarer[] // irrelevant
    endif endif endif
	
	//obtain consent/assent before dressing/administering medication
	rule r_Rule7 =
		/*r_SLEEC[dressingStarted and admininisteringMedication, <<r_obtainAssent>>,
				userCompetenceIndicator = n, <<r_checkForandObtainProxy>>,
				medicalEmergency, <<r_skip>>,
				withholdingActivityPhysicalHarm = MODERATE or withholdingActivityPhysicalHarm = SEVERE, <<r_skip>>,
				consentGranted, <<r_skip>>,
				not consentIndicatorRequired, <<r_skip>>,
				consentIndicatorisWithdrawn or consentIndicatorisRevoked, <<r_stopActivity>> // irrelevant
		]*/
    if (dressingStarted and admininisteringMedication) and not (userCompetenceIndicator = n) then r_obtainAssent[]
    else if (dressingStarted and admininisteringMedication) and (userCompetenceIndicator = n) and not medicalEmergency then r_checkForandObtainProxy[]
    else if (dressingStarted and admininisteringMedication) and (userCompetenceIndicator = n) and medicalEmergency
            and not (withholdingActivityPhysicalHarm = MODERATE or withholdingActivityPhysicalHarm = SEVERE) then r_skip[]
    else if (dressingStarted and admininisteringMedication) and (userCompetenceIndicator = n) and medicalEmergency
            and (withholdingActivityPhysicalHarm = MODERATE or withholdingActivityPhysicalHarm = SEVERE)
            and not consentGranted then r_skip[]
    else if (dressingStarted and admininisteringMedication) and (userCompetenceIndicator = n) and medicalEmergency
            and (withholdingActivityPhysicalHarm = MODERATE or withholdingActivityPhysicalHarm = SEVERE)
            and consentGranted and not (not consentIndicatorRequired) then r_skip[]
    else if (dressingStarted and admininisteringMedication) and (userCompetenceIndicator = n) and medicalEmergency
            and (withholdingActivityPhysicalHarm = MODERATE or withholdingActivityPhysicalHarm = SEVERE)
            and consentGranted and (not consentIndicatorRequired)
            and not (consentIndicatorisWithdrawn or consentIndicatorisRevoked) then r_skip[]
    else if (dressingStarted and admininisteringMedication) and (userCompetenceIndicator = n) and medicalEmergency
            and (withholdingActivityPhysicalHarm = MODERATE or withholdingActivityPhysicalHarm = SEVERE)
            and consentGranted and (not consentIndicatorRequired)
            and (consentIndicatorisWithdrawn or consentIndicatorisRevoked) then r_stopActivity[] // irrelevant
    endif endif endif endif endif endif endif
	  	
	rule r_Rule8 =    if collectionStarted then r_storeMinInfo[] endif //irrelevant
		
	
	  	
	/* CONSTANT (DOMAIN-GENERIC) RULES*/
	
	
	//reset of all locations that contribute to the out location output
	rule r_Reset =
	 	forall $c in Capability do 
	 		par
				outConstraint($c) := undef 
				outObligation($c) := false //undef not working for the model checher
			endpar
			
	//Semantic conflicts: some examples
	invariant inv_I1 over outObligation: not  (outObligation(openCurtains)=true and outObligation(closeCurtains)=true) //never both true
	
	
	
	/* DOMAIN-SPECIFIC RULES*/
		
	main rule r_Main = 
		seq	
			r_Reset[] //reset of out locations in sequential order, otherwise the function resetting updates will not be visible to the other rules in one machine step
			par //Run of a sample of SLEEC rules 
			r_Rule1[]
			r_Rule2[]
			r_Rule3[]
			r_Rule4[]
			r_Rule5[]
			r_Rule6[]
			r_Rule7[]
			r_Rule8[]
			endpar
		endseq 

default init s0:


