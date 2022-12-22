/// pirate gang define, thanks mabel
/datum/pirate_gang/zetan
	name = "ZETAWEST ENFORCERS"

	ship_template_id = "zetan"
	ship_name_pool = "zetan_names"

	threat_title = "Hi"
	threat_content = "AND CAN YOU PLEASE GIVE US A LITTLE MONEY BEFORE THE SUN SETS ON OUR LIFES? \
		THE NIGHT IS LONG AND ALL WE HAVE THIS WORLD IS EACH OTHER. WE HAVE TO BUY WARM MILK \
		TO SOOTHE OUR ACHING STOMACS. $PAYOFF PLEASE OR YOURE FUCKED."
	possible_answers = list("Pay them off","Risk it all")

	response_received = "FUCK YES KID."
	response_too_late = "THANK YOU SO MUCH FOR YOUR OFFER BUT!"
	response_not_enough = "YOUR NAME IS CARVED ON A WALL IN HELL."

/// roles for zetans
/obj/effect/mob_spawn/ghost_role/human/pirate/zetan
	name = "alien sleeper"
	desc = "An alien sleeping. Maybe? Are they watching you?"
	flavour_text = "The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot.\
					And if you can't find enough cash there's always abducting people!"
	density = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	prompt_name = "a zetan cowboy"
	mob_species = /datum/species/abductor
	outfit = /datum/outfit/pirate/zetan
	rank = "Deputy"
	fluff_spawn = /obj/structure/showcase/machinery/oldpod/used
	name_beginnings = "zetan_beginnings"
	name_endings = "zetan_endings"

/obj/effect/mob_spawn/ghost_role/human/pirate/zetan/captain
	rank = "Sheriff"
	outfit = /datum/outfit/pirate/zetan/captain

/// outfits for zetan pirates
/datum/outfit/pirate/zetan
	name = "Zetan Deputy"

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/pirate
	uniform = /obj/item/clothing/under/abductor
	suit = /obj/item/clothing/suit/costume/pirate/armored
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/military/abductor
	ears = /obj/item/radio/headset/abductor
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/cowboy/black
	shoes = /obj/item/clothing/shoes/cowboy
	mask = /obj/item/clothing/mask/bandana/black
	r_hand = /obj/item/gun/zetan_revolver

/datum/outfit/pirate/zetan/captain
	name = "Zetan Lone Star"

	head = /obj/item/clothing/head/cowboy/white
	mask = /obj/item/clothing/mask/bandana/white
	belt = /obj/item/storage/belt/holster/zetan_pirate
	l_hand = /obj/item/gun/zetan_revolver // captain gets two guns

/// special items for zetan pirates
/obj/item/storage/belt/holster/zetan_pirate
	name = "zetan holster"
	desc = "An ancient holster that can be folded in on itself, even when holding objects in it. Only holds zetan revolvers. Or snacks."
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/belt/holster/zetan_pirate/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 3
	atom_storage.max_total_storage = WEIGHT_CLASS_NORMAL
	atom_storage.set_holdable(list(
		/obj/item/gun/zetan_revolver,
		/obj/item/food/
		))

/obj/item/gun/zetan_revolver
	name = "Pearlescent Revolver Z"
	desc = "The most sophisticated weapon you've ever seen. This revolver's trigger can only be pulled by those with the chunkiest fingers. Will never miss."
	icon = 'orbstation/icons/obj/weapons.dmi'
	lefthand_file = 'orbstation/icons/mob/left_inhand.dmi'
	righthand_file = 'orbstation/icons/mob/right_inhand.dmi'
	icon_state = "zetan_revolver"
	inhand_icon_state = "zetan_revolver"
	throwforce = 10
	throw_speed = 3
	fire_sound = 'sound/weapons/gun/revolver/shot_alt.ogg'
	fire_sound_volume = 90
	spread = 15
	fire_delay = 1 SECONDS
	pin = /obj/item/firing_pin/chunky_fingers
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/zetan_revolver/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/mm712x82/bouncy(src)

	AddComponent(/datum/component/boomerang, throw_range+2, TRUE)

/obj/item/gun/zetan_revolver/handle_chamber(empty_chamber, from_firing, chamber_next_round)
	chambered.newshot()

/// new firing pin that allows anyone with chunky fingers to SHOOT REVOLVER
/obj/item/firing_pin/chunky_fingers
	name = "chunky firing pin"
	icon_state = "firing_pin_ayy"
	desc = "This firing pin is huge, the idea of pulling this thing is intimidating."
	fail_message = "Fingers too puny!"

/obj/item/firing_pin/chunky_fingers/pin_auth(mob/living/user)
	if(HAS_TRAIT_NOT_FROM(user, TRAIT_CHUNKYFINGERS, RIGHT_ARM_TRAIT) && HAS_TRAIT_NOT_FROM(user, TRAIT_CHUNKYFINGERS, LEFT_ARM_TRAIT))
		return TRUE
	return (user.active_hand_index % 2) ? HAS_TRAIT_FROM(user, TRAIT_CHUNKYFINGERS, LEFT_ARM_TRAIT) : HAS_TRAIT_FROM(user, TRAIT_CHUNKYFINGERS, RIGHT_ARM_TRAIT)
