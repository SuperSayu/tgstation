var/global/list/possiblethemes = list("organharvest","cult","wizden","cavein","xenoden","hitech","speakeasy","plantlab", "deadradio", "bluespa", "carpcave", "witch")

var/global/max_secret_rooms = 6
var/global/max_monoliths = 6 // Actually 5 monoliths, the one that appears under the mining station without an artifact counts as one

var/global/list/spawned_surprises = list()

/proc/spawn_room(atom/start_loc, x_size, y_size, list/walltypes, floor, name)
	var/list/room_turfs = list("walls"=list(),"floors"=list())

	for(var/x = 0, x < x_size, x++)		//sets the size of the room on the x axis
		for(var/y = 0, y < y_size, y++) //sets it on y axis.
			var/turf/T
			var/cur_loc = locate(start_loc.x + x, start_loc.y + y, start_loc.z)


			var/area/asteroid/artifactroom/A = new
			if(name)
				A.name = name
			else
				A.name = "Artifact Room #[start_loc.x]-[start_loc.y]-[start_loc.z]"


			if(x == 0 || x == x_size-1 || y == 0 || y == y_size-1)
				var/wall = pickweight(walltypes)//totally-solid walls are pretty boring.
				T = cur_loc
				T.ChangeTurf(wall)
				room_turfs["walls"] += T


			else
				T = cur_loc
				T.ChangeTurf(floor)
				room_turfs["floors"] += T

			A.contents += T

	return room_turfs

/proc/make_mining_asteroid_secrets()

	for(1 to max_monoliths)
		make_mining_asteroid_secret(1)

	for(1 to max_secret_rooms)
		make_mining_asteroid_secret()

