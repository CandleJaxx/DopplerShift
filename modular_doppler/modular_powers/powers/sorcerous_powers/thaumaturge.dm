/**
 * Root powers
 */

/datum/power/item/spellprep

	name = "Spell Preparation"
	desc = "Allows a Sorcerous individual to prepare and use a spellbook, which can be re-skinned as a spell focus or a bag of materials. All Thaumaturge abilities require the use of a spellbook."
	cost = 5
	root_power = /datum/power/item/spellprep
	power_type = TRAIT_PATH_SUBTYPE_THAUMATURGE
	gain_text = span_notice("You appear to have accidentaly picked up some random book instead of your spellbook...")

/datum/power/item/spellprep/add(mob/living/carbon/human/target)
	var/obj/item/book/random/spellbook = new(get_turf(target))
	spellbook.name = "[target.real_name]'s spellbook"
	give_item_to_holder(target, spellbook, list(
		LOCATION_LPOCKET,
		LOCATION_RPOCKET,
		LOCATION_BACKPACK,
		LOCATION_HANDS,
		),
	)

/**
 * Custom powers
 */

/obj/projectile/magic/fireball/thaum
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	exp_heavy = 0
	exp_light = 0
	exp_fire = 1
	exp_flash = 2

/datum/action/cooldown/spell/pointed/projectile/fireball/thaum
	name = "Lesser Fireball"
	desc = "This spell fires a weakened fireball at a target."
	button_icon_state = "fireball0"

	sound = 'sound/effects/magic/fireball.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 40 SECONDS

	invocation = "ONA SOMI!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to cast your weakened fireball spell!"
	deactive_msg = "You extinguish your fireball... for now."
	cast_range = 8
	projectile_type = /obj/projectile/magic/fireball/thaum

/datum/power/fireball_thaum
	name = "Lesser Fireball"
	desc = "This spell fires a weakened fireball at a target."
	cost = 4
	root_power = /datum/power/item/spellprep
	power_type = TRAIT_PATH_SUBTYPE_THAUMATURGE


/datum/power/fireball_thaum/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/pointed/projectile/fireball/thaum(target.mind || target)
	new_action.Grant(target)

/datum/action/cooldown/spell/conjure_item/infinite_guns/arcane_barrage/thaum
	name = "Lesser Arcane Barrage"
	desc = "Unleash a small torrent of energy at your foes with this spell."
	button_icon_state = "arcane_barrage"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cooldown_time = 120 SECONDS

/obj/item/ammo_casing/magic/arcane_barrage/thaum
	projectile_type = /obj/projectile/magic/arcane_barrage/thaum

/obj/projectile/magic/arcane_barrage/thaum
	name = "lesser arcane bolt"
	icon_state = "arcane_barrage"
	damage = 4
	damage_type = BURN
	hitsound = 'modular_doppler/modular_powers/sounds/barragespellhit.ogg'

/obj/item/gun/magic/wand/arcane_barrage/thaum
	name = "lesser arcane barrage"
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage/thaum

/datum/power/arcane_barrage_thaum
	name = "Lesser Arcane Barrage"
	desc = "Unleash a small torrent of energy at your foes with this spell."
	cost = 5
	root_power = /datum/power/item/spellprep
	power_type = TRAIT_PATH_SUBTYPE_THAUMATURGE

/datum/power/arcane_barrage_thaum/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/conjure_item/infinite_guns/arcane_barrage/thaum(target.mind || target)
	new_action.Grant(target)

/datum/action/cooldown/spell/touch/fleshmend_lesser
	name = "Lesser Fleshmend"
	desc = "Tought to nearly every apprentice by the Spinward Independent Magicians, \
		this spell transmutes a portion of the target's blood and the caster's mana into freshly grown bands \
		of new flesh with one slight caveat: <b>it is EXCRUCIATINGLY painful for the recipient.</b> It also \
		cannot completely mend flesh - some medical assistance will be required, but it is enough to a mage \
		or their apprentice back on their feet (and maybe wishing they weren't)."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"

	school = SCHOOL_SANGUINE
	cooldown_time = 60 SECONDS

	invocation_type = INVOCATION_NONE
	invocation = "Tronsum Lunae Santinus Eurekant Oonzu" //if you know, you know

	hand_path = /obj/item/melee/touch_attack/fleshmend_lesser
	can_cast_on_self = TRUE // yeah but... do you want to?

