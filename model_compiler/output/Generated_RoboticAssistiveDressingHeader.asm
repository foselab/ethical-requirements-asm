module Generated_RoboticAssistiveDressingHeader

import ../../libraries/StandardLibrary
import ../../libraries/SLEECLibrary
export *

signature:
	/* DOMAIN-SPECIFIC SIGNATURE */
	
	enum domain UserDistressed = {SHIGH}
	enum domain WithholdingActivityPhysicalHarm = {MODERATE | SEVERE}
	enum domain CapabilityID = {DONOTHING,CHECKFORANDOBTAINPROXY,CLOSECURTAINS,CURTAINSOPENED,DRESSINGCOMPLETE,DRESSINGSUCCESSFUL,DRESSINGINCLOTINGX,HEALTHCHECKED,INFORMUSER,INFORMUSERTHISISAGENTNOTHUMAN,INFORMUSERANDANDREFERTOHUMANCARER,OBTAINASSENT,PROVIDEINFO,REFUSEREQUEST,STOPACTIVITY,STOREMININFO,SUPPORTCALLED}
	
	//(input) events and measures
	monitored admininisteringMedication: Boolean
	monitored assentToSupportCalls: Boolean
	monitored buildingFloor: Integer
	monitored clothingItemNotFound: Boolean
	monitored collectionStarted: Boolean
	monitored competentIndicatorRequired: Boolean
	monitored competentToGrantConsent: Boolean
	monitored consentGranted: Boolean
	monitored consentGrantedwithinXmonths: Boolean
	monitored consentIndicatorRequired: Boolean
	monitored consentIndicatorisRevoked: Boolean
	monitored consentIndicatorisWithdrawn: Boolean
	monitored curtainOpenRqt: Boolean
	monitored dressPreferenceTypeA: Boolean
	monitored dressingStarted: Boolean
	monitored emergency: Boolean
	monitored emotionRecognitionDetected: Boolean
	monitored fallAssessed: Boolean
	monitored genderTypeB: Boolean
	monitored informationAvailable: Boolean
	monitored informationDisclosureNotPermitted: Boolean
	monitored interactionStarted: Boolean
	monitored medicalEmergency: Boolean
	monitored notVisible: Boolean
	monitored openCurtainsRequested: Boolean
	monitored roomDark: Boolean
	monitored roomTemperature: Integer
	monitored theUserHasBeenInformed: Boolean
	monitored userAdvices: Boolean
	monitored userAssent: Boolean
	monitored userCompetenceIndicator: Integer
	monitored userConfused: Boolean
	monitored userDistressed: UserDistressed
	monitored userFallen: Boolean
	monitored userRequestInfo: Boolean
	monitored userUnderDressed: Boolean
	monitored userUnresponsive: Boolean
	monitored withholdingActivityPhysicalHarm: WithholdingActivityPhysicalHarm
	
	//System's capabilities
	static checkForandObtainProxy: Capability
	static closeCurtains: Capability
	static curtainsOpened: Capability
	static dressingComplete: Capability
	static dressingSuccessful: Capability
	static dressinginClotingX: Capability
	static healthChecked: Capability
	static informUser: Capability
	static informUserThisIsAgentnotHuman: Capability
	static informUserandandReferToHumanCarer: Capability
	static obtainAssent: Capability
	static provideInfo: Capability
	static refuseRequest: Capability
	static stopActivity: Capability
	static storeMinInfo: Capability
	static supportCalled: Capability
	static id: Capability -> CapabilityID

	/* DOMAIN-GENERIC SIGNATURE */
	//(output) events as obligations that arise from the SLEEC rules for the system (robot) to act
	out outObligation: CapabilityID -> Boolean
	out outConstraint: CapabilityID -> Prod(TCType,Integer,TimerUnit,CapabilityID)

definitions:

	/* DOMAIN-GENERIC DEFINITIONS */
	
	function id($c in Capability) = 
		switch $c
			case doNothing : DONOTHING
			case checkForandObtainProxy : CHECKFORANDOBTAINPROXY
			case closeCurtains : CLOSECURTAINS
			case curtainsOpened : CURTAINSOPENED
			case dressingComplete : DRESSINGCOMPLETE
			case dressingSuccessful : DRESSINGSUCCESSFUL
			case dressinginClotingX : DRESSINGINCLOTINGX
			case healthChecked : HEALTHCHECKED
			case informUser : INFORMUSER
			case informUserThisIsAgentnotHuman : INFORMUSERTHISISAGENTNOTHUMAN
			case informUserandandReferToHumanCarer : INFORMUSERANDANDREFERTOHUMANCARER
			case obtainAssent : OBTAINASSENT
			case provideInfo : PROVIDEINFO
			case refuseRequest : REFUSEREQUEST
			case stopActivity : STOPACTIVITY
			case storeMinInfo : STOREMININFO
			case supportCalled : SUPPORTCALLED
		endswitch

	rule r_setObligation($c in Capability) = 
	par 
		outObligation(id($c)) := true
		outConstraint(id($c)) := undef
	endpar
	
	rule r_setObligation($c in Capability, $v in Boolean) = 
	par 
		outObligation(id($c)) := $v
		outConstraint(id($c)) := undef
	endpar
	
	rule r_setObligation($c in Capability, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		outObligation(id($c)) := true  
		if (isDef($alt) and $type=WITHIN) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar
	
	rule r_setObligation($c in Capability, $v in Boolean, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		outObligation(id($c)) := $v  
		if (isDef($alt) and $type=WITHIN) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar
	
	rule r_setObligation($c in Capability, $v in Boolean, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability, $guard in Boolean) = 
	par 
		outObligation(id($c)) := $v  
		if (isDef($alt) and $type=WITHIN and $guard) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar
