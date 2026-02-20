/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.
	Guidelines for using minds properly:
	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse
	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:
			mind.transfer_to(new_mob)
	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.
	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.
	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.
			new_mob.key = key
		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.
*/

/datum/mind
	var/key
	/// Replaces mob/var/original_name
	var/name
	/// Current mob of our mind.
	var/mob/living/current
	/// The original mob's UID. Used for example to see if a silicon with antag status is actually malf. Or just an antag put in a borg.
	var/original_mob_UID
	/// The original mob's name. Used in dead chat messages.
	var/original_mob_name

	var/active = FALSE

	var/memory

	var/assigned_role //assigned role is what job you're assigned to when you join the station.
	var/playtime_role //if set, overrides your assigned_role for the purpose of playtime awards. Set by IDcomputer when your ID is changed.
	var/special_role //special roles are typically reserved for antags or roles like ERT. If you want to avoid a character being automatically announced by the AI, on arrival (becuase they're an off station character or something); ensure that special_role and assigned_role are equal.
	var/offstation_role = FALSE //set to true for ERT, deathsquad, abductors, etc, that can go from and to z2 at will and shouldn't be antag targets
	var/list/restricted_roles = list()

	var/rev_cooldown = 0

	var/list/spell_list
	var/datum/martial_art/martial_art
	var/list/known_martial_arts = list()

	var/role_alt_title

	var/datum/job/assigned_job
	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	var/list/targets = list()

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/miming = 0 // Mime's vow of silence
	var/list/antag_datums

	/// this mind's ANTAG_HUD should have this icon_state
	var/antag_hud_icon_state = null
	/// this mind's antag HUD
	var/datum/atom_hud/antag/antag_hud = null
	var/datum/mindslaves/som //stands for slave or master...hush..
	var/damnation_type = 0
	var/datum/mind/soulOwner //who owns the soul.  Under normal circumstances, this will point to src
	var/hasSoul = TRUE

	var/isholy = FALSE // is this person a chaplain or admin role allowed to use bibles
	var/isblessed = FALSE // is this person blessed by a chaplain?
	var/num_blessed = 0 // for prayers

	var/lost_memory = FALSE // for the memorizers

	var/suicided = FALSE

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	//zealot_master is a reference to the mob that converted them into a zealot (for ease of investigation and such)
	var/mob/living/carbon/human/zealot_master = null

	var/list/learned_recipes //List of learned recipe TYPES.

	var/list/curses

	var/madeby_sentience_potion = FALSE

	///a list of objectives that a player with this job could complete for space credit rewards
	var/list/job_objectives = list()

/datum/mind/New(new_key)
	key = new_key
	soulOwner = src

/datum/mind/Destroy()
	SSticker.minds -= src

	for(var/datum/antagonist/antag as anything in antag_datums)
		if(QDELETED(antag))
			continue

		if(!antag.delete_on_mind_deletion)
			continue

		qdel(antag)

	current = null
	soulOwner = null
	return ..()

/datum/mind/proc/set_original_mob(mob/original)
	original_mob_UID = original.UID()

/datum/mind/proc/is_original_mob(mob/o_mob)
	return original_mob_UID == o_mob.UID()

// Do not use for admin related things as this can hide the mob's ckey
/datum/mind/proc/get_display_key()
	// Lets try find a client so we can check their prefs
	var/client/C = null

	var/cannonical_key = ckey(key)

	if(current?.client)
		// Active client
		C = current.client
	else if(cannonical_key in GLOB.directory)
		// Do a directory lookup on the last ckey this mind had
		// If theyre online we can grab them still and check prefs
		C = GLOB.directory[cannonical_key]

	// Ok we found a client, be it their active or their last
	// Now we see if we need to respect their privacy
	var/out_ckey
	if(C)
		if(C.prefs.toggles2 & PREFTOGGLE_2_ANON)
			out_ckey = "(Anon)"
		else
			out_ckey = C.ckey
	else
		// No client. Just mark as DC'd.
		out_ckey = "(Disconnected)"

	return out_ckey

