ADMIN_VERB(one_click_antag, R_SERVER|R_EVENT, "Create Antagonist", "Auto-create an antagonist of your choice.", ADMIN_CATEGORY_EVENTS)
	if(!user.holder)
		return

	user.holder.one_click_antag()

/datum/admins/proc/one_click_antag() // temporarily disabled uncomment when you make new antags
	// var/dat = {"<b>One-click Antagonist</b><br>
	// 	<a href='byond://?src=[UID()];makeAntag=1'>Make Traitors</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=2'>Make Changelings</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=3'>Make Revolutionaries</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=4'>Make Cult</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=5'>Make Clockwork Cult</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=6'>Make Wizard (Requires Ghosts)</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=7'>Make Vampires</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=8'>Make Vox Raiders (Requires Ghosts)</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=9'>Make Abductor Team (Requires Ghosts)</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=10'>Make Space Ninja (Requires Ghosts)</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=11'>Make Thieves</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=12'>Make Blobs</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=13'>Make Terror Spiders</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=14'>Make Aliens</a><br>
	// 	<a href='byond://?src=[UID()];makeAntag=15'>Make Nuke Team</a><br>
	// 	"}
	// var/datum/browser/popup = new(usr, "oneclickantag", "One-click Antagonist", 400, 400)
	// popup.set_content(dat)
	// popup.open(FALSE)
	return

/datum/admins/proc/CandCheck(role = null, mob/living/carbon/human/M, datum/game_mode/temp = null)
	// You pass in ROLE define (optional), the applicant, and the gamemode, and it will return true / false depending on whether the applicant qualify for the candidacy in question
	if(jobban_isbanned(M, "Syndicate"))
		return FALSE
	if(M.stat || !M.mind || M.mind.special_role || M.mind.offstation_role)
		return FALSE
	if(temp)
		if((M.mind.assigned_role in temp.restricted_jobs) || (M.client.prefs.species in temp.protected_species))
			return FALSE
	if(role) // Don't even bother evaluating if there's no role
		if(player_old_enough_antag(M.client,role) && (role in M.client.prefs.be_special) && !M.client.prefs?.skip_antag && (!jobban_isbanned(M, role)))
			return TRUE
		else
			return FALSE
	else
		return TRUE
/proc/makeBody(mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)	return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(GLOB.latejoin))//The mob being spawned.

	var/datum/preferences/A = new(G_found.client)
	A.copy_to(new_character)

	new_character.dna.ready_dna(new_character)
	new_character.possess_by_player(G_found.key)

	return new_character
