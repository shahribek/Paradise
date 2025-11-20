/datum/species/nucleation
	name = SPECIES_NUCLEATION
	name_plural = "Nucleations"
	icobase = 'icons/mob/human_races/r_nucleation.dmi'
	blacklisted = TRUE
	blurb = "A sub-race of unfortunates who have been exposed to too much supermatter radiation. As a result, \
	supermatter crystal clusters have begun to grow across their bodies. Research to find a cure for this ailment \
	has been slow, and so this is a common fate for veteran engineers. The supermatter crystals produce oxygen, \
	negating the need for the individual to breathe. Their massive change in biology, however, renders most medicines \
	obselete. Ionizing radiation seems to cause resonance in some of their crystals, which seems to encourage regeneration \
	and produces a calming effect on the individual. Nucleations are highly stigmatized, and are treated much in the same \
	way as lepers were back on Earth."
	language = LANGUAGE_SOL_COMMON
	blood_color = "#ada776"

	burn_mod = 4 // holy shite, poor guys wont survive half a second cooking smores
	brute_mod = 2 // damn, double wham, double dam
	tox_mod = 0 // nothing to intoxicate
	clone_mod = 0
	oxy_mod = 0 // no need to breathe
	coldmod = 0
	body_temperature = 290.15 // 17 С so yellow phosphorite wont ignite itself
	hazard_high_pressure = INFINITY
	warning_high_pressure = INFINITY
	warning_low_pressure = 0
	hazard_low_pressure = 0
	stun_mod = 0 // no dam muscles
	stamina_mod = 0.25 // it will become burn damage anyways and who will ever even think to use disablers to kill nuclies?

	heat_level_1 = 500 // also used as minimum required temprature for explosion on death and point of unstable state when nucleation starts to heat up for no reason
	heat_level_2 = 750
	heat_level_3 = 1000

	inherent_traits = list(
		TRAIT_EXOTIC_BLOOD,
		TRAIT_HAS_LIPS,
		TRAIT_NO_BREATH,
		TRAIT_NO_SCAN,
		TRAIT_NO_PAIN,
		TRAIT_NO_PAIN_HUD,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NO_GERMS,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_SUPERMATTERIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_BURNING_STAMINA,
	)
	bodyflags = HAS_BODY_MARKINGS
	ignore_critical_condition = TRUE // Nucleations do not suffer from complex critical condition
	dangerous_existence = TRUE // the only fact of their existance is dangerous
	can_revive_by_healing = TRUE // if somehow it does not explode
	var/touched_supermatter = FALSE

	exotic_blood = "radiocaesium"
	blood_color = "#9b8181"
	speciesbox = /obj/item/storage/box/survival/species/nucleation
	special_diet = MATERIAL_CLASS_TECH // our stomach can afford that

	//Default styles for created mobs.
	default_hair = "Nucleation Crystals"

	reagent_tag = PROCESS_NUC
	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/crystal,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/luminescent_crystal, //Standard darksight of 2.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
		INTERNAL_ORGAN_STRANGE_CRYSTAL = /obj/item/organ/internal/nucleation/strange_crystal,
		INTERNAL_ORGAN_RESONANT_CRYSTAL = /obj/item/organ/internal/nucleation/resonant_crystal,
	)

	var/static/list/alternate_organ_types = list(

	)
	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/nucleation

	age_sheet = list(
		SPECIES_AGE_MIN = 18,
		SPECIES_AGE_MAX = 230,
		JOB_MIN_AGE_HIGH_ED = 30,
		JOB_MIN_AGE_COMMAND = 30,
	)

/datum/species/nucleation/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	H.light_color = "#afaf21"
	H.set_light_range(2)

/datum/species/nucleation/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.light_color = null
	H.set_light_on(FALSE)

/datum/species/nucleation/handle_life(mob/living/carbon/human/H)

	// overheating damage
	var/crack_chance = 0 // chance every tick to take damage from overheating

	switch(H.bodytemperature)
		if(heat_level_1 to heat_level_2 - 1)
			crack_chance = 5
		if(heat_level_2 to heat_level_3 - 1)
			crack_chance = 10
		if(heat_level_3 to INFINITY)
			crack_chance = 15

	if(prob(crack_chance))
		H.visible_message(span_warning("Кристаллы на теле [H] трескаются!"))
		playsound(H, SFX_BONEBREAK, 150, TRUE)
		H.apply_damage(20, BRUTE) // total 40 damage to the chest from just overheating. Probably will also make a fracture and ignite mob

	// ignition of nucleation while having 30C+ body temperature
	if(H.bodytemperature > 303.15 && !H.on_fire)
		var/fractures = 0
		for(var/obj/item/organ/external/limb as anything in H.bodyparts)
			fractures += limb.has_fracture() // logic :nerd_emoji:
		H.fire_stacks += fractures
		H.IgniteMob()

	return ..()

/datum/species/nucleation/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "radium")
		if(R.volume >= 1)
			H.heal_overall_damage(3, 3)
			H.reagents.remove_reagent(R.id, 1)
			if(H.radiation < 80)
				H.apply_effect(4, IRRADIATE, negate_armor = 1)
			return FALSE //Что бы не выводилось больше одного, который уже вывелся за счет прока
	return ..()

/datum/species/nucleation/handle_death(gibbed, mob/living/carbon/human/human)
	if(human.health <= HEALTH_THRESHOLD_DEAD && human.bodytemperature >= heat_level_1)
		death_explosion(human)
		return

	human.adjustBruteLoss(15)
	human.do_jitter_animation(1000, 8)

/datum/species/nucleation/proc/death_explosion(mob/living/carbon/human/human)
	var/turf/turf = get_turf(human)

	human.visible_message(span_warning("Тело [human] взрывается, оставляя после себя множество микроскопических кристаллов!"))
	explosion(turf, devastation_range = round(human.bodytemperature / 1000), heavy_impact_range = round(human.bodytemperature / 750), light_impact_range = round(human.bodytemperature / 500), flash_range = round(human.bodytemperature / 250), cause = human) // Create an explosion depended on nucleations body temperature

	qdel(human)
