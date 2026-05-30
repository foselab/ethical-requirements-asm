module Generated_Autocar_corrected_sanHeader

import ../../libraries/StandardLibrary
import ../../libraries/SLEECLibrary
export *

signature:
	/* DOMAIN-SPECIFIC SIGNATURE */
	
	enum domain PreviousLight = {RED}
	enum domain RiskLevel = {LOW}
	enum domain CapabilityID = {DONOTHING,ASKFORCLARIFICATION,ASKIFUSERREADYTODRIVE,CALCULATESHORTESTPATH,CHANGECURRENTDRIVING,CHANGELANES,CHECKSYSTEMCOMPONENTS,DISPLAYALERT,DISPLAYCARINFORMATION,DISPLAYERROR,DISPLAYROUTE,DRIVECAR,GETREADYTODRIVE,MAINTAINEQUALDISTANCE,MAKESPACE,PARKVEHICLE,RECORDPEOPLE,SLOWDOWN,STAYCENTEREDINLANE,STOPAUTONOMOUSASSISTANCE,TAKENEWINPUT,TAKESHORTESTPATH,TAKEUSERINPUT,TEMPORARILYSTOPCAR,TURNOFFSENSORS,TURNONHAZARDSANDTEMPORARILYSTOP,TURNONSENSORS,WAITUNTILCHANGES}
	
	//(input) events and measures
	monitored actionIsLegal: Boolean
	monitored ambulanceBehindCar: Boolean
	monitored ambulanceNextToCar: Boolean
	monitored ambulanceOnOppositeSide: Boolean
	monitored carDriving: Boolean
	monitored carsBehind: Boolean
	monitored carsInFront: Boolean
	monitored centeredInLane: Boolean
	monitored commandClear: Boolean
	monitored currentDrivingChanged: Boolean
	monitored destinationExists: Boolean
	monitored doorClosed: Boolean
	monitored environmentClear: Boolean
	monitored equalDistanceMaintained: Boolean
	monitored errorDisplayed: Boolean
	monitored greenLight: Boolean
	monitored laneExists: Boolean
	monitored lanesChanged: Boolean
	monitored multipleLanes: Boolean
	monitored notseatBeltOn: Boolean
	monitored objectInPath: Boolean
	monitored pathExists: Boolean
	monitored peopleConsentObtained: Boolean
	monitored previousLight: PreviousLight
	monitored priorityVehicleNearby: Boolean
	monitored readyToDrive: Boolean
	monitored recognizeInput: Boolean
	monitored redLight: Boolean
	monitored riskLevel: RiskLevel
	monitored seatBeltOn: Boolean
	monitored seeTrafficLight: Boolean
	monitored sensorsTurnedOn: Boolean
	monitored shortestPathCalculated: Boolean
	monitored speedChanged: Boolean
	monitored systemReady: Boolean
	monitored userAskedIfReadyToDrive: Boolean
	monitored userCancelPath: Boolean
	monitored userChangeRoute: Boolean
	monitored userInputTaken: Boolean
	monitored userRequestedLaneChange: Boolean
	monitored userSaysYes: Boolean
	monitored userTurnOffSystem: Boolean
	monitored userTurnOnSystem: Boolean
	monitored userTurnedOffSystem: Boolean
	monitored vehicleParked: Boolean
	monitored vehicleSlowedDown: Boolean
	monitored withinLane: Boolean
	monitored yellowLight: Boolean
	
	//System's capabilities
	static askForClarification: Capability
	static askIfUserReadyToDrive: Capability
	static calculateShortestPath: Capability
	static changeCurrentDriving: Capability
	static changeLanes: Capability
	static checkSystemComponents: Capability
	static displayAlert: Capability
	static displayCarInformation: Capability
	static displayError: Capability
	static displayRoute: Capability
	static driveCar: Capability
	static getReadyToDrive: Capability
	static maintainEqualDistance: Capability
	static makeSpace: Capability
	static parkVehicle: Capability
	static recordPeople: Capability
	static slowDown: Capability
	static stayCenteredinLane: Capability
	static stopAutonomousAssistance: Capability
	static takeNewInput: Capability
	static takeShortestPath: Capability
	static takeUserInput: Capability
	static temporarilyStopCar: Capability
	static turnOffSensors: Capability
	static turnOnHazardsAndTemporarilyStop: Capability
	static turnOnSensors: Capability
	static waitUntilChanges: Capability
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
			case askForClarification : ASKFORCLARIFICATION
			case askIfUserReadyToDrive : ASKIFUSERREADYTODRIVE
			case calculateShortestPath : CALCULATESHORTESTPATH
			case changeCurrentDriving : CHANGECURRENTDRIVING
			case changeLanes : CHANGELANES
			case checkSystemComponents : CHECKSYSTEMCOMPONENTS
			case displayAlert : DISPLAYALERT
			case displayCarInformation : DISPLAYCARINFORMATION
			case displayError : DISPLAYERROR
			case displayRoute : DISPLAYROUTE
			case driveCar : DRIVECAR
			case getReadyToDrive : GETREADYTODRIVE
			case maintainEqualDistance : MAINTAINEQUALDISTANCE
			case makeSpace : MAKESPACE
			case parkVehicle : PARKVEHICLE
			case recordPeople : RECORDPEOPLE
			case slowDown : SLOWDOWN
			case stayCenteredinLane : STAYCENTEREDINLANE
			case stopAutonomousAssistance : STOPAUTONOMOUSASSISTANCE
			case takeNewInput : TAKENEWINPUT
			case takeShortestPath : TAKESHORTESTPATH
			case takeUserInput : TAKEUSERINPUT
			case temporarilyStopCar : TEMPORARILYSTOPCAR
			case turnOffSensors : TURNOFFSENSORS
			case turnOnHazardsAndTemporarilyStop : TURNONHAZARDSANDTEMPORARILYSTOP
			case turnOnSensors : TURNONSENSORS
			case waitUntilChanges : WAITUNTILCHANGES
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
