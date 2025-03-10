/*
 HUMANS
*/

/datum/species/human
	name = "Human"
	id = "human"
	desc = "Beings of flesh and bone who have colonized the majority of Nanotrasen-owned space. \
	Surprisingly versatile."
	default_color = "FFFFFF"
	roundstart = 1
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	mutant_bodyparts = list("tail_human", "ears")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None")
	use_skintones = 1


/datum/species/human/qualifies_for_rank(rank, list/features)
	if((!features["tail_human"] || features["tail_human"] == "None") && (!features["ears"] || features["ears"] == "None"))
		return 1	//Pure humans are always allowed in all roles.

	//Mutants are not allowed in most roles.
	if(rank in command_positions)
		return 0
	if(rank in security_positions) //This list does not include lawyers.
		return 0
	if(rank in science_positions)
		return 0
	if(rank in medical_positions)
		return 0
	if(rank in engineering_positions)
		return 0
	if(rank == "Quartermaster") //QM is not contained in command_positions but we still want to bar mutants from it.
		return 0
	return 1


/datum/species/human/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		H.set_species(/datum/species/jelly/slime)
		H.reagents.del_reagent(chem.type)
		H.faction |= "slime"
		return 1

//Curiosity killed the cat's wagging tail.
datum/species/human/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()

/*
 LIZARDPEOPLE
*/

/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Kokiyg"
	id = "lizard"
	desc = "The Kokiyg are coldblooded reptilian creatures known for their dexterity and perseverance."
	say_mod = "hisses"
	default_color = "00FF00"
	roundstart = 1
	specflags = list(MUTCOLORS,EYECOLOR,LIPS)
	mutant_bodyparts = list("tail_lizard", "snout", "spines", "horns", "frills", "body_markings")
	default_features = list("mcolor" = "0F0", "tail" = "Smooth", "snout" = "Round", "horns" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	species_temp_coeff = 0.5
	species_temp_offset = -20
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/lizard

/datum/species/lizard/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/lizard/qualifies_for_rank(rank, list/features)
	if(rank in command_positions)
		return 0
	return 1

/*
/datum/species/lizard/handle_speech(message)

	if(copytext(message, 1, 2) != "*")
		message = regEx_replaceall(message, "(?<!s)s(?!s)", "sss") //(?<!s) Not s before. (?!s) not s after. That way it only triples a single s instead of double ss.
		message = regEx_replaceall(message, "(?<!s)ss(?!s)", "ssss")
		message = regEx_replaceall(message, "(?<!S)S(?!S)", "SSS")
		message = regEx_replaceall(message, "(?<!S)SS(?!S)", "SSSS")

	return message
*/

//I wag in death
/datum/species/lizard/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()

/*
 PLANTPEOPLE
*/

/datum/species/plant
	// Creatures made of leaves and plant matter.
	name = "Chlorophyte"
	id = "plant"
	desc = "Made entirely of plant matter, the Chlorophytes are naturally free spirits, and do not care much for conformity."
	default_color = "59CE00"
	roundstart = 1
	specflags = list(MUTCOLORS,HAIR,FACEHAIR,EYECOLOR,NOPIXREMOVE)
	hair_luminosity = -115
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/plant

/datum/species/plant/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plantbgone")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/plant/on_hit(proj_type, mob/living/carbon/human/H)
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.rad_act(rand(30,80))
				H.Weaken(5)
				H.visible_message("<span class='warning'>[H] writhes in pain as \his vacuoles boil.</span>", "<span class='userdanger'>You writhe in pain as your vacuoles boil!</span>", "<span class='italics'>You hear the crunching of leaves.</span>")
				if(prob(80))
					randmutb(H)
				else
					randmutg(H)
				H.domutcheck()
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message("<span class='userdanger'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.nutrition = min(H.nutrition+30, NUTRITION_LEVEL_FULL)
	return

/*
 PODPEOPLE
*/

/datum/species/plant/pod
	// A mutation caused by a human being ressurected in a revival pod.
	// These regain health in light, and begin to wither in darkness.
	name = "Podperson"
	roundstart = 0
	//id = "pod" -- These use the same sprites now

/datum/species/plant/pod/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(10,T.get_lumcount()) - 5
		H.nutrition += light_amount
		if(H.nutrition > NUTRITION_LEVEL_FULL)
			H.nutrition = NUTRITION_LEVEL_FULL
		if(light_amount > 2) //if there's enough light, heal
			H.heal_overall_damage(1,1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/*
 SHADOWPEOPLE
*/

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = "shadow"
	darksight = 8
	invis_sight = SEE_INVISIBLE_MINIMUM
	sexes = 0
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	specflags = list(NOBREATH,NOBLOOD,RADIMMUNE)
	dangerous_existence = 1

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount()

		if(light_amount > 2) //if there's enough light, start dying
			H.take_overall_damage(1,1)
		else if (light_amount < 2) //heal in the dark
			H.heal_overall_damage(1,1)

/*
 JELLYPEOPLE
*/

/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "Xenobiological Jelly Entity"
	id = "jelly"
	default_color = "00FF90"
	say_mod = "chirps"
	eyes = "jelleyes"
	specflags = list(MUTCOLORS,EYECOLOR,NOBLOOD)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	var/recently_changed = 1

/datum/species/jelly/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD) //can't farm slime jelly from a dead slime/jelly person indefinitely
		return
	if(!H.reagents.get_reagent_amount("slimejelly"))
		if(recently_changed)
			H.reagents.add_reagent("slimejelly", 80)
			recently_changed = 0
		else
			H.reagents.add_reagent("slimejelly", 5)
			H.adjustBruteLoss(5)
			H << "<span class='danger'>You feel empty!</span>"

	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume < 100)
			if(H.nutrition >= NUTRITION_LEVEL_STARVING)
				H.reagents.add_reagent("slimejelly", 0.5)
				H.nutrition -= 2.5
		if(S.volume < 50)
			if(prob(5))
				H << "<span class='danger'>You feel drained!</span>"
		if(S.volume < 10)
			H.losebreath++

/datum/species/jelly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "slimejelly")
		return 1