/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		stack_trace("transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob.")

	var/datum/atom_hud/antag/hud_to_transfer = antag_hud // we need this because leave_hud() will clear this list
	var/mob/living/old_current = current

	if(current)					// remove ourself from our old body's mind variable
		current.mind = null
		leave_all_huds() // leave all the huds in the old body, so it won't get huds if somebody else enters it

		SStgui.on_transfer(current, new_character)

	if(new_character.mind)		// remove any mind currently in our new body's mind variable
		new_character.mind.current = null

	current = new_character		// link ourself to our new body
	new_character.mind = src	// and link our new body to ourself

	transfer_antag_huds(hud_to_transfer)				// inherit the antag HUD
	transfer_actions(new_character, old_current)

	if(martial_art)
		for(var/datum/martial_art/MA in known_martial_arts)
			MA.reset_combos(old_current)
			MA.remove(current)
			if(old_current)
				MA.remove_martial_art_verbs(old_current)
			if(!MA.temporary)
				MA.teach(current)

	for(var/datum/antagonist/antag in antag_datums)	// Makes sure all antag datums effects are applied in the new body
		antag.on_body_transfer(old_current, current)

	if(iscarbon(new_character))
		var/mob/living/carbon/carbon = new_character
		carbon.last_mind = src

	if(active)
		new_character.possess_by_player(key)		// now transfer the key to link the client to our new body

	// essential mob updates
	new_character.update_blind_effects()
	new_character.update_blurry_effects()
	new_character.update_sight()
	new_character.hud_used?.reload_fullscreen()
	new_character.reload_huds()

	SEND_SIGNAL(src, COMSIG_MIND_TRANSER_TO, new_character)
	SEND_SIGNAL(new_character, COMSIG_BODY_TRANSFER_TO)

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<br>"

/datum/mind/proc/wipe_memory()
	memory = null

/datum/mind/proc/show_memory(mob/recipient, window = TRUE)
	if(!recipient)
		recipient = current
	var/output = {"<b>[name]'s Memories:</b><hr>"}
	output += memory

	var/antag_datum_objectives = FALSE
	for(var/datum/antagonist/antag in antag_datums)
		output += antag.antag_memory
		if(!antag_datum_objectives && LAZYLEN(antag.objectives))
			antag_datum_objectives = TRUE

	if(LAZYLEN(objectives) || antag_datum_objectives)
		output += "<hr><b>Objectives:</b><br>"
		output += gen_objective_text()

	if(LAZYLEN(job_objectives))
		output += "<hr><b>Job Objectives:</b><ul>"

		var/obj_count = 1
		for(var/datum/job_objective/objective in job_objectives)
			output += "<li><b>Task #[obj_count]</b>: [objective.get_description()]</li>"
			obj_count++
		output += "</ul>"

	if(window)
		var/datum/browser/popup = new(recipient, "memory", "[name]'s Memories")
		popup.set_content(output)
		popup.open(FALSE)
	else
		to_chat(recipient, "<i>[output]</i>")

/datum/mind/proc/gen_objective_text(admin = FALSE)
	. = ""
	var/obj_count = 1

	// If they don't have any objectives, "" will be returned.
	for(var/datum/objective/objective in get_all_objectives())
		. += "<b>Objective #[obj_count++]</b>: [objective.explanation_text]"
		if(admin)
			. += " <a href='byond://?src=[UID()];obj_edit=[objective.UID()]'>Edit</a> " // Edit
			. += "<a href='byond://?src=[UID()];obj_delete=[objective.UID()]'>Delete</a> " // Delete

			. += "<a href='byond://?src=[UID()];obj_completed=[objective.UID()]'>" // Mark Completed
			. += "<font color=[objective.completed ? "green" : "red"]>Toggle Completion</font>"
			. += "</a>"
		. += "<br>"

/**
 * Gets every objective this mind owns, including all of those from any antag datums they have, and returns them as a list.
 */
/datum/mind/proc/get_all_objectives()
	var/list/all_objectives = list()

	for(var/datum/antagonist/antag in antag_datums)
		all_objectives += antag.objectives	// Add all antag datum objectives.

	for(var/datum/objective/objective in objectives)
		all_objectives += objective // Add all mind objectives.

	return all_objectives

/**
 * Completely remove the given objective from the src mind and it's antag datums.
 */
/datum/mind/proc/remove_objective(datum/objective/objective, qdel_on_remove = FALSE)
	for(var/datum/antagonist/antag in antag_datums)
		antag.objectives -= objective
	objectives -= objective
	if(qdel_on_remove)
		qdel(objective)

/**
 * Completely remove ALL objectives from the src mind and it's antag datums.
 */
/datum/mind/proc/remove_all_objectives(qdel_on_remove = FALSE)
	for(var/datum/objective/objective in get_all_objectives())
		remove_objective(objective, qdel_on_remove)

/datum/mind/proc/_memory_edit_header(gamemode, list/alt)
	. = gamemode
	if(SSticker.mode.config_tag == gamemode || (LAZYLEN(alt) && (SSticker.mode.config_tag in alt)))
		. = uppertext(.)
	. = "<i><b>[.]</b></i>: "

/datum/mind/proc/_memory_edit_role_enabled(role)
	. = "|Disabled in Prefs"
	if(current?.client && (role in current.client.prefs.be_special))
		. = "|Enabled in Prefs"
/datum/mind/proc/memory_edit_eventmisc(mob/living/H)
	. = _memory_edit_header("event", list())
	if(src in SSticker.mode.eventmiscs)
		. += "<b>YES</b>|<a href='byond://?src=[UID()];eventmisc=clear'>no</a>"
	else
		. += "<a href='byond://?src=[UID()];eventmisc=eventmisc'>Event Role</a>|<b>NO</b>"

/datum/mind/proc/memory_edit_silicon()
	. = "<i><b>Silicon</b></i>: "
	var/mob/living/silicon/silicon = current
	. = "<br>Current Laws: <b>[silicon.laws.name]</b> <a href='byond://?src=[UID()];silicon=lawmanager'>Law Manager</a>"
	var/mob/living/silicon/robot/robot = current
	if(istype(robot))
		. += "<br><b>Cyborg Module: [robot.module ? robot.module : "None" ]</b> <a href='byond://?src=[UID()];silicon=borgpanel'>Borg Panel</a>"
		if(robot.emagged)
			. += "<br>Cyborg: <b><font color='red'>Is emagged!</font></b> <a href='byond://?src=[UID()];silicon=unemag'>Unemag!</a>"
		if(robot.laws.zeroth_law)
			. += "<br>0th law: [robot.laws.zeroth_law?.law]"
	var/mob/living/silicon/ai/ai = current
	if(istype(ai) && length(ai.connected_robots))
		var/n_e_robots = 0
		for(var/mob/living/silicon/robot/R in ai.connected_robots)
			if(R.emagged)
				n_e_robots++
		. += "<br>[n_e_robots] of [length(ai.connected_robots)] slaved cyborgs are emagged. <a href='byond://?src=[UID()];silicon=unemagcyborgs'>Unemag</a>"

