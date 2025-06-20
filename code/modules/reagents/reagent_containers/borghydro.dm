#define BORGHYPO_REFILL_VALUE 10

/obj/item/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	item_state = "hypo"
	icon = 'icons/obj/hypo.dmi'
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	/// It doesn't matter what reagent is used in the autohypos, so we don't!
	var/total_reagents = 50
	/// Maximum reagents that the base autohypo can store
	var/maximum_reagents = 50
	var/charge_cost = 50
	/// Used for delay with the recharge time, each charge tick is worth 2 seconds of real time
	var/charge_tick = 0
	/// How many SSobj ticks it takes for the reagents to recharge by 10 units
	var/recharge_time = 3
	/// Can the autohypo inject through thick materials?
	var/penetrate_thick = FALSE
	var/choosen_reagent = "salglu_solution"
	var/list/datum/reagents/reagent_list = list()
	var/list/reagent_ids = list("salglu_solution", "epinephrine", "spaceacillin", "charcoal", "hydrocodone", "mannitol", "salbutamol")
	var/list/reagent_ids_emagged = list("tirizene")
	var/static/list/reagent_icons = list("salglu_solution" = image(icon = 'icons/goonstation/objects/iv.dmi', icon_state = "ivbag"),
							"epinephrine" = image(icon = 'icons/obj/hypo.dmi', icon_state = "autoinjector"),
							"spaceacillin" = image(icon = 'icons/obj/decals.dmi', icon_state = "bio"),
							"charcoal" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill17"),
							"hydrocodone" = image(icon = 'icons/obj/chemical.dmi', icon_state = "bottle19"),
							"styptic_powder" = image(icon = 'icons/obj/chemical.dmi', icon_state = "bandaid_brute"),
							"salbutamol" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill8"),
							"sal_acid" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill4"),
							"syndicate_nanites" = image(icon = 'icons/obj/decals.dmi', icon_state = "greencross"),
							"potass_iodide" = image(icon = 'icons/obj/decals.dmi', icon_state = "radiation"),
							"mannitol" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill19"),
							"salbutamol" = image(icon = 'icons/obj/chemical.dmi', icon_state = "pill8"),
							"corazone" = image(icon = 'icons/obj/abductor.dmi', icon_state = "bed"),
							"tirizene" = image(icon = 'icons/obj/aibots.dmi', icon_state = "pancbot"))

/obj/item/reagent_containers/borghypo/surgeon
	reagent_ids = list("styptic_powder", "epinephrine", "salbutamol")
	total_reagents = 60
	maximum_reagents = 60

<<<<<<< HEAD
/obj/item/reagent_containers/borghypo/crisis
	reagent_ids = list("salglu_solution", "epinephrine", "sal_acid")
	total_reagents = 60
	maximum_reagents = 60
=======
/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	cyborg = null
	return ..()

/obj/item/reagent_containers/borghypo/process()
	if(!should_refill()) // no need to refill
		STOP_PROCESSING(SSobj, src)
		return
	if(!refill_delay) // no delay, refill it now
		refill_hypo(cyborg)
		return
	if(charge_tick < refill_delay) // not ready to refill
		charge_tick++
	else // ready to refill
		refill_hypo(cyborg)

// Use this to add more chemicals for the borghypo to produce.
/obj/item/reagent_containers/borghypo/proc/refill_hypo(mob/living/silicon/robot/user, quick = FALSE)
	if(quick) // gives us a hypo full of reagents no matter what
		for(var/reagent as anything in reagent_ids)
			if(reagent_ids[reagent] < volume)
				reagent_ids[reagent] = volume
		return
	if(istype(user) && user.cell && user.cell.use(charge_cost)) // we are a robot, we have a cell and enough charge? let's refill now
		if(charge_tick)
			charge_tick = 0
		for(var/reagent as anything in reagent_ids)
			if(reagent_ids[reagent] < volume)
				var/reagents_to_add = min(volume - reagent_ids[reagent], BORGHYPO_REFILL_VALUE)
				reagent_ids[reagent] = (reagent_ids[reagent] || 0) + reagents_to_add // in case if it's null somehow, set it to 0

// whether our hypo's reagents are at max volume or not
/obj/item/reagent_containers/borghypo/proc/should_refill()
	for(var/reagent as anything in reagent_ids)
		if(reagent_ids[reagent] < volume)
			return TRUE
	return FALSE

/obj/item/reagent_containers/borghypo/mob_act(mob/target, mob/living/user)
	if(!ishuman(target))
		return
	if(!reagent_ids[reagent_selected])
		to_chat(user, "<span class='warning'>The injector is empty.</span>")
		return
	var/mob/living/carbon/human/mob = target
	if(mob.can_inject(user, TRUE, user.zone_selected, penetrate_thick))
		to_chat(user, "<span class='notice'>You inject [mob] with [src].</span>")
		to_chat(mob, "<span class='notice'>You feel a tiny prick!</span>")
		var/reagents_to_transfer = min(amount_per_transfer_from_this, reagent_ids[reagent_selected])
		mob.reagents.add_reagent(reagent_selected, reagents_to_transfer)
		reagent_ids[reagent_selected] -= reagents_to_transfer
		START_PROCESSING(SSobj, src) // start processing so we can refill hypo
		if(play_sound)
			playsound(loc, 'sound/goonstation/items/hypo.ogg', 80, FALSE)
		if(mob.reagents)
			var/datum/reagent/injected = GLOB.chemical_reagents_list[reagent_selected]
			var/contained = injected.name
			add_attack_logs(user, mob, "Injected with [name] containing [contained], transfered [reagents_to_transfer] units", injected.harmless ? ATKLOG_ALMOSTALL : null)
			to_chat(user, "<span class='notice'>[reagents_to_transfer] units injected. [reagent_ids[reagent_selected]] units remaining.</span>")

