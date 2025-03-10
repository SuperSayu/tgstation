
/////////////////////////// DNA DATUM
/datum/dna
	var/unique_enzymes
	var/struc_enzymes
	var/uni_identity
	var/blood_type
	var/datum/species/species = new /datum/species/human() //The type of mutant race the player is if applicable (i.e. potato-man)
	var/list/features = list("FFF") //first value is mutant color
	var/real_name //Stores the real name of the person who originally got this dna datum. Used primarely for changelings,
	var/list/mutations = list()   //All mutations are from now on here
	var/list/temporary_mutations = list() //Timers for temporary mutations
	var/list/previous = list() //For temporary name/ui/ue/blood_type modifications
	var/mob/living/carbon/holder

/datum/dna/New(mob/living/carbon/new_holder)
	if(new_holder)
		holder = new_holder

/datum/dna/proc/transfer_identity(mob/living/carbon/destination, transfer_SE = 0)
	destination.dna.unique_enzymes = unique_enzymes
	destination.dna.uni_identity = uni_identity
	destination.dna.blood_type = blood_type
	destination.set_species(species.type, icon_update=0)
	destination.dna.features = features
	destination.dna.real_name = real_name
	destination.dna.temporary_mutations = temporary_mutations
	if(transfer_SE)
		destination.dna.struc_enzymes = struc_enzymes

/datum/dna/proc/copy_dna(datum/dna/new_dna)
	new_dna.unique_enzymes = unique_enzymes
	new_dna.struc_enzymes = struc_enzymes
	new_dna.uni_identity = uni_identity
	new_dna.blood_type = blood_type
	new_dna.features = features
	new_dna.species = new species.type
	new_dna.real_name = real_name
	new_dna.mutations = mutations

/datum/dna/proc/add_mutation(mutation_name)
	var/datum/mutation/human/HM = mutations_list[mutation_name]
	HM.on_acquiring(holder)

/datum/dna/proc/remove_mutation(mutation_name)
	var/datum/mutation/human/HM = mutations_list[mutation_name]
	HM.on_losing(holder)

/datum/dna/proc/check_mutation(mutation_name)
	var/datum/mutation/human/HM = mutations_list[mutation_name]
	return mutations.Find(HM)

/datum/dna/proc/remove_all_mutations()
	remove_mutation_group(mutations)

/datum/dna/proc/remove_mutation_group(list/group)
	if(!group)	return
	for(var/datum/mutation/human/HM in group)
		HM.force_lose(holder)

/datum/dna/proc/generate_uni_identity()
	. = ""
	var/list/L = new /list(DNA_UNI_IDENTITY_BLOCKS)

	L[DNA_GENDER_BLOCK] = construct_block((holder.gender!=MALE)+1, 2)
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		if(!hair_styles_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, hair_styles_list, hair_styles_male_list, hair_styles_female_list)
		L[DNA_HAIR_STYLE_BLOCK] = construct_block(hair_styles_list.Find(H.hair_style), hair_styles_list.len)
		L[DNA_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.hair_color)
		if(!facial_hair_styles_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, facial_hair_styles_list, facial_hair_styles_male_list, facial_hair_styles_female_list)
		L[DNA_FACIAL_HAIR_STYLE_BLOCK] = construct_block(facial_hair_styles_list.Find(H.facial_hair_style), facial_hair_styles_list.len)
		L[DNA_FACIAL_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.facial_hair_color)
		L[DNA_SKIN_TONE_BLOCK] = construct_block(skin_tones.Find(H.skin_tone), skin_tones.len)
		L[DNA_EYE_COLOR_BLOCK] = sanitize_hexcolor(H.eye_color)

	for(var/i=1, i<=DNA_UNI_IDENTITY_BLOCKS, i++)
		if(L[i])	. += L[i]
		else		. += random_string(DNA_BLOCK_SIZE,hex_characters)
	return .

/datum/dna/proc/generate_struc_enzymes()
	var/list/sorting = new /list(DNA_STRUC_ENZYMES_BLOCKS)
	var/result = ""
	for(var/datum/mutation/human/A in good_mutations + bad_mutations + not_good_mutations)
		if(A.name == RACEMUT && ismonkey(holder))
			sorting[A.dna_block] = num2hex(A.lowest_value + rand(0, 256 * 6), DNA_BLOCK_SIZE)
			mutations |= A
		else
			sorting[A.dna_block] = random_string(DNA_BLOCK_SIZE, list("0","1","2","3","4","5","6"))

	for(var/B in sorting)
		result += B
	return result

