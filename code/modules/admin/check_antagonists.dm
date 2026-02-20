/datum/admins/proc/check_antagonists_line(mob/M, caption = "", close = 1)
	var/logout_status
	logout_status = M.client ? "" : " <i>(logged out)</i>"
	var/dname = M.real_name
	var/area/A = get_area(M)
	if(!dname)
		dname = M

	return {"<tr><td><a href='byond://?src=[UID()];adminplayeropts=[M.UID()]'>[dname]</a><b>[caption]</b>[logout_status][istype(A, /area/security/permabrig) ? "<b><span style='color: red;'> (PERMA) </b></span>" : ""][M.stat == 2 ? " <b><span style='color: red;'>(DEAD)</span></b>" : ""]</td>
		<td><a href='byond://?src=[usr.UID()];priv_msg=[M.client?.ckey]'>PM</a> [ADMIN_FLW(M, "FLW")] </td>[close ? "</tr>" : ""]"}

/datum/admins/proc/check_antagonists()
	if(!check_rights(R_ADMIN))
		return
	if(SSticker && SSticker.current_state >= GAME_STATE_PLAYING)
		var/dat = {"<body><h1><b>Round Status</b></h1>"}
		dat += "Current Game Mode: <b>[SSticker.mode.name]</b><br>"
		dat += "Round Duration: <b>[ROUND_TIME_TEXT()]</b><br>"
		dat += "<b>Emergency shuttle</b><br>"
		if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
			dat += "<a href='byond://?src=[UID()];call_shuttle=1'>Call Shuttle</a><br>"
		else
			var/timeleft = SSshuttle.emergency.timeLeft()
			if(SSshuttle.emergency.mode == SHUTTLE_CALL)
				dat += "ETA: <a href='byond://?_src_=holder;edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><br>"
				dat += "<a href='byond://?_src_=holder;call_shuttle=2'>Send Back</a><br>"
			else
				dat += "ETA: <a href='byond://?_src_=holder;edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><br>"
		if(!SSshuttle.emergencyNoEscape)
			dat += "<a href='byond://?src=[UID()];lockdown_shuttle=1'>Lockdown Shuttle</a><br>"
		else
			dat += span_danger("<b>Emergency shuttle lockdowned</b>")
			dat += "<br><a href='byond://?src=[UID()];stop_lockdown=1'>Stop lockdown</a><br>"
		if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
			dat += span_danger("<b>Emergency shuttle stranded</b>")
			dat += "<br><a href='byond://?src=[UID()];reload_shuttle=1'>Reload Shuttle</a><br>"
		dat += "<a href='byond://?src=[UID()];full_lockdown=1'>Full Lockdown</a>Now: [GLOB.full_lockdown? "ON" : "OFF"]<br>"
		dat += "<a href='byond://?src=[UID()];delay_round_end=1'>[SSticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
		var/connected_players = GLOB.clients.len
		var/lobby_players = 0
		var/observers = 0
		var/observers_connected = 0
		var/living_players = 0
		var/living_players_connected = 0
		var/living_players_antagonist = 0
		var/other_players = 0
		for(var/mob/M in GLOB.mob_list)
			if(M.ckey)
				if(isnewplayer(M))
					lobby_players++
					continue
				else if(M.stat != DEAD && M.mind && !isbrain(M))
					living_players++
					if(M.mind.special_role)
						living_players_antagonist++
					if(M.client)
						living_players_connected++
				else if((M.stat == DEAD)||(isobserver(M)))
					observers++
					if(M.client)
						observers_connected++
				else
					other_players++
		dat += "<br><b><span style='color: #9A67EA;'>Players:|[connected_players - lobby_players] ingame|[connected_players] connected|[lobby_players] lobby|</span></b>"
		dat += "<br><b><span style='color: green;'>Living Players:|[living_players_connected] active|[living_players - living_players_connected] disconnected|[living_players_antagonist] antagonists|</span></b>"
		dat += "<br><b><span style='color: red;'>Dead/Observing players:|[observers_connected] active|[observers - observers_connected] disconnected|</span></b>"
		if(other_players)
			dat += "<br>[span_userdanger("[other_players] players in invalid state or the statistics code is bugged!")]"
		dat += "<br>"
		dat +="<br><b>Code Phrases:</b> [span_codephrases("[GLOB.syndicate_code_phrase]")]"
		dat +="<br><b>Code Responses:</b> [span_coderesponses("[GLOB.syndicate_code_response]")]"
		dat += "<br><b>Antagonist Teams</b><br>"
		dat += "<a href='byond://?src=[UID()];check_teams=1'>View Teams</a><br>"


		if(length(SSticker.mode.eventmiscs))
			dat += check_role_table("Event Roles", SSticker.mode.eventmiscs)

		if(length(SSticker.mode.ert))
			dat += check_role_table("ERT", SSticker.mode.ert)

		//list active security force count, so admins know how bad things are
		var/list/sec_list = check_active_security_force()
		dat += "<br><table cellspacing=5><tr><td><b>Security</b></td><td></td></tr>"
		dat += "<tr><td>Total: </td><td>[sec_list[1]]</td>"
		dat += "<tr><td>Active: </td><td>[sec_list[2]]</td>"
		dat += "<tr><td>Dead: </td><td>[sec_list[3]]</td>"
		dat += "<tr><td>Antag: </td><td>[sec_list[4]]</td>"
		dat += "</table>"

		dat += "</body>"
		var/datum/browser/popup = new(usr, "roundstatus", "<div align='center'>Round Status</div>", 400, 500)
		popup.set_content(dat)
		popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
		popup.open()
		onclose(usr, "roundstatus")
	else
		tgui_alert(usr, "The game hasn't started yet!")

/datum/admins/proc/check_role_table(name, list/members, show_objectives=1)
	var/txt = "<br><table cellspacing=5><tr><td><b>[name]</b></td><td></td></tr>"
	for(var/datum/mind/M in members)
		txt += check_role_table_row(M.current, show_objectives)
	txt += "</table>"
	return txt

/datum/admins/proc/check_role_table_row(mob/M, show_objectives)
	if(!istype(M))
		return "<tr><td><i>Not found!</i></td></tr>"

	var/txt = check_antagonists_line(M, close = 0)

	if(show_objectives)
		txt += {"
			<td>
				<a href='byond://?src=[UID()];traitor=[M.UID()]'>Show Objective</a>
			</td>
		"}

	txt += "</tr>"
	return txt

/datum/admins/proc/check_security_line(mob/living/human, close = 1)
	var/logout_status = human.client ? "" : " <i>(logged out)</i>"
	var/list/coords = ATOM_COORDS(human)
	var/job = issilicon(human) ? "Cyborg" : human.job // || need because maybe ert robots with null in job
	return {"<tr><td><a href='byond://?src=[UID()];adminplayeropts=[human.UID()]'>[human.real_name]</a>[logout_status]</td><td>[job][human.stat == DEAD ? " <b><span style='color: red;'>(Dead)</span></b>" : "<span style='color: green;'> [human.health]%</span>"] <b>[get_area_name(human)]</b> [coords[1]],[coords[2]],[coords[3]]</td><td><a href='byond://?src=[usr.UID()];priv_msg=[human.client?.ckey]'>PM</a> [ADMIN_FLW(human, "FLW")]</td>[close ? "</tr>" : ""]"}

/datum/admins/proc/check_security()
	if(!check_rights(R_ADMIN))
		return
	if(!SSticker || SSticker.current_state < GAME_STATE_PLAYING)
		return

	var/dat = {"<body><h1><b>Round Status</b></h1>"}
	var/list/sec_list = check_active_security_force()
	dat += "<br><table cellspacing=5><tr><td><b>Security</b></td><td></td></tr>"
	dat += "<tr><td>Total: </td><td>[sec_list[1]]</td>"
	dat += "<tr><td>Active: </td><td>[sec_list[2]]</td>"
	dat += "<tr><td>Dead: </td><td>[sec_list[3]]</td>"
	dat += "<tr><td>Antag: </td><td>[sec_list[4]]</td>"
	dat += "</table>"
	dat += "</body>"

	dat += "<br><table cellspacing=5><tr><td><b>Security</b></td><td></td></tr>"
	for(var/datum/mind/mind in SSticker.mode.get_all_sec())
		if(mind.current)
			dat += check_security_line(mind.current)
	dat += "</table>"

	if(length(SSticker.mode.ert))
		dat += check_role_table_sec("ERT", SSticker.mode.ert)

	var/datum/browser/popup = new(usr, "secstatus", "<div align='center'>Security Status</div>", 500, 600)
	popup.set_content(dat)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.open()
	onclose(usr, "secstatus")

/datum/admins/proc/check_role_table_sec(name, list/members, show_objectives=0)
	var/txt = "<br><table cellspacing=5><tr><td><b>[name]</b></td><td></td></tr>"
	for(var/datum/mind/mind in members)
		txt += check_role_table_row_sec(mind.current, show_objectives)
	txt += "</table>"
	return txt

/datum/admins/proc/check_role_table_row_sec(mob/mob, show_objectives)
	var/txt = check_security_line(mob, close = 0)
	if(show_objectives)
		txt += {"
			<td>
				<a href='byond://?src=[UID()];traitor=[mob.UID()]'>Show Objective</a>
			</td>
		"}
	txt += "</tr>"
	return txt