/obj/item/reagent_containers/borghypo/proc/get_radial_contents()
	return reagent_icons & reagent_ids

/obj/item/reagent_containers/borghypo/activate_self(mob/user)
	if(..())
		return

	playsound(loc, 'sound/effects/pop.ogg', 50, 0)
	var/selected_reagent = show_radial_menu(user, src, get_radial_contents(), radius = 48)
	if(!selected_reagent)
		return
	var/datum/reagent/R = GLOB.chemical_reagents_list[selected_reagent]
	to_chat(user, "<span class='notice'>Synthesizer is now dispensing [R.name].</span>")
	reagent_selected = selected_reagent

/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()
	var/datum/reagent/get_reagent_name = GLOB.chemical_reagents_list[reagent_selected]
	. |= "<span class='notice'>Contains [reagent_ids[reagent_selected]] units of [get_reagent_name.name].</span>"

/obj/item/reagent_containers/borghypo/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		penetrate_thick = TRUE
		play_sound = FALSE
		reagent_ids += reagent_ids_emagged
		refill_hypo(quick = TRUE)
		return
	emagged = FALSE
	penetrate_thick = FALSE
	play_sound = initial(play_sound)
	reagent_ids -= reagent_ids_emagged
	refill_hypo(quick = TRUE)
>>>>>>> f52435ff064b75d6426124baab926c0dd89c0910

/obj/item/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "An experimental piece of Syndicate technology used to produce powerful restorative nanites used to very quickly restore injuries of all types. Also metabolizes potassium iodide, for radiation poisoning, and hydrocodone, for field surgery and pain relief."
	icon_state = "borghypo_s"
	charge_cost = 20
	recharge_time = 2 // No time to recharge
	reagent_ids = list("syndicate_nanites", "potass_iodide", "hydrocodone")
	total_reagents = 30
	maximum_reagents = 30
	penetrate_thick = TRUE
	choosen_reagent = "syndicate_nanites"

/obj/item/reagent_containers/borghypo/abductor
	charge_cost = 40
	recharge_time = 3
	reagent_ids = list("salglu_solution", "epinephrine", "hydrocodone", "spaceacillin", "charcoal", "mannitol", "salbutamol", "corazone")
	penetrate_thick = TRUE

/obj/item/reagent_containers/borghypo/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	charge_tick++
	if(charge_tick < recharge_time)
		return FALSE
	charge_tick = 0
	refill_borghypo()
	return TRUE

// Use this to add more chemicals for the borghypo to produce.
/obj/item/reagent_containers/borghypo/proc/refill_borghypo(reagent_id, mob/living/silicon/robot/robot)
	if(istype(robot))
		robot.cell.use(charge_cost)
	total_reagents = min((total_reagents + BORGHYPO_REFILL_VALUE), maximum_reagents)

/obj/item/reagent_containers/borghypo/attack__legacy__attackchain(mob/living/carbon/human/M, mob/user)
	if(!total_reagents)
		to_chat(user, "<span class='warning'>The injector is empty.</span>")
		return
	if(!istype(M))
		return
	if(total_reagents && M.can_inject(user, TRUE, user.zone_selected, penetrate_thick))
		to_chat(user, "<span class='notice'>You inject [M] with the injector.</span>")
		to_chat(M, "<span class='notice'>You feel a tiny prick!</span>")

		M.reagents.add_reagent(choosen_reagent, 5)
		total_reagents = (total_reagents - 5)
		if(M.reagents)
			var/datum/reagent/injected = GLOB.chemical_reagents_list[choosen_reagent]
			var/contained = injected.name
			add_attack_logs(user, M, "Injected with [name] containing [contained], transfered [5] units", injected.harmless ? ATKLOG_ALMOSTALL : null)
			to_chat(user, "<span class='notice'>[5] units injected. [total_reagents] units remaining.</span>")

/obj/item/reagent_containers/borghypo/proc/get_radial_contents()
	return reagent_icons & reagent_ids

/obj/item/reagent_containers/borghypo/attack_self__legacy__attackchain(mob/user)
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)
	var/selected_reagent = show_radial_menu(user, src, get_radial_contents(), radius = 48)
	if(!selected_reagent)
		return
	charge_tick = 0 //Prevents wasted chems/cell charge if you're cycling through modes.
	var/datum/reagent/R = GLOB.chemical_reagents_list[selected_reagent]
	to_chat(user, "<span class='notice'>Synthesizer is now producing [R.name].</span>")
	choosen_reagent = selected_reagent

/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()
	var/datum/reagent/get_reagent_name = GLOB.chemical_reagents_list[choosen_reagent]
	. |= "<span class='notice'>It is currently dispensing [get_reagent_name.name]. Contains [total_reagents] units of various reagents.</span>" // We couldn't care less what actual reagent is in the container, just if there IS reagent in it

/obj/item/reagent_containers/borghypo/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		penetrate_thick = TRUE
		reagent_ids += reagent_ids_emagged
		return
	emagged = FALSE
	penetrate_thick = FALSE
	reagent_ids -= reagent_ids_emagged

/obj/item/reagent_containers/borghypo/basic
	name = "Basic Medical Hypospray"
	desc = "A very basic medical hypospray, capable of providing simple medical treatment in emergencies."
	reagent_ids = list("salglu_solution", "epinephrine")
	total_reagents = 30
	maximum_reagents = 30

#undef BORGHYPO_REFILL_VALUE
