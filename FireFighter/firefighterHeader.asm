module firefighterHeader 

import ../libraries/StandardLibrary
import ../libraries/SLEECLibrary
export *

signature:	
 /* DOMAIN-SPECIFIC SIGNATURE */
    
    //domains
	domain Temperature subsetof Integer //discrete, limited numeric range to allow model checking
	enum domain WindScale = {LIGHT,MODERATE,STRONG}
	enum domain CapabilityID = {SOUNDALARM,GOHOME,STARTCAMERA,DONOTHING}
	
	//(input) events and measures
	monitored batteryCritical: Boolean
	monitored cameraStarted: Boolean
	monitored alarmSounding: Boolean //To not confuse with the capability soundAlarm
	monitored personNearby: Boolean
	monitored temperature: Temperature 
	monitored windSpeed: WindScale
	
	//constants
	static alarm_deadline: Integer 
	
	//System's capabilities
	static goHome: Capability
	static soundAlarm: Capability
	static startCamera: Capability
	static id: Capability -> CapabilityID //not in SLEEC lib, since it depends on CapabilityID that is domain-specific
	
/* DOMAIN-GENERIC SIGNATURE */	
	//(output) events as obligations that arise from the SLEEC rules for the system (robot) to act
	out outObligation: CapabilityID -> Boolean //any due obligation (there could be more than one) is activated through a flag
	out outConstraint: CapabilityID -> Prod(TCType,Integer,TimerUnit,CapabilityID) //time constraint over the obligation
	
	
	
definitions:
		
/* DOMAIN-SPECIFIC DEFINITIONS*/
    
	domain Temperature = {-5:90} //fire alarm threshold (thermal sensors) 60 °C – 90 °C
	
	function alarm_deadline = 30 //30 seconds (default value)
	
	function id($c in Capability) = 
		switch $c
			case doNothing : DONOTHING //(default capability; meaning: skip)
			case goHome : GOHOME
			case soundAlarm : SOUNDALARM
			case startCamera: STARTCAMERA
		endswitch	
	
    
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
		outObligation(id($c)) := $v  //Jan 2026 NEW
		if (isDef($alt) and $type=WITHIN) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

		



