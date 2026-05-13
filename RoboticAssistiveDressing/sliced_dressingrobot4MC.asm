asm sliced_dressingrobot4MC
import ../libraries/StandardLibrary
import ../libraries/CTLLibrary

signature:
	enum domain TimerUnit={NANOSEC, MILLISEC, SEC, MINUTE, HOUR}//lib: changed MIN in MINUTE
	
	//domains
	enum domain TCType = {AFTER, WITHIN} //lib
	abstract domain Capability //lib
	
/* DOMAIN-SPECIFIC SIGNATURE */

    //domains
	enum domain UserDistressed = {SLOW, SMEDIUM, SHIGH}
	domain RoomTemperature subsetof Integer
	domain TimeValue subsetof Integer //NEW to avoid Integer in the Prod domain

	
/* DOMAIN-SPECIFIC SIGNATURE */

	//(input) events and measures
	monitored dressingStarted: Boolean
	monitored userUnderDressed: Boolean
	monitored curtainOpenRqt: Boolean
	monitored userDistressed: UserDistressed
	monitored roomTemperature: RoomTemperature
	monitored userFallen: Boolean
	monitored assentToSupportCalls: Boolean
	monitored emergency: Boolean
	monitored dressingAbandoned: Boolean
	monitored userRequestInfo: Boolean
	monitored informationAvailable: Boolean
	monitored informationDisclosureNotPermitted: Boolean
	monitored medicalEmergency: Boolean
	monitored dressPreferenceTypeA: Boolean
	monitored genderTypeB: Boolean
	monitored userAdvices: Boolean
	monitored clothingItemNotFound: Boolean
	
	
	//System's capabilities
	static completeDressing: Capability
	static openCurtains: Capability
	static refuseRequest: Capability
	static callSupport: Capability
	static agreeRetry: Capability
	static provideInfo: Capability
	static informUser: Capability
	static referToHumanCarer: Capability
	static dressingInClotingX: Capability
	
	
/* DOMAIN-GENERIC SIGNATURE */	
	
	static doNothing : Capability //lib	
	static max_response_time: TimeValue
		
	//(output) events as obligations that arise from the SLEEC rules for the system (robot) to act
    out outObligation: Capability -> Boolean //any due obligation (there could be more than one) is activated through a flag
	out outConstraint: Capability -> TCType
	out outOtherwiseObligation: Capability -> Capability
	out outTimeBudget: Capability -> TimeValue
	out outTimeUnit: Capability -> TimerUnit

definitions:
	

/* DOMAIN-SPECIFIC DEFINITIONS*/
	/*function id($c in Capability) = 
		switch $c
			case completeDressing: COMPLETEDRESSING
			case openCurtains: OPENCURTAINS
			case refuseRequest: REFUSEREQUEST
			case callSupport: CALLSUPPORT
			case agreeRetry: AGREERETRY
			case provideInfo: PROVIDEINFO
			case informUser: INFORMUSER
			case referToHumanCarer: REFERTOHUMANCARER
			case dressingInClotingX: DRESSINGINCLOTHINGX
			case doNothing: DONOTHING
		endswitch	
	*/

    
/* DOMAIN-GENERIC DEFINITIONS */	
    domain RoomTemperature = {16, 18, 20}
	domain TimeValue = {1, 2, 3, 30, 60, 90}
	
	function max_response_time = 60
    
    
   
   rule r_skip = skip // named rule for no ASM state change (no prescribed obligation)
	
    //to set an obligation with no time constraint
	rule r_setObligation($c in Capability) = 
		 par 
			//prepare out locations
			outObligation($c) := true 
			outConstraint($c) := undef
			outOtherwiseObligation($c) := undef
			outTimeBudget($c) := undef
			outTimeUnit($c) := undef
		 endpar
	
	//Overloading to set an obligation with time constraints for responses and required alternative responses in the case of a timeout
	rule r_setObligation($c in Capability, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		//prepare out locations
		outObligation($c) := true  
		outConstraint($c) := $type
		outTimeBudget($c) := $t
		outTimeUnit($c) := $u
		if (isDef($alt) and $type=WITHIN) then outOtherwiseObligation($c) := $alt else outOtherwiseObligation($c) := doNothing endif
	endpar	
	
	//Jan 2026	NEW
	//Additional overloading to allow obligation suspension temporarily (when $v is false); if $v is true it is 
	//semantically equivalent to the previous rule 
	rule r_setObligation($c in Capability, $v in Boolean, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		//prepare out locations
		outObligation($c) := $v  //Jan 2026 NEW
		outConstraint($c) := $type
		//outOtherwiseObligation($c) := $alt
		outTimeBudget($c) := $t
		outTimeUnit($c) := $u
		if (isDef($alt) and $type=WITHIN) then outOtherwiseObligation($c) := $alt else outOtherwiseObligation($c) := doNothing endif
	endpar	

	//Additional overloading to allow obligation suspension temporarily and to allow a guarded alternative $alt obligation in case of deadline
	rule r_setObligation($c in Capability, $v in Boolean, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability, $guard in Boolean) = 
	par 
		//prepare out locations
		outObligation($c) := $v  
		outConstraint($c) := $type
		outTimeBudget($c) := $t
		outTimeUnit($c) := $u
		if (isDef($alt) and $type=WITHIN and $guard) then outOtherwiseObligation($c) := $alt 
		else outOtherwiseObligation($c) := doNothing endif
	endpar


/* DOMAIN-SPECIFIC CONTROL RULES*/

	rule r_completeDressingWithinTwoMinutes = r_setObligation[completeDressing,WITHIN,2,MINUTE,doNothing]
	rule r_completeDressingWithinNinetySeconds = r_setObligation[completeDressing,WITHIN,90,SEC,doNothing]
	rule r_completeDressingWithinSixtySeconds = r_setObligation[completeDressing,WITHIN,60,SEC,doNothing]
	rule r_openCurtainsWithinMaxResponseTime = r_setObligation[openCurtains,WITHIN,max_response_time,SEC,doNothing]
	rule r_refuseRequestWithinThirtySec = r_setObligation[refuseRequest,WITHIN,30,SEC,doNothing]
	rule r_callSupportWithinOneMinute = r_setObligation[callSupport,WITHIN,1,MINUTE,doNothing]
	rule r_agreeRetryWithinThreeMinutes = r_setObligation[agreeRetry,true,WITHIN,3,MINUTE,callSupport,true]
	rule r_openCurtains = r_setObligation[openCurtains]
	rule r_provideInfo = r_setObligation[provideInfo]
	rule r_informUser = r_setObligation[informUser]
	rule r_dressingInClotingX = r_setObligation[dressingInClotingX]
	rule r_informUserAndReferToHumanCarer = par r_setObligation[informUser] r_setObligation[referToHumanCarer] endpar

	//SLEEC rules


    rule r_Rule12 =
		if (dressingStarted and userUnderDressed) and not (roomTemperature < 19) then r_completeDressingWithinTwoMinutes[]
		else if (dressingStarted and userUnderDressed) and (roomTemperature < 19) and not (roomTemperature < 17) then r_completeDressingWithinNinetySeconds[]
		else if (dressingStarted and userUnderDressed) and (roomTemperature < 17) then r_completeDressingWithinSixtySeconds[]
		endif endif endif


	rule r_Rule22 =
		if curtainOpenRqt and not userUnderDressed then r_openCurtainsWithinMaxResponseTime[]
		else if curtainOpenRqt and userUnderDressed and not (userDistressed = SHIGH) then r_refuseRequestWithinThirtySec[]
		else if curtainOpenRqt and userUnderDressed and (userDistressed = SHIGH) then r_openCurtainsWithinMaxResponseTime[]
		endif endif endif


	rule r_Rule32 =
		if userFallen and not (not assentToSupportCalls) then r_callSupportWithinOneMinute[]
		else if userFallen and (not assentToSupportCalls) and not emergency then r_skip[]
		else if userFallen and (not assentToSupportCalls) and emergency then r_skip[] //irrelevant
		endif endif endif


	rule r_Rule42 =
		if dressingAbandoned then r_agreeRetryWithinThreeMinutes[] endif 


	rule r_Rule6 =
		if userRequestInfo and not (not informationAvailable) then r_provideInfo[]
		else if userRequestInfo and (not informationAvailable) and not informationDisclosureNotPermitted then r_informUserAndReferToHumanCarer[]
		else if userRequestInfo and (not informationAvailable) and informationDisclosureNotPermitted then r_informUserAndReferToHumanCarer[] 
		endif endif endif


	rule r_Rule4 =
		 if (dressingStarted and dressPreferenceTypeA and genderTypeB) and not userAdvices then r_dressingInClotingX[]
    	 else if (dressingStarted and dressPreferenceTypeA and genderTypeB) and userAdvices and not medicalEmergency then r_skip[]
    	 else if (dressingStarted and dressPreferenceTypeA and genderTypeB) and userAdvices and medicalEmergency
            and not clothingItemNotFound then r_skip[]
    	 else if (dressingStarted and dressPreferenceTypeA and genderTypeB) and userAdvices and medicalEmergency
            and clothingItemNotFound then r_informUser[] 
    	 endif endif endif endif


/* DOMAIN-GENERIC RULES*/

	//reset of all locations that contribute to the out location output
	rule r_Reset =
	 	forall $c in Capability do 
	 		par
				outObligation($c) := false 
				outConstraint($c) := undef
				outOtherwiseObligation($c) := undef
				outTimeBudget($c) := undef
				outTimeUnit($c) := undef
			endpar
			
	/* Main rule*/
	
	main rule r_Main = 
		seq	//sequential composition of rules within the same transition step, producing no intermediate observable states (Börger & Stärk)
			r_Reset[] //reset of out locations at each run step
			par 
			r_Rule12[]
			r_Rule22[]
			r_Rule32[]
			r_Rule42[]
			r_Rule6[]
			r_Rule4[]
			endpar
		endseq 

default init s0: