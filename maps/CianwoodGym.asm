	object_const_def
	const CIANWOODGYM_CHUCK
	const CIANWOODGYM_BLACK_BELT1
	const CIANWOODGYM_BLACK_BELT2
	const CIANWOODGYM_BLACK_BELT3
	const CIANWOODGYM_BLACK_BELT4
	const CIANWOODGYM_BOULDER1
	const CIANWOODGYM_BOULDER2
	const CIANWOODGYM_BOULDER3
	const CIANWOODGYM_BOULDER4

CianwoodGym_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_SPRITES, .LeaderSprite
	callback MAPCALLBACK_OBJECTS, .LeaderSpriteObjects

; Gym swap pair 5 (Chuck <-> Janine; see VioletGym.asm): roll once per
; save for pre-feature saves, then show whoever holds this gym. The
; OBJECTS callback reasserts the sprite because SPRITES can be skipped
; on cached re-entry.
.LeaderSpriteObjects:
	callasm ApplyCianwoodGymLeaderSprite
	endcallback

.LeaderSprite:
	checkevent EVENT_GYM_PAIR_5_ROLLED
	iftrue .SetSprite
	setevent EVENT_GYM_PAIR_5_ROLLED
	random 2
	ifequal 0, .SetSprite
	setevent EVENT_GYM_PAIR_5_SWAPPED
.SetSprite:
	callasm ApplyCianwoodGymLeaderSprite
	endcallback

CianwoodGymChuckScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_CHUCK
	iftrue .FightDone
	checkevent EVENT_GYM_PAIR_5_SWAPPED
	iftrue .GuestJanine
	writetext ChuckIntroText1
	waitbutton
	closetext
	turnobject CIANWOODGYM_CHUCK, RIGHT
	opentext
	writetext ChuckIntroText2
	waitbutton
	closetext
	applymovement CIANWOODGYM_BOULDER1, CianwoodGymMovement_ChuckChucksBoulder
	playsound SFX_STRENGTH
	earthquake 80
	disappear CIANWOODGYM_BOULDER1
	pause 30
	faceplayer
	opentext
	writetext ChuckIntroText3
	waitbutton
	closetext
	winlosstext ChuckLossText, 0
	;  Level scaling + team randomization
	scall .PickTier
	callasm LoadChuckTrainer
	sjump .CianwoodGymChuckScriptEnd

; Janine holds Cianwood Gym this run. Badge, TM, level cap, and story
; events are the slot's; she fights at the slot's badge tier with the
; slot's per-save variant roll. No boulder toss - that's Chuck's bit.
.GuestJanine:
	writetext JanineGuestIntroText
	waitbutton
	closetext
	winlosstext JanineGuestWinLossText, 0
	scall .PickTier
	callasm LoadJanineGuestTrainer
	sjump .CianwoodGymChuckScriptEnd

; Tier base in wScriptVar from the badge count. A subroutine because
; checkevent clobbers wScriptVar, so the swap branch must come first.
.PickTier:
	readvar VAR_BADGES
	ifgreater 5, .SevenBadges
	ifequal 5, .SixBadges
	setval 0           ; tier 1 base
	end
.SixBadges:
	setval 3           ; tier 2 base
	end
.SevenBadges:
	setval 6           ; tier 3 base
	end

.CianwoodGymChuckScriptEnd:
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_3
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_3
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_CHUCK
	opentext
	writetext GetStormBadgeText
	playsound SFX_GET_BADGE
	waitsfx
	setflag ENGINE_STORMBADGE

	; Update level caps with level scaling
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .DontUpdateBadge
	readvar VAR_BADGES
	ifequal 7, .SevenBadgeCap
	ifequal 6, .SixBadgeCap
	ifequal 5, .FiveBadgeCap
.FiveBadgeCap:
	loadmem wLevelCap, 36 ; update level cap for hard mode
	sjump .LevelCapScriptEnd
.SixBadgeCap:
	loadmem wLevelCap, 38 ; update level cap for hard mode
	sjump .LevelCapScriptEnd
.SevenBadgeCap:
	loadmem wLevelCap, 45 ; update level cap for hard mode
	sjump .LevelCapScriptEnd
.DontUpdateBadge
.LevelCapScriptEnd:

	readvar VAR_BADGES
	scall CianwoodGymActivateRockets
.FightDone:
	checkevent EVENT_GOT_TM01_DYNAMICPUNCH
	iftrue .AlreadyGotTM
	setevent EVENT_BEAT_BLACKBELT_YOSHI
	setevent EVENT_BEAT_BLACKBELT_LAO
	setevent EVENT_BEAT_BLACKBELT_NOB
	setevent EVENT_BEAT_BLACKBELT_LUNG
	writetext ChuckExplainBadgeText
	promptbutton
	setval 5
	callasm GetGymTM
	verbosegiveitem ITEM_FROM_MEM, 1
	iffalse .BagFull
	setevent EVENT_GOT_TM01_DYNAMICPUNCH
	checkevent EVENT_GYM_PAIR_5_SWAPPED
	iftrue .GuestTMText
	writetext ChuckExplainTMText
	sjump .AfterTMText
.GuestTMText:
	writetext JanineGuestTMText
.AfterTMText:
	waitbutton
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .SkipLevelCapText
	farwritetext LevelCapRaisedText
	waitbutton
.SkipLevelCapText:
	closetext
	end

.AlreadyGotTM:
	checkevent EVENT_BEAT_ELITE_FOUR
	iffalse .NotBeatE4
	checkevent EVENT_GYM_PAIR_5_SWAPPED
	iftrue .GuestRematchAsk
	writetext ChuckRematchText
	yesorno
	iftrue .ChuckRematch
	sjump .BagFull
.GuestRematchAsk:
	writetext JanineGuestRematchText
	yesorno
	iftrue .GuestJanineRematch
	sjump .BagFull
.NotBeatE4
	checkevent EVENT_GYM_PAIR_5_SWAPPED
	iftrue .GuestFightDone
	writetext ChuckAfterText
	waitbutton
.BagFull:
	closetext
	end

.GuestFightDone:
	writetext JanineGuestFightDoneText
	waitbutton
	closetext
	end

; Swapped rematch: Janine brings her real (Kanto-tier) team.
.GuestJanineRematch:
	special HealParty
	winlosstext JanineGuestWinLossText, 0
	setval 8
	callasm LoadKantoGymTrainer
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_guest_rematch
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_guest_rematch
	startbattle
	reloadmapafterbattle
	end

.ChuckRematch:
	special HealParty
	winlosstext Chuck_RematchDefeatText, 0
	loadtrainer CHUCK, 10
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_4
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_4
	startbattle
	reloadmapafterbattle
	end

CianwoodGymActivateRockets:
	ifequal 7, .RadioTowerRockets
	ifequal 6, .GoldenrodRockets
	end

.GoldenrodRockets:
	jumpstd GoldenrodRocketsScript

.RadioTowerRockets:
	jumpstd RadioTowerRocketsScript

TrainerBlackbeltYoshi:
	trainer BLACKBELT_T, YOSHI, EVENT_BEAT_BLACKBELT_YOSHI, BlackbeltYoshiSeenText, BlackbeltYoshiBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BlackbeltYoshiAfterText
	waitbutton
	closetext
	end

TrainerBlackbeltLao:
	trainer BLACKBELT_T, LAO, EVENT_BEAT_BLACKBELT_LAO, BlackbeltLaoSeenText, BlackbeltLaoBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BlackbeltLaoAfterText
	waitbutton
	closetext
	end

TrainerBlackbeltNob:
	trainer BLACKBELT_T, NOB, EVENT_BEAT_BLACKBELT_NOB, BlackbeltNobSeenText, BlackbeltNobBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BlackbeltNobAfterText
	waitbutton
	closetext
	end

TrainerBlackbeltLung:
	trainer BLACKBELT_T, LUNG, EVENT_BEAT_BLACKBELT_LUNG, BlackbeltLungSeenText, BlackbeltLungBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext BlackbeltLungAfterText
	waitbutton
	closetext
	end

CianwoodGymBoulder:
	jumpstd StrengthBoulderScript

CianwoodGymStatue:
	checkflag ENGINE_STORMBADGE
	iftrue .Beaten
	jumpstd GymStatue1Script
.Beaten:
	gettrainername STRING_BUFFER_4, CHUCK, CHUCK1
	jumpstd GymStatue2Script

CianwoodGymMovement_ChuckChucksBoulder:
	set_sliding
	big_step LEFT
	big_step UP
	fast_jump_step RIGHT
	remove_sliding
	step_end

ChuckIntroText1:
	text "WAHAHAH!"

	para "So you've come"
	line "this far!"

	para "Let me tell you,"
	line "I'm tough!"

	para "My #MON will"
	line "crush stones and"
	cont "shatter bones!"

	para "Watch this!"
	done

ChuckIntroText2:
	text "CHUCK: Urggh!"
	line "…"

	para "Oooarrgh!"
	done

ChuckIntroText3:
	text "There! Scared now,"
	line "are you?"

	para "What?"
	line "It has nothing to"

	para "do with #MON?"
	line "That's true!"

	para "Come on. We shall"
	line "do battle!"
	done

ChuckLossText:
	text "Wha? Huh?"
	line "I lost?"

	para "How about that!"
	line "You're worthy of"
	cont "STORMBADGE!"
	done

