	object_const_def
	const ECRUTEAKMART_CLERK
	const ECRUTEAKMART_SUPER_NERD
	const ECRUTEAKMART_GRANNY

EcruteakMart_MapScripts:
	def_scene_scripts

	def_callbacks

EcruteakMartClerkScript:
	opentext
	setval 4
	callasm CheckMartTM
	iffalse .SkipTM
	writetext EcruteakMartTMOfferText
	yesorno
	iffalse .SkipTM
	checkmoney YOUR_MONEY, 2500
	ifequal HAVE_LESS, .CantAffordTM
	setval 4
	callasm GiveMartTM
	iffalse .BagFullTM
	takemoney YOUR_MONEY, 2500
	writetext EcruteakMartReceivedTMText
	playsound SFX_TRANSACTION
	waitsfx
	promptbutton
	sjump .SkipTM
.CantAffordTM:
	writetext EcruteakMartCantAffordTMText
	promptbutton
	sjump .SkipTM
.BagFullTM:
	writetext EcruteakMartBagFullTMText
	promptbutton
.SkipTM:
	pokemart MARTTYPE_STANDARD, MART_ECRUTEAK
	closetext
	end

EcruteakMartSuperNerdScript:
	jumptextfaceplayer EcruteakMartSuperNerdText

EcruteakMartGrannyScript:
	jumptextfaceplayer EcruteakMartGrannyText

EcruteakMartSuperNerdText:
	text "My EEVEE evolved"
	line "into an ESPEON."

	para "But my friend's"
	line "EEVEE turned into"
	cont "an UMBREON."

	para "I wonder why? We"
	line "both were raising"

	para "our EEVEE in the"
	line "same way…"
	done

EcruteakMartGrannyText:
	text "If you use REVIVE,"
	line "a #MON that's"

	para "fainted will wake"
	line "right up."
	done

EcruteakMartTMOfferText:
	text "I have a special"
	line "deal today!"
	para "@"
	text_ram wStringBuffer3
	text ""
	line "just ¥2500!"
	done

EcruteakMartReceivedTMText:
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

EcruteakMartCantAffordTMText:
	text "Sorry, you can't"
	line "afford that."
	done

EcruteakMartBagFullTMText:
	text "You can't carry"
	line "any more items."
	done

EcruteakMart_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, ECRUTEAK_CITY, 9
	warp_event  3,  7, ECRUTEAK_CITY, 9

	def_coord_events

	def_bg_events

	def_object_events
	object_event  1,  3, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, EcruteakMartClerkScript, -1
	object_event  5,  2, SPRITE_SUPER_NERD, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, EcruteakMartSuperNerdScript, -1
	object_event  6,  6, SPRITE_GRANNY, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, EcruteakMartGrannyScript, -1
