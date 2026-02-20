///AI Upgrades

//Lipreading
/obj/item/surveillance_upgrade
	name = "surveillance software upgrade"
	desc = "A software package that will allow an artificial intelligence to 'hear' from its cameras via lip reading."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"

/obj/item/surveillance_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user, proximity, params)
	if(!istype(AI))
		return
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = 1
		to_chat(AI, span_userdanger("[user] has upgraded you with surveillance software!"))
		to_chat(AI, "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations.")
	to_chat(user, span_notice("You upgrade [AI]. [src] is consumed in the process."))
	qdel(src)
