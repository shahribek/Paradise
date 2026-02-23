/obj/effect/spawner/random_spawners	//number means chanse to create obj
	name = "random spawners"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "standart"
	var/list/result = list(
	/turf/simulated/floor/plasteel = 1,
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/blood/splatter = 1,
	/obj/effect/decal/cleanable/blood/oil = 1,
	/obj/effect/decal/cleanable/fungus = 1)
	var/spawn_inside = null
	var/use_power = null // Хотим ли мы чтобы то, что мы спавним, тратило электричество
	var/active_power_usage = null // Сколько энергии оно тратит если активно
	var/idle_power_usage = null // Сколько энергии оно тратит в пассивном режиме

/obj/effect/spawner/random_spawners/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		stack_trace("Spawner placed in nullspace!")
		return
	randspawn(T)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/random_spawners/proc/randspawn(turf/T)
	var/thing_to_place = pickweight(result)
	if(ispath(thing_to_place, /datum/nothing))
		qdel(src)
		return
	else if(ispath(thing_to_place, /turf))
		T.ChangeTurf(thing_to_place)
	else
		if(ispath(spawn_inside, /obj))
			var/obj/O = new thing_to_place(T)
			var/obj/E = new spawn_inside(T)
			if(pixel_x	||	pixel_y	||	pixel_z) //Чтобы если мы меняем по пикселям позицию спавнера, это меняло и позицию того, что мы спавним
				E.pixel_x = pixel_x
				E.pixel_y = pixel_y
				E.pixel_z = pixel_z
			O.forceMove(E)
		else
			var/obj/O = new thing_to_place(T)
			if(pixel_x	||	pixel_y	||	pixel_z) //Чтобы если мы меняем по пикселям позицию спавнера, это меняло и позицию того, что мы спавним
				O.pixel_x = pixel_x
				O.pixel_y = pixel_y
				O.pixel_z = pixel_z
			if(use_power && ismachinery(O)) //В основном для спавна туррелей. Чтобы туррели тратили электричество при работе
				var/obj/machinery/OM = O
				OM.use_power = use_power
				if(active_power_usage)
					OM.active_power_usage = active_power_usage
				if(idle_power_usage)
					OM.idle_power_usage = idle_power_usage

/obj/effect/spawner/random_spawners/blood_5
	name = "blood maybe"
	icon_state = "blood"
	result = list(
		/datum/nothing = 20,
		/obj/effect/decal/cleanable/blood/splatter = 1,
	)

/obj/effect/spawner/random_spawners/blood_20
	name = "blood often"
	icon_state = "blood"
	result = list(
		/datum/nothing = 5,
		/obj/effect/decal/cleanable/blood/splatter = 1,
	)

/obj/effect/spawner/random_spawners/oil_5
	name = "oil maybe"
	icon_state = "oil"
	result = list(
		/datum/nothing = 20,
		/obj/effect/decal/cleanable/blood/oil = 1,
	)

/obj/effect/spawner/random_spawners/oil_20
	name = "oil often"
	icon_state = "oil"
	result = list(
		/datum/nothing = 5,
		/obj/effect/decal/cleanable/blood/oil = 1,
	)

/obj/effect/spawner/random_spawners/wall_rusted_70
	name = "rusted wall probably"
	icon_state = "rusted"
	result = list(
		/turf/simulated/wall = 3,
		/turf/simulated/wall/rust = 7,
	)

/obj/effect/spawner/random_spawners/wall_rusted_30
	name = "rusted wall maybe"
	icon_state = "rusted"
	result = list(
		/turf/simulated/wall = 7,
		/turf/simulated/wall/rust = 3,
	)

/obj/effect/spawner/random_spawners/cobweb_left_frequent
	name = "cobweb left frequent"
	icon_state = "coweb"
	result = list(
		/datum/nothing = 1,
		/obj/effect/decal/cleanable/cobweb = 1,
	)

/obj/effect/spawner/random_spawners/cobweb_right_frequent
	name = "cobweb right frequent"
	icon_state = "coweb1"
	result = list(
		/datum/nothing = 1,
		/obj/effect/decal/cleanable/cobweb2 = 1,
	)

/obj/effect/spawner/random_spawners/cobweb_left_rare
	name = "cobweb left rare"
	icon_state = "coweb"
	result = list(
		/datum/nothing = 10,
		/obj/effect/decal/cleanable/cobweb = 1,
	)

/obj/effect/spawner/random_spawners/cobweb_right_rare
	name = "cobweb right rare"
	icon_state = "coweb1"
	result = list(
		/datum/nothing = 10,
		/obj/effect/decal/cleanable/cobweb2 = 1,
	)

