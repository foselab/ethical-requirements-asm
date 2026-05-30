//Auto-generated from SLEEC DSL

asm Generated_Autocar_corrected_san

import ../../libraries/StandardLibrary
import ../../libraries/CTLLibrary
import ../../libraries/SLEECLibrary
import Generated_Autocar_corrected_sanHeader

signature:

definitions:

	/* DOMAIN-SPECIFIC CONTROL RULES */
		rule r_askForClarification = r_setObligation[askForClarification]
		rule r_askIfUserReadyToDrive = r_setObligation[askIfUserReadyToDrive]
		rule r_calculateShortestPath = r_setObligation[calculateShortestPath]
		rule r_changeCurrentDriving = r_setObligation[changeCurrentDriving]
		rule r_changeLanes = r_setObligation[changeLanes]
		rule r_checkSystemComponents = r_setObligation[checkSystemComponents]
		rule r_displayAlert = r_setObligation[displayAlert]
		rule r_displayCarInformation = r_setObligation[displayCarInformation]
		rule r_displayError = r_setObligation[displayError]
		rule r_displayRoute = r_setObligation[displayRoute]
		rule r_driveCar = r_setObligation[driveCar]
		rule r_getReadyToDrive = r_setObligation[getReadyToDrive]
		rule r_maintainEqualDistance = r_setObligation[maintainEqualDistance]
		rule r_makeSpace = r_setObligation[makeSpace]
		rule r_notRecordPeople = r_setObligation[recordPeople,false]
		rule r_notTurnOffSensors = r_setObligation[turnOffSensors,false]
		rule r_parkVehicle = r_setObligation[parkVehicle]
		rule r_slowDown = r_setObligation[slowDown]
		rule r_stayCenteredinLane = r_setObligation[stayCenteredinLane]
		rule r_stopAutonomousAssistance = r_setObligation[stopAutonomousAssistance]
		rule r_takeNewInput = r_setObligation[takeNewInput]
		rule r_takeShortestPath = r_setObligation[takeShortestPath]
		rule r_takeUserInput = r_setObligation[takeUserInput]
		rule r_temporarilyStopCar = r_setObligation[temporarilyStopCar]
		rule r_turnOffSensors = r_setObligation[turnOffSensors]
		rule r_turnOnHazardsAndTemporarilyStop = r_setObligation[turnOnHazardsAndTemporarilyStop]
		rule r_turnOnSensors = r_setObligation[turnOnSensors]
		rule r_waitUntilChanges = r_setObligation[waitUntilChanges]

	//SLEEC rules
	rule r_R1 =
	  r_SLEEC[userTurnOnSystem, <<r_turnOnSensors>>
	  ]

	rule r_R1bb =
	  r_SLEEC[userTurnOffSystem, <<r_turnOffSensors>>
	  ]

	rule r_R1b =
	  r_SLEEC[userTurnOnSystem and ( not userTurnedOffSystem ), <<r_notTurnOffSensors>>
	  ]

	rule r_R1_cont =
	  r_SLEEC[sensorsTurnedOn, <<r_checkSystemComponents>>
	  ]

	rule r_R2 =
	  r_SLEEC[systemReady, <<r_takeUserInput>>
	  ]

	rule r_R3 =
	  r_SLEEC[userInputTaken, <<r_calculateShortestPath>>,
	           (  ( not destinationExists ) or ( not pathExists )  ), <<r_displayError>>
	  ]

	rule r_R3_cont =
	  r_SLEEC[shortestPathCalculated, <<r_displayRoute>>,
	           ( riskLevel != LOW ), <<r_skip>>,
	           ( not actionIsLegal ), <<r_skip>>
	  ]

	rule r_R5 =
	  r_SLEEC[userChangeRoute, <<r_calculateShortestPath>>,
	           ( not commandClear ), <<r_askForClarification>>
	  ]

	rule r_R6 =
	  r_SLEEC[userCancelPath, <<r_parkVehicle>>,
	           ( riskLevel != LOW ), <<r_waitUntilChanges>>
	  ]

	rule r_R7 =
	  r_SLEEC[carDriving and ( carsInFront and carsBehind ), <<r_maintainEqualDistance>>
	  ]

	rule r_R8 =
	  r_SLEEC[carDriving and objectInPath, <<r_temporarilyStopCar>>,
	           ( riskLevel != LOW ), <<r_changeLanes>>,
	           ( not multipleLanes ), <<r_turnOnHazardsAndTemporarilyStop>>,
	           ( not objectInPath ), <<r_driveCar>>
	  ]

	rule r_R9 =
	  r_SLEEC[carDriving and withinLane, <<r_stayCenteredinLane>>,
	           ( userRequestedLaneChange and ( environmentClear and ( riskLevel = LOW )  )  ), <<r_changeLanes>>,
	           (  ( not withinLane ) or ( not laneExists )  ), <<r_displayAlert>>
	  ]

	rule r_R10 =
	  r_SLEEC[userTurnOffSystem, <<r_parkVehicle>>
	  ]

	rule r_R10_1 =
	  r_SLEEC[vehicleParked and userTurnedOffSystem, <<r_turnOffSensors>>
	  ]

	rule r_R11 =
	  r_SLEEC[priorityVehicleNearby, <<r_displayAlert>>
	  ]

	rule r_R12 =
	  r_SLEEC[priorityVehicleNearby and ( ambulanceBehindCar and ( not ambulanceOnOppositeSide )  ), <<r_changeLanes>>,
	           ( ambulanceNextToCar or ( not multipleLanes )  ), <<r_makeSpace>>,
	           ( riskLevel != LOW ), <<r_skip>>
	  ]

	rule r_R13 =
	  r_SLEEC[seeTrafficLight and ( redLight and recognizeInput ), <<r_temporarilyStopCar>>,
	           ( not redLight ), <<r_takeNewInput>>
	  ]

	rule r_R14 =
	  r_SLEEC[seeTrafficLight and ( yellowLight and recognizeInput ), <<r_slowDown>>,
	           ( not yellowLight ), <<r_takeNewInput>>,
	           ( previousLight = RED ), <<r_getReadyToDrive>>
	  ]

	rule r_R15 =
	  r_SLEEC[seeTrafficLight and ( greenLight and recognizeInput ), <<r_driveCar>>,
	           objectInPath, <<r_waitUntilChanges>>
	  ]

	rule r_R16 =
	  r_SLEEC[seeTrafficLight and ( not recognizeInput ), <<r_slowDown>>
	  ]

	rule r_R16_cont =
	  r_SLEEC[vehicleSlowedDown and environmentClear, <<r_driveCar>>
	  ]

	rule r_R17 =
	  r_SLEEC[systemReady and ( not (  ( doorClosed or seatBeltOn ) or destinationExists )  ), <<r_displayAlert>>
	  ]

	rule r_R17b =
	  r_SLEEC[systemReady and ( doorClosed and (  ( seatBeltOn and destinationExists ) and ( not userSaysYes )  )  ), <<r_askIfUserReadyToDrive>>
	  ]

	rule r_R17bbb =
	  r_SLEEC[systemReady and (  ( not userSaysYes ) and (  (  ( not doorClosed ) or ( notseatBeltOn )  ) or ( not destinationExists )  )  ), <<r_displayError>>
	  ]

	rule r_R19 =
	  r_SLEEC[userAskedIfReadyToDrive and ( not userSaysYes ), <<r_stopAutonomousAssistance>>
	  ]

	rule r_R17bbbb =
	  r_SLEEC[errorDisplayed, <<r_stopAutonomousAssistance>>
	  ]

	rule r_R17bb =
	  r_SLEEC[systemReady and ( doorClosed and (  ( seatBeltOn and destinationExists ) and ( not userSaysYes )  )  ), <<r_stopAutonomousAssistance>>
	  ]

	rule r_R20 =
	  r_SLEEC[systemReady, <<r_displayCarInformation>>
	  ]

	rule r_R26 =
	  r_SLEEC[userTurnOffSystem, <<r_turnOffSensors>>
	  ]

	rule r_R21 =
	  r_SLEEC[shortestPathCalculated, <<r_takeShortestPath>>,
	           ( riskLevel != LOW ), <<r_skip>>,
	           ( not actionIsLegal ), <<r_skip>>
	  ]

	rule r_R22 =
	  r_SLEEC[systemReady, <<r_notRecordPeople>>,
	           peopleConsentObtained, <<r_skip>>
	  ]

	rule r_R24 =
	  r_SLEEC[systemReady and ( not actionIsLegal ), <<r_changeCurrentDriving>>
	  ]

	rule r_R25 =
	  r_SLEEC[carDriving and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27I =
	  r_SLEEC[userTurnOnSystem and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27II =
	  r_SLEEC[sensorsTurnedOn and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27III =
	  r_SLEEC[systemReady and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27IV =
	  r_SLEEC[readyToDrive and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27V =
	  r_SLEEC[userAskedIfReadyToDrive and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27VI =
	  r_SLEEC[carDriving and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27VII =
	  r_SLEEC[vehicleSlowedDown and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27VIII =
	  r_SLEEC[speedChanged and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27IX =
	  r_SLEEC[lanesChanged and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27X =
	  r_SLEEC[currentDrivingChanged and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27XI =
	  r_SLEEC[equalDistanceMaintained and ( not peopleConsentObtained ), <<r_notRecordPeople>>
	  ]

	rule r_R27XII =
	  r_SLEEC[centeredInLane and ( not peopleConsentObtained ), <<r_notRecordPeople>>
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
				r_R1[]
				r_R1bb[]
				r_R1b[]
				r_R1_cont[]
				r_R2[]
				r_R3[]
				r_R3_cont[]
				r_R5[]
				r_R6[]
				r_R7[]
				r_R8[]
				r_R9[]
				r_R10[]
				r_R10_1[]
				r_R11[]
				r_R12[]
				r_R13[]
				r_R14[]
				r_R15[]
				r_R16[]
				r_R16_cont[]
				r_R17[]
				r_R17b[]
				r_R17bbb[]
				r_R19[]
				r_R17bbbb[]
				r_R17bb[]
				r_R20[]
				r_R26[]
				r_R21[]
				r_R22[]
				r_R24[]
				r_R25[]
				r_R27I[]
				r_R27II[]
				r_R27III[]
				r_R27IV[]
				r_R27V[]
				r_R27VI[]
				r_R27VII[]
				r_R27VIII[]
				r_R27IX[]
				r_R27X[]
				r_R27XI[]
				r_R27XII[]
			endpar
		endseq

default init s0:
