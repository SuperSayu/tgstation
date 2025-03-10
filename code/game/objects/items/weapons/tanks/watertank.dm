//Hydroponics tank and base code
/obj/item/weapon/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	w_class = 4
	slot_flags = SLOT_BACK
	slowdown = 1
	action_button_name = "Toggle Mister"

	var/obj/item/weapon/noz
	var/on = 0
	var/volume = 500

/obj/item/weapon/watertank/New()
	..()
	create_reagents(volume)
	noz = make_noz()

/obj/item/weapon/watertank/ui_action_click()
	toggle_mister()

/obj/item/weapon/watertank/verb/toggle_mister()
	set name = "Toggle Mister"
	set category = "Object"
	if (usr.get_item_by_slot(usr.getWatertankSlot()) != src)
		usr << "<span class='warning'>The watertank must be worn properly to use!</span>"
		return
	if(usr.incapacitated())
		return
	on = !on

	var/mob/living/carbon/human/user = usr
	if(on)
		if(noz == null)
			noz = make_noz()

		//Detach the nozzle into the user's hands
		if(!user.put_in_hands(noz))
			on = 0
			user << "<span class='warning'>You need a free hand to hold the mister!</span>"
			return
		noz.loc = user
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()
	return

/obj/item/weapon/watertank/proc/make_noz()
	return new /obj/item/weapon/reagent_containers/spray/mister(src)

/obj/item/weapon/watertank/equipped(mob/user, slot)
	if (slot != slot_back)
		remove_noz()

/obj/item/weapon/watertank/proc/remove_noz()
	if(ismob(noz.loc))
		var/mob/M = noz.loc
		M.unEquip(noz, 1)
	return

/obj/item/weapon/watertank/Destroy()
	if (on)
		remove_noz()
		qdel(noz)
		noz = null
	return ..()

/obj/item/weapon/watertank/attack_hand(mob/user)
	if(src.loc == user)
		ui_action_click()
		return
	..()

/obj/item/weapon/watertank/MouseDrop(obj/over_object)
	var/mob/H = src.loc
	if(istype(H))
		switch(over_object.name)
			if("r_hand")
				if(H.r_hand)
					return
				if(!H.unEquip(src))
					return
				H.put_in_r_hand(src)
			if("l_hand")
				if(H.l_hand)
					return
				if(!H.unEquip(src))
					return
				H.put_in_l_hand(src)
	return

/obj/item/weapon/watertank/attackby(obj/item/W, mob/user, params)
	if(W == noz)
		remove_noz()
		return
	..()

/mob/proc/getWatertankSlot()
	return slot_back

/mob/living/simple_animal/drone/getWatertankSlot()
	return slot_drone_storage

// This mister item is intended as an extension of the watertank and always attached to it.
// Therefore, it's designed to be "locked" to the player's hands or extended back onto
// the watertank backpack. Allowing it to be placed elsewhere or created without a parent
// watertank object will likely lead to weird behaviour or runtimes.
/obj/item/weapon/reagent_containers/spray/mister
	name = "water mister"
	desc = "A mister nozzle attached to a water tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "mister"
	item_state = "mister"
	w_class = 4
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(25,50,100)
	volume = 500
	flags = NODROP | OPENCONTAINER | NOBLUDGEON

	var/obj/item/weapon/watertank/tank

/obj/item/weapon/reagent_containers/spray/mister/New(parent_tank)
	..()
	if(check_tank_exists(parent_tank, src))
		tank = parent_tank
		reagents = tank.reagents	//This mister is really just a proxy for the tank's reagents
		loc = tank
	return

/obj/item/weapon/reagent_containers/spray/mister/dropped(mob/user)
	user << "<span class='notice'>The mister snaps back onto the watertank.</span>"
	tank.on = 0
	loc = tank

/obj/item/weapon/reagent_containers/spray/mister/attack_self()
	return

/proc/check_tank_exists(parent_tank, mob/living/carbon/human/M, obj/O)
	if (!parent_tank || !istype(parent_tank, /obj/item/weapon/watertank))	//To avoid weird issues from admin spawns
		M.unEquip(O)
		qdel(0)
		return 0
	else
		return 1

/obj/item/weapon/reagent_containers/spray/mister/Move()
	..()
	if(loc != tank.loc)
		loc = tank.loc

/obj/item/weapon/reagent_containers/spray/mister/afterattack(obj/target, mob/user, proximity)
	if(target.loc == loc || target == tank) //Safety check so you don't fill your mister with mutagen or something and then blast yourself in the face with it putting it away
		return
	..()

//Janitor tank
/obj/item/weapon/watertank/janitor
	name = "backpack water tank"
	desc = "A janitorial watertank backpack with nozzle to clean dirt and graffiti."
	icon_state = "waterbackpackjani"
	item_state = "waterbackpackjani"