/*
 SLIMEPEOPLE
*/

/datum/species/jelly/slime
	// Humans mutated by slime mutagen, produced from green slimes. They are not targetted by slimes.
	name = "Slimeperson"
	id = "slime"
	default_color = "00FFFF"
	darksight = 3
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD)
	say_mod = "says"
	eyes = "eyes"
	hair_color = "mutcolor"
	hair_alpha = 150
	ignored_by = list(/mob/living/simple_animal/slime)
	burnmod = 0.5
	coldmod = 2
	heatmod = 0.5

/datum/species/jelly/slime/spec_life(mob/living/carbon/human/H)
	if(recently_changed)
		var/datum/action/innate/split_body/S = new
		S.Grant(H)

	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume >= 200)
			if(prob(5))
				H << "<span class='notice'>You feel very bloated!</span>"
		if(S.volume < 200)
			if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
				H.reagents.add_reagent("slimejelly", 0.5)
				H.nutrition -= 2.5

	..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_ALIVE
	button_icon_state = "slimesplit"
	background_icon_state = "bg_alien"

/datum/action/innate/split_body/CheckRemoval()
	var/mob/living/carbon/human/H = owner
	if(!ishuman(H) || !H.dna || !H.dna.species || H.dna.species.id != "slime")
		return 1
	return 0

/datum/action/innate/split_body/Activate()
	var/mob/living/carbon/human/H = owner
	H << "<span class='notice'>You focus intently on moving your body while standing perfectly still...</span>"
	H.notransform = 1
	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume >= 200)
			var/mob/living/carbon/human/spare = new /mob/living/carbon/human(H.loc)
			spare.underwear = "Nude"
			H.dna.transfer_identity(spare, transfer_SE=1)
			H.dna.features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
			spare.real_name = spare.dna.real_name
			spare.name = spare.dna.real_name
			spare.updateappearance(mutcolor_update=1)
			spare.domutcheck()
			spare.Move(get_step(H.loc, pick(NORTH,SOUTH,EAST,WEST)))
			S.volume = 80
			H.notransform = 0
			var/datum/action/innate/swap_body/callforward = new /datum/action/innate/swap_body()
			var/datum/action/innate/swap_body/callback = new /datum/action/innate/swap_body()
			callforward.body = spare
			callforward.Grant(H)
			callback.body = H
			callback.Grant(spare)
			H.mind.transfer_to(spare)
			spare << "<span class='notice'>...and after a moment of disorentation, you're besides yourself!</span>"
			return

	H << "<span class='warning'>...but there is not enough of you to go around! You must attain more mass to split!</span>"
	H.notransform = 0

/datum/action/innate/swap_body
	name = "Swap Body"
	check_flags = AB_CHECK_ALIVE
	button_icon_state = "slimeswap"
	background_icon_state = "bg_alien"
	var/mob/living/carbon/human/body

/datum/action/innate/swap_body/CheckRemoval()
	var/mob/living/carbon/human/H = owner
	if(!ishuman(H) || !H.dna || !H.dna.species || H.dna.species.id != "slime")
		return 1
	return 0

