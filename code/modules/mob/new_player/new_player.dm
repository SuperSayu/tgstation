//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/mob/new_player
	var/ready = 0
	var/spawning = 0//Referenced when you want to delete the new_player later on in the code.

	flags = NONE

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around

/mob/new_player/New()
	tag = "mob_[next_mob_id++]"
	mob_list += src

/mob/new_player/proc/new_player_panel()

	var/output = "<center><p><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A></p>"

	if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
		if(ready)
			output += "<p>\[ <b>Ready</b> | <a href='byond://?src=\ref[src];ready=0'>Not Ready</a> \]</p>"
		else
			output += "<p>\[ <a href='byond://?src=\ref[src];ready=1'>Ready</a> | <b>Not Ready</b> \]</p>"

	else
		output += "<p><a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A></p>"
		output += "<p><a href='byond://?src=\ref[src];late_join=1'>Join Game!</A></p>"

	output += "<p><a href='byond://?src=\ref[src];observe=1'>Observe</A></p>"

	if(!IsGuestKey(src.key))
		establish_db_connection()

		if(dbcon.IsConnected())
			var/isadmin = 0
			if(src.client && src.client.holder)
				isadmin = 1
			var/DBQuery/query = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_question")] WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime AND id NOT IN (SELECT pollid FROM [format_table_name("poll_vote")] WHERE ckey = \"[ckey]\") AND id NOT IN (SELECT pollid FROM [format_table_name("poll_textreply")] WHERE ckey = \"[ckey]\")")
			query.Execute()
			var/newpoll = 0
			while(query.NextRow())
				newpoll = 1
				break

			if(newpoll)
				output += "<p><b><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A> (NEW!)</b></p>"
			else
				output += "<p><a href='byond://?src=\ref[src];showpoll=1'>Show Player Polls</A></p>"

	output += "</center>"

	//src << browse(output,"window=playersetup;size=210x240;can_close=0")
	var/datum/browser/popup = new(src, "playersetup", "<div align='center'>New Player Options</div>", 220, 265)
	popup.set_window_options("can_close=0")
	popup.set_content(output)
	popup.open(0)
	return

/mob/new_player/Stat()
	..()

	if(statpanel("Lobby"))
		stat("Game Mode:", (ticker.hide_mode) ? "Secret" : "[master_mode]")
		stat("Map:", MAP_NAME)

		if(ticker.current_state == GAME_STATE_PREGAME)
			stat("Time To Start:", (ticker.timeLeft >= 0) ? "[round(ticker.timeLeft / 10)]s" : "DELAYED")

			stat("Players:", "[ticker.totalPlayers]")
			if(client.holder)
				stat("Players Ready:", "[ticker.totalPlayersReady]")

