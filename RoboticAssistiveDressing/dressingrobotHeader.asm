module dressingrobotHeader //domain-specific library

import ../libraries/StandardLibrary
import ../libraries/CTLLibrary
import ../libraries/SLEECLibrary
export *

signature:	
 /* DOMAIN-SPECIFIC SIGNATURE */
    
    //domains
	domain RoomTemperature subsetof Integer
	enum domain UserDistressed = {SLOW | SMEDIUM | SHIGH}
	domain BuildingFloor subsetof Integer 
	enum domain WithholdingActivityPhysicalHarm = {LOW | MODERATE | SEVERE}

	
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
	monitored userCompetenceIndicator: Integer
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
	static n: Integer
	static max_response_time: Integer

	static id: Capability -> CapabilityID //not in lib, since it depends on CapabilityID that is model-specific
	
/* CONSTANT (DOMAIN-GENERIC) SIGNATURE */	
	out outObligation: CapabilityID -> Boolean
	out outConstraint: CapabilityID -> Prod(TCType,Integer,TimerUnit,CapabilityID)

	static userDistressedHigh: UserDistressed -> Boolean
	static withholdingActivityPhysicalHarmHigh: WithholdingActivityPhysicalHarm -> Boolean
	
definitions:
		
/* DOMAIN-SPECIFIC DEFINITIONS*/
    
	domain RoomTemperature = {-5:50}
	domain BuildingFloor = {1:10} //the building has max 10 floors.
	
	function n = 5
	function max_response_time = 60

	function id($c in Capability) = 
		switch $c
		
		case doNothing: DONOTHING
		case completeDressing: COMPLETEDRESSING
		case openCurtains: OPENCURTAINS
		case provideInfo: PROVIDEINFO
		case refuseRequest: REFUSEREQUEST
		case callSupport: CALLSUPPORT
		case agreeRetry: AGREERETRY
		case informUser: INFORMUSER
		case startDressing: STARTDRESSING
		case closeCurtains: CLOSECURTAINS
		case dressingInClotingX: DRESSINGINCLOTHINGX
		case informUserThisIsAgentnotHuman: INFORMUSERTHISISAGENTNOTHUMAN
		case informUserAndReferToHumanCarer: INFORMUSERANDANDREFERTOHUMANCARER
		case obtainAssent: OBTAINASSENT
		case checkForAndObtainProxy: CHECKFORANDOBTAINPROXY
		case stopActivity: STOPACTIVITY
		case startCollection: STARTCOLLECTION
		case healthCheck: HEALTHCHECK
		case referToHumanCarer: REFERTOHUMANCARER
		case dressingSuccessful: DRESSINGSUCCESSFULL
		endswitch	
	
	function userDistressedHigh($x in UserDistressed) = $x = SHIGH
	function withholdingActivityPhysicalHarmHigh($x in WithholdingActivityPhysicalHarm) = $x = SEVERE
    
/* DOMAIN-GENERIC DEFINITIONS */	
    //to set an obligation with no time constraint
	rule r_setObligation($c in Capability) = 
	par 
		//prepare out locations
		outObligation(id($c)) := true //true if doObligation is true 
		outConstraint(id($c)) := undef 
	endpar
	
	//Overloading to set an obligation with time constraints for responses and required alternative responses in the case of a timeout
	rule r_setObligation($c in Capability, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		//prepare out locations
		outObligation(id($c)) := true  
		if (isDef($alt) and $type=WITHIN) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar		
		
	
	//Additional overloading to allow obligation suspension temporarily (when $v is false); if $v is true it is 
	//semantically equivalent to the previous rule 
	rule r_setObligation($c in Capability, $v in Boolean, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		//prepare out locations
		outObligation(id($c)) := $v  
		if (isDef($alt) and $type=WITHIN) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar	
	
	
	//Additional overloading to allow obligation suspension temporarily and to allow a guarded alternative $alt obligation in case of deadline
	rule r_setObligation($c in Capability, $v in Boolean, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability, $guard in Boolean) = 
	par 
		//prepare out locations
		outObligation(id($c)) := $v  
		if (isDef($alt) and $type=WITHIN and $guard) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar	
		