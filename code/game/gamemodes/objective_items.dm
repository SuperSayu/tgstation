//Contains the target item datums for Steal objectives.

/datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/weapon/bikehorn		//typepath of the objective item
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)
	var/list/altitems = list()				//Items which can serve as an alternative to the objective (darn you blueprints)
	var/list/special_equipment = list()

	var/list/antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/objective_item/proc/add_objective()
	return src // some objectives need to be their own copy, some do not
// see if the objectives are the same, usually true

/datum/objective_item/proc/compare_to(datum/objective_item/i)
	return 1

/datum/objective_item/proc/find_duplicate(datum/mind/M)
	for(var/datum/objective/steal/s in M.objectives)
		if(s.targetinfo.targetitem == targetitem && compare_to(s.targetinfo))
			return s
	return null


/datum/objective_item/steal
	antag_types = list()

/datum/objective_item/steal/caplaser
	name = "the captain's antique laser gun"
	targetitem = /obj/item/weapon/gun/energy/laser/captain
	difficulty = 5
	excludefromjob = list("Captain")
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/steal/hoslaser
	name = "the head of security's personal laser gun"
	targetitem = /obj/item/weapon/gun/energy/gun/hos
	difficulty = 10
	excludefromjob = list("Head Of Security")
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/steal/handtele
	name = "a hand teleporter"
	targetitem = /obj/item/weapon/hand_tele
	difficulty = 5
	excludefromjob = list("Captain")
	antag_types = list("traitor","Changeling","Wizard")

/datum/objective_item/steal/jetpack
	name = "the Captain's jetpack"
	targetitem = /obj/item/weapon/tank/jetpack/oxygen/captain
	difficulty = 5
	excludefromjob = list("Captain")
	antag_types = list("traitor","Changeling","Wizard")

/datum/objective_item/steal/magboots
	name = "the chief engineer's advanced magnetic boots"
	targetitem =  /obj/item/clothing/shoes/magboots/advance
	difficulty = 5
	excludefromjob = list("Chief Engineer")
	antag_types = list("traitor","Changeling","Space Ninja")

/datum/objective_item/steal/capmedal
	name = "the medal of captaincy"
	targetitem = /obj/item/clothing/tie/medal/gold/captain
	difficulty = 5
	excludefromjob = list("Captain")

/datum/objective_item/steal/hypo
	name = "the hypospray"
	targetitem = /obj/item/weapon/reagent_containers/hypospray/CMO
	difficulty = 5
	excludefromjob = list("Chief Medical Officer")
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/steal/nukedisc
	name = "the nuclear authentication disk"
	targetitem = /obj/item/weapon/disk/nuclear
	difficulty = 5
	excludefromjob = list("Captain")
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/steal/reflector
	name = "a reflector vest"
	targetitem = /obj/item/clothing/suit/armor/laserproof
	difficulty = 3
	excludefromjob = list("Quartermaster","Cargo Technician","Head of Security", "Warden")
	antag_types = list("traitor","Changeling","Wizard")

/datum/objective_item/steal/reactive
	name = "the reactive teleport armor"
	targetitem = /obj/item/clothing/suit/armor/reactive
	difficulty = 5
	excludefromjob = list("Research Director")
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/steal/documents
	name = "any set of secret documents of any organization"
	targetitem = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's
	difficulty = 5
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/steal/nuke_core
	name = "the heavily radioactive plutonium core from the onboard self-destruct. Take care to wear the proper safety equipment when extracting the core"
	targetitem = /obj/item/nuke_core
	difficulty = 15
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/steal/nuke_core/New()
	special_equipment += /obj/item/weapon/storage/box/syndie_kit/nuke

//Items with special checks!
/datum/objective_item/steal/plasma
	name = "28 moles of plasma (full tank)"
	targetitem = /obj/item/weapon/tank
	difficulty = 3
	excludefromjob = list("Chief Engineer","Research Director","Station Engineer","Scientist","Atmospheric Technician")
	antag_types = list("traitor","Changeling","Space Ninja")

/datum/objective_item/steal/plasma/check_special_completion(obj/item/weapon/tank/T)
	var/target_amount = text2num(name)
	var/found_amount = 0
	found_amount += T.air_contents.toxins
	return found_amount>=target_amount


