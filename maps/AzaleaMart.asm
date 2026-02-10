	object_const_def
	const AZALEAMART_CLERK
	const AZALEAMART_COOLTRAINER_M
	const AZALEAMART_BUG_CATCHER

AzaleaMart_MapScripts:
	def_scene_scripts

	def_callbacks

AzaleaMartClerkScript:
	opentext
	setval 3
	callasm CheckMartTM
	iffalse .SkipTM
	writetext AzaleaMartTMOfferText
	yesorno
	iffalse .SkipTM
	checkmoney YOUR_MONEY, 2500
	ifequal HAVE_LESS, .CantAffordTM
	setval 3
	callasm GiveMartTM
	iffalse .BagFullTM
	takemoney YOUR_MONEY, 2500
	writetext AzaleaMartReceivedTMText
	playsound SFX_TRANSACTION
	waitsfx
	promptbutton
	sjump .SkipTM
.CantAffordTM:
	writetext AzaleaMartCantAffordTMText
	promptbutton
	sjump .SkipTM
.BagFullTM:
	writetext AzaleaMartBagFullTMText
	promptbutton
.SkipTM:
	pokemart MARTTYPE_STANDARD, MART_AZALEA
	closetext
	end

AzaleaMartCooltrainerMScript:
	jumptextfaceplayer AzaleaMartCooltrainerMText

AzaleaMartBugCatcherScript:
	jumptextfaceplayer AzaleaMartBugCatcherText

AzaleaMartCooltrainerMText:
	text "There's no GREAT"
	line "BALL here. #"

	para "BALLS will have"
	line "to do."

	para "I wish KURT would"
	line "make me some of"
	cont "his custom BALLS."
	done

AzaleaMartBugCatcherText:
	text "A GREAT BALL is"
	line "better for catch-"
	cont "ing #MON than a"
	cont "# BALL."

	para "But KURT's might"
	line "be better some-"
	cont "times."
	done

AzaleaMartTMOfferText:
	text "I have a special"
	line "deal today!"
	para "@"
	text_ram wStringBuffer3
	text ""
	line "just ¥2500!"
	done

AzaleaMartReceivedTMText:
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

AzaleaMartCantAffordTMText:
	text "Sorry, you can't"
	line "afford that."
	done

AzaleaMartBagFullTMText:
	text "You can't carry"
	line "any more items."
	done

AzaleaMart_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, AZALEA_TOWN, 3
	warp_event  3,  7, AZALEA_TOWN, 3

	def_coord_events

	def_bg_events

	def_object_events
	object_event  1,  3, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, AzaleaMartClerkScript, -1
	object_event  2,  5, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, AzaleaMartCooltrainerMScript, -1
	object_event  7,  2, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, AzaleaMartBugCatcherScript, -1
