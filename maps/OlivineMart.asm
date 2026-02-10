	object_const_def
	const OLIVINEMART_CLERK
	const OLIVINEMART_COOLTRAINER_F
	const OLIVINEMART_LASS

OlivineMart_MapScripts:
	def_scene_scripts

	def_callbacks

OlivineMartClerkScript:
	opentext
	setval 5
	callasm CheckMartTM
	iffalse .SkipTM
	writetext OlivineMartTMOfferText
	yesorno
	iffalse .SkipTM
	checkmoney YOUR_MONEY, 5000
	ifequal HAVE_LESS, .CantAffordTM
	setval 5
	callasm GiveMartTM
	iffalse .BagFullTM
	takemoney YOUR_MONEY, 5000
	writetext OlivineMartReceivedTMText
	playsound SFX_TRANSACTION
	waitsfx
	promptbutton
	sjump .SkipTM
.CantAffordTM:
	writetext OlivineMartCantAffordTMText
	promptbutton
	sjump .SkipTM
.BagFullTM:
	writetext OlivineMartBagFullTMText
	promptbutton
.SkipTM:
	pokemart MARTTYPE_STANDARD, MART_OLIVINE
	closetext
	end

OlivineMartCooltrainerFScript:
	jumptextfaceplayer OlivineMartCooltrainerFText

OlivineMartLassScript:
	jumptextfaceplayer OlivineMartLassText

OlivineMartCooltrainerFText:
	text "Do your #MON"
	line "already know the"

	para "move for carrying"
	line "people on water?"
	done

OlivineMartLassText:
	text "My BUTTERFREE came"
	line "from my boyfriend"
	cont "overseas."

	para "It carried some"
	line "MAIL from him."

	para "Want to know what"
	line "it says?"

	para "Let's see… Nope!"
	line "It's a secret!"
	done

OlivineMartTMOfferText:
	text "I have a special"
	line "deal today!"
	para "@"
	text_ram wStringBuffer3
	text ""
	line "just ¥5000!"
	done

OlivineMartReceivedTMText:
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

OlivineMartCantAffordTMText:
	text "Sorry, you can't"
	line "afford that."
	done

OlivineMartBagFullTMText:
	text "You can't carry"
	line "any more items."
	done

OlivineMart_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, OLIVINE_CITY, 8
	warp_event  3,  7, OLIVINE_CITY, 8

	def_coord_events

	def_bg_events

	def_object_events
	object_event  1,  3, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineMartClerkScript, -1
	object_event  6,  2, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, OlivineMartCooltrainerFScript, -1
	object_event  1,  6, SPRITE_LASS, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineMartLassScript, -1
