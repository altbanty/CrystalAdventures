	object_const_def
	const VIOLETMART_CLERK
	const VIOLETMART_GRANNY
	const VIOLETMART_COOLTRAINER_M

VioletMart_MapScripts:
	def_scene_scripts

	def_callbacks

VioletMartClerkScript:
	opentext
	setval 2
	callasm CheckMartTM
	iffalse .SkipTM
	writetext VioletMartTMOfferText
	yesorno
	iffalse .SkipTM
	checkmoney YOUR_MONEY, 2500
	ifequal HAVE_LESS, .CantAffordTM
	setval 2
	callasm GiveMartTM
	iffalse .BagFullTM
	takemoney YOUR_MONEY, 2500
	writetext VioletMartReceivedTMText
	playsound SFX_TRANSACTION
	waitsfx
	promptbutton
	sjump .SkipTM
.CantAffordTM:
	writetext VioletMartCantAffordTMText
	promptbutton
	sjump .SkipTM
.BagFullTM:
	writetext VioletMartBagFullTMText
	promptbutton
.SkipTM:
	pokemart MARTTYPE_STANDARD, MART_VIOLET
	closetext
	end

VioletMartGrannyScript:
	jumptextfaceplayer VioletMartGrannyText

VioletMartCooltrainerMScript:
	jumptextfaceplayer VioletMartCooltrainerMText

VioletMartGrannyText:
	text "When you first"
	line "catch a #MON,"
	cont "it may be weak."

	para "But it will even-"
	line "tually grow to be"
	cont "strong."

	para "It's important to"
	line "treat #MON with"
	cont "love."
	done

VioletMartCooltrainerMText:
	text "#MON can hold"
	line "items like POTION"
	cont "and ANTIDOTE."

	para "But they don't"
	line "appear to know how"

	para "to use manmade"
	line "items."
	done

VioletMartTMOfferText:
	text "I have a special"
	line "deal today!"
	para "@"
	text_ram wStringBuffer3
	text ""
	line "just ¥2500!"
	done

VioletMartReceivedTMText:
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

VioletMartCantAffordTMText:
	text "Sorry, you can't"
	line "afford that."
	done

VioletMartBagFullTMText:
	text "You can't carry"
	line "any more items."
	done

VioletMart_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, VIOLET_CITY, 1
	warp_event  3,  7, VIOLET_CITY, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  1,  3, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, VioletMartClerkScript, -1
	object_event  7,  6, SPRITE_GRANNY, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, VioletMartGrannyScript, -1
	object_event  5,  2, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, VioletMartCooltrainerMScript, -1