/mob/new_player/Topic(href, href_list[])
	if(src != usr)
		return 0

	if(!client)	return 0

	//Determines Relevent Population Cap
	var/relevant_cap
	if(config.hard_popcap && config.extreme_popcap)
		relevant_cap = min(config.hard_popcap, config.extreme_popcap)
	else
		relevant_cap = max(config.hard_popcap, config.extreme_popcap)

	if(href_list["show_preferences"])
		client.prefs.ShowChoices(src)
		return 1

	if(href_list["ready"])
		if(!ticker || ticker.current_state <= GAME_STATE_PREGAME) // Make sure we don't ready up after the round has started
			ready = text2num(href_list["ready"])
		else
			ready = 0

	if(href_list["refresh"])
		src << browse(null, "window=playersetup") //closes the player setup window
		new_player_panel()

	if(href_list["observe"])

		if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
			if(!client)	return 1
			var/mob/dead/observer/observer = new()

			spawning = 1

			observer.started_as_observer = 1
			close_spawn_windows()
			var/obj/O = locate("landmark*Observer-Start")
			src << "<span class='notice'>Now teleporting.</span>"
			if (O)
				observer.loc = O.loc
			else
				src << "<span class='notice'>Teleporting failed. You should be able to use ghost verbs to teleport somewhere useful</span>"
			if(client.prefs.be_random_name)
				client.prefs.real_name = random_unique_name(gender)
			if(client.prefs.be_random_body)
				client.prefs.random_character(gender)
			observer.real_name = client.prefs.real_name
			observer.name = observer.real_name
			observer.key = key
			observer.stopLobbySound()
			qdel(mind)

			qdel(src)
			return 1

	if(href_list["late_join"])
		if(!ticker || ticker.current_state != GAME_STATE_PLAYING)
			usr << "<span class='danger'>The round is either not ready, or has already finished...</span>"
			return

		if(href_list["late_join"] == "override")
			LateChoices()
			return

		if(ticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(key) in admin_datums)))
			usr << "<span class='danger'>[config.hard_popcap_message]</span>"

			var/queue_position = ticker.queued_players.Find(usr)
			if(queue_position == 1)
				usr << "<span class='notice'>You are next in line to join the game. You will be notified when a slot opens up.</span>"
			else if(queue_position)
				usr << "<span class='notice'>There are [queue_position-1] players in front of you in the queue to join the game.</span>"
			else
				ticker.queued_players += usr
				usr << "<span class='notice'>You have been added to the queue to join the game. Your position in queue is [ticker.queued_players.len].</span>"
			return
		LateChoices()

	if(href_list["manifest"])
		ViewManifest()

	if(href_list["SelectedJob"])

		if(!enter_allowed)
			usr << "<span class='notice'>There is an administrative lock on entering the game!</span>"
			return

		if(ticker.queued_players.len && !(ckey(key) in admin_datums))
			if((living_player_count() >= relevant_cap) || (src != ticker.queued_players[1]))
				usr << "<span class='warning'>Server is full.</span>"
				return

		AttemptLateSpawn(href_list["SelectedJob"])
		return

	if(!ready && href_list["preference"])
		if(client)
			client.prefs.process_link(src, href_list)
	else if(!href_list["late_join"])
		new_player_panel()

	if(href_list["showpoll"])
		handle_player_polling()
		return

	if(href_list["pollid"])
		var/pollid = href_list["pollid"]
		if(istext(pollid))
			pollid = text2num(pollid)
		if(isnum(pollid))
			src.poll_player(pollid)
		return

	if(href_list["votepollid"] && href_list["votetype"])
		var/pollid = text2num(href_list["votepollid"])
		var/votetype = href_list["votetype"]
		switch(votetype)
			if(POLLTYPE_OPTION)
				var/optionid = text2num(href_list["voteoptionid"])
				vote_on_poll(pollid, optionid)
			if(POLLTYPE_TEXT)
				var/replytext = href_list["replytext"]
				log_text_poll_reply(pollid, replytext)
			if(POLLTYPE_RATING)
				var/id_min = text2num(href_list["minid"])
				var/id_max = text2num(href_list["maxid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					usr << "The option ID difference is too big. Please contact administration or the database admin."
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["o[optionid]"]))	//Test if this optionid was replied to
						var/rating
						if(href_list["o[optionid]"] == "abstain")
							rating = null
						else
							rating = text2num(href_list["o[optionid]"])
							if(!isnum(rating))
								return

						vote_on_numval_poll(pollid, optionid, rating)
			if(POLLTYPE_MULTI)
				var/id_min = text2num(href_list["minoptionid"])
				var/id_max = text2num(href_list["maxoptionid"])

				if( (id_max - id_min) > 100 )	//Basic exploit prevention
					usr << "The option ID difference is too big. Please contact administration or the database admin."
					return

				for(var/optionid = id_min; optionid <= id_max; optionid++)
					if(!isnull(href_list["option_[optionid]"]))	//Test if this optionid was selected
						vote_on_poll(pollid, optionid, 1)

/mob/new_player/proc/IsJobAvailable(rank)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)
		return 0
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		if(job.title == "Assistant")
			if(isnum(client.player_age) && client.player_age <= 14) //Newbies can always be assistants
				return 1
			for(var/datum/job/J in SSjob.occupations)
				if(J && J.current_positions < J.total_positions && J.title != job.title)
					return 0
		else
			return 0
	if(jobban_isbanned(src,rank))
		return 0
	if(!job.player_old_enough(src.client))
		return 0
	if(config.enforce_human_authority && !client.prefs.pref_species.qualifies_for_rank(rank, client.prefs.features))
		return 0
	return 1


