	object_const_def
	const OLIVINEGYM_JASMINE
	const OLIVINEGYM_GYM_GUIDE

OlivineGym_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_SPRITES, .LeaderSprite
	callback MAPCALLBACK_OBJECTS, .LeaderSpriteObjects

; Gym swap pair 6 (Jasmine <-> Sabrina; see CianwoodGym.asm). The leader
; object stays hidden until the lighthouse is resolved whoever holds the
; gym - the guest went along to see Amphy.
.LeaderSpriteObjects:
	callasm ApplyOlivineGymLeaderSprite
	endcallback

.LeaderSprite:
	checkevent EVENT_GYM_PAIR_6_ROLLED
	iftrue .SetSprite
	setevent EVENT_GYM_PAIR_6_ROLLED
	random 2
	ifequal 0, .SetSprite
	setevent EVENT_GYM_PAIR_6_SWAPPED
.SetSprite:
	callasm ApplyOlivineGymLeaderSprite
	endcallback

OlivineGymJasmineScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_JASMINE
	iftrue .FightDone
	checkevent EVENT_GYM_PAIR_6_SWAPPED
	iftrue .GuestSabrina
	writetext Jasmine_SteelTypeIntro
	waitbutton
	closetext
	winlosstext Jasmine_BetterTrainer, 0
	;  Level scaling + team randomization
	scall .PickTier
	callasm LoadJasmineTrainer
	sjump .OlivineGymJasmineScriptEnd

.GuestSabrina:
	writetext SabrinaGuestIntroText
	waitbutton
	closetext
	winlosstext SabrinaGuestWinLossText, 0
	scall .PickTier
	callasm LoadSabrinaGuestTrainer
	sjump .OlivineGymJasmineScriptEnd

; Tier base in wScriptVar from the badge count (subroutine: checkevent
; clobbers wScriptVar, so the swap branch comes first).
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

.OlivineGymJasmineScriptEnd
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_3
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_3
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_JASMINE
	opentext
	writetext Text_ReceivedMineralBadge
	playsound SFX_GET_BADGE
	waitsfx
	setflag ENGINE_MINERALBADGE

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
	scall OlivineGymActivateRockets
.FightDone:
	checkevent EVENT_GOT_TM23_IRON_TAIL
	iftrue .GotIronTail
	writetext Jasmine_BadgeSpeech
	promptbutton
	setval 6
	callasm GetGymTM
	verbosegiveitem ITEM_FROM_MEM, 1
	iffalse .NoRoomForIronTail
	setevent EVENT_GOT_TM23_IRON_TAIL
	checkevent EVENT_GYM_PAIR_6_SWAPPED
	iftrue .GuestTMText
	writetext Jasmine_IronTailSpeech
	sjump .AfterTMText
.GuestTMText:
	writetext SabrinaGuestTMText
.AfterTMText:
	waitbutton
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .SkipLevelCapText
	farwritetext LevelCapRaisedText
	waitbutton
.SkipLevelCapText:
	closetext
	end

.GotIronTail:
	checkevent EVENT_BEAT_ELITE_FOUR
	iffalse .NotBeatE4
	checkevent EVENT_GYM_PAIR_6_SWAPPED
	iftrue .GuestRematchAsk
	writetext JasmineRematchText
	yesorno
	iftrue .JasmineRematch
	sjump .NoRoomForIronTail
.GuestRematchAsk:
	writetext SabrinaGuestRematchText
	yesorno
	iftrue .GuestSabrinaRematch
	sjump .NoRoomForIronTail
.NotBeatE4
	checkevent EVENT_GYM_PAIR_6_SWAPPED
	iftrue .GuestFightDone
	writetext Jasmine_GoodLuck
	waitbutton
.NoRoomForIronTail:
	closetext
	end

.GuestFightDone:
	writetext SabrinaGuestFightDoneText
	waitbutton
	closetext
	end

; Swapped rematch: Sabrina brings her real (Kanto-tier) team.
.GuestSabrinaRematch:
	special HealParty
	winlosstext SabrinaGuestWinLossText, 0
	setval 9
	callasm LoadKantoGymTrainer
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_guest_rematch
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_guest_rematch
	startbattle
	reloadmapafterbattle
	end

.JasmineRematch:
	special HealParty
	winlosstext Jasmine_RematchDefeatText, 0
	loadtrainer JASMINE, 10
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_4
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_4
	startbattle
	reloadmapafterbattle
	end

OlivineGymActivateRockets:
	ifequal 7, .RadioTowerRockets
	ifequal 6, .GoldenrodRockets
	end

.GoldenrodRockets:
	jumpstd GoldenrodRocketsScript

.RadioTowerRockets:
	jumpstd RadioTowerRocketsScript

OlivineGymGuideScript:
	faceplayer
	checkevent EVENT_BEAT_JASMINE
	iftrue .OlivineGymGuideWinScript
	checkevent EVENT_JASMINE_RETURNED_TO_GYM
	iffalse .OlivineGymGuidePreScript
	opentext
	checkevent EVENT_GYM_PAIR_6_SWAPPED
	iftrue .GuestGuide
	writetext OlivineGymGuideText
	waitbutton
	closetext
	end

.GuestGuide:
	writetext OlivineGymGuideGuestText
	waitbutton
	closetext
	end

.OlivineGymGuideWinScript:
	opentext
	writetext OlivineGymGuideWinText
	waitbutton
	closetext
	end

.OlivineGymGuidePreScript:
	opentext
	checkevent EVENT_GYM_PAIR_6_SWAPPED
	iftrue .GuestPreGuide
	writetext OlivineGymGuidePreText
	waitbutton
	closetext
	end

