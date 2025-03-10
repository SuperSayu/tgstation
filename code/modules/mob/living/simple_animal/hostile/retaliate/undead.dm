// This is important
/mob/living/attack_ghost(mob/dead/observer/user)
	if(prob(80)) return ..()
	var/found = 0
	for(var/mob/living/simple_animal/hostile/retaliate/R in range(4,src))
		if(("undead" in faction) || R == src || !prob(R.retaliate_chance)) continue
		found = 1
		R.enemies ^= src
		if(src in R.enemies)
			R.visible_message("[R]'s head swivels eerily towards [src].")
		else
			R.visible_message("[R] stares at [src] for a minute before turning away.")
			if(R.target == src)
				R.target = null
	if(!found)
		return ..()


/mob/living/simple_animal/hostile/retaliate/ghost
	icon = 'icons/mob/mob.dmi'
	name = "ghost"
	icon_state = "ghost2"
	icon_living = "ghost2"
	icon_dead = "ghost"
	density = 0 // ghost
	invisibility = 60 // no seriously ghost
	speak_chance = 0 // fyi, ghost
	retaliate_chance = 20

	response_help = "passes through" // by the way ghost
	response_disarm = "shoves"
	response_harm = "hits"
	turns_per_move = 10
	speed = -1
	maxHealth = 20
	health = 20

	harm_intent_damage = 10
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "grips"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15

	faction = list("undead") // did I mention ghost

/mob/living/simple_animal/hostile/retaliate/ghost/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/retaliate/ghost/FindTarget()
	. = ..()
	if(.)
		emote("wails at [.]")

/mob/living/simple_animal/hostile/retaliate/ghost/Life()
	if(target)
		invisibility = pick(0,0,60,invisibility)
	else
		invisibility = pick(0,60,60,invisibility)
	..()
/mob/living/simple_animal/hostile/retaliate/ghost/death()
	..()
	new /obj/item/weapon/ectoplasm(loc)
	Retaliate()
	del src
	return

/mob/living/simple_animal/hostile/retaliate/skeleton
	name = "skeleton"
	icon = 'icons/mob/human.dmi'
	icon_state = "skeleton_s"
	icon_living = "skeleton_s"
	icon_dead = "skeleton_l"
	speak_chance = 0
	turns_per_move = 10
	response_help = "shakes hands with"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	maxHealth = 20
	health = 20
	retaliate_chance = 30

	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15

	faction = list("undead")

/mob/living/simple_animal/hostile/retaliate/skeleton/death()
	..()
	new /obj/effect/decal/remains/human(loc)
	Retaliate()
	del src
	return

/mob/living/simple_animal/hostile/retaliate/zombie
	name = "zombie"
	icon = 'icons/mob/human.dmi'
	icon_state = "zombie_s"
	icon_living = "zombie_s"
	icon_dead = "zombie_l"
	speak_chance = 0
	turns_per_move = 10
	response_help = "gently prods"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	maxHealth = 20
	health = 20
	retaliate_chance = 10

	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("undead")

/mob/living/simple_animal/hostile/retaliate/zombie/death()
	..()
	new /obj/effect/decal/cleanable/blood/gibs/old(loc)
	Retaliate()
	del src
	return