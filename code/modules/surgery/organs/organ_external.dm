
/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC


//Old Datum Limbs:
// code/modules/unused/limbs.dm


/obj/item/organ/limb
	name = "limb"
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/list/embedded_objects = list()

	var/bone_status = BONE_INTACT //needed its own flag variable, otherwise it would have wrought havoc with most checks
	var/bone_name = "bone"
	var/break_chance_multiplier = 1



/obj/item/organ/limb/chest
	name = "chest"
	desc = "why is it detached..."
	icon_state = "chest"
	max_damage = 200
	body_part = CHEST
	break_chance_multiplier = 0.5


/obj/item/organ/limb/head
	name = "head"
	desc = "what a way to get a head in life..."
	icon_state = "head"
	max_damage = 200
	body_part = HEAD
	break_chance_multiplier = 0.25


/obj/item/organ/limb/l_arm
	name = "l_arm"
	desc = "why is it detached..."
	icon_state = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT


/obj/item/organ/limb/l_leg
	name = "l_leg"
	desc = "why is it detached..."
	icon_state = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT


/obj/item/organ/limb/r_arm
	name = "r_arm"
	desc = "why is it detached..."
	icon_state = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT


/obj/item/organ/limb/r_leg
	name = "r_leg"
	desc = "why is it detached..."
	icon_state = "r_leg"
	max_damage = 75
	body_part = LEG_RIGHT

/obj/item/organ/severedtail
	name = "tail"
	desc = "A severed tail."
	icon_state = "severedtail"
	color = "#161"
	var/markings = "Smooth"

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/organ/limb/proc/take_damage(brute, burn)
	if(owner && (owner.status_flags & GODMODE))	return 0	//godmode
	brute	= max(brute,0)
	burn	= max(burn,0)


	if(status == ORGAN_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)

	var/can_inflict = max_damage - (brute_dam + burn_dam)
	if(!can_inflict)	return 0

	if((brute + burn) < can_inflict)
		brute_dam	+= brute
		burn_dam	+= burn
	else
		if(brute > 0)
			if(burn > 0)
				brute	= round( (brute/(brute+burn)) * can_inflict, 1 )
				burn	= can_inflict - brute	//gets whatever damage is left over
				brute_dam	+= brute
				burn_dam	+= burn
			else
				brute_dam	+= can_inflict
		else
			if(burn > 0)
				burn_dam	+= can_inflict
			else
				return 0
	return update_organ_icon()


//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/organ/limb/proc/heal_damage(brute, burn, robotic)

	if(robotic && status != ORGAN_ROBOTIC) // This makes organic limbs not heal when the proc is in Robotic mode.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	if(!robotic && status == ORGAN_ROBOTIC) // This makes robolimbs not healable by chems.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	return update_organ_icon()


//Returns total damage...kinda pointless really
/obj/item/organ/limb/proc/get_damage()
	return brute_dam + burn_dam


//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/organ/limb/proc/update_organ_icon()
	if(status == ORGAN_ORGANIC) //Robotic limbs show no damage - RR
		var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
		var/tburn	= round( (burn_dam/max_damage)*3, 1 )
		if((tbrute != brutestate) || (tburn != burnstate))
			brutestate = tbrute
			burnstate = tburn
			return 1
		return 0

//Returns a display name for the organ
/obj/item/organ/limb/proc/getDisplayName() //Added "Chest" and "Head" just in case, this may not be needed
	switch(name)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		if("chest")     return "chest"
		if("head")		return "head"
		else			return name


//Remove all embedded objects from all limbs on the human mob
/mob/living/carbon/human/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/obj/item/organ/limb/L in organs)
		for(var/obj/item/I in L.embedded_objects)
			L.embedded_objects -= I
			I.loc = T

	clear_alert("embeddedobject")

/mob/living/carbon/human/proc/has_embedded_objects()
	. = 0
	for(var/obj/item/organ/limb/L in organs)
		for(var/obj/item/I in L.embedded_objects)
			return 1
