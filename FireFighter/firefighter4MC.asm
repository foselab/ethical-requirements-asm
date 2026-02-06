//Version: Multiple obligation
// Sample SLEEC rules for a firefighter UAV


asm firefighter4MC

import ../libraries/StandardLibrary
import ../libraries/CTLLibrary

signature: 

	enum domain TimerUnit={NANOSEC, MILLISEC, SEC, MINUTE, HOUR}//lib: changed MIN in MINUTE
	
	//domains
	enum domain TCType = {AFTER, WITHIN} //lib
	abstract domain Capability //lib
	
/* DOMAIN-SPECIFIC SIGNATURE */
    
    //domains
	domain Temperature subsetof Integer //discrete, limited numeric range to allow model checking
	enum domain WindScale = {LIGHT,MODERATE,STRONG}
	//enum domain CapabilityID = {SOUNDALARM,GOHOME,STARTCAMERA,DONOTHING}
	domain TimeValue subsetof Integer//NEW to avoid Integer in the Prod domain
	
	//(input) events and measures
	monitored batteryCritical: Boolean
	monitored cameraStarted: Boolean
	monitored alarmSounding: Boolean //To not confuse with the obligation soundAlarm
	monitored personNearby: Boolean
	monitored temperature: Temperature 
	monitored windSpeed: WindScale

	
	//System's capabilities
	static goHome: Capability
	static soundAlarm: Capability
	static startCamera: Capability
	//static id: Capability -> CapabilityID //not in SLEEC lib, since it depends on CapabilityID that is domain-specific
	
/* DOMAIN-GENERIC SIGNATURE */	
	
	//controlled otherwiseC: Capability -> Capability //lib, applicable only with WITHIN time constraint
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
	
definitions:
	

/* DOMAIN-SPECIFIC DEFINITIONS*/
    
	domain Temperature = {-5:90} //fire alarm threshold (thermal sensors) 60 °C – 90 °C
	domain TimeValue = {0:60}
	
	/*function id($c in Capability) = 
		switch $c
			case doNothing : DONOTHING //(default capability; meaning: skip)
			case goHome : GOHOME
			case soundAlarm : SOUNDALARM
			case startCamera: STARTCAMERA
		endswitch	
	*/
    
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

	/* DOMAIN-SPECIFIC CONTROL RULES*/
    
	 
	rule r_doNothing = r_setObligation[doNothing]  //default: no obligation to do
	
	rule r_soundAlarm = r_setObligation[soundAlarm]
			
	rule r_soundAlarmWithinTwoSeconds = r_setObligation[soundAlarm,WITHIN,2,SEC,doNothing]
	
	rule r_soundAlarmWithinTwoSeconds_a = r_setObligation[soundAlarm,WITHIN,2,SEC,goHome]
	
	rule r_goHome = r_setObligation[goHome]
		
	rule r_goHomeAfterFiveMinutes = r_setObligation[goHome,AFTER,5,MINUTE,doNothing]

	rule r_goHomeWithinOneMinute = r_setObligation[goHome,WITHIN,1,MINUTE,doNothing]
	
	rule r_notGoHomeWithinFiveMinutes = r_setObligation[goHome,false,WITHIN,5,MINUTE,doNothing]
	
	rule r_startCamera = r_setObligation[startCamera]
	
	
	//SLEEC rules
	
	//legal, social
	rule r_Rule1 =
		if cameraStarted and personNearby then r_soundAlarm[] endif 	
	
	//legal, ethical	
	rule r_Rule2 =
		if cameraStarted and personNearby then r_soundAlarmWithinTwoSeconds[] endif
					
	//legal		
	rule r_Rule3 =  
       	if alarmSounding then r_notGoHomeWithinFiveMinutes[] endif //to clearly distinguish between input events (triggers) and output events (obligations); to prefer for a direct match with probe/effector interfaces of the autonomous agent
       	
	//emphatatic	
	rule r_Rule4 =
	 if cameraStarted and not personNearby then r_soundAlarm[] 
	 else if cameraStarted and personNearby and not (temperature > 35) then r_goHome[] 
	 else if cameraStarted and personNearby and temperature > 35 then skip endif endif endif
	      
	  
	rule r_RuleA =
	  if batteryCritical and temperature < 25 then r_goHomeWithinOneMinute[] endif 
	    
	/* DOMAIN-GENERIC RULES*/
	

	//reset of all locations that contribute to the out location output
	rule r_Reset =
	 	forall $c in Capability do 
	 		par
				outConstraint($c) := undef 
				outObligation($c) := false //undef not working for the model checher
			endpar
	
	
	//invariant inv_I1 over outObligation: not  (outObligation(goHome) and outObligation(soundAlarm)) //never both true: GoHome forbids soundAlarm and viceversa
	
	//ctlspec ag(cameraStarted implies (ax (outObligation(soundAlarm))))
	
	
	/* Main rule*/
	
	
	main rule r_Main =  
		seq	//sequential composition of rules within the same transition step, producing no intermediate observable states (Börger & Stärk)
			r_Reset[] //reset of out locations at each run step
			par 
			//r_Rule1[]
			r_Rule2[]
			r_Rule3[]
			r_Rule4[] //Rule3 and 4 are in conflict when all input events are true and temperature is <= 35
			//r_RuleA[] //in conflict with Rule3 when alarmsounding & batteryCritical & (temperature < 25)
			endpar
		endseq

default init s0:

