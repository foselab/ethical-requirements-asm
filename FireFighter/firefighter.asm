//Version: Multiple obligation
// Sample SLEEC rules for a firefighter UAV

asm firefighter

import ../libraries/StandardLibrary
import ../libraries/CTLLibrary
import ../libraries/SLEECLibrary
import firefighterHeader


signature: 
	
definitions:
	

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
       	if alarmSounding then r_notGoHomeWithinFiveMinutes[] endif       
       	
	//emphatatic	
	rule r_Rule4 =
		r_SLEEC[cameraStarted, <<r_soundAlarm>>, personNearby, <<r_goHome>>, temperature > 35, <<r_skip>>]
	   
	
	//Variants or additional SLEEC rules for demo
	
	//legal, ethical	
	rule r_Rule2_a =
		r_SLEEC[cameraStarted and personNearby,<<r_soundAlarmWithinTwoSeconds_a>>]
		
	//legal		
	rule r_Rule3_a =
       	r_SLEEC[alarmSounding,<<r_goHomeAfterFiveMinutes>>]
       			
	rule r_RuleA =
	   if batteryCritical and temperature < 25 then r_goHomeWithinOneMinute[] endif 
		
	rule r_RuleB = //example of SLEEC rule covering all modeling constructs (not in JSS paper)
	  r_SLEEC[cameraStarted, <<r_soundAlarm>>, personNearby, <<r_goHomeWithinOneMinute>>, temperature > 35, <<r_goHomeAfterFiveMinutes>>]
	
	rule r_RuleC =
	   r_SLEEC[batteryCritical,<<r_startCamera>>,personNearby,<<r_goHome>>,temperature > 35, <<r_soundAlarm>>]
	   
	rule r_RuleD =
	  r_SLEEC[batteryCritical,<<r_startCamera>>,personNearby,<<r_soundAlarm>>,temperature > 35, <<r_goHome>>]
	      
			       
	  
	/* DOMAIN-GENERIC RULES*/
	

	//reset of all locations that contribute to the out location output
	rule r_Reset =
	 	forall $c in Capability do 
	 		par
				outConstraint(id($c)) := undef 
				outObligation(id($c)) := undef 
				otherwiseC($c) := undef
			endpar
	
	
	//invariant inv_I1 over outObligation: not  (outObligation(GOHOME)=true and outObligation(SOUNDALARM)=true) //never both true: goHome forbids soundAlarm and viceversa
	
	/* Main rule*/
	
	
	main rule r_Main =  
		seq	//sequential composition of rules within the same transition step, producing no intermediate observable states (Börger & Stärk)
			r_Reset[] //reset of out locations at each run step
			par 
			//Rule 1 and 2 are redundant (inconsistent update on secondary attributes of the outOblication: outConstraint(SOUNDALARM) updated to undef and (WITHIN,2,SEC,DONOTHING) 
			//r_Rule1[]
			r_Rule2[] //Rule 2 is in semantic conflict with Rule4 if (like for rule C and D) we want that GoHome forbids soundAlarm and viceversa
					 //This is captured by Invariant violation inv_I1.
			r_Rule3[] //Rule 3 and 4 are in conflict when all input events are true and temperature is <= 35
			r_Rule4[] 	
			//r_RuleA[] //Rule A and rule 3 are in conflict. 
					  //e.g.: outOligation(GOHOME) updated to false and true
					  //or outConstraint(GOHOME) updated to (WITHIN,5,MINUTE,DONOTHING) and (WITHIN,1,MINUTE,DONOTHING)
			//r_RuleC[]
			//r_RuleD[] //Rule C and rule D are in a subdle semantic conflict, but this is captured by the semantic invariant inv_I1!
			endpar
		endseq

default init s0:


