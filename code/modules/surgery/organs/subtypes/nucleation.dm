//NUCLEATION ORGAN
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

	if(stored_rad)
		switch(owner.radiation)
			if(0 to RADIATION_LEVEL_LOW - 1)
				owner.apply_effect(min(stored_rad, RADIATION_LEVEL_LOW - owner.radiation), IRRADIATE, negate_armor = TRUE)
				stored_rad -= min(stored_rad, RADIATION_LEVEL_LOW - owner.radiation)
			if(RADIATION_LEVEL_LOW to RADIATION_LEVEL_NORMAL - 1)
				owner.apply_effect(min(stored_rad, 10), IRRADIATE, negate_armor = TRUE)
				stored_rad -= min(stored_rad, 10)
			if(RADIATION_LEVEL_NORMAL to RADIATION_LEVEL_HIGH - 1)
				owner.apply_effect(min(stored_rad, 5), IRRADIATE, negate_armor = TRUE)
				stored_rad -= min(stored_rad, 5)
			// TO-DO:
			// make it work with heart-beat rate as irradiation multiplier
			// make sure that reagent processing proc gives to this organ radiation

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

