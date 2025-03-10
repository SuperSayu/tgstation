/**********************Mineral ores**************************/

/obj/item/weapon/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"
	var/points = 0 //How many points this ore gets you from the ore redemption machine
	var/refined_type = null //What this ore defaults to being refined into

/obj/item/weapon/ore/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.remove_fuel(15) && refined_type)
			new refined_type(get_turf(src.loc))
			qdel(src)
		else if(W.isOn())
			user << "<span class='info'>Not enough fuel to smelt [src].</span>"
	..()

/obj/item/weapon/ore/uranium
	name = "uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	points = 30
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/uranium

/obj/item/weapon/ore/iron
	name = "iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	points = 1
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/metal

/obj/item/weapon/ore/glass
	name = "sand pile"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	points = 1
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/glass

/obj/item/weapon/ore/glass/attack_self(mob/living/user)
	user << "<span class='notice'>You use the sand to make sandstone.</span>"
	var/sandAmt = 1
	for(var/obj/item/weapon/ore/glass/G in user.loc) // The sand on the floor
		sandAmt += 1
		qdel(G)
	while(sandAmt > 0)
		var/obj/item/stack/sheet/mineral/sandstone/SS = new /obj/item/stack/sheet/mineral/sandstone(user.loc)
		if(sandAmt >= SS.max_amount)
			SS.amount = SS.max_amount
		else
			SS.amount = sandAmt
			for(var/obj/item/stack/sheet/mineral/sandstone/SA in user.loc)
				if(SA != SS && SA.amount < SA.max_amount)
					SA.attackby(SS, user) //we try to transfer all old unfinished stacks to the new stack we created.
		sandAmt -= SS.max_amount
	qdel(src)
	return

/obj/item/weapon/ore/plasma
	name = "plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "plasmatech=2;materials=2"
	points = 15
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/plasma

/obj/item/weapon/ore/plasma/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.welding)
			user << "<span class='warning'>You can't hit a high enough temperature to smelt [src] properly!</span>"
	else
		..()


/obj/item/weapon/ore/silver
	name = "silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	points = 16
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/silver

/obj/item/weapon/ore/gold
	name = "gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	points = 18
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/gold

/obj/item/weapon/ore/diamond
	name = "diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	points = 50
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/diamond

/obj/item/weapon/ore/bananium
	name = "bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"
	points = 60
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/bananium

/obj/item/weapon/ore/slag
	name = "slag"
	desc = "Completely useless"
	icon_state = "slag"

/obj/item/weapon/twohanded/required/gibtonite
	name = "gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = 4
	throw_range = 0
	anchored = 1 //Forces people to carry it by hand, no pulling!
	var/primed = 0
	var/det_time = 100
	var/quality = 1 //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher value = better
	var/attacher = "UNKNOWN"
	var/datum/wires/explosive/gibtonite/wires

/obj/item/weapon/twohanded/required/gibtonite/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/item/weapon/twohanded/required/gibtonite/attackby(obj/item/I, mob/user, params)
	if(!wires && istype(I, /obj/item/device/assembly/igniter))
		user.visible_message("[user] attaches [I] to [src].", "<span class='notice'>You attach [I] to [src].</span>")
		wires = new(src)
		attacher = key_name(user)
		qdel(I)
		overlays += "Gibtonite_igniter"
		return

	if(wires && !primed)
		if(wires.IsInteractionTool(I))
			wires.Interact(user)
			return

	if(istype(I, /obj/item/weapon/pickaxe) || istype(I, /obj/item/weapon/resonator) || I.force >= 10)
		GibtoniteReaction(user)
		return
	if(primed)
		if(istype(I, /obj/item/device/mining_scanner) || istype(I, /obj/item/device/t_scanner/adv_mining_scanner) || istype(I, /obj/item/device/multitool))
			primed = 0
			user.visible_message("The chain reaction was stopped! ...The ore's quality looks diminished.", "<span class='notice'>You stopped the chain reaction. ...The ore's quality looks diminished.</span>")
			icon_state = "Gibtonite ore"
			quality = 1
			return
	..()

/obj/item/weapon/twohanded/required/gibtonite/attack_self(user)
	if(wires)
		wires.Interact(user)
	else
		..()

/obj/item/weapon/twohanded/required/gibtonite/bullet_act(obj/item/projectile/P)
	GibtoniteReaction(P.firer)
	..()

/obj/item/weapon/twohanded/required/gibtonite/ex_act()
	GibtoniteReaction(null, 1)



