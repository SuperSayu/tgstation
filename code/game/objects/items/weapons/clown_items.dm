/* Clown Items
 * Contains:
 *		Soap
 *		Bike Horns
 *		Air Horns
 */

/*
 * Soap
 */

/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = 1
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	var/uses = 10
	var/usesize = 1
	var/cleanspeed = 50 //slower than mop

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"
	uses = 30

/obj/item/weapon/soap/homemade
	desc = "A homemade bar of soap. Smells of... well...."
	icon_state = "soapgibs"
	cleanspeed = 45 // a little faster to reward chemists for going to the effort

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of high-class luxury."
	icon_state = "soapdeluxe"
	uses = 25
	cleanspeed = 40 //same speed as mop because deluxe -- captain gets one of these

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	usesize = 0

/obj/item/weapon/soap/borg
	desc = "A very durable bar of robo-soap."
	icon_state = "soapdeluxe"
	usesize = 0
	cleanspeed = 10 //much faster than mop so it is useful for traitors who want to clean crime scenes

/obj/item/weapon/soap/suicide_act(mob/user)
	user.say(";FFFFFFFFFFFFFFFFUUUUUUUDGE!!")
	user.visible_message("<span class='suicide'>[user] lifts the [src.name] to their mouth and gnaws on it furiously, producing a thick froth! They'll never get that BB gun now!")
	PoolOrNew(/obj/effect/particle_effect/foam, loc)
	return (TOXLOSS)

/obj/item/weapon/soap/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		M.slip(4, 2, src)
		if(CLUMSY in M.disabilities)
			uses++ // murphy's law compels you
		else
			uses--
		if(uses <= 0)
			qdel(src)

/obj/item/weapon/soap/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !check_allowed_items(target))
		return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		user << "<span class='warning'>You need to take that [target.name] off before cleaning it!</span>"
	else if(istype(target,/turf))
		var/cleaned = 0
		for(var/obj/effect/decal/cleanable/C in target)
			if(uses <= 0 || cleaned > 3) break
			cleaned++
			uses-=usesize
			qdel(C)
		if(cleaned > 0)
			usr << "<span class='notice'>You clean \the [target.name].</span>"
			checkUses(user)
	else if(istype(target,/obj/effect/decal/cleanable))
		user.visible_message("[user] begins to scrub \the [target.name] out with [src].", "<span class='warning'>You begin to scrub \the [target.name] out with [src]...</span>")
		if(do_after(user, src.cleanspeed, target = target))
			user << "<span class='notice'>You scrub \the [target.name] out.</span>"
			uses-=usesize
			qdel(target)
			checkUses(user)
	else if(ishuman(target) && user.zone_sel && user.zone_sel.selecting == "mouth")
		user.visible_message("<span class='warning'>\the [user] washes \the [target]'s mouth out with [src.name]!</span>", "<span class='notice'>You wash \the [target]'s mouth out with [src.name]!</span>") //washes mouth out with soap sounds better than 'the soap' here
		return
	else if(istype(target, /obj/structure/window))
		user.visible_message("[user] begins to clean \the [target.name] with [src]...", "<span class='notice'>You begin to clean \the [target.name] with [src]...</span>")
		if(do_after(user, src.cleanspeed, target = target))
			user << "<span class='notice'>You clean \the [target.name].</span>"
			target.color = initial(target.color)
			target.SetOpacity(initial(target.opacity))
	else
		user.visible_message("[user] begins to clean \the [target.name] with [src]...", "<span class='notice'>You begin to clean \the [target.name] with [src]...</span>")
		if(do_after(user, src.cleanspeed, target = target))
			user << "<span class='notice'>You clean \the [target.name].</span>"
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			target.clean_blood()
			checkUses(user)
	return

/obj/item/weapon/soap/proc/checkUses(mob/user as mob)
	if(src.uses<=0)
		user << "<span class='notice'>That's the last of this bar of soap.</span>"
		qdel(src)

/obj/item/weapon/soap/attackby(obj/item/I as obj, mob/user as mob) //todo: implement isSharp for soap splitting

	if(is_sharp(I))

		if(usesize == 0)
			user << "You try to split the soap in twain, but alas, it is too though."
			return

		//Split the soap in two.  Other bladed implements could do this, but it would be pretty awkward.  That's my excuse...
		if(uses <= 5)
			user << "You try to split the soap in twain, but end up destroying it."
			qdel(src)
		else
			user << "You split the bar of soap down the middle."
			var/newuses = round(uses/2) - 1
			uses = newuses
			new type(user.loc)
		return
	..()

/*
/obj/item/weapon/soap/examine(user)
	..()
	usr << "<span class='notice'> It has [uses] uses left.</span>"
*/

/*
 * Bike Horns
 */


/obj/item/weapon/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 0
	hitsound = null //To prevent tap.ogg playing, as the item lacks of force
	w_class = 1
	throw_speed = 3
	throw_range = 7
	attack_verb = list("HONKED")
	var/spam_flag = 0
	var/honksound = 'sound/items/bikehorn.ogg'
	var/cooldowntime = 20

/obj/item/weapon/bikehorn/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] solemnly points the horn at \his temple! It looks like \he's trying to commit suicide..</span>")
	playsound(src.loc, honksound, 50, 1)
	return (BRUTELOSS)

/obj/item/weapon/bikehorn/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!spam_flag)
		playsound(loc, honksound, 50, 1, -1) //plays instead of tap.ogg!
	return ..()

/obj/item/weapon/bikehorn/attack_self(mob/user)
	if(!spam_flag)
		spam_flag = 1
		playsound(src.loc, honksound, 50, 1)
		src.add_fingerprint(user)
		spawn(cooldowntime)
			spam_flag = 0
	return

/obj/item/weapon/bikehorn/Crossed(mob/living/L)
	if(isliving(L))
		playsound(loc, honksound, 50, 1, -1)
	..()

/obj/item/weapon/bikehorn/airhorn
	name = "air horn"
	desc = "Damn son, where'd you find this?"
	icon_state = "air_horn"
	honksound = 'sound/items/AirHorn2.ogg'
	cooldowntime = 50