/datum/action/innate/swap_body/Activate()
	if(!body || !istype(body) || !body.dna || !body.dna.species || body.dna.species.id != "slime" || body.stat == DEAD || qdeleted(body))
		owner << "<span class='warning'>Something is wrong, you cannot sense your other body!</span>"
		Remove(owner)
		return
	if(body.stat == UNCONSCIOUS)
		owner << "<span class='warning'>You sense this body has passed out for some reason. Best to stay away.</span>"
		return

	owner.mind.transfer_to(body)


/datum/species/jelly_sayu
	name = "Xenoid"
	id = "xenoid"
	desc = "The three-eyed Xenoids hail from the outer reaches of the galaxy. They are vulnerable to water, but are also resistant to cellular damage."
	default_color = "00FF90"
	roundstart = 1
	eyes = "jelleyes"
	eyecount = 3
	specflags = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR)
	hair_color = "mutcolor"
	hair_alpha = 195
	hair_luminosity = -75
	bone_chance_adjust = 1.2
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime

/datum/species/jelly_sayu/before_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	if(H.job == "Quartermaster" || H.job == "Captain" || H.job == "Head of Personnel")
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sunglasses3(H), slot_glasses)
	if(H.job == "Head of Security" || H.job == "Warden")
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses/sunglasses3(H), slot_glasses)

/datum/species/jelly_sayu/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "water")	// DANGER
		if(H.reagents.has_reagent("water", 10))
			H.adjustToxLoss(1)
		H.reagents.remove_reagent(chem.id, 0.8)
		return 1

/datum/species/jelly_sayu/spec_life(mob/living/carbon/human/H)
	if(H.getCloneLoss()) // clone loss is slowly regenerated
		H.adjustCloneLoss(-0.2)

/*
 GOLEMS
*/

/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "golem"
	sexes = 0
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE)
	speedmod = 3
	armor = 55
	siemens_coeff = 0
	punchmod = 5
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform)
	nojumpsuit = 1
	bone_chance_adjust = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem

/*
 ADAMANTINE GOLEMS
*/

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine

/*
 FLIES
*/

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.
	name = "Human?"
	id = "fly"
	say_mod = "buzzes"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/fly

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/fly/handle_speech(message)
	return replacetext(message, "z", stutter("zz"))

/*
 SKELETONS
*/

/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	say_mod = "rattles"
	need_nutrition = 0
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(NOBREATH,HEATRES,COLDRES,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE)
	var/list/myspan = null


/datum/species/skeleton/New()
	..()
	myspan = list(pick(SPAN_SANS,SPAN_PAPYRUS)) //pick a span and stick with it for the round


/datum/species/skeleton/get_spans()
	return myspan


/*
 ZOMBIES
*/

/datum/species/zombie
	// 1spooky
	name = "Brain-Munching Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	specflags = list(NOBREATH,HEATRES,COLDRES,NOBLOOD,RADIMMUNE)

/datum/species/zombie/handle_speech(message)
	var/list/message_list = text2list(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, length(inserttext) - 2) == "..."))
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("BRAINS", "Brains", "Braaaiinnnsss", "BRAAAIIINNSSS")]...")

	return list2text(message_list, " ")

/datum/species/cosmetic_zombie
	name = "Human"
	id = "zombie"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie

/*
 AXOLOTL PEOPLE -- WIP IN PROGRESS
*/

/*/datum/species/axolotl
	// The Lotyn are a race of axolotl-like aliens who are known for being religious, although a handful of them have rejected
	// their customs.

	name = "Lotyn"
	id = "axolotl"
	roundstart = 1
	specflags = list(MUTCOLORS,EYECOLOR,LIPS,NOPIXREMOVE)
	default_color = "#EC88FF"

/datum/species/axolotl/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "holywater")	// holy water acts as ryetalyn
		H.mutations = list()
		H.disabilities = 0
		H.sdisabilities = 0
		H.update_mutations()
		H.reagents.remove_reagent(chem.id, 2) // metabolizes faster
		return 1*/

/*
 BIRD PEOPLE -- ALSO A WIP IN PROGRESS
 */

/*/datum/species/bird
	name = "Aven"
	id = "bird"
	desc = "Stuff goes here."
	specflags = list(HAIR,MUTCOLORS,EYECOLOR)
	say_mod = "hisses"
	spec_hair = 1
	hair_color = "mutcolor"
	speedmod = -1
	no_equip = list(slot_wear_mask, slot_shoes)
	roundstart = 1

/*/datum/species/bird/before_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	H.equip_to_slot(new /obj/item/weapon/tank/co2(H), slot_r_store)
	H.equip_to_slot(new /obj/item/clothing/mask/breath(H), slot_wear_mask)*/

