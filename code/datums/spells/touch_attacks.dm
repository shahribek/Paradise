/obj/item/melee/touch_attack
	name = "outstretched hand"
	desc = "High Five?"
	icon_state = "syndballoon"
	item_state = null
	item_flags = ABSTRACT|DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throw_range = 0
	throw_speed = 0
	/// If defined caster will say this on afterattack
	var/catchphrase = "High Five!"
	/// Sound used on successful afterattack
	var/on_use_sound = null

	/// Special message shown on item deletion. Used as a part of [/obj/effect/proc_holder/spell/touch]. Do not change manually.
	var/on_withdraw_message
	/// Whether an item needs to show message stored in "on_remove_message". This is needed to distinguish actual [proc/discharge_hand] from any qdels. Do not change manually.
	var/is_withdraw = FALSE
	/// Spell this item belongs to
	var/obj/effect/proc_holder/spell/touch/attached_spell
	/// Current owner of the item
	var/mob/living/carbon/owner

/obj/item/melee/touch_attack/New(spell, owner)
	attached_spell = spell
	src.owner = owner
	..()

/obj/item/melee/touch_attack/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/melee/touch_attack/Destroy()
	if(owner)
		if(is_withdraw && on_withdraw_message)
			to_chat(owner, on_withdraw_message)
		owner = null

	if(attached_spell)
		attached_spell.attached_hand = null
		attached_spell.UnregisterSignal(attached_spell.action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)

	return ..()

/obj/item/melee/touch_attack/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!iscarbon(user)) //Look ma, no hands
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't reach out!"))
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
	return ..()

/obj/item/melee/touch_attack/afterattack(atom/target, mob/user, proximity, params)
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(catchphrase)
		user.say(catchphrase)
	playsound(get_turf(user), on_use_sound, 50, TRUE)
	if(attached_spell)
		attached_spell.perform(list())
	qdel(src)

/obj/effect/proc_holder/spell/touch
	/// What type of item this spell summons
	var/hand_path = /obj/item/melee/touch_attack
	/// Link to the spawned item
	var/obj/item/melee/touch_attack/attached_hand = null
	/// Special message shown on item gain
	var/on_gain_message = span_notice("You channel the power of the spell to your hand.")
	/// Special message shown on item withdrowal
	var/on_withdraw_message = span_notice("You draw the power out of your hand.")

/obj/effect/proc_holder/spell/touch/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/touch/Click()
	if(HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		to_chat(usr, span_warning("You can't control your hands!!"))
		return FALSE
	if(attached_hand)
		discharge_hand(usr, TRUE)
		return FALSE
	charge_hand(usr)

/obj/effect/proc_holder/spell/touch/proc/charge_hand(mob/living/carbon/user)

	var/obj/item/melee/touch_attack/new_hand = new hand_path(src, user)

	if(user.put_in_hands(new_hand, qdel_on_fail = TRUE))
		RegisterSignal(user, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(discharge_hand))

		attached_hand = new_hand

		if(on_gain_message)
			to_chat(user, on_gain_message)

		if(on_withdraw_message)
			new_hand.on_withdraw_message = on_withdraw_message
	else
		to_chat(user, span_warning("Your hands are full!"))

/obj/effect/proc_holder/spell/touch/proc/discharge_hand(atom/target, any_hand = FALSE)
	SIGNAL_HANDLER

	var/mob/living/carbon/user = action.owner
	if(!istype(attached_hand))
		return

	if(!any_hand && attached_hand != user.get_active_hand())
		return

	attached_hand.is_withdraw = TRUE
	QDEL_NULL(attached_hand)
	return COMPONENT_CANCEL_DROP