/datum/mind/proc/edit_memory()
	if(!SSticker || !SSticker.mode)
		tgui_alert(usr, "Not before round-start!", "Alert")
		return

	var/list/out = list("<body><b>[name]</b>[(current && (current.real_name != name))?" (as [current.real_name])" : ""]")
	out.Add("Mind currently owned by key: [key] [active ? "(synced)" : "(not synced)"]")
	out.Add("Assigned role: [assigned_role]. <a href='byond://?src=[UID()];role_edit=1'>Edit</a>")
	out.Add("Special role: [special_role].") //better to change this through /datum/antagonist/, some code uses this var and can break if something goes wrong
	out.Add("Factions and special roles:")

	var/list/sections = list(
		// "implant",
		// "revolution",
		// "cult",
		// "clockwork",
		// "wizard",
		// "changeling",	// "traitorchan", "thiefchan", "changelingthief",
		// "vampire",		// "traitorvamp", "thiefvamp", "vampirethief",
		// "nuclear",
		// "traitor",
		// "ninja",
		// "thief",		//	"traitorthief", "traitorthiefvamp", "traitorthiefchan",
		// "malf_ai",
		// "blob"
	) // it can work if it's empty anyways

	var/mob/living/carbon/human/H = current
	// if(ishuman(current))
	// 	/** TRAITOR ***/
	// 	sections["traitor"] = memory_edit_traitor()

	sections["eventmisc"] = memory_edit_eventmisc(H)

	/** SILICON ***/
	if(issilicon(current))
		sections["silicon"] = memory_edit_silicon()
	/*
		This prioritizes antags relevant to the current round to make them appear at the top of the panel.
		Traitorchan and traitorvamp are snowflaked in because they have multiple sections.
	*/
	// switch(SSticker.mode.config_tag) // left first twou ifs and the last else for reference
		// if("traitorchan")
		// 	if(sections["traitor"])
		// 		out.Add(sections["traitor"])
		// 	if(sections["changeling"])
		// 		out.Add(sections["changeling"])
		// 	sections -= "traitor"
		// 	sections -= "changeling"
		// Elif technically unnecessary but it makes the following else look better
		// if("traitorvamp")
		// 	if(sections["traitor"])
		// 		out.Add(sections["traitor"])
		// 	if(sections["vampire"])
		// 		out.Add(sections["vampire"])
		// 	sections -= "traitor"
		// 	sections -= "vampire"
		// else
		// 	if(sections[SSticker.mode.config_tag])
		// 		out.Add(sections[SSticker.mode.config_tag])
		// 	sections -= SSticker.mode.config_tag

	for(var/i in sections)
		if(sections[i])
			out.Add(sections[i])

	// out.Add(memory_edit_uplink()) // just to remind that we can give something instead of an uplink

	out.Add("<b>Memory:</b>")
	out.Add(memory)
	out.Add("<br><a href='byond://?src=[UID()];memory_edit=1'>Edit memory</a><br>")
	out.Add("Objectives:")
	if(!length(get_all_objectives()))
		out.Add("EMPTY<br>")
	else
		out.Add(gen_objective_text(admin = TRUE))
	out.Add("<a href='byond://?src=[UID()];obj_add=1'>Add objective</a><br>")
	out.Add("<a href='byond://?src=[UID()];obj_announce=1'>Announce objectives</a><br>")
	out.Add("</body></html>")

	var/datum/browser/popup = new(usr, "edit_memory[src]", "<div align='center'>[name]</div>", 500, 500)
	popup.set_content(out.Join("<br>"))
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.open()
	onclose(usr, "edit_memory[src]")

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	if(href_list["role_edit"])
		var/new_role = tgui_input_list(usr, "Select new role", "Assigned role", GLOB.joblist)
		if(!new_role)
			return
		assigned_role = new_role
		log_admin("[key_name(usr)] has changed [key_name(current)]'s assigned role to [assigned_role]")
		message_admins("[key_name_admin(usr)] has changed [key_name_admin(current)]'s assigned role to [assigned_role]")

	else if(href_list["memory_edit"])
		var/messageinput = tgui_input_text(usr, "Write new memory", "Memory", memory, multiline = TRUE, encode = FALSE)
		if(isnull(messageinput))
			return
		var/confirmed = tgui_alert(usr, "Are you sure you want to edit their memory? It will wipe out their original memory!", "Edit Memory", list("Yes", "No"))
		if(confirmed == "Yes") // Because it is too easy to accidentally wipe someone's memory
			memory = messageinput
			log_admin("[key_name(usr)] has edited [key_name(current)]'s memory")
			message_admins("[key_name_admin(usr)] has edited [key_name_admin(current)]'s memory")

	else if(href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if(href_list["obj_edit"])
			objective = locateUID(href_list["obj_edit"])
			if(!objective)
				return

			if(objectives.Find(objective))
				objective_pos = list(objectives.Find(objective), null)
			else
				for(var/datum/antagonist/antag in antag_datums)
					if(antag.objectives.Find(objective))
						objective_pos = list(antag.objectives.Find(objective), antag)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 18)	//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

			switch(def_value)
				if("maroon")
					def_value = "prevent from escape"
				if("pain_hunter")
					def_value = "pain hunter"
				if("debrain")
					def_value = "steal brain"
				if("steal/hard")
					def_value = "thief hard"
				if("steal/medium")
					def_value = "thief medium"
				if("collect")
					def_value = "thief collect"
				if("steal_pet")
					def_value = "thief pet"
				if("steal_structure")
					def_value = "thief structure"
				if("escape_with_identity")
					def_value = "identity theft"
				if("block")
					def_value = "kill all humans"
				if("get_money")
					def_value = "get money"
				if("find_and_scan")
					def_value = "find and scan"
				if("set_up")
					def_value = "set up"
				if("research_corrupt")
					def_value = "research corrupt"
				if("ai_corrupt")
					def_value = "ai corrupt"
				if("plant_explosive")
					def_value = "plant explosive"
				if("cyborg_hijack")
					def_value = "cyborg hijack"

		var/list/objective_types = list(
			"assassinate", "prevent from escape", "pain hunter", "steal brain", "protect", "escape", "survive",
			"steal", "thief hard", "thief medium", "thief collect", "thief pet", "thief structure", "die",
			// Кастомная цель//
			"custom")

		var/new_obj_type = tgui_input_list(usr, "Select objective type:", "Objective type", objective_types)
		if(!new_obj_type)
			return

		var/datum/objective/new_objective = null

		switch(new_obj_type)
			if("assassinate", "protect", "steal brain", "prevent from escape", "pain hunter")

				var/list/possible_targets = list()
				var/list/possible_targets_random = list()
				for(var/datum/mind/possible_target in SSticker.minds)
					if((possible_target != src) && ishuman(possible_target.current))
						possible_targets += possible_target.current // Allows for admins to pick off station roles
						if(!is_invalid_target(possible_target))
							possible_targets_random += possible_target.current // For random picking, only valid targets

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate,
											/datum/objective/protect,
											/datum/objective/debrain,
											/datum/objective/maroon,
											/datum/objective/pain_hunter
										)
				if(objective && (objective.type in objective_list) && objective:target)
					def_target = objective.target.current
				possible_targets = sortAtom(possible_targets)

				var/new_target
				if(length(possible_targets))
					if(tgui_alert(usr, "Do you want to pick the objective yourself? No will randomise it", "Pick objective", list("Yes", "No")) == "Yes")
						possible_targets += "Free objective"
						new_target = tgui_input_list(usr, "Select target:", "Objective target", possible_targets, def_target)
					else
						if(!length(possible_targets_random))
							to_chat(usr, span_warning("No random target found. Pick one manually."))
							return
						new_target = pick(possible_targets_random)

					if(!new_target)
						return
				else
					to_chat(usr, span_warning("No possible target found. Defaulting to a Free objective."))
					new_target = "Free objective"

				var/obj_type = list("assassinate" = /datum/objective/assassinate,
								"protect" = /datum/objective/protect,
								"steal brain" = /datum/objective/debrain,
								"prevent from escape" = /datum/objective/maroon,
								"pain hunter" = /datum/objective/pain_hunter
								)[new_obj_type]

				if(new_target == "Free objective")
					new_objective = new obj_type
					new_objective.owner = src
					new_objective:target = null
					new_objective.explanation_text = "Free objective"
				else
					new_objective = new obj_type
					new_objective.owner = src
					new_objective:target = new_target:mind

					var/description = ""
					switch(new_obj_type)
						if("assassinate")
							description = "Assassinate"
						if("protect")
							description = "Protect"
						if("steal brain")
							var/mob/living/target = new_target
							var/obj/item/organ/internal/brains = target.get_organ_slot(INTERNAL_ORGAN_BRAIN)
							description = "Steal the [brains ? brains.name : "brain"] of"
						if("prevent from escape")
							description = "Prevent from escaping alive or free"
						if("pain hunter")
							var/datum/objective/pain_hunter/choose_objective = new_objective
							choose_objective.update_find_objective()
					if(description)
						//Will display as special role if assigned mode is equal to special role.. Ninjas/commandos/nuke ops.
						new_objective.explanation_text = "[description] [new_target:real_name], the [new_target:mind:assigned_role == new_target:mind:special_role ? (new_target:mind:special_role) : (new_target:mind:assigned_role)]."

			if("destroy")
				var/list/possible_targets = active_ais(1)
				if(length(possible_targets))
					var/mob/new_target = tgui_input_list(usr, "Select target:", "Objective target", possible_targets)
					new_objective = new /datum/objective/destroy
					new_objective.target = new_target.mind
					new_objective.owner = src
					new_objective.explanation_text = "Destroy [new_target.name], the experimental AI."
				else
					to_chat(usr, "No active AIs with minds")


			if("escape")
				new_objective = new /datum/objective/escape
				new_objective.owner = src

			if("survive")
				new_objective = new /datum/objective/survive
				new_objective.owner = src

			if("die")
				new_objective = new /datum/objective/die
				new_objective.owner = src

			if("steal")
				if(!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, span_warning("Цель не обнаружена. Выберите другую или создайте её."))
					return

			if("thief hard")
				if(!istype(objective, /datum/objective/steal/hard))
					new_objective = new /datum/objective/steal/hard
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/hard/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, span_warning("Цель не обнаружена. Выберите другую или создайте её."))
					return

			if("thief medium")
				if(!istype(objective, /datum/objective/steal/medium))
					new_objective = new /datum/objective/steal/medium
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/medium/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, span_warning("Цель не обнаружена. Выберите другую или создайте её."))
					return

			if("thief pet")
				if(!istype(objective, /datum/objective/steal/animal))
					new_objective = new /datum/objective/steal/animal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/animal/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, span_warning("Цель не обнаружена. Выберите другую или создайте её."))
					return

			if("thief structure")
				if(!istype(objective, /datum/objective/steal/structure))
					new_objective = new /datum/objective/steal/structure
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/structure/steal = new_objective
				if(!steal.select_target())
					to_chat(usr, span_warning("Цель не обнаружена. Выберите другую или создайте её."))
					return

			if("custom")
				var/expl = sanitize(tgui_input_text(usr, "Custom objective:", "Objective", objective ? objective.explanation_text : ""))
				if(!expl)
					return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if(!new_objective)
			return

		if(objective)
			remove_objective(objective)
			if(objective_pos[2])
				var/datum/antagonist/antag = objective_pos[2]
				antag.objectives.Insert(objective_pos[1], new_objective)
			else
				objectives.Insert(objective_pos[1], new_objective)
		else
			objectives += new_objective

		log_admin("[key_name(usr)] has updated [key_name(current)]'s objectives: [new_objective]")
		message_admins("[key_name_admin(usr)] has updated [key_name_admin(current)]'s objectives: [new_objective]")

	else if(href_list["obj_delete"])
		var/datum/objective/objective = locateUID(href_list["obj_delete"])
		if(!istype(objective))
			return

		log_admin("[key_name(usr)] has removed one of [key_name(current)]'s objectives: [objective]")
		message_admins("[key_name_admin(usr)] has removed one of [key_name_admin(current)]'s objectives: [objective]")
		remove_objective(objective)

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locateUID(href_list["obj_completed"])
		if(!istype(objective))
			return
		objective.completed = !objective.completed

		log_admin("[key_name(usr)] has toggled the completion of one of [key_name(current)]'s objectives")
		message_admins("[key_name_admin(usr)] has toggled the completion of one of [key_name_admin(current)]'s objectives")

	// else if(href_list["implant"]) // we probably won'r use these but anyways will keep them just in case
	// 	var/mob/living/carbon/human/H = current

	// 	switch(href_list["implant"])
	// 		if("ertremove")
	// 			for(var/obj/item/implant/mindshield/ert/I in H.contents)
	// 				if(I?.implanted)
	// 					qdel(I)
	// 			to_chat(H, span_notice(span_fontsize3("<b>Your ert mindshield implant has been deactivated.</b>")))
	// 			log_admin("[key_name(usr)] has deactivated [key_name(current)]'s ert mindshield implant")
	// 			message_admins("[key_name_admin(usr)] has deactivated [key_name_admin(current)]'s ert mindshield implant")
	// 		if("remove")
	// 			for(var/obj/item/implant/mindshield/I in H.contents)
	// 				if(I?.implanted)
	// 					qdel(I)
	// 			to_chat(H, span_notice(span_fontsize3("<b>Your mindshield implant has been deactivated.</b>")))
	// 			log_admin("[key_name(usr)] has deactivated [key_name(current)]'s mindshield implant")
	// 			message_admins("[key_name_admin(usr)] has deactivated [key_name_admin(current)]'s mindshield implant")
	// 		if("add")
	// 			var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)
	// 			L.implant(H)

	// 			log_admin("[key_name(usr)] has given [key_name(current)] a mindshield implant")
	// 			message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] a mindshield implant")

	// 			to_chat(H, span_warning(span_fontsize3("<b>You somehow have become the recepient of a mindshield transplant, and it just activated!</b>")))
	// 			if(src in SSticker.mode.revolutionaries)
	// 				SSticker.mode.remove_revolutionary(src)
	// 		if("ertadd")
	// 			var/obj/item/implant/mindshield/ert/L = new/obj/item/implant/mindshield/ert(H)
	// 			L.implant(H)

	// 			log_admin("[key_name(usr)] has given [key_name(current)] a ert mindshield implant")
	// 			message_admins("[key_name_admin(usr)] has given [key_name_admin(current)] a ert mindshield implant")

	// 			to_chat(H, span_warning(span_fontsize3("<b>You somehow have become the recepient of a ert mindshield transplant, and it just activated!</b>")))
	// 			if(src in SSticker.mode.revolutionaries)
	// 				SSticker.mode.remove_revolutionary(src)

	else if(href_list["silicon"])
		switch(href_list["silicon"])
			if("borgpanel")
				var/mob/living/silicon/robot/robot = current
				if(!istype(robot))
					return
				SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/borg_panel, current)
			if("lawmanager")
				SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/open_law_manager)
			if("unemag")
				var/mob/living/silicon/robot/R = current
				if(!istype(R))
					return
				R.unemag()
				log_admin("[key_name(usr)] has un-emagged [key_name(current)]")
				message_admins("[key_name_admin(usr)] has un-emagged [key_name_admin(current)]")

			if("unemagcyborgs")
				if(!isAI(current))
					return
				var/mob/living/silicon/ai/ai = current
				for(var/mob/living/silicon/robot/R in ai.connected_robots)
					R.unemag()
				log_admin("[key_name(usr)] has unemagged [key_name(ai)]'s cyborgs")
				message_admins("[key_name_admin(usr)] has unemagged [key_name_admin(ai)]'s cyborgs")

	else if(href_list["obj_announce"])
		var/list/messages = prepare_announce_objectives()
		to_chat(current, chat_box_red(messages.Join("<br>")))
		SEND_SOUND(current, sound('sound/ambience/alarm4.ogg'))
		log_admin("[key_name(usr)] has announced [key_name(current)]'s objectives")
		message_admins("[key_name_admin(usr)] has announced [key_name_admin(current)]'s objectives")

	edit_memory()

/**
 * Create and/or add the `datum_type_or_instance` antag datum to the src mind.
 *
 * Arguments:
 * * datum_type - an antag datum typepath or instance
 * * datum/team/team - the antag team that the src mind should join, if any
 */
/datum/mind/proc/add_antag_datum(datum_type_or_instance, team)
	if(!datum_type_or_instance)
		return
	var/datum/antagonist/antag
	if(!ispath(datum_type_or_instance))
		antag = datum_type_or_instance
		if(!istype(antag))
			return
	else
		antag = new datum_type_or_instance()

	if(!antag.can_be_owned(src))
		qdel(antag)
		return

	antag.owner = src
	LAZYADD(antag_datums, antag)

	if(team)
		antag.create_team(team)
		var/datum/team/antag_team = antag.get_team()
		if(antag_team)
			antag_team.add_member(src)

	ASSERT(antag.owner && antag.owner.current)
	antag.on_gain()
	return antag

/**
 * Remove the specified `datum_type` antag datum from the src mind.
 *
 * Arguments:
 * * datum_type - an antag datum typepath
 */

/datum/mind/proc/remove_antag_datum(datum_type)
	var/datum/antagonist/antag = has_antag_datum(datum_type)

	if(!antag)
		return

	qdel(antag)

/**
 * Removes all antag datums from the src mind.
 *
 * Use this over doing `QDEL_LIST_CONTENTS(antag_datums)`.
 */
