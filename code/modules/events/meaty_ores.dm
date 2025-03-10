/*
/datum/round_event_control/dust/meaty
	name = "Meaty Space Dust"
	typepath = /datum/round_event/dust/meaty
	weight = 10
	max_occurrences = 20
	earliest_start = 0

/datum/round_event/dust/meaty/announce()
	if(prob(16))
		priority_announce("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")
	else
		priorty_announce("Meaty ores have been detected on collision course with the station.", "Meaty Ore Alert")
		world << sound('sound/AI/meteors.ogg')

/datum/round_event/dust/meaty/setup()
	qnty = rand(45,125)

/datum/round_event/dust/meaty/start()
	while(qnty-- > 0)
		new /obj/effect/space_dust/meaty()
		if(prob(10))
			sleep(rand(10,15))

/obj/effect/space_dust/meaty
	icon = 'icons/mob/animal.dmi'
	icon_state = "cow"

	strength = 1
	life = 3

	Bump(atom/A)
		if(prob(20))
			spawn(1)
				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))
						shake_camera(M, 3, 1)
		if (A)
			playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
			walk(src,0)
			invisibility = 101
			new /obj/effect/decal/cleanable/blood(get_turf(A))
			if(ismob(A))
				A.meteorhit(src)
			else
				spawn(0)
					if(A)
						A.ex_act(strength)
					if(src)
						walk_towards(src,goal,1)
			life--
			if(!life)
				if(prob(80))
					gibs(loc)
					if(prob(45))
						new /obj/item/weapon/reagent_containers/food/snacks/meat(loc)
					else if(prob(10))
						explosion(get_turf(loc), 0, pick(0,1), pick(2,3), 0)
				else
					new /mob/living/simple_animal/cow(loc)

				del(src)
*/