/datum/species/bird/after_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	if(H.job == "Head of Security" || H.job == "Warden" || H.job == "Security Officer")
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), slot_shoes)
	else
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)*/

/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	darksight = 3
	say_mod = "gibbers"
	sexes = 0
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(NOBLOOD,NOBREATH,VIRUSIMMUNE)
	var/scientist = 0 // vars to not pollute spieces list with castes
	var/agent = 0
	var/team = 1

/datum/species/abductor/handle_speech(message)
	//Hacks
	var/mob/living/carbon/human/user = usr
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.dna.species.id != "abductor")
			continue
		else
			var/datum/species/abductor/target_spec = H.dna.species
			if(target_spec.team == team)
				H << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
				//return - technically you can add more aliens to a team
	for(var/mob/M in dead_mob_list)
		M << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
	return ""


var/global/image/plasmaman_on_fire = image("icon"='icons/mob/OnFire.dmi', "icon_state"="plasmaman")

/datum/species/plasmaman
	name = "Plasmaman"
	id = "plasmaman"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/stack/sheet/mineral/plasma
	desc = "A skeletal species, who need plasma to live. Without their suits, oxygen sets them on fire."
	specflags = list(NOBLOOD,RADIMMUNE,NOTRANSSTING)
	safe_oxygen_min = 0 //We don't breath this
	safe_toxins_min = 16 //We breath THIS!
	safe_toxins_max = 0
	dangerous_existence = 1 //So so much
	need_nutrition = 0 //Hard to eat through a helmet
	burnmod = 2
	heatmod = 2
	speedmod = 1
	var/skin = 0

/datum/species/plasmaman/skin
	name = "Skinbone"
	skin = 1
	roundstart = 0

/datum/species/plasmaman/update_base_icon_state(mob/living/carbon/human/H)
	var/base = ..()
	if(base == id && !skin)
		base = "[base]_m"
	else
		base = "skinbone_m"
	return base

/datum/species/plasmaman/spec_life(mob/living/carbon/human/H)
	var/datum/gas_mixture/environment = H.loc.return_air()

	if(!istype(H.w_uniform, /obj/item/clothing/under/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/plasmaman))
		if(environment)
			var/total_moles = environment.total_moles()
			if(total_moles)
				if((environment.oxygen /total_moles) >= 0.01)
					H.adjust_fire_stacks(0.5)
					if(!H.on_fire && H.fire_stacks > 0)
						H.visible_message("<span class='danger'>[H]'s body reacts with the atmosphere and bursts into flames!</span>","<span class='userdanger'>Your body reacts with the atmosphere and bursts into flame!</span>")
					H.IgniteMob()
	else
		if(H.fire_stacks)
			var/obj/item/clothing/under/plasmaman/P = H.w_uniform
			if(istype(P))
				P.Extinguish(H)
	H.update_fire()

/datum/species/plasmaman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/datum/outfit/plasmaman/O = new /datum/outfit/plasmaman
	H.equipOutfit(O, visualsOnly)
	return 0

/datum/species/plasmaman/qualifies_for_rank(rank, list/features)
	if(rank in command_positions)
		return 0
	if(rank in security_positions)
		return 0
	if(rank == "Clown" || rank == "Mime")//No funny bussiness
		return 0
	return 1




var/global/list/synth_flesh_disguises = list()

/datum/species/synth
	name = "Synth" //inherited from the real species, for health scanners and things
	id = "synth"
	say_mod = "beep boops" //inherited from a user's real species
	sexes = 0
	specflags = list(NOTRANSSTING,NOBREATH,VIRUSIMMUNE) //all of these + whatever we inherit from the real species
	safe_oxygen_min = 0
	safe_toxins_min = 0
	safe_toxins_max = 0
	safe_co2_max = 0
	SA_para_min = 0
	SA_sleep_min = 0
	dangerous_existence = 1
	need_nutrition = 0 //beep boop robots do not need sustinance
	meat = null
	var/list/initial_specflags = list(NOTRANSSTING,NOBREATH,VIRUSIMMUNE) //for getting these values back for assume_disguise()
	var/disguise_fail_health = 75 //When their health gets to this level their synthflesh partially falls off
	var/image/damaged_synth_flesh = null //an image to display when we're below disguise_fail_health
	var/datum/species/fake_species = null //a species to do most of our work for us, unless we're damaged


