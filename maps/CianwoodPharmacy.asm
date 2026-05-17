	object_const_def
	const CIANWOODPHARMACY_PHARMACIST

CianwoodPharmacy_MapScripts:
	def_scene_scripts
	scene_script .DummyScene

	def_callbacks

.DummyScene:
	end

CianwoodPharmacist:
	faceplayer
	opentext
	checkevent EVENT_GOT_SECRETPOTION_FROM_PHARMACY
	iftrue .Mart
	checkevent EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS
	iffalse .Mart
	writetext PharmacistGiveSecretpotionText
	promptbutton
	giveitem SECRETPOTION
	writetext ReceivedSecretpotionText
	playsound SFX_KEY_ITEM
	waitsfx
	itemnotify
	setevent EVENT_GOT_SECRETPOTION_FROM_PHARMACY
	writetext PharmacistDescribeSecretpotionText
	waitbutton
	closetext
	end

.Mart:
	setval 7
	callasm CheckMartTM
	iffalse .SkipTM
	writetext CianwoodPharmacyTMOfferText
	yesorno
	iffalse .SkipTM
	checkmoney YOUR_MONEY, 5000
	ifequal HAVE_LESS, .CantAffordTM
	setval 7
	callasm GiveMartTM
	iffalse .BagFullTM
	takemoney YOUR_MONEY, 5000
	writetext CianwoodPharmacyReceivedTMText
	playsound SFX_TRANSACTION
	waitsfx
	promptbutton
	sjump .SkipTM
.CantAffordTM:
	writetext CianwoodPharmacyCantAffordTMText
	promptbutton
	sjump .SkipTM
.BagFullTM:
	writetext CianwoodPharmacyBagFullTMText
	promptbutton
.SkipTM:
	callasm BuildCianwoodMart
	pokemart MARTTYPE_PHARMACY, wStringBuffer5
	closetext
	end

CianwoodPharmacyBookshelf:
	jumpstd DifficultBookshelfScript

PharmacistGiveSecretpotionText:
	text "Your #MON ap-"
	line "pear to be fine."

	para "Is something wor- "
	line "rying you?"

	para "…"

	para "The LIGHTHOUSE"
	line "#MON is in"
	cont "trouble?"

	para "I got it!"

	para "This ought to do"
	line "the trick."
	done

ReceivedSecretpotionText:
	text "<PLAYER> received"
	line "SECRETPOTION."
	done

PharmacistDescribeSecretpotionText:
	text "My SECRETPOTION is"
	line "a tad too strong."

	para "I only offer it in"
	line "an emergency."
	done

CianwoodPharmacyTMOfferText:
	text "I have a special"
	line "deal today!"
	para "@"
	text_ram wStringBuffer3
	text ""
	line "just ¥5000!"
	done

CianwoodPharmacyReceivedTMText:
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

CianwoodPharmacyCantAffordTMText:
	text "Sorry, you can't"
	line "afford that."
	done

CianwoodPharmacyBagFullTMText:
	text "You can't carry"
	line "any more items."
	done

BuildCianwoodMart::
; Copies fixed pharmacy items + 1 random evo stone into wStringBuffer5.
; The evo stone is offset +3 from Goldenrod 3F's stone so they never overlap.
	ld a, [wGoldenrod3FItemSeed]
	bit 7, a
	jr nz, .buildMart
	call Random
	ld [wGoldenrod3FItemSeed], a
	call Random
	ld [wGoldenrod3FItemSeed + 1], a
	ld a, [wGoldenrod3FItemSeed]
	or %10000000
	ld [wGoldenrod3FItemSeed], a
.buildMart:
	ld hl, wStringBuffer5
	ld [hl], 7
	inc hl
	ld [hl], BERRY_JUICE
	inc hl
	ld [hl], ETHER
	inc hl
	ld [hl], ENERGYPOWDER
	inc hl
	ld [hl], ENERGY_ROOT
	inc hl
	ld [hl], HEAL_POWDER
	inc hl
	ld [hl], REVIVAL_HERB
	inc hl
	ld a, [wGoldenrod3FItemSeed]
	and $70
	swap a
	cp 6
	jr c, .modOk
	sub 6
.modOk:
	add 3
	cp 6
	jr c, .noWrap
	sub 6
.noWrap:
	push hl
	ld hl, .CianwoodEvoStones
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	pop hl
	ld [hli], a
	ld [hl], -1
	ret
.CianwoodEvoStones:
	db FIRE_STONE, WATER_STONE, THUNDERSTONE, LEAF_STONE, SUN_STONE, MOON_STONE

CianwoodPharmacy_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, CIANWOOD_CITY, 4
	warp_event  3,  7, CIANWOOD_CITY, 4

	def_coord_events

	def_bg_events
	bg_event  0,  1, BGEVENT_READ, CianwoodPharmacyBookshelf
	bg_event  1,  1, BGEVENT_READ, CianwoodPharmacyBookshelf

	def_object_events
	object_event  2,  3, SPRITE_PHARMACIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, CianwoodPharmacist, -1
