	object_const_def
	const BLACKTHORNMART_CLERK
	const BLACKTHORNMART_COOLTRAINER_M
	const BLACKTHORNMART_BLACK_BELT

BlackthornMart_MapScripts:
	def_scene_scripts

	def_callbacks

BlackthornMartClerkScript:
	opentext
	setval 8
	callasm CheckMartTM
	iffalse .SkipTM
	writetext BlackthornMartTMOfferText
	yesorno
	iffalse .SkipTM
	checkmoney YOUR_MONEY, 10000
	ifequal HAVE_LESS, .CantAffordTM
	setval 8
	callasm GiveMartTM
	iffalse .BagFullTM
	takemoney YOUR_MONEY, 10000
	writetext BlackthornMartReceivedTMText
	playsound SFX_TRANSACTION
	waitsfx
	promptbutton
	sjump .SkipTM
.CantAffordTM:
	writetext BlackthornMartCantAffordTMText
	promptbutton
	sjump .SkipTM
.BagFullTM:
	writetext BlackthornMartBagFullTMText
	promptbutton
.SkipTM:
	pokemart MARTTYPE_STANDARD, MART_BLACKTHORN
	closetext
	end

BlackthornMartCooltrainerMScript:
	jumptextfaceplayer BlackthornMartCooltrainerMText

BlackthornMartBlackBeltScript:
	jumptextfaceplayer BlackthornMartBlackBeltText

BlackthornMartCooltrainerMText:
	text "You can't buy MAX"
	line "REVIVE, but it"

	para "fully restores a"
	line "fainted #MON."

	para "Beware--it won't"
	line "restore PP, the"

	para "POWER POINTS"
	line "needed for moves."
	done

BlackthornMartBlackBeltText:
	text "MAX REPEL keeps"
	line "weak #MON away"
	cont "from you."

	para "It's the longest"
	line "lasting of the"
	cont "REPEL sprays."
	done

BlackthornMartTMOfferText:
	text "I have a special"
	line "deal today!"
	para "@"
	text_ram wStringBuffer3
	text ""
	line "just ¥10000!"
	done

BlackthornMartReceivedTMText:
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

BlackthornMartCantAffordTMText:
	text "Sorry, you can't"
	line "afford that."
	done

BlackthornMartBagFullTMText:
	text "You can't carry"
	line "any more items."
	done

BlackthornMart_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, BLACKTHORN_CITY, 4
	warp_event  3,  7, BLACKTHORN_CITY, 4

	def_coord_events

	def_bg_events

	def_object_events
	object_event  1,  3, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BlackthornMartClerkScript, -1
	object_event  7,  6, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BlackthornMartCooltrainerMScript, -1
	object_event  5,  2, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, BlackthornMartBlackBeltScript, -1