/mob/new_player/proc/AttemptLateSpawn(rank)
	if(!IsJobAvailable(rank))
		src << alert("[rank] is not available. Please try another.")
		return 0

	//Remove the player from the join queue if he was in one and reset the timer
	ticker.queued_players -= src
	ticker.queue_delay = 4

	SSjob.AssignRole(src, rank, 1)

	var/mob/living/carbon/human/character = create_character()	//creates the human and transfers vars and mind
	SSjob.EquipRank(character, rank, 1)					//equips the human

	var/D = pick(latejoin)
	if(!D)
		for(var/turf/T in get_area_turfs(/area/shuttle/arrival))
			if(!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					D = T
					continue

	character.loc = D

	if(character.mind.assigned_role != "Cyborg")
		data_core.manifest_inject(character)
		ticker.minds += character.mind//Cyborgs and AIs handle this in the transform proc.	//TODO!!!!! ~Carn
		AnnounceArrival(character, rank)
	else
		character.Robotize()

	joined_player_list += character.ckey

	if(config.allow_latejoin_antagonists)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_RECALL, SHUTTLE_IDLE)
				ticker.mode.make_antag_chance(character)
			if(SHUTTLE_CALL)
				if(SSshuttle.emergency.timeLeft(1) > initial(SSshuttle.emergencyCallTime)*0.5)
					ticker.mode.make_antag_chance(character)
	qdel(src)

/mob/new_player/proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank)
	if (ticker.current_state == GAME_STATE_PLAYING)
		if(announcement_systems.len)
			if(character.mind)
				if((character.mind.assigned_role != "Cyborg") && (character.mind.assigned_role != character.mind.special_role))
					var/obj/machinery/announcement_system/announcer = pick(announcement_systems)
					announcer.announce("ARRIVAL", character.real_name, rank, list()) //make the list empty to make it announce it in common

/mob/new_player/proc/LateChoices()
	var/mills = world.time // 1/10 of a second, not real milliseconds but whatever
	//var/secs = ((mills % 36000) % 600) / 10 //Not really needed, but I'll leave it here for refrence.. or something
	var/mins = (mills % 36000) / 600
	var/hours = mills / 36000

	var/dat = "<div class='notice'>Round Duration: [round(hours)]h [round(mins)]m</div>"

	switch(SSshuttle.emergency.mode)
		if(SHUTTLE_ESCAPE)
			dat += "<div class='notice red'>The station has been evacuated.</div><br>"
		if(SHUTTLE_CALL)
			if(!SSshuttle.canRecall())
				dat += "<div class='notice red'>The station is currently undergoing evacuation procedures.</div><br>"

	var/available_job_count = 0
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobAvailable(job.title))
			available_job_count++;

	dat += "<div class='clearBoth'>Choose from the following open positions:</div><br>"
	dat += "<div class='jobs'><div class='jobsColumn'>"
	var/job_count = 0
	for(var/datum/job/job in SSjob.occupations)
		if(job && IsJobAvailable(job.title))
			job_count++;
			if (job_count > round(available_job_count / 2))
				dat += "</div><div class='jobsColumn'>"
			var/position_class = "otherPosition"
			if (job.title in command_positions)
				position_class = "commandPosition"
			dat += "<a class='[position_class]' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
	if(!job_count) //if there's nowhere to go, assistant opens up.
		for(var/datum/job/job in SSjob.occupations)
			if(job.title != "Assistant") continue
			dat += "<a class='otherPosition' href='byond://?src=\ref[src];SelectedJob=[job.title]'>[job.title] ([job.current_positions])</a><br>"
			break
	dat += "</div></div>"

	// Removing the old window method but leaving it here for reference
	//src << browse(dat, "window=latechoices;size=300x640;can_close=1")

	// Added the new browser window method
	var/datum/browser/popup = new(src, "latechoices", "Choose Profession", 440, 500)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	popup.set_content(dat)
	popup.open(0) // 0 is passed to open so that it doesn't use the onclose() proc


/mob/new_player/proc/create_character()
	spawning = 1
	close_spawn_windows()

	var/mob/living/carbon/human/new_character = new(loc)

	if(config.force_random_names || appearance_isbanned(src))
		client.prefs.random_character()
		client.prefs.real_name = client.prefs.pref_species.random_name(gender,1)
	client.prefs.copy_to(new_character)
	new_character.dna.update_dna_identity()
	if(mind)
		mind.active = 0					//we wish to transfer the key manually
		mind.transfer_to(new_character)					//won't transfer key since the mind is not active

	new_character.name = real_name

	new_character.key = key		//Manually transfer the key to log them in
	new_character.stopLobbySound()

	return new_character

/mob/new_player/proc/ViewManifest()
	var/dat = "<html><body>"
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest(OOC = 1)

	src << browse(dat, "window=manifest;size=387x420;can_close=1")

/mob/new_player/Move()
	return 0


/mob/new_player/proc/close_spawn_windows()

	src << browse(null, "window=latechoices") //closes late choices window
	src << browse(null, "window=playersetup") //closes the player setup window
	src << browse(null, "window=preferences") //closes job selection
	src << browse(null, "window=mob_occupation")
	src << browse(null, "window=latechoices") //closes late job selection
