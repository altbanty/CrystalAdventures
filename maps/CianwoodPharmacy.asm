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
	pokemart MARTTYPE_PHARMACY, MART_CIANWOOD
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
