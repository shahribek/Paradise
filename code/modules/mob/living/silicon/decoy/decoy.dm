/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/ai.dmi'//
	icon_state = "ai"
	anchored = TRUE // -- TLE
	a_intent = INTENT_HARM // This is apparently the only thing that stops other mobs walking through them as if they were thin air.
	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_law_manager,
	)

/mob/living/silicon/decoy/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/aicard))
		to_chat(user, span_warning("You cannot find an intellicard slot on [src]."))
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
	return ..()

/mob/living/silicon/decoy/welder_act()
	return
