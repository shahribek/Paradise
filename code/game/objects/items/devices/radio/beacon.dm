/obj/item/beacon
	name = "tracking beacon"
	desc = "A beacon used by a teleporter."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = "bluespace=1"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 200, MAT_GLASS = 100)

	var/syndicate = FALSE
	var/area_bypass = FALSE
	/// Set if allowed to teleport to even if on zlevel2
	var/cc_beacon = FALSE

/obj/item/beacon/Initialize(mapload)
	. = ..()
	GLOB.beacons |= src

/obj/item/beacon/Destroy()
	GLOB.beacons -= src
	return ..()

/obj/item/beacon/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		syndicate = TRUE
		if(user)
			to_chat(user, span_notice("The This beacon now only be locked on to by emagged teleporters!"))

/// Probably a better way of doing this, I'm lazy.
/obj/item/beacon/bacon

/obj/item/beacon/bacon/proc/digest_delay()
	QDEL_IN(src, 60 SECONDS)

/obj/item/beacon/engine
	desc = "A label on it reads: <i>Warning: This device is used for transportation of high-density objects used for high-yield power generation. Stay away!</i>."
	anchored = TRUE //Let's not move these around. Some folk might get the idea to use these for assassinations
	var/list/enginetype = list()

/obj/item/beacon/engine/Initialize(mapload)
	LAZYADD(GLOB.engine_beacon_list, src)
	return ..()

/obj/item/beacon/engine/Destroy()
	GLOB.engine_beacon_list -= src
	return ..()

/obj/item/beacon/engine/tesling
	name = "Engine Beacon for Tesla and Singularity"
	enginetype = list(ENGTYPE_TESLA, ENGTYPE_SING)

/obj/item/beacon/engine/tesla
	name = "Engine Beacon for Tesla"
	enginetype = list(ENGTYPE_TESLA)

/obj/item/beacon/engine/sing
	name = "Engine Beacon for Singularity"
	enginetype = list(ENGTYPE_SING)
