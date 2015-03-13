/datum/round_event/wizard/shuffle/start()


/datum/round_event_control/wizard/shuffleloc //Somewhere an AI is crying
	name = "Change Places!"
	weight = 2
	typepath = /datum/round_event/wizard/shuffleloc/
	max_occurrences = 5
	earliest_start = 0

/datum/round_event/wizard/shuffleloc/start()
	var/list/moblocs = list()
	var/list/mobs	 = list()

	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H.z != 1)	continue //lets not try to strand people in space or stuck in the wizards den
		moblocs += H.loc
		mobs += H

	if(!mobs) return

	shuffle(moblocs)
	shuffle(mobs)

	for(var/mob/living/carbon/human/H in mobs)
		if(!moblocs)	break //locs aren't always unique, so this may come into play
		H.loc = moblocs[moblocs.len]
		moblocs.len -= 1

	for(var/mob/living/carbon/human/H in living_mob_list)
		var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
		smoke.set_up(max(1,1), 0, H.loc)
		smoke.start()

//---//

/datum/round_event_control/wizard/shufflenames //Face/off joke
	name = "Change Faces!"
	weight = 4
	typepath = /datum/round_event/wizard/shufflenames/
	max_occurrences = 5
	earliest_start = 0

/datum/round_event/wizard/shufflenames/start()
	var/list/mobnames = list()
	var/list/mobs	 = list()

	for(var/mob/living/carbon/human/H in living_mob_list)
		mobnames += H.name
		mobs += H

	if(!mobs) return

	shuffle(mobnames)
	shuffle(mobs)

	for(var/mob/living/carbon/human/H in mobs)
		if(!mobnames)	break
		H.name = mobnames[mobnames.len]
		mobnames.len -= 1

	for(var/mob/living/carbon/human/H in living_mob_list)
		var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
		smoke.set_up(max(1,1), 0, H.loc)
		smoke.start()

//---//


/datum/round_event_control/wizard/shuffleminds //Basically Mass Ranged Mindswap
	name = "Change Minds!"
	weight = 1
	typepath = /datum/round_event/wizard/shuffleminds/
	max_occurrences = 3
	earliest_start = 0

/datum/round_event/wizard/shuffleminds/start()
	var/list/mobs	 = list()

	for(var/mob/living/carbon/human/H in living_mob_list)
		if(!H.mind || H.mind in ticker.mode.wizards)	continue //the wizard(s) are spared on this one
		mobs += H

	if(!mobs || mobs.len == 1) return

	shuffle(mobs)

	var/obj/effect/proc_holder/spell/targeted/mind_transfer/swapper = new /obj/effect/proc_holder/spell/targeted/mind_transfer/
	for(var/mob/living/carbon/human/H in mobs)
		swapper.cast(list(H), mobs[mobs.len], 1)
		mobs.len -= 1
		if(mobs.len <= 1) break

	for(var/mob/living/carbon/human/H in living_mob_list)
		var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
		smoke.set_up(max(1,1), 0, H.loc)
		smoke.start()