/datum/mind/proc/remove_all_antag_datums() //For the Lazy amongst us.
	// This is not `QDEL_LIST_CONTENTS(antag_datums)`because it's possible for the `antag_datums` list to be set to null during deletion of an antag datum.
	// Then `QDEL_LIST` would runtime because it would be doing `null.Cut()`.
	for(var/datum/antagonist/A as anything in antag_datums)
		qdel(A)
	antag_datums?.Cut()
	antag_datums = null

/datum/mind/proc/remove_event_role()
	if(src in SSticker.mode.eventmiscs)
		SSticker.mode.eventmiscs -= src
		SSticker.mode.update_eventmisc_icons_removed(src)
		special_role = null

/datum/mind/proc/remove_all_antag_roles(adminlog = TRUE) // Except abductor, because it isnt implemented in admin panel
	// remove_revolutionary_role()
	// remove_cult_role()
	// remove_clocker_role()
	// remove_wizard_role()
	// remove_changeling_role()
	// remove_vampire_role()
	// remove_syndicate_role()
	remove_event_role()
	// remove_devil_role()
	// remove_traitor_role()
	// remove_thief_role()
	// remove_shadow_role()
	// remove_ninja_role()

	if(adminlog)
		message_admins("[ADMIN_LOOKUP(current)] lost all antag roles")
		log_admin("[key_name_log(current)] lost all antag roles")