/datum/species/synth/military
	name = "Military Synth"
	id = "military_synth"
	armor = 25
	punchmod = 10
	disguise_fail_health = 50


/datum/species/synth/admin_set_species(mob/living/carbon/human/H, old_species)
	assume_disguise(old_species,H)


/datum/species/synth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "synthflesh")
		chem.reaction_mob(H, TOUCH, 2 ,0) //heal a little
		handle_disguise(H) //and update flesh disguise
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1


/datum/species/synth/proc/assume_disguise(datum/species/S, mob/living/carbon/human/H)
	if(S && !istype(S, type))
		name = S.name
		say_mod = S.say_mod
		sexes = S.sexes
		specflags = initial_specflags.Copy()
		specflags.Add(S.specflags)
		attack_verb = S.attack_verb
		attack_sound = S.attack_sound
		miss_sound = S.miss_sound
		meat = S.meat
		mutant_bodyparts = S.mutant_bodyparts.Copy()
		default_features = S.default_features.Copy()
		nojumpsuit = S.nojumpsuit
		no_equip = S.no_equip.Copy()
		fake_species = new S.type
	else
		name = initial(name)
		say_mod = initial(say_mod)
		specflags = initial_specflags.Copy()
		attack_verb = initial(attack_verb)
		attack_sound = initial(attack_sound)
		miss_sound = initial(miss_sound)
		mutant_bodyparts = list()
		default_features = list()
		nojumpsuit = initial(nojumpsuit)
		no_equip = list()
		qdel(fake_species)
		fake_species = null
		meat = initial(meat)

	build_disguise(H)
	handle_disguise(H)


/datum/species/synth/proc/build_disguise(mob/living/carbon/human/H)
	var/base = ""
	if(fake_species)
		base = fake_species.update_base_icon_state(H)
		if(synth_flesh_disguises[base])
			damaged_synth_flesh = synth_flesh_disguises[base]
		else
			var/icon/base_flesh = icon(H.icon,"[base]_s")
			var/icon/damage = icon(H.icon,"synthflesh_damage")
			base_flesh.Blend(damage,ICON_MULTIPLY) //damage the skin
			damaged_synth_flesh = image(icon = base_flesh, layer= -SPECIES_LAYER)
			synth_flesh_disguises[base] = damaged_synth_flesh
	else
		damaged_synth_flesh = null


/datum/species/synth/proc/handle_disguise(mob/living/carbon/human/H)
	if(H)
		H.updatehealth()
		var/add_overlay = FALSE
		if(H.health < disguise_fail_health)
			//clear these out, they look weird
			H.underwear = ""
			H.undershirt = ""
			H.socks = ""
			add_overlay = TRUE
		else
			H.overlays -= damaged_synth_flesh
			if(H.overlays_standing[SPECIES_LAYER] == damaged_synth_flesh)
				H.overlays_standing[SPECIES_LAYER] = null

		H.regenerate_icons()
		if(add_overlay)
			H.remove_overlay(SPECIES_LAYER)

			//Copy and colour the image for coloured species
			var/image/I = image(layer = -SPECIES_LAYER)
			I.appearance = damaged_synth_flesh.appearance
			if(MUTCOLORS in specflags)
				I.color = "#[H.dna.features["mcolor"]]"
			damaged_synth_flesh = I

			H.overlays_standing[SPECIES_LAYER] = damaged_synth_flesh
			H.apply_overlay(SPECIES_LAYER)



/datum/species/synth/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	. = ..()
	handle_disguise(H)


//Proc redirects:
//Passing procs onto the fake_species, to ensure we look as much like them as possible

/datum/species/synth/update_base_icon_state(mob/living/carbon/human/H)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			return fake_species.update_base_icon_state(H)
		else
			return ..()
	else
		. = ..()

/datum/species/synth/update_color(mob/living/carbon/human/H, forced_colour)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			fake_species.update_color(H, forced_colour)


/datum/species/synth/handle_hair(mob/living/carbon/human/H, forced_colour)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			fake_species.handle_hair(H, forced_colour)


/datum/species/synth/handle_body(mob/living/carbon/human/H)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			fake_species.handle_body(H)


/datum/species/synth/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			fake_species.handle_body(H,forced_colour)


/datum/species/synth/get_spans()
	if(fake_species)
		return fake_species.get_spans()
	return list()


/datum/species/synth/handle_speech(message, mob/living/carbon/human/H)
	H.updatehealth()
	if(H.health > disguise_fail_health)
		if(fake_species)
			return fake_species.handle_speech(message,H)
		else
			return ..()
	else
		return ..()
