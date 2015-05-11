/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	locked = 1
	icon_state = "secure"
	health = 200
	var/panel_uncovered = 0

/obj/structure/closet/secure_closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	..()

	if(!opened)
		if(panel_uncovered)
			if(!broken)
				overlays += image('icons/obj/sayu_closet.dmi', "hacking")
			else
				overlays += image('icons/obj/sayu_closet.dmi', "hackingsparks")
			return

		if(!broken)
			if(locked)
				overlays += "locked"
			else
				overlays += "unlocked"
		else
			overlays += "off"

/obj/structure/closet/secure_closet/examine(mob/user)
	..()
	if(broken || opened || !ishuman(user))
		return //Monkeys don't get a message, nor does anyone ief it's open or emagged
	else
		user << "<span class='notice'>Alt-click the locker to [locked ? "unlock" : "lock"] it.</span>"

/obj/structure/closet/secure_closet/AltClick(var/mob/user)
	..()
	if(!in_range(src, user))
		return
	if(!ishuman(user))
		user << "<span class='notice'>You have no idea how this thing is supposed to work.</span>"
		return
	if(user.stat || !user.canmove || user.restrained() || broken)
		user << "<span class='notice'>You can't do that right now.</span>"
		return
	if(src.opened)
		return
	else
		togglelock(user)

/obj/structure/closet/secure_closet/can_open()
	if(src.locked || src.welded)
		return 0
	return 1

/obj/structure/closet/secure_closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken)
		if(prob(50/severity))
			src.locked = !src.locked
			src.update_icon()
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				src.req_access = list()
				src.req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/secure_closet/proc/togglelock(mob/user as mob)
	if(src.allowed(user))
		src.locked = !src.locked
		add_fingerprint(user)
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.eye_blind )))
				O << "<span class='notice'>[user] has [locked ? null : "un"]locked the locker.</span>"
		update_icon()
	else
		user << "<span class='notice'>Access Denied</span>"

/obj/structure/closet/secure_closet/place(var/mob/user, var/obj/item/I)
	if(!src.opened)
		togglelock(user)
		return 1
	return 0

/obj/structure/closet/secure_closet/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(welded == 1)
			user << "<span class='warning'>It's welded shut!</span>"
			return
		else
			src.add_fingerprint(user)
			panel_uncovered = !panel_uncovered
			if(!panel_uncovered) // if the panel is now closed
				user << "<span class='notice'>You close the locking mechanism's panel on the locker.</span>"
			else
				user << "<span class='notice'>You open the locking mechanism's panel on the locker.</span>"
			update_icon()
			return
	else if(panel_uncovered && istype(W, /obj/item/device/multitool))
		src.add_fingerprint(user)
		playsound(src.loc, 'sound/machines/twobeep.ogg', 150, 1)
		if(!broken)
			user << "<span class='danger'>You begin hacking the locker open. (This action will take 20 seconds to complete.)</span>"
			if(do_after(user,200) && panel_uncovered) // makes sure that the user stays in place and does not close the panel
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				broken = 1
				locked = 0
				desc = "It appears to be broken."
				visible_message("<span class='warning'>The locker has been broken by [user] with a multitool!</span>")
				update_icon()
		else
			user << "<span class='danger'>You begin repairing the broken locker. (This action will take 30 seconds to complete.)</span>"
			if(do_after(user,300) && panel_uncovered) // longer than hacking it open for reasons
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				broken = 0
				locked = 0	// the locker stays unlocked after it's been fixed, which should be noticable to anyone who's paying attention (read: nobody at all)
				desc = initial(desc)
				visible_message("<span class='warning'>The locker has been repaired by [user] with a multitool!</span>")
				update_icon()
		return
	else if(src.panel_uncovered)
		user << "<span class='notice'>You cannot do that while the locker's panel is open!</span>"
		return
	else if(!src.opened && src.broken)
		user << "<span class='notice'>The locker appears to be broken.</span>"
		return
	else
		..(W, user)

/obj/structure/closet/secure_closet/emag_act(mob/user as mob)
	if(!broken)
		broken = 1
		locked = 0
		desc += "It appears to be broken."
		update_icon()

		for(var/mob/O in viewers(user, 3))
			O.show_message("<span class='warning'>The locker has been broken by [user] with an electromagnetic card!</span>", 1, "You hear a faint electrical spark.", 2)
		overlays += "sparking"
		spawn(4) //overlays don't support flick so we have to cheat
		update_icon()

/obj/structure/closet/secure_closet/relaymove(mob/user as mob)
	if(user.stat || !isturf(src.loc))
		return

	if(!(src.locked))
		open()
	else
		user << "<span class='notice'>The locker is locked!</span>"
		if(world.time > lastbang+5)
			lastbang = world.time
			for(var/mob/M in get_hearers_in_view(src, null))
				M.show_message("<FONT size=[max(0, 5 - get_dist(src, M))]>BANG, bang!</FONT>", 2)
	return

/obj/structure/closet/secure_closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if(panel_uncovered)
		user << "<span class='notice'>You cannot do that while the locker's panel is open!</span>"
		return
	if(!src.toggle())
		return src.attackby(null, user)

/obj/structure/closet/secure_closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)
