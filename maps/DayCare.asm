	object_const_def
	const DAYCARE_GRAMPS
	const DAYCARE_GRANNY

DayCare_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, .EggCheckCallback

.EggCheckCallback:
	checkflag ENGINE_DAY_CARE_MAN_HAS_EGG
	iftrue .PutDayCareManOutside
	clearevent EVENT_DAY_CARE_MAN_IN_DAY_CARE
	setevent EVENT_DAY_CARE_MAN_ON_ROUTE_34
	endcallback

.PutDayCareManOutside:
	setevent EVENT_DAY_CARE_MAN_IN_DAY_CARE
	clearevent EVENT_DAY_CARE_MAN_ON_ROUTE_34
	endcallback

DayCareManScript_Inside:
	faceplayer
	opentext
	checkevent EVENT_GOT_ODD_EGG
	iftrue .AlreadyHaveOddEgg
	writetext DayCareManText_GiveOddEgg
	promptbutton
	closetext
	readvar VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, .PartyFull
	special GiveOddEgg
	opentext
	writetext DayCareText_GotOddEgg
	playsound SFX_KEY_ITEM
	waitsfx
	writetext DayCareText_DescribeOddEgg
	waitbutton
	closetext
	setevent EVENT_GOT_ODD_EGG
	end

.PartyFull:
	opentext
	writetext DayCareText_PartyFull
	waitbutton
	closetext
	end

.AlreadyHaveOddEgg:
	writetext DayCareManServicesText
	loadmenu .ServicesMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .DayCareService
	ifequal 2, .Training
	closetext
	end

.DayCareService:
	special DayCareMan
	waitbutton
	closetext
	end

; --- Instant paid training: pay to level a party Pokemon on the spot.
; Cost: each level gained costs (level reached) x 50. Capped by wLevelCap.
.Training:
	writetext TrainingIntroText
	waitbutton
	closetext
	callasm TrainingSelectMon
	ifequal 0, .TrainingDone
	ifequal 2, .TrainingEgg
	opentext
	writetext TrainingChooseAmountText
	loadmenu .TrainingMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Plus1
	ifequal 2, .Plus5
	ifequal 3, .ToCap
	closetext
	end

.Plus1:
	setval 1
	sjump .Quote
.Plus5:
	setval 5
	sjump .Quote
.ToCap:
	setval 255
.Quote:
	callasm CalculateTrainingCost
	ifequal 0, .AtCap
	writetext TrainingCostText
	yesorno
	iffalse .TrainingDeclined
	callasm CheckTrainingPayment
	iffalse .TrainingNoMoney
	callasm TakeTrainingPayment
	playsound SFX_TRANSACTION
	waitsfx
	writetext TrainingWorkoutText
	waitbutton
	writetext TrainingDoneText
	waitbutton
	closetext
	callasm TrainingEvolveCheck
	end

.AtCap:
	writetext TrainingAtCapText
	waitbutton
	closetext
	end

.TrainingNoMoney:
	writetext TrainingNoMoneyText
	waitbutton
	closetext
	end

.TrainingDeclined:
	writetext TrainingDeclinedText
	waitbutton
	closetext
	end

.TrainingEgg:
	opentext
	writetext TrainingEggText
	waitbutton
	closetext
	end

.TrainingDone:
	end

.ServicesMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 2, 13, TEXTBOX_Y - 1
	dw .ServicesMenuData
	db 1 ; default option

.ServicesMenuData:
	db STATICMENU_CURSOR ; flags
	db 3 ; items
	db "DAY-CARE@"
	db "TRAINING@"
	db "CANCEL@"

.TrainingMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 2, 13, TEXTBOX_Y - 1
	dw .TrainingMenuData
	db 1 ; default option

.TrainingMenuData:
	db STATICMENU_CURSOR ; flags
	db 4 ; items
	db "+1 LEVEL@"
	db "+5 LEVELS@"
	db "TO THE CAP@"
	db "CANCEL@"

DayCareLadyScript:
	faceplayer
	opentext
	checkflag ENGINE_DAY_CARE_MAN_HAS_EGG
	iftrue .HusbandWasLookingForYou
	special DayCareLady
	waitbutton
	closetext
	end