/obj/item/weapon/watertank/janitor/New()
	..()
	reagents.add_reagent("cleaner", 500)

/obj/item/weapon/reagent_containers/spray/mister/janitor
	name = "janitor spray nozzle"
	desc = "A janitorial spray nozzle attached to a watertank, designed to clean up large messes."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "misterjani"
	item_state = "misterjani"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()

/obj/item/weapon/watertank/janitor/make_noz()
	return new /obj/item/weapon/reagent_containers/spray/mister/janitor(src)

/obj/item/weapon/reagent_containers/spray/mister/janitor/attack_self(var/mob/user)
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	user << "<span class='notice'>You [amount_per_transfer_from_this == 10 ? "remove" : "fix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>"

//ATMOS FIRE FIGHTING BACKPACK

#define EXTINGUISHER 0
#define NANOFROST 1
#define METAL_FOAM 2

/obj/item/weapon/watertank/atmos
	name = "backpack firefighter tank"
	desc = "A refridgerated and pressurized backpack tank with extinguisher nozzle, intended to fight fires. Swaps between extinguisher, nanofrost launcher, and metal foam dispenser for breaches. Nanofrost converts plasma in the air to nitrogen, but only if it is combusting at the time."
	icon_state = "waterbackpackatmos"
	item_state = "waterbackpackatmos"
	volume = 200

/obj/item/weapon/watertank/atmos/New()
	..()
	reagents.add_reagent("water", 200)

/obj/item/weapon/watertank/atmos/make_noz()
	return new /obj/item/weapon/extinguisher/mini/nozzle(src)

/obj/item/weapon/watertank/atmos/dropped(mob/user)
	icon_state = "waterbackpackatmos"
	if(istype(noz, /obj/item/weapon/extinguisher/mini/nozzle))
		var/obj/item/weapon/extinguisher/mini/nozzle/N = noz
		N.nozzle_mode = 0

/obj/item/weapon/extinguisher/mini/nozzle
	name = "extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a firefighter's backpack tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "atmos_nozzle"
	item_state = "nozzleatmos"
	safety = 0
	max_water = 200
	power = 8
	precision = 1
	cooling_power = 5
	w_class = 5
	flags = NODROP //Necessary to ensure that the nozzle and tank never seperate
	var/obj/item/weapon/watertank/tank
	var/nozzle_mode = 0
	var/metal_synthesis_cooldown = 0
	var/nanofrost_cooldown = 0

/obj/item/weapon/extinguisher/mini/nozzle/New(parent_tank)
	if(check_tank_exists(parent_tank, src))
		tank = parent_tank
		reagents = tank.reagents
		max_water = tank.volume
		loc = tank
	return

/obj/item/weapon/extinguisher/mini/nozzle/Move()
	..()
	if(loc != tank.loc)
		loc = tank
	return

/obj/item/weapon/extinguisher/mini/nozzle/attack_self(mob/user)
	switch(nozzle_mode)
		if(EXTINGUISHER)
			nozzle_mode = NANOFROST
			tank.icon_state = "waterbackpackatmos_1"
			user << "Swapped to nanofrost launcher"
			return
		if(NANOFROST)
			nozzle_mode = METAL_FOAM
			tank.icon_state = "waterbackpackatmos_2"
			user << "Swapped to metal foam synthesizer"
			return
		if(METAL_FOAM)
			nozzle_mode = EXTINGUISHER
			tank.icon_state = "waterbackpackatmos_0"
			user << "Swapped to water extinguisher"
			return
	return

/obj/item/weapon/extinguisher/mini/nozzle/dropped(mob/user)
	user << "<span class='notice'>The nozzle snaps back onto the tank!</span>"
	tank.on = 0
	loc = tank

/obj/item/weapon/extinguisher/mini/nozzle/afterattack(atom/target, mob/user)
	if(nozzle_mode == EXTINGUISHER)
		..()
		return
	var/Adj = user.Adjacent(target)
	if(Adj)
		AttemptRefill(target, user)
	if(nozzle_mode == NANOFROST)
		if(Adj)
			return //Safety check so you don't blast yourself trying to refill your tank
		var/datum/reagents/R = reagents
		if(R.total_volume < 100)
			user << "<span class='warning'>You need at least 100 units of water to use the nanofrost launcher!</span>"
			return
		if(nanofrost_cooldown)
			user << "<span class='warning'>Nanofrost launcher is still recharging...</span>"
			return
		nanofrost_cooldown = 1
		R.remove_any(100)
		var/obj/effect/nanofrost_container/A = new /obj/effect/nanofrost_container(get_turf(src))
		log_game("[user.ckey] ([user.name]) used Nanofrost at [get_area(user)] ([user.x], [user.y], [user.z]).")
		playsound(src,'sound/items/syringeproj.ogg',40,1)
		for(var/a=0, a<5, a++)
			step_towards(A, target)
			sleep(2)
		A.Smoke()
		spawn(100)
			if(src)
				nanofrost_cooldown = 0
		return
	if(nozzle_mode == METAL_FOAM)
		if(!Adj|| !istype(target, /turf))
			return
		if(metal_synthesis_cooldown < 5)
			var/obj/effect/particle_effect/foam/metal/F = PoolOrNew(/obj/effect/particle_effect/foam/metal, get_turf(target))
			F.amount = 0
			metal_synthesis_cooldown++
			spawn(100)
				metal_synthesis_cooldown--
		else
			user << "<span class='warning'>Metal foam mix is still being synthesized...</span>"
			return