/datum/dna/proc/generate_unique_enzymes()
	. = ""
	if(istype(holder))
		real_name = holder.real_name
		. += md5(holder.real_name)
	else
		. += random_string(DNA_UNIQUE_ENZYMES_LEN, hex_characters)
	return .

/datum/dna/proc/update_ui_block(blocknumber)
	if(!blocknumber || !ishuman(holder))
		return
	var/mob/living/carbon/human/H = holder
	switch(blocknumber)
		if(DNA_HAIR_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.hair_color))
		if(DNA_FACIAL_HAIR_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.facial_hair_color))
		if(DNA_SKIN_TONE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(skin_tones.Find(H.skin_tone), skin_tones.len))
		if(DNA_EYE_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.eye_color))
		if(DNA_GENDER_BLOCK)
			setblock(uni_identity, blocknumber, construct_block((H.gender!=MALE)+1, 2))
		if(DNA_FACIAL_HAIR_STYLE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(facial_hair_styles_list.Find(H.facial_hair_style), facial_hair_styles_list.len))
		if(DNA_HAIR_STYLE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(hair_styles_list.Find(H.hair_style), hair_styles_list.len))

/datum/dna/proc/mutations_say_mods(message)
	if(message)
		for(var/datum/mutation/human/M in mutations)
			message = M.say_mod(message)
		return message

/datum/dna/proc/mutations_get_spans()
	var/list/spans = list()
	for(var/datum/mutation/human/M in mutations)
		spans |= M.get_spans()
	return spans

/datum/dna/proc/species_get_spans()
	var/list/spans = list()
	if(species)
		spans |= species.get_spans()
	return spans


/datum/dna/proc/is_same_as(datum/dna/D)
	if(uni_identity == D.uni_identity && struc_enzymes == D.struc_enzymes && real_name == D.real_name)
		if(species.type == D.species.type && features == D.features && blood_type == D.blood_type)
			return 1
	return 0

//used to update dna UI, UE, and dna.real_name.
/datum/dna/proc/update_dna_identity()
	uni_identity = generate_uni_identity()
	unique_enzymes = generate_unique_enzymes()