GetStormBadgeText:
	text "<PLAYER> received"
	line "STORMBADGE."
	done

ChuckExplainBadgeText:
	text "STORMBADGE lets"
	line "your #MON use"

	para "FLY when you're"
	line "not in a battle."

	para "Here, take this"
	line "too!"
	done

ChuckExplainTMText:
	text "Use it to train"
	line "harder! WAHAHA!"
	done

ChuckAfterText:
	text "WAHAHAH! I enjoyed"
	line "battling you!"

	para "But a loss is a"
	line "loss!"

	para "From now on, I'm"
	line "going to train 24"
	cont "hours a day!"
	done

ChuckRematchText:
	text "WAHAHAH!"
	line "JOHTO CHAMPION!"

	para "You've come"
	line "back for more!"

	para "I see your"
	line "skills have"
	cont "improved!"

	para "Ready to see"
	line "who's stronger?"
	done

Chuck_RematchDefeatText:
	text "Wha? Huh?"
	line "I lost?"
	cont "Again?"
	done

JanineGuestIntroText:
	text "Fufufufu…"

	para "Surprised? CHUCK"
	line "and I traded GYMS"
	cont "for a while."

	para "This GYM is full"
	line "of muscle, but"

	para "poison beats"
	line "muscle every time!"
	done

JanineGuestWinLossText:
	text "JANINE: You saw"
	line "through my tricks…"

	para "STORMBADGE is"
	line "yours. Take it."
	done

JanineGuestTMText:
	text "JANINE: Train with"
	line "it, and sneak up"
	cont "on your rivals!"
	done

JanineGuestFightDoneText:
	text "JANINE: CHUCK's"
	line "students train so"
	cont "loudly…"

	para "A ninja prefers"
	line "silence. Fufufu."
	done

JanineGuestRematchText:
	text "JANINE: JOHTO"
	line "CHAMPION! My real"
	cont "team came along."

	para "Care for a real"
	line "rematch?"
	done

BlackbeltYoshiSeenText:
	text "My #MON and I"
	line "are bound togeth-"
	cont "er by friendship."

	para "Our bond will"
	line "never be broken!"
	done

BlackbeltYoshiBeatenText:
	text "This isn't real!"
	done

BlackbeltYoshiAfterText:
	text "You seem to have a"
	line "strong bond with"
	cont "your #MON too!"
	done

BlackbeltLaoSeenText:
	text "We martial artists"
	line "fear nothing!"
	done

BlackbeltLaoBeatenText:
	text "That's shocking!"
	done

BlackbeltLaoAfterText:
	text "Fighting #MON"
	line "are afraid of"
	cont "psychics…"
	done

BlackbeltNobSeenText:
	text "Words are useless."
	line "Let your fists do"
	cont "the talking!"
	done

BlackbeltNobBeatenText:
	text "…"
	done

BlackbeltNobAfterText:
	text "I lost! "
	line "I'm speechless!"
	done

BlackbeltLungSeenText:
	text "My raging fists"
	line "will shatter your"
	cont "#MON!"
	done

BlackbeltLungBeatenText:
	text "I got shattered!"
	done

BlackbeltLungAfterText:
	text "My #MON lost…"
	line "My… my pride is"
	cont "shattered…"
	done

CianwoodGym_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 17, CIANWOOD_CITY, 2
	warp_event  5, 17, CIANWOOD_CITY, 2

	def_coord_events

	def_bg_events
	bg_event  3, 15, BGEVENT_READ, CianwoodGymStatue
	bg_event  6, 15, BGEVENT_READ, CianwoodGymStatue

	def_object_events
	object_event  4,  1, SPRITE_GYM_LEADER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodGymChuckScript, -1
	object_event  2, 12, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 3, TrainerBlackbeltYoshi, -1
	object_event  7, 12, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 3, TrainerBlackbeltLao, -1
	object_event  3,  9, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 2, TrainerBlackbeltNob, -1
	object_event  5,  5, SPRITE_BLACK_BELT, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_TRAINER, 1, TrainerBlackbeltLung, -1
	object_event  5,  1, SPRITE_BOULDER, SPRITEMOVEDATA_STRENGTH_BOULDER, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodGymBoulder, -1
	object_event  3,  7, SPRITE_BOULDER, SPRITEMOVEDATA_STRENGTH_BOULDER, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodGymBoulder, -1
	object_event  4,  7, SPRITE_BOULDER, SPRITEMOVEDATA_STRENGTH_BOULDER, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodGymBoulder, -1
	object_event  5,  7, SPRITE_BOULDER, SPRITEMOVEDATA_STRENGTH_BOULDER, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodGymBoulder, -1