/datum/action/cooldown/spell/touch/fleshmend_lesser/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/human/caster)
	if (!ishuman(victim))
		caster.balloon_alert(caster, "can't heal that!")
		return FALSE

	var/mob/living/carbon/human/human_victim = victim
	//only works if they're pretty severely brute/burn injured and not much else
	if ((human_victim.getBruteLoss() + human_victim.getFireLoss()) < 44)
		caster.balloon_alert(caster, "not injured enough!")
		return FALSE

	//otherwise, LET'S GET HEALING YAAAY
	caster.visible_message(
		span_danger("[caster] hovers [caster.p_their()] hands over [human_victim] and closes [caster.p_their()] eyes, the flesh of their exposed wounds writhing angrily..."),
		span_notice("You hover your hands over [human_victim] and begin forcing flesh to knit and mend itself...")
	)
	caster.whisper(invocation)
	var/sound/channel_sound = sound('modular_doppler/modular_powers/sounds/cosmic_energy.ogg')
	channel_sound.pitch = 1.25

	while (do_after(caster, 1 SECONDS, human_victim) && (human_victim.getBruteLoss() + human_victim.getFireLoss()))
		human_victim.adjustBruteLoss(-5, updating_health = TRUE)
		human_victim.adjustFireLoss(-2.5, updating_health = TRUE)
		human_victim.bleed(1.5)
		playsound(caster, channel_sound, 75, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE)

		if (human_victim.stat == UNCONSCIOUS)
			human_victim.adjustOxyLoss(-2.5) //just a smidge so crit people aren't unconscious for seven hundred years

		if (prob(66))
			//pain time
			human_victim.visible_message(
				span_danger("[human_victim] involuntarily writhes in agony as [caster] continues to mend their flesh together!"),
				span_userdanger("A bolt of RAW AGONY ricochets through your being as nerves that were never meant to touch, touch. It is EXCRUCIATING!!!")
			)
			human_victim.Knockdown(6 SECONDS)
			human_victim.set_jitter_if_lower(5 SECONDS)
			if (prob(50))
				human_victim.emote("scream")

	return TRUE


/obj/item/melee/touch_attack/fleshmend_lesser
	name = "\improper blood-wreathed hand"
	desc = "Uh, this really doesn't look like healing magic, boss..."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "scream_for_me"
	inhand_icon_state = "disintegrate"

/datum/power/fleshmend_thaum
	name = "Lesser Fleshmend"
	desc = "This spell transmutes a portion of the target's blood and the caster's mana into freshly grown bands \
		of new flesh with one slight caveat: it cannot completely mend flesh - some medical assistance will be required."
	root_power = /datum/power/item/spellprep
	power_type = TRAIT_PATH_SUBTYPE_THAUMATURGE

/datum/power/fleshmend_thaum/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/touch/fleshmend_lesser(target.mind || target)
	new_action.Grant(target)

/datum/action/cooldown/spell/summonitem/lesser
	name = "Bonded Object"
	desc = "This spell allows you to tie some of your mana to a treasured object of yours, \
		allowing you to retrieve it from just about anywhere within a five solar system radius. \
		In addition, while held in your hands, your bonded item will help you regenerate mana more efficiently, \
		and if it is a staff of some kind, even more efficiently again."

/datum/power/summonitem_thaum
	name = "Lesser Fleshmend"
	desc = "This spell transmutes a portion of the target's blood and the caster's mana into freshly grown bands \
		of new flesh with one slight caveat: it cannot completely mend flesh - some medical assistance will be required."
	root_power = /datum/power/item/spellprep
	power_type = TRAIT_PATH_SUBTYPE_THAUMATURGE

/datum/power/summonitem_thaum/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/summonitem/lesser(target.mind || target)
	new_action.Grant(target)
