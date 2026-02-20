/obj/machinery/bluespace_beacon
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = WIRE_LAYER
	plane = FLOOR_PLANE
	layer = 2.5
	anchored = TRUE
	var/syndicate = 0
	var/area_bypass = FALSE
	var/obj/item/beacon/Beacon
	var/enabled = TRUE
	var/cc_beacon = FALSE //can be teleported to even if on zlevel2

/obj/machinery/bluespace_beacon/Initialize(mapload)
	. = ..()
	create_beacon()

/obj/machinery/bluespace_beacon/proc/create_beacon()
	var/turf/T = loc
	Beacon = new /obj/item/beacon
	Beacon.invisibility = INVISIBILITY_MAXIMUM
	Beacon.loc = T
	Beacon.syndicate = syndicate
	Beacon.area_bypass = area_bypass
	Beacon.cc_beacon = cc_beacon
	if(!T.transparent_floor)
		hide(T.intact)

/obj/machinery/bluespace_beacon/proc/destroy_beacon()
	QDEL_NULL(Beacon)

/obj/machinery/bluespace_beacon/proc/toggle()
	enabled = !enabled
	return enabled

/obj/machinery/bluespace_beacon/Destroy()
	destroy_beacon()
	return ..()

/obj/machinery/bluespace_beacon/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon(UPDATE_ICON_STATE)

// update the icon_state
/obj/machinery/bluespace_beacon/update_icon_state()
	var/state="floor_beacon"
	if(invisibility)
		icon_state = "[state]f"
	else
		icon_state = "[state]"

/obj/machinery/bluespace_beacon/process()
	if(enabled)
		if(Beacon)
			if(Beacon.loc != loc)
				Beacon.loc = loc
		else
			create_beacon()
			update_icon(UPDATE_ICON_STATE)
	else
		if(Beacon)
			destroy_beacon()
			update_icon(UPDATE_ICON_STATE)