/**
 * Returns an antag datum instance if the src mind has the specified `datum_type`. Returns `null` otherwise.
 *
 * Arguments:
 * * datum_type - an antag datum typepath
 * * check_subtypes - TRUE if this proc will consider subtypes of `datum_type` as valid. FALSE if only the exact same type should be considered.
 */
/datum/mind/proc/has_antag_datum(datum_type, check_subtypes = TRUE)
	for(var/datum/antagonist/A as anything in antag_datums)
		if(check_subtypes && istype(A, datum_type))
			return A
		else if(A.type == datum_type)
			return A

/datum/mind/proc/prepare_announce_objectives(title = TRUE)
	if(!current)
		return
	var/list/text = list()
	if(title)
		text.Add(span_notice("Your current objectives:"))
	text.Add(gen_objective_text())
	return text

/datum/mind/proc/AddSpell(obj/effect/proc_holder/spell/spell)
	if(!istype(spell))
		return
	LAZYADD(spell_list, spell)
	spell.action.Grant(current)
	spell.on_spell_gain(current)

/datum/mind/proc/RemoveSpell(obj/effect/proc_holder/spell/instance_or_path) //To remove a specific spell from a mind
	if(!ispath(instance_or_path))
		instance_or_path = instance_or_path.type
	for(var/obj/effect/proc_holder/spell/spell as anything in spell_list)
		if(spell.type == instance_or_path)
			spell.on_spell_removed(current)
			LAZYREMOVE(spell_list, spell)
			qdel(spell)