.HusbandWasLookingForYou:
	writetext Text_GrampsLookingForYou
	waitbutton
	closetext
	end

DayCareBookshelf:
	jumpstd DifficultBookshelfScript

Text_GrampsLookingForYou:
	text "Gramps was looking"
	line "for you."
	done

DayCareManServicesText:
	text "I can watch a"
	line "#MON for you…"

	para "Or, for a fee, we"
	line "can power train"
	cont "one on the spot!"
	done

TrainingIntroText:
	text "Power training!"

	para "Pay up front, and"
	line "your #MON"
	cont "levels up right"
	cont "away."

	para "We can't train"
	line "past the level"
	cont "cap, mind you."

	para "Which #MON"
	line "should we train?"
	done

TrainingChooseAmountText:
	text "How much training"
	line "should it get?"
	done

TrainingCostText:
	text "That's @"
	text_decimal wStringBuffer2 + 3, 1, 3
	text " level(s)"
	line "of training."

	para "It'll cost ¥@"
	text_decimal wStringBuffer2, 3, 6
	text "."
	line "Deal?"
	done

TrainingWorkoutText:
	text "Hup! Hyah!"
	line "One, two! Hup!"

	para "…Whew!"
	done

TrainingDoneText:
	text "All done! It grew"
	line "to level @"
	text_decimal wStringBuffer2 + 4, 1, 3
	text "!"
	done

TrainingAtCapText:
	text "That #MON is"
	line "already at the"
	cont "level cap."

	para "I can't train it"
	line "any further!"
	done

TrainingNoMoneyText:
	text "You're short on"
	line "cash, friend."
	done

TrainingDeclinedText:
	text "No? Come back"
	line "anytime."
	done

TrainingEggText:
	text "That's an EGG!"

	para "Training an EGG"
	line "would just crack"
	cont "it!"
	done

Text_DayCareManTalksAboutEggTicket: ; unreferenced
	text "I'm the DAY-CARE"
	line "MAN."

	para "There's something"
	line "new in GOLDENROD"

	para "called the TRADE"
	line "CORNER."

	para "I was given an EGG"
	line "TICKET that can be"

	para "traded in for a"
	line "ODD EGG."

	para "But since we run a"
	line "DAY-CARE, we don't"

	para "need it. You may"
	line "as well have it."
	done

DayCareManText_GiveOddEgg:
	text "I'm the DAY-CARE"
	line "MAN."

	para "Do you know about"
	line "EGGS?"

	para "I was raising"
	line "#MON with my"
	cont "wife, you see."

	para "We were shocked to"
	line "find an EGG!"

	para "How incredible is"
	line "that?"

	para "You know, your"
	line "#DEX shows EGG"
	cont "groups, and how"
	
	para "long they take to"
	line "hatch!"

	para "Well, wouldn't you"
	line "like this EGG?"

	para "Then fine, this is"
	line "yours to keep!"
	done

DayCareText_ComeAgain: ; unreferenced
	text "Come again."
	done

DayCareText_GotOddEgg:
	text "<PLAYER> received"
	line "ODD EGG!"
	done

DayCareText_DescribeOddEgg:
	text "I found that when"
	line "I was caring for"

	para "someone's #MON"
	line "before."

	para "But the trainer"
	line "didn't want the"

	para "EGG, so I'd kept"
	line "it around."
	done

DayCareText_PartyFull:
	text "You've no room for"
	line "this."
	done

DayCare_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  0,  5, ROUTE_34, 3
	warp_event  0,  6, ROUTE_34, 4
	warp_event  2,  7, ROUTE_34, 5
	warp_event  3,  7, ROUTE_34, 5

	def_coord_events

	def_bg_events
	bg_event  0,  1, BGEVENT_READ, DayCareBookshelf
	bg_event  1,  1, BGEVENT_READ, DayCareBookshelf

	def_object_events
	object_event  2,  3, SPRITE_GRAMPS, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, DayCareManScript_Inside, EVENT_DAY_CARE_MAN_IN_DAY_CARE
	object_event  5,  3, SPRITE_GRANNY, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, DayCareLadyScript, -1