/obj/effect/spawner/random_spawners/dirt_50
	name = "dirt frequent"
	icon_state = "dirt"
	result = list(
		/datum/nothing = 1,
		/obj/effect/decal/cleanable/dirt = 1,
	)

/obj/effect/spawner/random_spawners/dirt_10
	name = "dirt rare"
	icon_state = "dirt"
	result = list(
		/datum/nothing = 10,
		/obj/effect/decal/cleanable/dirt = 1,
	)

/obj/effect/spawner/random_spawners/fungus_30
	name = "rusted wall maybe"
	icon_state = "fungus"
	result = list(
		/turf/simulated/wall = 7,
		/obj/effect/decal/cleanable/fungus = 3,
	)

/obj/effect/spawner/random_spawners/fungus_70
	name = "rusted wall maybe"
	icon_state = "fungus"
	result = list(
		/turf/simulated/wall = 3,
		/obj/effect/decal/cleanable/fungus = 7,
	)

/obj/effect/spawner/random_spawners/rodent
	name = "33pc mouse 33pc rat 33pc cockroach"
	icon_state = "mouse"
	result = list(
		/mob/living/simple_animal/mouse = 1,
		/mob/living/simple_animal/mouse/white = 1,
		/mob/living/simple_animal/mouse/brown = 1,
		/mob/living/simple_animal/mouse/rat = 1,
		/mob/living/simple_animal/mouse/rat/white = 1,
		/mob/living/simple_animal/mouse/rat/irish = 1,
		/mob/living/basic/cockroach = 3,
	)

/obj/effect/spawner/random_spawners/rat
	name = "random color rat"
	icon_state = "rat"
	result = list(
		/mob/living/simple_animal/mouse/rat = 1,
		/mob/living/simple_animal/mouse/rat/white = 1,
		/mob/living/simple_animal/mouse/rat/irish = 1,
	)

/obj/effect/spawner/random_spawners/crate_spawner // for ruins
	name = "lootcrate spawner"
	icon_state = "lootcrate"
	result = list(
		/obj/structure/closet/crate/secure/loot = 20,
		/datum/nothing = 80,
	)

//random lavaland loot
/obj/effect/spawner/random_spawners/lavaland_random_loot //terraria fishing vibes
	name = "33pc random lavaland minor loot"
	result = list(
		/datum/nothing = 40, //40-20
		/obj/item/stack/sheet/sinew/five = 4,
		/obj/item/stack/sheet/animalhide/goliath_hide/five = 2,
		/obj/item/stack/sheet/animalhide/ashdrake = 1,
		/obj/item/stack/sheet/animalhide/weaver_chitin/five = 3,
		/obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit = 3,
		/obj/item/kitchen/knife/combat/survival/bone = 1,
		/obj/item/gem/random = 5,
		/obj/item/clothing/accessory/necklace/gem = 1,
	)

/obj/effect/spawner/random_spawners/forty_pc_skull
	name = "40pc scorched_skull"
	result = list(
		/datum/nothing = 60,
		/obj/item/clothing/head/scorched_skull = 40,
	)

/obj/effect/spawner/random_spawners/mod
	name = "MOD module spawner"
	icon_state = "circuit"

/obj/effect/spawner/random_spawners/mod/maint
	name = "maint MOD module spawner"
	result = list(
		/obj/item/mod/module/springlock = 2,
		/obj/item/mod/module/balloon = 1,
		/obj/item/mod/module/stamp = 1,
		/obj/item/mod/module/paper_dispenser = 1,
		/obj/item/mod/module/hat_stabilizer = 2,
		/obj/item/mod/module/bikehorn = 1,
		/obj/item/mod/module/dispenser = 1,
	)

// Security armory random guns
/obj/effect/spawner/random_spawners/security_lasers
	name = "lasers closet spawner"
	icon_state = "guncabinet_laser"
	result = list(
		/obj/structure/closet/secure_closet/guncabinet/lasergun = 50,
		/obj/structure/closet/secure_closet/guncabinet/lr30 = 50,
	)

/obj/effect/spawner/random_spawners/security_ballistics
	name = "ballistics closet spawner"
	icon_state = "guncabinet_ballistic"
	result = list(
		/obj/structure/closet/secure_closet/guncabinet/sparkle_a12 = 33,
		/obj/structure/closet/secure_closet/guncabinet/sp91 = 33,
		/obj/structure/closet/secure_closet/guncabinet/wt550 = 34,
	)
