/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up �_� ~Carn
	..()
	regenerate_icons()

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/display as anything in GLOB.ai_displays) //change status
			display.mode = AI_DISPLAY_MODE_EMOTE
			display.emotion = "Neutral"
			display.update_icon(UPDATE_OVERLAYS)

	view_core()
