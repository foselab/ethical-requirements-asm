//Auto-generated from SLEEC DSL

asm Generated_FireFighter

import ../../libraries/StandardLibrary
import ../../libraries/CTLLibrary
import ../../libraries/SLEECLibrary
import Generated_FireFighterHeader

signature:

definitions:

	/* DOMAIN-SPECIFIC CONTROL RULES */
		rule r_goHome = r_setObligation[goHome]
		rule r_goHomeWithin1Minutes = r_setObligation[goHome,WITHIN,1,MINUTE,doNothing]
		rule r_notGoHomeWithin5Minutes = r_setObligation[goHome,false,WITHIN,5,MINUTE,doNothing]
		rule r_soundAlarm = r_setObligation[soundAlarm]
		rule r_soundAlarmWithin2Seconds = r_setObligation[soundAlarm,WITHIN,2,SEC,doNothing]
		rule r_soundAlarmWithin2SecondsOtherwiseGoHome = r_setObligation[soundAlarm,WITHIN,2,SEC,goHome]
		rule r_startCamera = r_setObligation[startCamera]

	//SLEEC rules
	rule r_Rule1 =
	  r_SLEEC[cameraStart and personNearby, <<r_soundAlarm>>
	  ]

	rule r_Rule2 =
	  r_SLEEC[cameraStart and personNearby, <<r_soundAlarmWithin2Seconds>>
	  ]

	rule r_Rule3 =
	  r_SLEEC[alarmSounding, <<r_notGoHomeWithin5Minutes>>
	  ]

	rule r_Rule4 =
	  r_SLEEC[cameraStart, <<r_soundAlarm>>,
	           personNearby, <<r_goHome>>,
	           temperature > 35, <<r_skip>>
	  ]

	rule r_Rule2_a =
	  r_SLEEC[cameraStart and personNearby, <<r_soundAlarmWithin2SecondsOtherwiseGoHome>>
	  ]

	rule r_Rule4_a =
	  r_SLEEC[cameraStart, <<r_soundAlarm>>,
	           personNearby, <<r_goHome>>
	  ]

	rule r_RuleA =
	  r_SLEEC[batteryCritical and temperature < 25, <<r_goHomeWithin1Minutes>>
	  ]

	rule r_RuleC =
	  r_SLEEC[batteryCritical, <<r_startCamera>>,
	           personNearby, <<r_goHome>>,
	           temperature > 35, <<r_soundAlarm>>
	  ]

	rule r_RuleD =
	  r_SLEEC[batteryCritical, <<r_startCamera>>,
	           personNearby, <<r_soundAlarm>>,
	           temperature > 35, <<r_goHome>>
	  ]

		rule r_Reset =
		forall $c in Capability do 
			par
				outConstraint(id($c)) := undef
				outObligation(id($c)) := undef
			endpar


	main rule r_Main =
		seq
			r_Reset[]
			par
				r_Rule1[]
				r_Rule2[]
				r_Rule3[]
				r_Rule4[]
				r_Rule2_a[]
				r_Rule4_a[]
				r_RuleA[]
				r_RuleC[]
				r_RuleD[]
			endpar
		endseq

default init s0:
