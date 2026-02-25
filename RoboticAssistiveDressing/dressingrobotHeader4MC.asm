module dressingrobotHeader4MC //domain-specific library

import ../libraries/StandardLibrary
import ../libraries/CTLLibrary
//import ../libraries/SLEECLibrary
export *

signature:	
	enum domain TimerUnit = {NANOSEC, MILLISEC, SEC, MINUTE, HOUR} //lib
	enum domain TCType = {AFTER, WITHIN}
	abstract domain Capability //lib
	domain TimeValue subsetof Integer//NEW to avoid Integer in the Prod domain
	

 /* DOMAIN-SPECIFIC SIGNATURE */
    
    //domains
	domain RoomTemperature subsetof Integer
	enum domain UserDistressed = {SLOW | SMEDIUM | SHIGH}
	domain BuildingFloor subsetof Integer 
	enum domain WithholdingActivityPhysicalHarm = {LOW | MODERATE | SEVERE}
	domain CompetenceIndicator subsetof Integer 
	domain ResponseTimeRange subsetof Integer

	
	enum domain CapabilityID = {
	  DONOTHING,
	  COMPLETEDRESSING,
	  OPENCURTAINS,
	  PROVIDEINFO,
	  REFUSEREQUEST,
	  CALLSUPPORT,
	  AGREERETRY,
	  INFORMUSER,
	  STARTDRESSING,
	  CLOSECURTAINS,
	  DRESSINGINCLOTHINGX,
	  INFORMUSERTHISISAGENTNOTHUMAN,
	  INFORMUSERANDANDREFERTOHUMANCARER,
	  OBTAINASSENT,
	  STARTCOLLECTION,
	  CHECKFORANDOBTAINPROXY,
	  STOPACTIVITY,
	  STOREMININFO,
	  HEALTHCHECK,
	  REFERTOHUMANCARER,
	  DRESSINGSUCCESSFULL
	}
		
	//Events and sensed variables
	monitored dressingStarted: Boolean
	monitored userUnderDressed: Boolean
	monitored userDressed: Boolean
	monitored curtainsOpened: Boolean
	monitored curtainOpenRqt: Boolean
	monitored medicalEmergency: Boolean
	monitored emergency: Boolean
	monitored userFallen: Boolean
	monitored assentToSupportCalls: Boolean
	monitored dressingAbandoned: Boolean
	monitored roomDark: Boolean
	monitored notVisible: Boolean
	monitored userAssent: Boolean
	monitored consentGrantedwithinXmonths: Boolean
	monitored competentIndicatorRequired: Boolean
	monitored competentToGrantConsent: Boolean
	monitored dressPreferenceTypeA: Boolean
	monitored genderTypeB: Boolean
	monitored userAdvices: Boolean
	monitored clothingItemNotFound: Boolean
	monitored userConfused: Boolean
	monitored theUserHasBeenInformed: Boolean
	monitored informationAvailable: Boolean
	monitored informationDisclosureNotPermitted: Boolean
	monitored admininisteringMedication: Boolean
	monitored emotionRecognitionDetected: Boolean
	//monitored userCompetenceIndicator: Integer
	monitored userCompetenceIndicator: CompetenceIndicator
	monitored consentGranted: Boolean
	monitored consentIndicatorRequired: Boolean
	monitored consentIndicatorisWithdrawn: Boolean
	monitored consentIndicatorisRevoked: Boolean
	monitored interactionStarted: Boolean
	monitored userRequestInfo: Boolean
	monitored collectionStarted: Boolean
	monitored fallAssessed: Boolean
	monitored userUnresponsive: Boolean
	monitored openCurtainsRequested: Boolean
	monitored userUndressed: Boolean
	
	monitored roomTemperature: RoomTemperature
	monitored userDistressed: UserDistressed
	monitored buildingFloor: BuildingFloor
	monitored withholdingActivityPhysicalHarm: WithholdingActivityPhysicalHarm
	
	//Capabilities
	static completeDressing: Capability
	static openCurtains: Capability
	static provideInfo: Capability
	static refuseRequest: Capability
	static callSupport: Capability
	static agreeRetry: Capability
	static informUser: Capability
	static startDressing: Capability
	static closeCurtains: Capability
	static dressingInClotingX: Capability
	static informUserThisIsAgentnotHuman: Capability
	static informUserAndReferToHumanCarer: Capability
	static obtainAssent: Capability
	static checkForAndObtainProxy: Capability
	static stopActivity: Capability
	static startCollection: Capability
	static storeMinInfo: Capability
	static healthCheck: Capability
	static referToHumanCarer: Capability
	static dressingSuccessful: Capability
	//static n: Integer
	static n: CompetenceIndicator
	//static max_response_time: Integer
	static max_response_time: ResponseTimeRange

	static doNothing : Capability //lib	
		
	//(output) events as obligations that arise from the SLEEC rules for the system (robot) to act
    out outObligation: Capability -> Boolean //any due obligation (there could be more than one) is activated through a flag
	//Not supported Product domains with more than two sub-domains
	//out outConstraint: CapabilityID -> Prod(TCType,TimeValue,TimerUnit,CapabilityID) //time constraint over the obligation
	//Alternative by partitioning the tuple into singles:
	/*out outConstraint: CapabilityID -> Prod(TCType,CapabilityID) 
	out outTimeBudget: CapabilityID -> Prod(TimeValue,TimerUnit)*/
	out outConstraint: Capability ->TCType
	out outOtherwiseObligation: Capability ->Capability
	out outTimeBudget: Capability -> TimeValue
	out outTimeUnit: Capability -> TimerUnit
	
	static userDistressedHigh: UserDistressed -> Boolean
	static withholdingActivityPhysicalHarmHigh: WithholdingActivityPhysicalHarm -> Boolean
	
definitions:
	domain TimeValue = {0:60}
		
/* DOMAIN-SPECIFIC DEFINITIONS*/
    
	domain RoomTemperature = {-5:50}
	domain BuildingFloor = {1:10} //the building has max 10 floors.
	domain CompetenceIndicator = {1:10}
	domain ResponseTimeRange = {1:100}
	
	function n = 5
	function max_response_time = 60

	
	
	function userDistressedHigh($x in UserDistressed) = $x = SHIGH
	function withholdingActivityPhysicalHarmHigh($x in WithholdingActivityPhysicalHarm) = $x = SEVERE
    
/* DOMAIN-GENERIC DEFINITIONS */	
   
   rule r_skip = skip // named rule for no ASM state change (no prescribed obligation)
	
   
    //to set an obligation with no time constraint
	rule r_setObligation($c in Capability) = 
	par 
		//prepare out locations
		outObligation($c) := true //true if doObligation is true 
		outConstraint($c) := undef 
		outTimeBudget($c) := undef
		outOtherwiseObligation($c) := undef
		outTimeUnit($c) := undef
	endpar
	
	//Overloading to set an obligation with time constraints for responses and required alternative responses in the case of a timeout
	rule r_setObligation($c in Capability, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		//prepare out locations
		outObligation($c) := true  
		outConstraint($c) := $type
		//outOtherwiseObligation($c) := $alt
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
	
	//Additional overloading to allow a guarded alternative capability in timeouts
	rule r_setObligation($c in Capability, $v in Boolean, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability, $altv in Boolean) = 
	par 
		//prepare out locations
		outObligation($c) := $v  //Jan 2026 NEW
		outConstraint($c) := $type
		//outOtherwiseObligation($c) := $alt
		outTimeBudget($c) := $t
		outTimeUnit($c) := $u
		if (isDef($alt) and $type=WITHIN) 
		then if $altv then outOtherwiseObligation($c) := $alt endif //guarded alternative obligation
		else outOtherwiseObligation($c) := doNothing endif
	endpar		