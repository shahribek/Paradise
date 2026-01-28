
// Skill levels
#define SKILL_LEVEL_NONE 1
#define SKILL_LEVEL_NOVICE 2
#define SKILL_LEVEL_APPRENTICE 3
#define SKILL_LEVEL_JOURNEYMAN 4
#define SKILL_LEVEL_EXPERT 5
#define SKILL_LEVEL_MASTER 6
#define SKILL_LEVEL_LEGENDARY 7

#define SKILL_LVL 1

//Skill modifier types
///ideally added/subtracted in speed calculations to make you do stuff faster
#define SKILL_SPEED_MODIFIER "skill_speed_modifier"
///ideally added/subtracted where beneficial in prob(x) calls
#define SKILL_PROBS_MODIFIER "skill_probability_modifier"
///ideally added/subtracted where beneficial in rand(x,y) calls
#define SKILL_RANDS_MODIFIER "skill_randomness_modifier"
///ideally for addittive operations
#define SKILL_VALUE_MODIFIER "skill_value_modifier"

// Gets the reference for the skill type that was given
#define GetSkillRef(A) (SSskills.all_skills[A])