/proc/make_mining_asteroid_secret(var/monolith = 0)
	var/valid = 0
	var/turf/T = null
	var/sanity = 0
	var/list/room = null
	var/list/turfs = null
	var/x_size = 5
	var/y_size = 5

	var/areapoints = 0
	var/theme = "organharvest"
	var/list/walltypes = list(/turf/simulated/wall=3, /turf/simulated/mineral/random=1)
	var/list/floortypes = list(/turf/simulated/floor/plasteel)
	var/list/treasureitems = list()//good stuff. only 1 is created per room.
	var/list/fluffitems = list()//lesser items, to help fill out the room and enhance the theme.

	x_size = rand(3,7)
	y_size = rand(3,7)
	areapoints = x_size * y_size

	switch(monolith ? "monolith" : pick(possiblethemes))//what kind of room is this gonna be?
		if("organharvest")
			walltypes = list(/turf/simulated/wall/r_wall=2,/turf/simulated/wall=2,/turf/simulated/mineral/random/high_chance=1)
			floortypes = list(/turf/simulated/floor/plasteel,/turf/simulated/floor/engine)
			treasureitems = list(/mob/living/simple_animal/bot/medbot/mysterious=1, /obj/item/weapon/circular_saw=1, /obj/structure/closet/critter/cat=2)
			fluffitems = list(/obj/effect/decal/cleanable/blood=5,/obj/item/organ/internal/appendix=2,/obj/structure/closet/crate/freezer=2,
							  /obj/structure/table/optable=1,/obj/item/weapon/scalpel=1,/obj/item/weapon/storage/firstaid/regular=3,
							  /obj/item/weapon/tank/internals/anesthetic=1, /obj/item/weapon/surgical_drapes=2, /obj/item/device/mass_spectrometer/adv=1,/obj/item/clothing/glasses/hud/health=1)

		if("cult")
			theme = "cult"
			walltypes = list(/turf/simulated/wall/cult=3,/turf/simulated/mineral/random/high_chance=1)
			floortypes = list(/turf/simulated/floor/plasteel/cult)
			treasureitems = list(/obj/item/device/soulstone/anybody=1, /obj/item/clothing/suit/space/cult=1, /obj/item/weapon/bedsheet/cult=2,
								 /obj/item/clothing/suit/cultrobes=2, /mob/living/simple_animal/hostile/creature=3)
			fluffitems = list(/obj/effect/gateway=1,/obj/effect/gibspawner=1,/obj/structure/cult/talisman=1,/obj/item/toy/crayon/red=2,
							  /obj/item/organ/internal/heart=2, /obj/effect/decal/cleanable/blood=4,/obj/structure/table/wood=2,/obj/item/weapon/ectoplasm=3,
							  /obj/item/clothing/head/helmet/space/cult=1, /obj/item/clothing/shoes/cult=1)

		if("wizden")
			theme = "wizden"
			walltypes = list(/turf/simulated/wall/mineral/plasma=3,/turf/simulated/mineral/random/high_chance=1)
			floortypes = list(/turf/simulated/floor/wood)
			treasureitems = list(/obj/item/weapon/veilrender/vealrender=2, /obj/item/weapon/spellbook/oneuse/blind=1,/obj/item/clothing/head/wizard/red=2,
							/obj/item/weapon/spellbook/oneuse/forcewall=1, /obj/item/weapon/spellbook/oneuse/smoke=1, /obj/structure/constructshell = 1, /obj/item/toy/katana=3,/obj/item/voodoo=3)
			fluffitems = list(/obj/structure/safe/floor=1,/obj/structure/dresser=1,/obj/item/weapon/storage/belt/soulstone=1,/obj/item/trash/candle=3,
							  /obj/item/weapon/dice=3,/obj/item/weapon/staff=2,/obj/effect/decal/cleanable/dirt=3,/obj/item/weapon/coin/mythril=3)

		if("cavein")
			theme = "cavein"
			walltypes = list(/turf/simulated/mineral/random/high_chance=1)
			floortypes = list(/turf/simulated/floor/plating/asteroid/airless, /turf/simulated/floor/plating/beach/sand)
			treasureitems = list(/obj/mecha/working/ripley/mining=1, /obj/item/weapon/pickaxe/drill/diamonddrill=2,/obj/item/weapon/gun/energy/kinetic_accelerator/hyper=1,
							/obj/item/weapon/resonator/upgraded=1, /obj/item/weapon/pickaxe/drill/jackhammer=5)
			fluffitems = list(/obj/effect/decal/cleanable/blood=3,/obj/effect/decal/remains/human=1,/obj/item/clothing/under/overalls=1,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/chili=1,/obj/item/weapon/tank/internals/oxygen/red=2)

		if("xenoden")
			theme = "xenoden"
			walltypes = list(/turf/simulated/mineral/random/high_chance=1)
			floortypes = list(/turf/simulated/floor/plating/asteroid/airless, /turf/simulated/floor/plating/beach/sand)
			treasureitems = list(/obj/item/clothing/mask/facehugger=1)
			fluffitems = list(/obj/effect/decal/remains/human=1,/obj/effect/decal/cleanable/xenoblood/xsplatter=5)

		if("hitech")
			theme = "hitech"
			walltypes = list(/turf/simulated/wall/r_wall=5,/turf/simulated/mineral/random=1)
			floortypes = list(/turf/simulated/floor/greengrid,/turf/simulated/floor/bluegrid)
			treasureitems = list(/obj/item/weapon/stock_parts/cell/hyper=1, /obj/machinery/chem_dispenser/constructable=1,/obj/machinery/computer/telescience=1, /obj/machinery/r_n_d/protolathe=1,
								/obj/machinery/biogenerator=1)
			fluffitems = list(/obj/structure/table/reinforced=2,/obj/item/weapon/stock_parts/scanning_module/phasic=3,
							  /obj/item/weapon/stock_parts/matter_bin/super=3,/obj/item/weapon/stock_parts/manipulator/pico=3,
							  /obj/item/weapon/stock_parts/capacitor/super=3,/obj/item/device/pda/clear=1, /obj/structure/mecha_wreckage/phazon=1)

		if("speakeasy")
			theme = "speakeasy"
			floortypes = list(/turf/simulated/floor/plasteel,/turf/simulated/floor/wood)
			treasureitems = list(/obj/item/weapon/melee/energy/sword/pirate=1,/obj/item/weapon/gun/projectile/revolver/doublebarrel=1,/obj/item/weapon/storage/backpack/satchel_flat=1,
			/obj/machinery/reagentgrinder=2, /obj/machinery/computer/security/wooden_tv=4, /obj/machinery/vending/coffee=3)
			fluffitems = list(/obj/structure/table/wood=2,/obj/structure/reagent_dispensers/beerkeg=1,/obj/item/stack/spacecash/c500=4,
							  /obj/item/weapon/reagent_containers/food/drinks/shaker=1,/obj/item/weapon/reagent_containers/food/drinks/bottle/wine=3,
							  /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey=3,/obj/item/clothing/shoes/laceup=2)

		if("plantlab")
			theme = "plantlab"
			treasureitems = list(/obj/item/weapon/gun/energy/floragun=1,/obj/item/seeds/novaflowerseed=2,/obj/item/seeds/bluespacetomatoseed=2,/obj/item/seeds/bluetomatoseed=2,
			/obj/item/seeds/coffee_robusta_seed=2, /obj/item/seeds/cashseed=2)
			fluffitems = list(/obj/structure/flora/kirbyplants=1,/obj/structure/table/reinforced=2,/obj/machinery/hydroponics/constructable=1,
							  /obj/effect/glowshroom/single=2,/obj/item/weapon/reagent_containers/syringe/charcoal=2,
							  /obj/item/weapon/reagent_containers/glass/bottle/diethylamine=3,/obj/item/weapon/reagent_containers/glass/bottle/ammonia=3)

		if("deadradio")
			theme = "deadradio"
			treasureitems = list(/obj/item/device/encryptionkey/binary=1,/obj/item/device/camera_bug=1)
			fluffitems = list(/obj/effect/decal/remains/human=1,/obj/item/device/radio/headset=2)

		if("bluespa")
			theme = "bluespa"
			floortypes = list(/turf/simulated/floor,/turf/simulated/floor/wood)
			treasureitems = list(/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/blue/bluespace=1,/obj/item/weapon/soap/deluxe=2)
			fluffitems = list(/obj/machinery/shower=2,/obj/item/weapon/bikehorn/rubberducky=1,/obj/structure/mirror=1)

		if("carpcave")
			theme = "carpcave"
			walltypes = list(/turf/simulated/mineral/random/high_chance=1)
			floortypes = list(/turf/simulated/floor/plating/beach/water)
			treasureitems = list(/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans=3,/mob/living/simple_animal/hostile/carp=1)
			fluffitems = list(/mob/living/simple_animal/crab=1,/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans=2)

		if("witch")
			theme = "witch"
			walltypes = list(/turf/simulated/wall/r_wall=1)
			floortypes = list(/turf/simulated/floor/wood)
			treasureitems = list(/obj/item/device/soulstone=1,/obj/item/weapon/reagent_containers/glass/bottle/wizarditis=1)
			fluffitems = list(/mob/living/simple_animal/pet/cat=1,/obj/item/weapon/staff/broom=1,/obj/item/clothing/head/wizard/marisa=1,/obj/item/clothing/suit/wizrobe/marisa=1)

		/*if("poly")
			theme = "poly"
			x_size = 5
			y_size = 5
			walltypes = list(/turf/simulated/wall/mineral/clown)
			floortypes= list(/turf/simulated/floor/engine)
			treasureitems = list(/obj/item/weapon/spellbook=1,/obj/mecha/combat/marauder=1,/obj/machinery/wish_granter=1)
			fluffitems = list(/obj/item/weapon/melee/energy/axe)*/

		if("monolith")
			theme = "monolith"
			walltypes = list(/turf/simulated/wall/cult=3,/turf/simulated/mineral/random/high_chance=1)
			floortypes = list(/turf/simulated/floor/plasteel/cult/airless)
			treasureitems = list(/obj/structure/monolith=1)
			fluffitems = list(/obj/effect/decal/remains/xeno=1,/obj/effect/decal/cleanable/xenoblood=3)
			x_size = 5
			y_size = 5
			areapoints = 25

	if(!monolith)
		possiblethemes -= theme //once a theme is selected, it's out of the running!

	var/floor = pick(floortypes)

	turfs = get_area_turfs(/area/mine/unexplored)

	if(!turfs.len)
		return 0

	while(!valid)//Finds some spots to place these rooms at, where they won't be spotted immediately.
		valid = 1
		sanity++
		if(sanity > 100)
			return 0

		T=pick(turfs)
		if(!T)
			return 0

		var/list/surroundings = list()

		surroundings += range(7, locate(T.x,T.y,T.z))
		surroundings += range(7, locate(T.x+x_size,T.y,T.z))
		surroundings += range(7, locate(T.x,T.y+y_size,T.z))
		surroundings += range(7, locate(T.x+x_size,T.y+y_size,T.z))

		if(locate(/area/mine/explored) in surroundings)
			valid = 0
			continue

		if(locate(/area/mine/abandoned) in surroundings)
			valid = 0
			continue

		if(locate(/turf/space) in surroundings)
			valid = 0
			continue

		if(locate(/area/asteroid/artifactroom) in surroundings)
			valid = 0
			continue

		if(locate(/turf/simulated/floor/plating/asteroid/airless) in range(5,T))//A little less strict than the other checks due to tunnels
			valid = 0
			continue

	if(!T)
		return 0

	room = spawn_room(T,x_size,y_size,walltypes,floor,) //WE'RE FINALLY CREATING THE ROOM

	if(room)//time to fill it with stuff
		var/list/emptyturfs = room["floors"]
		for(var/turf/simulated/floor/A in emptyturfs) //remove pls doesn't fix problem
			if(istype(A))
				spawn(2)
					A.fullUpdateMineralOverlays()
		T = pick(emptyturfs)
		if(T)
			new /obj/effect/glowshroom/single(T) //Just to make it a little more visible
			var/atom/surprise = null
			surprise = pickweight(treasureitems)
			var/atom/created = new surprise(T)//here's the prize
			emptyturfs -= T
			if(monolith)
				var/obj/structure/monolith/M = created
				M.make_artifact() // Here's your artifact!

			while(areapoints >= 10)//lets throw in the fluff items
				T = pick(emptyturfs)
				var/garbage = null
				garbage = pickweight(fluffitems)
				new garbage(T)
				areapoints -= 5
				emptyturfs -= T
			//world.log << "The [theme] themed [T.loc] has been created!"

	return 1