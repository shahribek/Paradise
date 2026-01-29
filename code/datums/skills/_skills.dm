GLOBAL_LIST_INIT(skill_types, init_skills_list())
GLOBAL_LIST_INIT(skill_names, list(
	SKILL_LEVEL_UNAVAILABLE = SKILL_UNAVAILABLE,
	SKILL_LEVEL_NONE = SKILL_NONE,
	SKILL_LEVEL_BEGINNER = SKILL_BEGINNER,
	SKILL_LEVEL_BASIC = SKILL_BASIC,
	SKILL_LEVEL_ADVANCED = SKILL_ADVANCED,
	SKILL_LEVEL_PROFESSIONAL = SKILL_EXPERT,
	SKILL_LEVEL_EXPERT = SKILL_EXPERT,
	SKILL_LEVEL_LEGEND = SKILL_LEGEND,
))

/datum/skill
	var/name = "Skilling"
	var/title = "Skiller"
	var/desc = "the art of doing things"
	///Dictionary of modifier type - list of modifiers (indexed by level). 7 entries in each list for all 7 skill levels.
	var/modifiers = list(
		SKILL_SPEED_MODIFIER = list(2, 1.5, 1, 0.75, 0.5, 0.25, 0.1),
		SKILL_EFFICIENCE_MODIFIER = list(0.5, 0.75, 1, 1.25, 1.5, 2, 3),
		SKILL_VALUE_MODIFIER = list(0, 0, 0, 1, 2, 3, 4)
	)
/datum/skill/proc/get_skill_modifier(modifier, level)
	return modifiers[modifier][level] //Levels range from 1 (None) to 7 (Legendary)

/datum/skill/proc/on_level_change(datum/mind/mind, newlevel, oldlevel)
	return

/datum/skill/proc/unavailable_massage()
	switch(rand(1, 100))
		if(1)
			return "Ты долбаёб"
		if(2 to 25)
			return "Слишком сложно!"
		if(26 to 50)
			return "Ты такое не умеешь!"
		if(51 to 75)
			return "Ты в недоумении!"
		if(76 to 100)
			return "Хмм..."

/proc/init_skills_list()
	var/list/skills = subtypesof(/datum/skill)
	var/list/output = list()
	for(var/datum/skill/skill as anything in skills)
		output[skill.title] = skill
	return output