.GuestPreGuide:
	writetext OlivineGymGuidePreGuestText
	waitbutton
	closetext
	end

OlivineGymStatue:
	checkflag ENGINE_MINERALBADGE
	iftrue .Beaten
	jumpstd GymStatue1Script
.Beaten:
	gettrainername STRING_BUFFER_4, JASMINE, JASMINE1
	jumpstd GymStatue2Script

Jasmine_SteelTypeIntro:
	text "…Thank you for"
	line "your help at the"
	cont "LIGHTHOUSE…"

	para "But this is dif-"
	line "ferent. Please"

	para "allow me to intro-"
	line "duce myself."

	para "I am JASMINE, a"
	line "GYM LEADER. I use"
	cont "the STEEL-type."

	para "…Do you know about"
	line "the STEEL-type?"

	para "It's a type that"
	line "was only recently"
	cont "discovered."

	para "…Um… May I begin?"
	done

Jasmine_BetterTrainer:
	text "…You are a better"
	line "trainer than me,"

	para "in both skill and"
	line "kindness."

	para "In accordance with"
	line "LEAGUE rules, I"

	para "confer upon you"
	line "this BADGE."
	done

Text_ReceivedMineralBadge:
	text "<PLAYER> received"
	line "MINERALBADGE."
	done

Jasmine_BadgeSpeech:
	text "MINERALBADGE"
	line "raises #MON's"
	cont "DEFENSE."

	para "…Um… Please take"
	line "this too…"
	done

Text_ReceivedTM09: ; unreferenced
	text "<PLAYER> received"
	line "TM09."
	done

Jasmine_IronTailSpeech:
	text "I hope that TM"
	line "helps you on your"
	cont "journey…"
	done

Jasmine_GoodLuck:
	text "Um… I don't know"
	line "how to say this,"
	cont "but good luck…"
	done

JasmineRematchText:
	text "…Congratulations,"
    line "JOHTO CHAMPION."

    para "You have become"
    line "so strong…"

    para "I wonder if I"
    line "have improved."

    para "Would you like"
    line "to test that?"

    para "Want to have a"
    line "rematch with me?"
	done

Jasmine_RematchDefeatText:
	text "…You are a better"
	line "trainer than me,"

	para "in both skill and"
	line "kindness."
	done

OlivineGymGuideText:
	text "JASMINE uses the"
	line "newly discovered"
	cont "STEEL-type."

	para "She's known for"
	line "having not one,"
	cont "but two aces."
	
	para "The first is a"
	line "metal bug that can"
	
	para "use a technique to"
	line "boost its ATTACK."
	
	para "While fire will"
	line "hurt it, it can"

	para "sometimes endure"
	line "powerful blows."
	
	para "The second is a"
	line "giant iron snake"
	
	para "with lots of"
	line "powerful moves."
	
	para "Approach it with"
	line "caution."
	
	para "It may look slow,"
	line "but I've seen it"

	para "strike first with"
	line "shocking displays"
	cont "of SPEED."
	done

OlivineGymGuideWinText:
	text "That was awesome."

	para "The STEEL-type,"
	line "huh?"

	para "That was a close"
	line "encounter of an"
	cont "unknown kind!"
	done

OlivineGymGuidePreText:
	text "JASMINE, the GYM"
	line "LEADER, is at the"
	cont "LIGHTHOUSE."

	para "She's been tending"
	line "to a sick #MON."

	para "A strong trainer"
	line "has to be compas-"
	cont "sionate."
	done

SabrinaGuestIntroText:
	text "SABRINA: I foresaw"
	line "you coming here."

	para "JASMINE and I"
	line "traded GYMS for a"
	cont "while."

	para "Your kindness at"
	line "the LIGHTHOUSE…"

	para "I sensed it too."
	line "Now show me your"
	cont "power!"
	done

SabrinaGuestWinLossText:
	text "SABRINA: Beyond"
	line "what I foresaw…"

	para "MINERALBADGE is"
	line "yours."
	done

SabrinaGuestTMText:
	text "SABRINA: I see"
	line "that TM in your"
	cont "future battles."
	done

SabrinaGuestFightDoneText:
	text "SABRINA: The sea"
	line "air clears the"
	cont "mind."

	para "Still, I miss the"
	line "quiet of SAFFRON."
	done

SabrinaGuestRematchText:
	text "SABRINA: JOHTO"
	line "CHAMPION… I knew."

	para "My true team is"
	line "ready. Rematch?"
	done

OlivineGymGuideGuestText:
	text "SABRINA from KANTO"
	line "holds this GYM"
	cont "for now."

	para "Her PSYCHIC-types"
	line "hit hard and fast."

	para "BUG and GHOST"
	line "moves are your"
	cont "best friends,"

	para "and a DARK-type"
	line "shrugs them off."
	done

OlivineGymGuidePreGuestText:
	text "SABRINA, our guest"
	line "LEADER, went to"
	cont "the LIGHTHOUSE"

	para "with JASMINE to"
	line "tend to a sick"
	cont "#MON."

	para "A strong trainer"
	line "has to be compas-"
	cont "sionate."
	done

OlivineGym_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 15, OLIVINE_CITY, 2
	warp_event  5, 15, OLIVINE_CITY, 2

	def_coord_events

	def_bg_events
	bg_event  3, 13, BGEVENT_READ, OlivineGymStatue
	bg_event  6, 13, BGEVENT_READ, OlivineGymStatue

	def_object_events
	object_event  5,  3, SPRITE_GYM_LEADER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OlivineGymJasmineScript, EVENT_OLIVINE_GYM_JASMINE
	object_event  7, 13, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, OlivineGymGuideScript, -1
