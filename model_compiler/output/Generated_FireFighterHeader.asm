module Generated_FireFighterHeader

import ../../libraries/StandardLibrary
import ../../libraries/SLEECLibrary
export *

signature:
	/* DOMAIN-SPECIFIC SIGNATURE */
	
	enum domain CapabilityID = {DONOTHING,GOHOME,SOUNDALARM,STARTCAMERA}
	
	//(input) events and measures
	monitored alarmSounding: Boolean
	monitored batteryCritical: Boolean
	monitored cameraStart: Boolean
	monitored personNearby: Boolean
	monitored temperature: Integer
	
	//System's capabilities
	static goHome: Capability
	static soundAlarm: Capability
	static startCamera: Capability
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
			case goHome : GOHOME
			case soundAlarm : SOUNDALARM
			case startCamera : STARTCAMERA
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
