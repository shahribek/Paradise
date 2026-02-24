/obj/item/suit_sensor
	name = "suit sensor"
	desc = "Маленькое устройство, которое крепится на одежду и позволяет отслеживать жизненные показатели и местополежние владельца"
	var/obj/item/clothing/under/suit = null
	var/sensor_state = SENSOR_OFF
	var/locked = FALSE
	var/static/list/modes = list(
		SENSOR_OFF_STRING = SENSOR_OFF,
		SENSOR_LIVING_STRING = SENSOR_LIVING,
		SENSOR_VITALS_STRING = SENSOR_VITALS,
		SENSOR_COORDS_STRING = SENSOR_COORDS,
	)

/obj/item/suit_sensor/get_ru_names()
	return list(
		NOMINATIVE = "датчик костюма",
		GENITIVE = "датчика костюма",
		DATIVE = "датчику костюма",
		ACCUSATIVE = "датчик костюма",
		INSTRUMENTAL = "датчиком костюма",
		PREPOSITIONAL = "датчике костюма",
	)

/obj/item/suit_sensor/attack_self(mob/user)
	. = ..()
	if(!user)
		return
	toggle(user)

/obj/item/suit_sensor/proc/toggle(mob/user)
	var/switchMode = tgui_input_list(user, "Выберите режим работы датчиков:", "Режим работы датчиков костюма", modes)
	if(!switchMode)
		return
	if(get_dist(user, src) > 1)
		balloon_alert(user, "слишком далеко!")
		return

	switch_sensor_state(modes[switchMode])

	return TRUE

/obj/item/suit_sensor/proc/switch_sensor_state(state)
	sensor_state = state
	if(suit)
		suit.sensor_mode = state
	else
		to_chat(src, span_notice("Датчик теперь в режиме \"[modes[sensor_state]]\"."))

/obj/item/suit_sensor/proc/install(obj/item/clothing/under/under, mob/user)
	if(crit_fail)
		user.balloon_alert(user, "Датчики повреждены!")
		return FALSE
	if(user)
		if(!user.drop_transfer_item_to_loc(src, under))
			return FALSE
	else
		forceMove(under)
		sensor_state = under.sensor_mode

	suit = under
	under.suit_sensor = src
	return TRUE

/obj/item/suit_sensor/emp_act(severity)
	switch_sensor_state(SENSOR_OFF)
	locked = TRUE
	crit_fail = TRUE
	if(suit)
		suit.desc += " Проводка датчиков слежки повреждена!"
	desc += " Провода датчиков повреждены!"

/obj/item/suit_sensor/proc/repair()
	locked = initial(src.locked)
	crit_fail = FALSE
	if(suit)
		suit.desc -= " Проводка датчиков слежки повреждена!"
	desc -=" Провода датчиков повреждены!"


