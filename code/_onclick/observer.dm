/mob/dead/observer/DblClickOn(var/atom/A, var/params)
	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return
	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return									// seems legit.

	// Things you might plausibly want to follow
	if(istype(A, /atom/movable))
		ManualFollow(A)

	// Otherwise jump
	else if(A.loc)
		loc = get_turf(A)

/mob/dead/observer/ClickOn(var/atom/A, var/params)
	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return
	// You are responsible for checking config.ghost_interaction when you override this function
	// Not all of them require checking, see below
	A.attack_ghost(src)

// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/dead/observer/user)
	if(user.client)
		if(check_rights(R_ADMIN, 0))
			attack_ai(user)
		if(user.client.prefs.inquisitive_ghost)
			user.examinate(src)
	return

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, gateways, and teleporters while observing. -Sayu

/obj/machinery/teleport/hub/attack_ghost(mob/user)
	var/atom/l = loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if(com && com.locked)
		user.loc = get_turf(com.locked)

/obj/effect/portal/attack_ghost(mob/user)
	if(target)
		user.loc = get_turf(target)

/obj/machinery/gateway/centerstation/attack_ghost(mob/user)
	if(awaygate)
		user.loc = awaygate.loc
	else
		user << "[src] has no destination."

/obj/machinery/gateway/centeraway/attack_ghost(mob/user)
	if(stationgate)
		user.loc = stationgate.loc
	else
		user << "[src] has no destination."

/obj/item/weapon/storage/attack_ghost(mob/user)
	orient2hud(user)
	show_to(user)

/obj/machinery/teleport/hub/attack_ghost(mob/user)
	if(power_station && power_station.engaged && power_station.teleporter_console && power_station.teleporter_console.target)
		user.Move(get_turf(power_station.teleporter_console.target))
	return

// -------------------------------------------
// This was supposed to be used by adminghosts
// I think it is a *terrible* idea
// but I'm leaving it here anyway
// commented out, of course.
/*
/atom/proc/attack_admin(mob/user as mob)
	if(!user || !user.client || !user.client.holder)
		return
	attack_hand(user)

*/