/obj/item/weapon/twohanded/required/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by = 0)
	if(!primed)
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		primed = 1
		icon_state = "Gibtonite active"
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		var/notify_admins = 0
		if(z != 5)//Only annoy the admins ingame if we're triggered off the mining zlevel
			notify_admins = 1

		if(notify_admins)
			if(triggered_by == 1)
				message_admins("An explosion has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			else if(triggered_by == 2)
				message_admins("A signal has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>. Igniter attacher: [key_name_admin(attacher)]<A HREF='?_src_=holder;adminmoreinfo=\ref[attacher]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[attacher]'>FLW</A>)")
			else
				message_admins("[key_name_admin(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
		if(triggered_by == 1)
			log_game("An explosion has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		else if(triggered_by == 2)
			log_game("A signal has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z]). Igniter attacher: [key_name(attacher)].")
		else
			user.visible_message("<span class='warning'>[user] strikes \the [src], causing a chain reaction!</span>", "<span class='danger'>You strike \the [src], causing a chain reaction.</span>")
			log_game("[key_name(user)] has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		spawn(det_time)
		if(primed)
			if(quality == 3)
				explosion(src.loc,2,4,9,adminlog = notify_admins)
			if(quality == 2)
				explosion(src.loc,1,2,5,adminlog = notify_admins)
			if(quality == 1)
				explosion(src.loc,-1,1,3,adminlog = notify_admins)
			qdel(src)

/obj/item/weapon/ore/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/weapon/ore/ex_act()
	return

/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'icons/obj/economy.dmi'
	name = "coin"
	icon_state = "coin__heads"
	flags = CONDUCT
	force = 1
	throwforce = 2
	w_class = 1
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cmineral = null
	var/cooldown = 0
	var/value = 10

/obj/item/weapon/coin/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

	icon_state = "coin_[cmineral]_heads"
	if(cmineral)
		name = "[cmineral] coin"

/obj/item/weapon/coin/gold
	cmineral = "gold"
	icon_state = "coin_gold_heads"
	value = 160
	materials = list(MAT_GOLD = 400)

/obj/item/weapon/coin/silver
	cmineral = "silver"
	icon_state = "coin_silver_heads"
	value = 40
	materials = list(MAT_SILVER = 400)

/obj/item/weapon/coin/diamond
	cmineral = "diamond"
	icon_state = "coin_diamond_heads"
	value = 120
	materials = list(MAT_DIAMOND = 400)

/obj/item/weapon/coin/iron
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	value = 20
	materials = list(MAT_METAL = 400)

/obj/item/weapon/coin/plasma
	cmineral = "plasma"
	icon_state = "coin_plasma_heads"
	value = 80
	materials = list(MAT_PLASMA = 400)

/obj/item/weapon/coin/uranium
	cmineral = "uranium"
	icon_state = "coin_uranium_heads"
	value = 160
	materials = list(MAT_URANIUM = 400)

/obj/item/weapon/coin/clown
	cmineral = "bananium"
	icon_state = "coin_bananium_heads"
	value = 600 //makes the clown cri
	materials = list(MAT_BANANIUM = 400)

/obj/item/weapon/coin/adamantine
	cmineral = "adamantine"
	icon_state = "coin_adamantine_heads"
	value = 400

/obj/item/weapon/coin/mythril
	cmineral = "mythril"
	icon_state = "coin_mythril_heads"
	value = 400

/obj/item/weapon/coin/twoheaded
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")
	value = 20

/obj/item/weapon/coin/antagtoken
	name = "antag token"
	icon_state = "coin_valid_valid"
	cmineral = "valid"
	desc = "A novelty coin that helps the heart know what hard evidence cannot prove."
	sideslist = list("valid", "salad")
	value = 20

/obj/item/weapon/coin/antagtoken/New()
	return

/obj/item/weapon/coin/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			user << "<span class='warning'>There already is a string attached to this coin!</span>"
			return

		if (CC.use(1))
			overlays += image('icons/obj/economy.dmi',"coin_string_overlay")
			string_attached = 1
			user << "<span class='notice'>You attach a string to the coin.</span>"
		else
			user << "<span class='warning'>You need one length of cable to attach a string to the coin!</span>"
			return

	else if(istype(W,/obj/item/weapon/wirecutters))
		if(!string_attached)
			..()
			return

		var/obj/item/stack/cable_coil/CC = new/obj/item/stack/cable_coil(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays = list()
		string_attached = null
		user << "<span class='notice'>You detach the string from the coin.</span>"
	else if(istype(W,/obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.welding && WT.remove_fuel(0, user))
			var/typelist = list("iron" = /obj/item/clothing/gloves/ring,
								"silver" = /obj/item/clothing/gloves/ring/silver,
								"gold" = /obj/item/clothing/gloves/ring/gold,
								"plasma" = /obj/item/clothing/gloves/ring/plasma,
								"uranium" = /obj/item/clothing/gloves/ring/uranium)
			var/typekey = typelist[cmineral]
			if(ispath(typekey))
				user << "\blue You make [src] into a ring."
				new typekey(get_turf(loc))
				del src
	else ..()

/obj/item/weapon/coin/attack_self(mob/user)
	if(cooldown < world.time - 15)
		var/coinflip = pick(sideslist)
		cooldown = world.time
		flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, 1)
		var/oldloc = loc
		sleep(15)
		if(loc == oldloc && user && !user.incapacitated())
			user.visible_message("[user] has flipped [src]. It lands on [coinflip].", \
								 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>", \
								 "<span class='italics'>You hear the clattering of loose change.</span>")