/datum/objective_item/steal/functionalai
	name = "a functional AI"
	targetitem = /obj/item/device/aicard
	difficulty = 30 //beyond the impossible
	antag_types = list("traitor","Changeling","Wizard")

/datum/objective_item/steal/functionalai/check_special_completion(obj/item/device/aicard/C)
	for(var/mob/living/silicon/ai/A in C)
		if(istype(A, /mob/living/silicon/ai) && A.stat != 2) //See if any AI's are alive inside that card.
			return 1
	return 0

/datum/objective_item/steal/blueprints
	name = "the station blueprints"
	targetitem = /obj/item/areaeditor/blueprints
	difficulty = 10
	excludefromjob = list("Chief Engineer")
	antag_types = list("traitor","Changeling","Space Ninja")
	altitems = list(/obj/item/weapon/photo)

/datum/objective_item/steal/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints))
		return 1
	if(istype(I, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/P = I
		if(P.blueprints)	//if the blueprints are in frame
			return 1
	return 0

/datum/objective_item/steal/slime
	name = "an unused sample of slime extract"
	targetitem = /obj/item/slime_extract
	difficulty = 3
	excludefromjob = list("Research Director","Scientist")
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/steal/slime/check_special_completion(obj/item/slime_extract/E)
	if(E.Uses > 0)
		return 1
	return 0

//Unique Objectives
/datum/objective_item/unique
	antag_types = list()

/datum/objective_item/unique/docs_red
	name = "the \"Red\" secret documents"
	targetitem = /obj/item/documents/syndicate/red
	difficulty = 10

/datum/objective_item/unique/docs_blue
	name = "the \"Blue\" secret documents"
	targetitem = /obj/item/documents/syndicate/blue
	difficulty = 10

//Old ninja objectives.
/datum/objective_item/special
	antag_types = list()

/datum/objective_item/special/pinpointer
	name = "the captain's pinpointer"
	targetitem = /obj/item/weapon/pinpointer
	difficulty = 10
	antag_types = list("traitor","Changeling","Wizard","Space Ninja")

/datum/objective_item/special/aegun
	name = "an advanced energy gun"
	targetitem = /obj/item/weapon/gun/energy/gun/nuclear
	difficulty = 10
	antag_types = list("Space Ninja")

/datum/objective_item/special/ddrill
	name = "a diamond drill"
	targetitem = /obj/item/weapon/pickaxe/drill/diamonddrill
	difficulty = 10
	antag_types = list("Space Ninja")

/datum/objective_item/special/boh
	name = "a bag of holding"
	targetitem = /obj/item/weapon/storage/backpack/holding
	difficulty = 10
	antag_types = list("Space Ninja")

/datum/objective_item/special/hypercell
	name = "a hyper-capacity cell"
	targetitem = /obj/item/weapon/stock_parts/cell/hyper
	difficulty = 5
	antag_types = list("Space Ninja")

/datum/objective_item/special/laserpointer
	name = "a laser pointer"
	targetitem = /obj/item/device/laser_pointer
	difficulty = 5
	antag_types = list("Space Ninja")

/datum/objective_item/special/telecomhub
	name =  "a telecom hub circuit board"
	targetitem = /obj/item/weapon/circuitboard/telecomms/hub
	difficulty = 15
	antag_types = list("Space Ninja")

//Stack objectives get their own subtype
/datum/objective_item/stack
	name = "5 cardboards"
	targetitem = /obj/item/stack/sheet/cardboard
	difficulty = 9001
	antag_types = list()

/datum/objective_item/stack/check_special_completion(obj/item/stack/S)
	var/target_amount = text2num(name)
	var/found_amount = 0

	if(istype(S, targetitem))
		found_amount = S.amount
	return found_amount>=target_amount

/datum/objective_item/stack/diamond
	name = "10 diamonds"
	targetitem = /obj/item/stack/sheet/mineral/diamond
	difficulty = 10
	antag_types = list("Space Ninja")

/datum/objective_item/stack/gold
	name = "50 gold bars"
	targetitem = /obj/item/stack/sheet/mineral/gold
	difficulty = 15
	antag_types = list("Space Ninja")

/datum/objective_item/stack/uranium
	name = "25 refined uranium bars"
	targetitem = /obj/item/stack/sheet/mineral/uranium
	difficulty = 10
	antag_types = list("Space Ninja")
