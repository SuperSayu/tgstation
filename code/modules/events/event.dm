//this datum is used by the events controller to dictate how it selects events
/datum/round_event_control
	var/name					//The name human-readable name of the event
	var/typepath				//The typepath of the event datum /datum/round_event

	var/weight = 10				//The weight this event has in the random-selection process.
								//Higher weights are more likely to be picked.
								//10 is the default weight. 20 is twice more likely; 5 is half as likely as this default.

	var/earliest_start = 12000	//The earliest world.time that an event can start (round-duration in deciseconds) default: 20 mins

	var/occurrences = 0			//How many times this event has occured
	var/max_occurrences = 20		//The maximum number of times this event can occur (naturally), it can still be forced.
								//By setting this to 0 you can effectively disable an event.

	var/holidayID = ""			//string which should be in the SSevents.holidays list if you wish this event to be holiday-specific
								//anything with a (non-null) holidayID which does not match holiday, cannot run.
	var/wizardevent = 0

	var/minimumCrew = 0

	var/alertadmins = 1			//should we let the admins know this event is firing
								//should be disabled on events that fire a lot

	var/list/gamemode_blacklist = list() // Event won't happen in these gamemodes
	var/list/gamemode_whitelist = list() // Event will happen ONLY in these gamemodes if not empty

/datum/round_event_control/wizard
	wizardevent = 1

/datum/round_event_control/proc/runEvent()
	if(!ispath(typepath,/datum/round_event))
		return PROCESS_KILL
	var/datum/round_event/E = new typepath()
	E.control = src
	feedback_add_details("event_ran","[E]")
	occurrences++

	testing("[time2text(world.time, "hh:mm:ss")] [E.type]")

	return E

/datum/round_event	//NOTE: Times are measured in master controller ticks!
	var/processing = 1
	var/datum/round_event_control/control

	var/startWhen		= 0	//When in the lifetime to call start().
	var/announceWhen	= 0	//When in the lifetime to call announce(). Set an event's announceWhen to >0 if there is an announcement.
	var/endWhen			= 0	//When in the lifetime the event should end.

	var/activeFor		= 0	//How long the event has existed. You don't need to change this.

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the startWhen and or announceWhen variables.
//Only called once.
//EDIT: if there's anything you want to override within the new() call, it will not be overridden by the time this proc is called.
//It will only have been overridden by the time we get to announce() start() tick() or end() (anything but setup basically).
//This is really only for setting defaults which can be overridden later when New() finishes.
/datum/round_event/proc/setup()
	return

//Called when the tick is equal to the startWhen variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/round_event/proc/start()
	return

//Called when the tick is equal to the announceWhen variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/round_event/proc/announce()
	return

//Called on or after the tick counter is equal to startWhen.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/round_event/proc/tick()
	return

//Called on or after the tick is equal or more than endWhen
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/round_event/proc/end()
	return



//Do not override this proc, instead use the appropiate procs.
//This proc will handle the calls to the appropiate procs.
/datum/round_event/process()
	if(!processing)
		return

	if(activeFor == startWhen)
		start()

	if(activeFor == announceWhen)
		announce()

	if(startWhen < activeFor && activeFor < endWhen)
		tick()

	if(activeFor == endWhen)
		end()

	// Everything is done, let's clean up.
	if(activeFor >= endWhen && activeFor >= announceWhen && activeFor >= startWhen)
		kill()

	activeFor++


//Garbage collects the event by removing it from the global events list,
//which should be the only place it's referenced.
//Called when start(), announce() and end() has all been called.
/datum/round_event/proc/kill()
	SSevent.running -= src


//Sets up the event then adds the event to the the list of running events
/datum/round_event/New()
	setup()
	SSevent.running += src
	return ..()