/obj/effect/nanofrost_container
	name = "nanofrost container"
	desc = "A frozen shell of ice containing nanofrost that freezes the surrounding area after activation."
	icon = 'icons/effects/effects.dmi'
	icon_state = "frozen_smoke_capsule"
	mouse_opacity = 0
	pass_flags = PASSTABLE

/obj/effect/nanofrost_container/proc/Smoke()
	var/datum/effect_system/smoke_spread/freezing/S = new
	S.set_up(2, src.loc, blasting=1)
	S.start()
	var/obj/effect/decal/cleanable/flour/F = new /obj/effect/decal/cleanable/flour(src.loc)
	F.color = "#B2FFFF"
	F.name = "nanofrost residue"
	F.desc = "Residue left behind from a nanofrost detonation. Perhaps there was a fire here?"
	playsound(src,'sound/effects/bamf.ogg',100,1)
	qdel(src)

#undef EXTINGUISHER
#undef NANOFROST
#undef METAL_FOAM

/obj/item/weapon/reagent_containers/chemtank
	name = "backpack chemical injector"
	desc = "A chemical autoinjector that can be carried on your back."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpackatmos"
	item_state = "waterbackpackatmos"
	w_class = 4
	slot_flags = SLOT_BACK
	slowdown = 1
	action_button_name = "Activate Injector"

	var/on = 0
	volume = 300
	var/usage_ratio = 5 //5 unit added per 1 removed
	var/injection_amount = 1 
	amount_per_transfer_from_this = 5
	flags = OPENCONTAINER
	spillable = 0
	possible_transfer_amounts = list(5,10,15)

/obj/item/weapon/reagent_containers/chemtank/ui_action_click()
	toggle_injection()

/obj/item/weapon/reagent_containers/chemtank/proc/toggle_injection()
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if (user.get_item_by_slot(slot_back) != src)
		user << "<span class='warning'>The chemtank needs to be on your back before you can activate it!</span>"
		return
	if(on)
		turn_off()
	else
		turn_on()

//Todo : cache these.
/obj/item/weapon/reagent_containers/chemtank/proc/update_filling()
	overlays.Cut()

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi',icon_state = "backpack-10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 15)		filling.icon_state = "backpack-10"
			if(16 to 60) 	filling.icon_state = "backpack50"
			if(61 to INFINITY)	filling.icon_state = "backpack100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/chemtank/worn_overlays(var/isinhands = FALSE) //apply chemcolor and level
	. = list()
	//inhands + reagent_filling
	if(!isinhands && reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi',icon_state = "backpackmob-10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 15)		filling.icon_state = "backpackmob-10"
			if(16 to 60) 	filling.icon_state = "backpackmob50"
			if(61 to INFINITY)	filling.icon_state = "backpackmob100"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling

/obj/item/weapon/reagent_containers/chemtank/proc/turn_on()
	on = 1
	SSobj.processing |= src
	if(ismob(loc))
		loc << "<span class='notice'>[src] turns on.</span>"

/obj/item/weapon/reagent_containers/chemtank/proc/turn_off()
	on = 0
	SSobj.processing.Remove(src)
	if(ismob(loc))
		loc << "<span class='notice'>[src] turns off.</span>"

/obj/item/weapon/reagent_containers/chemtank/process()
	if(!istype(loc,/mob/living/carbon/human))
		turn_off()
		return
	if(!reagents.total_volume)
		turn_off()
		return
	var/mob/living/carbon/human/user = loc
	if(user.back != src)
		turn_off()
		return

	var/used_amount = injection_amount/usage_ratio
	reagents.reaction(user, INJECT,injection_amount,0)
	reagents.trans_to(user,used_amount,multiplier=usage_ratio)
	update_filling()
	user.update_inv_back() //for overlays update

/obj/item/weapon/reagent_containers/chemtank/stim/New()
	..()
	reagents.add_reagent("stimulants_longterm", 300)
	update_filling()