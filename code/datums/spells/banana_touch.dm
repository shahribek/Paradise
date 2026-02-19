/obj/effect/proc_holder/spell/touch/banana
	name = "Banana Touch"
	desc = "A spell popular at wizard birthday parties, this spell will put on a clown costume on the target, \
		stun them with a loud HONK, and mutate them to make them more entertaining! \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/banana
	school = "transmutation"

	base_cooldown = 30 SECONDS
	cooldown_min = 10 SECONDS //50 deciseconds reduction per rank
	action_icon_state = "clown"

/obj/item/melee/touch_attack/banana
	name = "banana touch"
	desc = "It's time to start clowning around."
	catchphrase = "NWOLC YRGNA"
	on_use_sound = 'sound/items/AirHorn.ogg'
	icon_state = "banana_touch"
	item_state = "banana_touch"

/obj/item/melee/touch_attack/banana/afterattack(atom/target, mob/living/carbon/user, proximity, params)
	if(!proximity || target == user || !ishuman(target) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 5, location = target)
	smoke.start()

	to_chat(user, "<font color='red' size='6'>HONK</font>")
	var/mob/living/carbon/human/h_target = target
	h_target.bananatouched()
	..()

/mob/living/carbon/human/proc/bananatouched()
	to_chat(src, "<font color='red' size='6'>HONK</font>")
	Weaken(14 SECONDS)
	Stuttering(30 SECONDS)
	do_jitter_animation(15)

	qdel(shoes)
	qdel(wear_mask)
	qdel(w_uniform)
	equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown/nodrop, ITEM_SLOT_CLOTH_INNER)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes/nodrop, ITEM_SLOT_FEET)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat/nodrop, ITEM_SLOT_MASK)
	force_gene_block(GLOB.clumsyblock, TRUE)
	force_gene_block(GLOB.comicblock, TRUE)