/datum/dna/proc/initialize_dna(newblood_type)
	if(newblood_type)
		blood_type = newblood_type
	unique_enzymes = generate_unique_enzymes()
	uni_identity = generate_uni_identity()
	struc_enzymes = generate_struc_enzymes()
	features = list("mcolor" = "FFF", "tail" = "Smooth", "snout" = "Round", "horns" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None")



/////////////////////////// DNA MOB-PROCS //////////////////////

/mob/proc/set_species(datum/species/mrace, icon_update = 1)
	return

/mob/living/carbon/set_species(datum/species/mrace, icon_update = 1)
	if(has_dna())
		if(dna.species.exotic_blood)
			var/datum/reagent/EB = dna.species.exotic_blood
			reagents.del_reagent(initial(EB.id))
		dna.species = new mrace()

/mob/living/carbon/human/set_species(datum/species/mrace, icon_update = 1)
	..()
	if(icon_update)
		update_body()
		update_hair()
		update_mutcolor()
		update_mutations_overlay()// no lizard with human hulk overlay please.


/mob/proc/has_dna()
	return

/mob/living/carbon/has_dna()
	return dna


/mob/living/carbon/human/proc/hardset_dna(ui, se, newreal_name, newblood_type, datum/species/mrace, newfeatures)

	if(newfeatures)
		dna.features = newfeatures

	if(mrace)
		set_species(mrace, icon_update=0)

	if(newreal_name)
		real_name = newreal_name
		dna.generate_unique_enzymes()

	if(newblood_type)
		dna.blood_type = newblood_type

	if(ui)
		dna.uni_identity = ui
		updateappearance(icon_update=0)

	if(se)
		dna.struc_enzymes = se
		domutcheck()

	if(mrace || newfeatures || ui)
		update_body()
		update_hair()
		update_mutcolor()
		update_mutations_overlay()


/mob/living/carbon/proc/create_dna()
	dna = new /datum/dna(src)
	if(!dna.species)
		dna.species = new /datum/species/human()

//proc used to update the mob's appearance after its dna UI has been changed
/mob/living/carbon/proc/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	if(!has_dna())
		return
	gender = (deconstruct_block(getblock(dna.uni_identity, DNA_GENDER_BLOCK), 2)-1) ? FEMALE : MALE

mob/living/carbon/human/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	..()
	var/structure = dna.uni_identity
	hair_color = sanitize_hexcolor(getblock(structure, DNA_HAIR_COLOR_BLOCK))
	facial_hair_color = sanitize_hexcolor(getblock(structure, DNA_FACIAL_HAIR_COLOR_BLOCK))
	skin_tone = skin_tones[deconstruct_block(getblock(structure, DNA_SKIN_TONE_BLOCK), skin_tones.len)]
	eye_color = sanitize_hexcolor(getblock(structure, DNA_EYE_COLOR_BLOCK))
	facial_hair_style = facial_hair_styles_list[deconstruct_block(getblock(structure, DNA_FACIAL_HAIR_STYLE_BLOCK), facial_hair_styles_list.len)]
	hair_style = hair_styles_list[deconstruct_block(getblock(structure, DNA_HAIR_STYLE_BLOCK), hair_styles_list.len)]
	if(icon_update)
		update_body()
		update_hair()
		if(mutcolor_update)
			update_mutcolor()
		if(mutations_overlay_update)
			update_mutations_overlay()


/mob/proc/domutcheck()
	return

/mob/living/carbon/domutcheck()
	if(!has_dna())
		return

	for(var/datum/mutation/human/A in good_mutations | bad_mutations | not_good_mutations)
		if(ismob(A.check_block(src)))
			return //we got monkeyized/humanized, this mob will be deleted, no need to continue.

	update_mutations_overlay()



/////////////////////////// DNA HELPER-PROCS //////////////////////////////
/proc/getleftblocks(input,blocknumber,blocksize)
	if(blocknumber > 1)
		return copytext(input,1,((blocksize*blocknumber)-(blocksize-1)))

/proc/getrightblocks(input,blocknumber,blocksize)
	if(blocknumber < (length(input)/blocksize))
		return copytext(input,blocksize*blocknumber+1,length(input)+1)

/proc/getblock(input, blocknumber, blocksize=DNA_BLOCK_SIZE)
	return copytext(input, blocksize*(blocknumber-1)+1, (blocksize*blocknumber)+1)

/proc/setblock(istring, blocknumber, replacement, blocksize=DNA_BLOCK_SIZE)
	if(!istring || !blocknumber || !replacement || !blocksize)	return 0
	return getleftblocks(istring, blocknumber, blocksize) + replacement + getrightblocks(istring, blocknumber, blocksize)

/proc/randmut(mob/living/carbon/M, list/candidates, difficulty = 2)
	if(!M.has_dna())
		return
	var/datum/mutation/human/num = pick(candidates)
	. = num.force_give(M)
	return

/proc/randmutb(mob/living/carbon/M)
	if(!M.has_dna())
		return
	var/datum/mutation/human/HM = pick((bad_mutations | not_good_mutations) - mutations_list[RACEMUT])
	. = HM.force_give(M)

/proc/randmutg(mob/living/carbon/M)
	if(!M.has_dna())
		return
	var/datum/mutation/human/HM = pick(good_mutations)
	. = HM.force_give(M)

/proc/randmuti(mob/living/carbon/M)
	if(!M.has_dna())
		return
	var/num = rand(1, DNA_UNI_IDENTITY_BLOCKS)
	var/newdna = setblock(M.dna.uni_identity, num, random_string(DNA_BLOCK_SIZE, hex_characters))
	M.dna.uni_identity = newdna
	return

/proc/clean_dna(mob/living/carbon/M)
	if(!M.has_dna())
		return
	M.dna.remove_all_mutations()

/proc/clean_randmut(mob/living/carbon/M, list/candidates, difficulty = 2)
	clean_dna(M)
	randmut(M, candidates, difficulty)

/proc/scramble_dna(mob/living/carbon/M, ui=FALSE, se=FALSE, probability)
	if(!M.has_dna())
		return 0
	if(se)
		for(var/i=1, i<=DNA_STRUC_ENZYMES_BLOCKS, i++)
			if(prob(probability))
				M.dna.struc_enzymes = setblock(M.dna.struc_enzymes, i, random_string(DNA_BLOCK_SIZE, hex_characters))
		M.domutcheck()
	if(ui)
		for(var/i=1, i<=DNA_UNI_IDENTITY_BLOCKS, i++)
			if(prob(probability))
				M.dna.uni_identity = setblock(M.dna.uni_identity, i, random_string(DNA_BLOCK_SIZE, hex_characters))
		M.updateappearance(mutations_overlay_update=1)
	return 1

//value in range 1 to values. values must be greater than 0
//all arguments assumed to be positive integers
/proc/construct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	if(value < 1)
		value = 1
	value = (value * width) - rand(1,width)
	return num2hex(value, blocksize)

//value is hex
/proc/deconstruct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	value = round(hex2num(value) / width) + 1
	if(value > values)
		value = values
	return value

/////////////////////////// DNA HELPER-PROCS
