//NUCLEATION INTERNAL ORGANS
/obj/item/organ/internal/nucleation
	species_type = /datum/species/nucleation
	name = "nucleation organ"

/obj/item/organ/internal/nucleation/resonant_crystal
	name = "resonant crystal"
	desc = "Жёлтого цвета странно выглядящий кристалл. Судя по всему, он принадлежал нуклеату."
	icon_state = "resonant-crystal"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_RESONANT_CRYSTAL

/obj/item/organ/internal/nucleation/resonant_crystal/get_ru_names()
	return list(
		NOMINATIVE = "резонантный кристалл",
		GENITIVE = "резонантного кристалла",
		DATIVE = "резонантному кристаллу",
		ACCUSATIVE = "резонантный кристалл",
		INSTRUMENTAL = "резонантным кристаллом",
		PREPOSITIONAL = "резонантном кристалле",
	)

/obj/item/organ/internal/nucleation/strange_crystal
	name = "strange crystal"
	desc = "Жёлтого цвета странно выглядящий кристалл. Судя по всему, он принадлежал нуклеату."
	icon_state = "strange-crystal"
	slot = INTERNAL_ORGAN_STRANGE_CRYSTAL
	unremovable = TRUE // only one per nucleation
	var/stored_rad = 1000
	var/max_stored_rad = 5000

/obj/item/organ/internal/nucleation/strange_crystal/get_ru_names()
	return list(
		NOMINATIVE = "странный кристалл",
		GENITIVE = "странного кристалла",
		DATIVE = "странному кристаллу",
		ACCUSATIVE = "странный кристалл",
		INSTRUMENTAL = "странным кристаллом",
		PREPOSITIONAL = "странном кристалле",
	)

/obj/item/organ/internal/nucleation/strange_crystal/on_life()
	. = ..()

	if(!owner)
		return


	var/target_rad = RADIATION_LEVEL_NORMAL
	var/rad = owner.radiation
	var/boost = owner.pulse / 2

	if(stored_rad && rad < target_rad)
		irradiate(owner, round(10 * boost, 1))

/obj/item/organ/internal/nucleation/strange_crystal/proc/irradiate(mob/living/carbon/human/H, amount)
	var/rad = min(stored_rad, amount)

	H.apply_effect(rad, IRRADIATE, negate_armor = 1)
	stored_rad -= rad

/obj/item/organ/internal/heart/crystal
	species_type = /datum/species/nucleation
	name = "crystallized heart"
	desc = "Основной орган кровеносной системы гуманоида. Судя по кристаллизированной структуре, этот принадлежал нуклеату."
	icon_state = "crystal-heart"

/obj/item/organ/internal/heart/crystal/get_ru_names()
	return list(
		NOMINATIVE = "кристаллизированное сердце",
		GENITIVE = "кристаллизированного сердца",
		DATIVE = "кристаллизированному сердцу",
		ACCUSATIVE = "кристаллизированное сердце",
		INSTRUMENTAL = "кристаллизированным сердцем",
		PREPOSITIONAL = "кристаллизированном сердце",
	)

/obj/item/organ/internal/eyes/luminescent_crystal
	species_type = /datum/species/nucleation
	name = "luminescent eyes"
	desc = "Необычного вида глаза, источающие свет. Эти принадлежали нуклеату."
	icon_state = "crystal-eyes"
	light_color = "#f7f792"
	light_range = 2

/obj/item/organ/internal/eyes/luminescent_crystal/get_ru_names()
	return list(
		NOMINATIVE = "люминесцентные глаза",
		GENITIVE = "люминесцентных глаз",
		DATIVE = "люминесцентным глазам",
		ACCUSATIVE = "люминесцентные глаза",
		INSTRUMENTAL = "люминесцентными глазами",
		PREPOSITIONAL = "люминесцентных глазах",
	)

/obj/item/organ/internal/brain/crystal
	species_type = /datum/species/nucleation
	name = "crystallized brain"
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Судя по кристаллизированной структуре, этот принадлежал нуклеату."
	icon_state = "crystal-brain"

/obj/item/organ/internal/brain/crystal/get_ru_names()
	return list(
		NOMINATIVE = "кристаллизированный мозг",
		GENITIVE = "кристаллизированного мозга",
		DATIVE = "кристаллизированному мозгу",
		ACCUSATIVE = "кристаллизированный мозг",
		INSTRUMENTAL = "кристаллизированным мозгом",
		PREPOSITIONAL = "кристаллизированном мозге",
	)

/obj/item/organ/internal/brain/crystal/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT)
	..(target, special)
	if(isnucleation(target))
		return //no need to apply disease to nucleation
	var/datum/disease/virus/nuclefication/D = new()
	D.Contract(target, need_protection_check = FALSE)

// NUCLEATION EXTERNAL ORGANS
/obj/item/organ/external/nucleation
	species_type = /datum/species/nucleation
	name = "nucleation external organ"
	desc = "внешний орган нуклеата."
	cannot_internal_bleed = TRUE
	burn_mod = 4 // as weak as before but won't blow up instantly >:]

/obj/item/organ/external/nucleation/external_receive_damage(
	brute = 0,
	burn = 0,
	blocked = 0,
	sharp = FALSE,
	used_weapon = null,
	list/forbidden_limbs = null,
	forced = FALSE,
	updating_health = TRUE,
	silent = FALSE,
)
	burn *= burn_mod
	if(burn)
		owner.bodytemperature += burn // ignoring any resistance cuz "balance"
		burn = 0

	..()