/datum/mind/proc/deactivate_spell(obj/effect/proc_holder/spell/instance_or_path)
	if(!ispath(instance_or_path))
		instance_or_path = instance_or_path.type

	var/obj/effect/proc_holder/spell/spell = LAZYIN(spell_list, locate(instance_or_path))

	if(!spell)
		return FALSE

	LAZYREMOVE(spell_list, spell)

	spell.action.Remove(current)

	return TRUE

/datum/mind/proc/transfer_actions(mob/living/new_character, mob/living/old_current)
	if(old_current?.actions)
		for(var/datum/action/A in old_current.actions)
			if(A.check_flags & AB_TRANSFER_MIND)
				A.Grant(new_character)
	transfer_mindbound_actions(new_character)

/datum/mind/proc/transfer_mindbound_actions(mob/living/new_character)
	for(var/obj/effect/proc_holder/spell/spell as anything in spell_list)
		spell.action.Grant(new_character)

/datum/mind/proc/disrupt_spells(delay, list/exceptions)
	for(var/obj/effect/proc_holder/spell/spell as anything in spell_list)
		var/exception = FALSE
		for(var/typepath in exceptions)
			if(istype(spell, typepath))
				exception = TRUE
				break
		if(exception)
			continue
		if(spell.cooldown_handler)
			INVOKE_ASYNC(spell.cooldown_handler, TYPE_PROC_REF(/datum/spell_cooldown, start_recharge), delay)
		spell.updateButtonIcon()

/datum/mind/proc/get_ghost(even_if_they_cant_reenter)
	for(var/mob/dead/observer/G in GLOB.dead_mob_list)
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/grab_ghost(force)
	var/mob/dead/observer/G = get_ghost(even_if_they_cant_reenter = force)
	. = G
	if(G)
		G.reenter_corpse()

/datum/mind/proc/is_revivable() //Note, this ONLY checks the mind.
	if(damnation_type)
		return FALSE
	if(!hasSoul)
		return FALSE
	if(soulOwner != src)
		return FALSE
	return TRUE

// returns a mob to message to produce something visible for the target mind
/datum/mind/proc/messageable_mob()
	if(!QDELETED(current) && current.client)
		return current
	else
		return get_ghost(even_if_they_cant_reenter = TRUE)

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		if(SSticker)
			SSticker.minds += mind
		else
			error("mind_initialize(): No ticker ready yet! Please inform Carn")
	if(!mind.name)
		mind.name = real_name
	mind.current = src
	SEND_SIGNAL(src, COMSIG_MOB_MIND_INITIALIZED, mind)

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	last_mind = mind
	if(!mind.assigned_role)
		mind.assigned_role = JOB_TITLE_CIVILIAN	//defualt

/mob/proc/sync_mind()
	mind_initialize()  //updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = TRUE    //indicates that the mind is currently synced with a client

//slime
/mob/living/simple_animal/slime/mind_initialize()
	..()
	mind.assigned_role = "slime"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = JOB_TITLE_AI

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = JOB_TITLE_CYBORG
	if(is_taipan(z))
		give_taipan_hud()
		GLOB.taipan_players_active += mind

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = null

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/pet/dog/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

