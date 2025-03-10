// ---------------------------
//  This is a two-line wonder
// ---------------------------
/obj/item/weapon/grown/bananapeel/research
	name = "Genetically modified banana peel"
	potency = 100

// -------------------------------------
//			Lizard pet
// -------------------------------------
/mob/living/simple_animal/lizard/professor
	name = "The Professor"
	desc = "A remarkably booksmart reptile."
	gender = "male"
	melee_damage_upper = 0
	friendly = "flicks his tongue at"
	emote_see = list("looks around slowly","has an introspective look","tastes the air","sits placidly", "judges you silently","looks at you with one eye")
	pixel_y = 16

// -------------------------------------
//			False walls hide doors
// -------------------------------------
/obj/structure/falsewall
	layer = 3.2

// -------------------------------------
//			Soapmaking
// See also:
//  game/objects/weapons/clown_items.dm
// -------------------------------------

/datum/chemical_reaction/soap
	name = "Soap"
	id = "soap"
	result = null
	required_reagents = list("ammonia" = 5, "cornoil" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10
	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		var/number_of_bars = rand(1,round(created_volume / 15))
		var/average_volume = round(created_volume / number_of_bars)
		while(number_of_bars>0)
			var/obj/item/weapon/soap/S = new(location)
			S.uses = average_volume
			S.pixel_x = rand(-10,10)
			S.pixel_y = rand(-10,10)
			number_of_bars--
		return

// ------------------------------------------
//  Pet collars - Allows renaming of animals
//   Actual code in simple_animal/attackby
// ------------------------------------------

/*
/mob/living/simple_animal/
	var/renamable = 1 // if 0, pet collars cannot be used
	hostile/renamable = 0
	hostile/retaliate/goat/renamable = 1
	cat/Runtime/renamable = 0
	corgi
		Ian/renamable = 0
		Lisa/renamable = 0
		puppy/smart/sgt_pepper/renamable = 0
	crab/Coffee/renamable = 0
	lizard/professor/renamable = 0
	mouse/Tom/renamable = 0
	parrot/Poly/renamable = 0
	cow/Bessie/renamable = 0

/obj/item/weapon/pet_collar
	name = "Pet Collar"
	desc = "Helps you keep track of an animal's name."
	icon = 'icons/obj/sayu_items.dmi'
	icon_state = "collar"

/obj/item/weapon/storage/box/collars
	name = "Pet Supplies"
	desc = "Carries a number of collars for renaming animals."
	New()
		..()
		new /obj/item/weapon/pet_collar(src)
		new /obj/item/weapon/pet_collar(src)
		new /obj/item/weapon/pet_collar(src)
		new /obj/item/weapon/pet_collar(src)
		new /obj/item/weapon/pet_collar(src)
		new /obj/item/weapon/pet_collar(src)
		new /obj/item/weapon/pet_collar(src)
//from simple animal attackby, archived
	if(istype(O,/obj/item/weapon/pet_collar))
		if(!renamable)
			if(istype(src,/mob/living/simple_animal/hostile) && src.type != /mob/living/simple_animal/hostile/retaliate/goat)
				user << "\red [src] doesn't seem to like being labelled a pet."
				return
			user << "\red [src] is already quite attached to their existing name."
			return

		var/tag = input(user,"Pet's name:","Name the pet",real_name) as text|null
		if(O && src && length(tag) && (O in user) && get_dist(user,src) <= 1)
			src.real_name = tag
			src.name = tag
			src.visible_message("[user] gives [src] a shiny new pet collar!")
			src.renamable = 0
			del O
		return
*/

//
// Actual bombs
//

/obj/item/weapon/dynamite
	name = "Dynamite"
	desc = "If the fuse is sparkin' done come a-knockin', baby."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "tnt"

	var/fuselength = 3000 // 5 minutes
	var/lit_time = null

	New()
		..()
		SSobj.processing |= src

	proc/Time(var/length)
		var/m = round(length / 600)
		var/s = round((length - 600*m) / 10)
		if(s<10) s = "0[s]"
		return "[m]:[s]"

	update_icon()
		if(lit_time)
			icon_state = "tnt-armed"
		else if(fuselength)
			icon_state = "tnt"
		else
			icon_state = "tnt-disarmed"

	examine(mob/user)
		..()
		if(lit_time)
			var/det_time = lit_time + fuselength
			var/difference = det_time - world.time
			user << "\red The fuse is lit!  You have [Time(difference)] to get away!"
		else
			if(fuselength)
				user << "\blue The fuse is [Time(fuselength)] long."
			else
				user << "\blue The fuse was removed."

	attackby(var/obj/item/W as obj, var/mob/living/user as mob)
		if(istype(W,/obj/item/weapon/wirecutters))
			if(lit_time != null)
				var/time_left = (lit_time + fuselength) - world.time
				if(time_left < 100)
					user << "\red The fuse it too short!  You can't get the [W] in close enough to stop it!"
					return
				lit_time = null
				fuselength = round(time_left * (rand(5,18) / 20))
				update_icon()
				user << "\blue You clip the fuse.  The burning piece of fuse falls harmlessly to the ground."
				return
			var/list/possible_lengths = list(0, 50,100,150,300,450,600,900,1200,1500,1800,2100,2400,2700)
			var/list/entries = list()
			for(var/index = 1; index <= possible_lengths.len; index++)
				if(possible_lengths[index] >= fuselength)
					possible_lengths.Cut(index)
					break
				entries += Time(possible_lengths[index])
			if(possible_lengths.len <= 1 && fuselength > 0)
				fuselength = 0
				user << "\blue You remove the last of the fuse."
				update_icon()
				return
			var/chosen = input(user, "Shorten the fuse from [Time(fuselength)] to...","Cut Fuse",entries[1]) as null|anything in entries
			var/index = entries.Find(chosen)
			if(!index) return
			fuselength = possible_lengths[index]
			if(fuselength)
				user << "\blue You shorten the fuse to [index]."
			else
				user << "\blue You remove the fuse."
				update_icon()
			return
		if(is_hot(W))
			if(lit_time)
				user << "\red The fuse is alread lit!"
				return
			if(!fuselength)
				user << "\blue The fuse seems to have been removed."
				return
			lit_time = world.time
			user << "You light the fuse.  It should go off in [Time(fuselength)]."
			update_icon()
			return


	process()
		if(!lit_time) return
		if(world.time >= (lit_time + fuselength))
			explosion(get_turf(loc), 1, 3, 5, 7) // todo actual values
			if(src) del src
			return



/obj/item/weapon/book/debug
	name = "Null obj log"
	unique	= 1
	title	= "The holy book of oshit"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	var/list/oshit = list()
	var/list/names = list()
	var/total_oshit = 0
	var/beenrun = 0

	attack_ghost(user)
		attack_self(user)

	proc/populate()
		oshit.Cut()
		names.Cut()
		for(var/obj/O in world)
			if(O.loc != null) continue
			var/t = O.type
			if(t in oshit)
				oshit[t]++
			else
				oshit[t]=1
				names[t]=O.name
		total_oshit = 0
		for(var/man in oshit)
			total_oshit += oshit[man]
	proc/format()
		dat = ""
		var/d_temp = ""
		var/a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/stack/tile))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Floor tiles (turf references): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/machinery))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Machines (processing list): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/weapon/reagent_containers))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Reagent Containers (reagent datum): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/screen))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Screen objects: [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/weapon/storage))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Storage containers (contents, screen objects): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/device/radio))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Radios (radio datum): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			if(ispath(type, /obj/item/organ))
				d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
				a_temp += oshit[type]
				oshit -= type
				names -= type
		dat += "Organs (mob reference): [a_temp]<hr>[d_temp]<br>"
		d_temp = ""
		a_temp = 0
		for(var/type in oshit)
			d_temp += "[oshit[type]] \"[names[type]]\" ([type])<br>"
			a_temp += oshit[type]
			oshit -= type
			names -= type
		dat += "Other (external reference, circular datum reference, contents, ???): [a_temp]<hr>[d_temp]"


	attack_self(var/mob/user as mob)
		if(!beenrun)
			testing("Making [src]")
			populate()
			format()
			beenrun = 1
		user << browse(dat, "window=oshit")

	examine(mob/user)
		..()
		user << "The holy book of oshit is [oshit.len] pages long and contains [total_oshit] entries total."
/obj/item/weapon/book/debug/mobs
	name = "Null mob log"
	populate()
		oshit.Cut()
		names.Cut()
		for(var/mob/M in world)
			if(M.loc != null) continue
			var/t = M.type
			if(t in oshit)
				oshit[t]++
			else
				oshit[t]=1
				names[t]=M.name
/obj/item/weapon/book/debug/effects
	name = "Effect log"
	populate()
		oshit.Cut()
		names.Cut()
		for(var/obj/effect/E in world)
			var/t = E.type
			if(t in oshit)
				oshit[t]++
			else
				oshit[t]=1
				names[t]=E.name