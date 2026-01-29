///Skill namings
#define SKILL_UNAVAILABLE "UNAVAILABLE"
#define SKILL_NONE "NONE"
#define SKILL_NOVICE "NOVICE"
#define SKILL_APPRENTICE "APPRENTICE"
#define SKILL_JOURNEYMAN "JOURNEYMAN"
#define SKILL_EXPERT "EXPERT"
#define SKILL_MASTER "MASTER"
#define SKILL_LEGENDARY "LEGENDARY"

// Skill levels
#define SKILL_LEVEL_UNAVAILABLE 0
#define SKILL_LEVEL_NONE 1
#define SKILL_LEVEL_NOVICE 2
#define SKILL_LEVEL_APPRENTICE 3
#define SKILL_LEVEL_JOURNEYMAN 4
#define SKILL_LEVEL_EXPERT 5
#define SKILL_LEVEL_MASTER 6
#define SKILL_LEVEL_LEGENDARY 7

//Skill modifier types
///ideally added/subtracted in speed calculations to make you do stuff faster
#define SKILL_SPEED_MODIFIER "skill_speed_modifier"
///how perfecly we can it
#define SKILL_EFFICIENCY_MODIFIER "skill officiency modifier"
///ideally added/subtracted where beneficial in prob(x) calls
#define SKILL_PROBS_MODIFIER "skill_probability_modifier"
///ideally added/subtracted where beneficial in rand(x,y) calls
#define SKILL_RANDS_MODIFIER "skill_randomness_modifier"
///ideally for addittive operations
#define SKILL_VALUE_MODIFIER "skill_value_modifier"

// Gets the reference for the skill type that was given
#define GetSkillRef(A) (GLOB.skill_types[A])

//GENERAL SKILLS
#define SKILL_CARRYING "carrying skill"
#define SKILL_EXOSUIT_CONTROL "exosuit controlling skill"
#define SKILL_MOD_CONTROL "MODsuit controlling skill"
#define SKILL_COOKING "cooking skill"

//SERVICE SKILLS
#define SKILL_DRINKING "drinking skill"
#define SKILL_BOTANICS "botanical skill"
#define SKILL_CLEANING "cleaning skill"

//COMBAT SKILLS
#define SKILL_ACCURACY "accuracy skill"
#define SKILL_RANGED_WEAPONS "ranged weapon skill"
#define SKILL_MELEE_WEAPONS "melee weapon skill"
#define SKILL_CQC "close quarter combat skill"
#define SKILL_SHIELDS "shield skill"

//ENGINEERING SKILLS
#define SKILL_BUILDING "building skill"
#define SKILL_CONSTRUCTION "construction skill"
#define SKILL_ELECTRICAL "electrical skill"
#define SKILL_ATMOS "atmos skill"
#define SKILL_HACKING "hacking skill"

//MEDICAL SKILLS
#define SKILL_SURGERY "surgical skill"
#define SKILL_HEALING "healing skill"
#define SKILL_CHEMISTRY "chemistry skill"
#define SKILL_GENETICS "genetic skill"
#define SKILL_VIROLOGY "virology skill"

//SCIENCE SKILLS
#define SKILL_RESEARCH "research skill"
#define SKILL_DESIGNING "designing skill"
#define SKILL_EXO_CONSTRUCTION "exostui construction skill"
#define SKILL_ANOMALIES "anomalist skill"
#define SKILL_XENOBIOLOGY "xenobiology"
