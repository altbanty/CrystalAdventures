	object_const_def
	const FUCHSIAGYM_JANINE
	const FUCHSIAGYM_FUCHSIA_GYM_1
	const FUCHSIAGYM_FUCHSIA_GYM_2
	const FUCHSIAGYM_FUCHSIA_GYM_3
	const FUCHSIAGYM_FUCHSIA_GYM_4
	const FUCHSIAGYM_GYM_GUIDE

FuchsiaGym_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_SPRITES, .LeaderSprite
	callback MAPCALLBACK_OBJECTS, .LeaderSpriteObjects

; Gym swap pair 5 (see CianwoodGym.asm): roll if this gym is reached
; first, then show whoever holds this gym.
.LeaderSpriteObjects:
	callasm ApplyFuchsiaGymLeaderSprite
	endcallback

.LeaderSprite:
	checkevent EVENT_GYM_PAIR_5_ROLLED
	iftrue .SetSprite
	setevent EVENT_GYM_PAIR_5_ROLLED
	random 2
	ifequal 0, .SetSprite
	setevent EVENT_GYM_PAIR_5_SWAPPED
.SetSprite:
	callasm ApplyFuchsiaGymLeaderSprite
	endcallback

FuchsiaGymJanineScript:
	checkflag ENGINE_SOULBADGE
	iftrue .FightDone
	checkevent EVENT_GYM_PAIR_5_SWAPPED
	iftrue .GuestChuck
	applymovement FUCHSIAGYM_JANINE, Movement_NinjaSpin
	faceplayer
	opentext
	writetext JanineText_DisappointYou
	waitbutton
	closetext
	winlosstext JanineText_ToughOne, 0
	setval 8
	callasm LoadKantoGymTrainer
	sjump .JanineLoadEnd

; Chuck holds Fuchsia Gym this run; the Soul Badge flow is unchanged.
; The students still dress as Janine - they're her students, not his.
.GuestChuck:
	faceplayer
	opentext
	writetext ChuckGuestIntroText
	waitbutton
	closetext
	winlosstext ChuckGuestWinLossText, 0
	setval 12
	callasm LoadKantoGymTrainer
.JanineLoadEnd:
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_JANINE1
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_JANINE1
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_JANINE
	setevent EVENT_BEAT_LASS_ALICE
	setevent EVENT_BEAT_LASS_LINDA
	setevent EVENT_BEAT_PICNICKER_CINDY
	setevent EVENT_BEAT_CAMPER_BARRY
	variablesprite SPRITE_FUCHSIA_GYM_1, SPRITE_LASS
	variablesprite SPRITE_FUCHSIA_GYM_2, SPRITE_LASS
	variablesprite SPRITE_FUCHSIA_GYM_3, SPRITE_LASS
	variablesprite SPRITE_FUCHSIA_GYM_4, SPRITE_YOUNGSTER
	special LoadUsedSpritesGFX
	opentext
	writetext Text_ReceivedSoulBadge
	playsound SFX_GET_BADGE
	waitsfx
	setflag ENGINE_SOULBADGE
	closetext
	jumpstd KantoLevelCapUpdateScript
	opentext
	sjump .AfterBattle
.FightDone:
	faceplayer
	opentext
.AfterBattle:
	checkevent EVENT_GOT_TM06_TOXIC
	iftrue .AfterTM
	checkevent EVENT_GYM_PAIR_5_SWAPPED
	iftrue .GuestToxicSpeech
	writetext JanineText_ToxicSpeech
	sjump .GiveToxic
.GuestToxicSpeech:
	writetext ChuckGuestToxicSpeechText
.GiveToxic:
	promptbutton
	verbosegiveitem TM_TOXIC
	iffalse .AfterTM
	setevent EVENT_GOT_TM06_TOXIC
.AfterTM:
	checkevent EVENT_ELITE_4_REMATCH
	iffalse .NotBeatE4Rematch
	checkevent EVENT_GYM_PAIR_5_SWAPPED
	iftrue .GuestRematchAsk
	writetext JanineRematchText
	yesorno
	iftrue .JanineRematch
	sjump .SaidNo
.GuestRematchAsk:
	writetext ChuckGuestRematchText
	yesorno
	iftrue .GuestChuckRematch
	sjump .SaidNo
.NotBeatE4Rematch
	checkevent EVENT_GYM_PAIR_5_SWAPPED
	iftrue .GuestTalk
	writetext JanineText_ApplyMyself
	waitbutton
.SaidNo
	closetext
	end

.GuestTalk:
	writetext ChuckGuestFightDoneText
	waitbutton
	closetext
	end

.GuestChuckRematch:
	special HealParty
	winlosstext ChuckGuestWinLossText, 0
	setval 12
	callasm LoadKantoGymTrainer
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_guest
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_guest
	startbattle
	reloadmapafterbattle
	end

.JanineRematch:
	special HealParty
	winlosstext Janine_RematchDefeatText, 0
	setval 8
	callasm LoadKantoGymTrainer
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_2
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
	.normalmode_2
	startbattle
	reloadmapafterbattle
	end

LassAliceScript:
	checkevent EVENT_BEAT_LASS_ALICE
	iftrue .AliceUnmasked
	applymovement FUCHSIAGYM_FUCHSIA_GYM_1, Movement_NinjaSpin
	faceplayer
	variablesprite SPRITE_FUCHSIA_GYM_1, SPRITE_LASS
	special LoadUsedSpritesGFX
.AliceUnmasked:
	faceplayer
	opentext
	checkevent EVENT_BEAT_LASS_ALICE
	iftrue .AliceAfterScript
	writetext LassAliceBeforeText
	waitbutton
	closetext
	winlosstext LassAliceBeatenText, 0
	loadtrainer LASS, ALICE
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_ALICE
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_ALICE
	startbattle
	iftrue .AliceBecomesJanine
	reloadmapafterbattle
	setevent EVENT_BEAT_LASS_ALICE
	end

.AliceBecomesJanine:
	variablesprite SPRITE_FUCHSIA_GYM_1, SPRITE_JANINE
	reloadmapafterbattle
	end

.AliceAfterScript:
	writetext LassAliceAfterText
	waitbutton
	closetext
	end

LassLindaScript:
	checkevent EVENT_BEAT_LASS_LINDA
	iftrue .LindaUnmasked
	applymovement FUCHSIAGYM_FUCHSIA_GYM_2, Movement_NinjaSpin
	faceplayer
	variablesprite SPRITE_FUCHSIA_GYM_2, SPRITE_LASS
	special LoadUsedSpritesGFX
.LindaUnmasked:
	faceplayer
	opentext
	checkevent EVENT_BEAT_LASS_LINDA
	iftrue .LindaAfterScript
	writetext LassLindaBeforeText
	waitbutton
	closetext
	winlosstext LassLindaBeatenText, 0
	loadtrainer LASS, LINDA
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_LINDA
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_LINDA
	startbattle
	iftrue .LindaBecomesJanine
	reloadmapafterbattle
	setevent EVENT_BEAT_LASS_LINDA
	end

.LindaBecomesJanine:
	variablesprite SPRITE_FUCHSIA_GYM_2, SPRITE_JANINE
	reloadmapafterbattle
	end

.LindaAfterScript:
	writetext LassLindaAfterText
	waitbutton
	closetext
	end

PicnickerCindyScript:
	checkevent EVENT_BEAT_PICNICKER_CINDY
	iftrue .CindyUnmasked
	applymovement FUCHSIAGYM_FUCHSIA_GYM_3, Movement_NinjaSpin
	faceplayer
	variablesprite SPRITE_FUCHSIA_GYM_3, SPRITE_LASS
	special LoadUsedSpritesGFX
.CindyUnmasked:
	faceplayer
	opentext
	checkevent EVENT_BEAT_PICNICKER_CINDY
	iftrue .CindyAfterScript
	writetext PicnickerCindyBeforeText
	waitbutton
	closetext
	winlosstext PicnickerCindyBeatenText, 0
	loadtrainer PICNICKER, CINDY
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_CINDY
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_CINDY
	startbattle
	iftrue .CindyBecomesJanine
	reloadmapafterbattle
	setevent EVENT_BEAT_PICNICKER_CINDY
	end

.CindyBecomesJanine:
	variablesprite SPRITE_FUCHSIA_GYM_3, SPRITE_JANINE
	reloadmapafterbattle
	end

.CindyAfterScript:
	writetext PicnickerCindyAfterText
	waitbutton
	closetext
	end

CamperBarryScript:
	checkevent EVENT_BEAT_CAMPER_BARRY
	iftrue .BarryUnmasked
	applymovement FUCHSIAGYM_FUCHSIA_GYM_4, Movement_NinjaSpin
	faceplayer
	variablesprite SPRITE_FUCHSIA_GYM_4, SPRITE_YOUNGSTER
	special LoadUsedSpritesGFX
.BarryUnmasked:
	faceplayer
	opentext
	checkevent EVENT_BEAT_CAMPER_BARRY
	iftrue .BarryAfterScript
	writetext CamperBarryBeforeText
	waitbutton
	closetext
	winlosstext CamperBarryBeatenText, 0
	loadtrainer CAMPER, BARRY
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_BARRY
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_BARRY
	startbattle
	iftrue .BarryBecomesJanine
	reloadmapafterbattle
	setevent EVENT_BEAT_CAMPER_BARRY
	end

.BarryBecomesJanine:
	variablesprite SPRITE_FUCHSIA_GYM_4, SPRITE_JANINE
	reloadmapafterbattle
	end

.BarryAfterScript:
	writetext CamperBarryAfterText
	waitbutton
	closetext
	end

FuchsiaGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_JANINE
	iftrue .FuchsiaGymGuideWinScript
	checkevent EVENT_GYM_PAIR_5_SWAPPED
	iftrue .GuestGuide
	writetext FuchsiaGymGuideText
	waitbutton
	closetext
	end

.GuestGuide:
	writetext FuchsiaGymGuideGuestText
	waitbutton
	closetext
	end

.FuchsiaGymGuideWinScript:
	writetext FuchsiaGymGuideWinText
	waitbutton
	closetext
	end

FuchsiaGymStatue:
	checkflag ENGINE_SOULBADGE
	iftrue .Beaten
	jumpstd GymStatue1Script
.Beaten:
	gettrainername STRING_BUFFER_4, JANINE, JANINE1
	jumpstd GymStatue2Script

Movement_NinjaSpin:
	turn_head DOWN
	turn_head LEFT
	turn_head UP
	turn_head RIGHT
	turn_head DOWN
	turn_head LEFT
	turn_head UP
	turn_head RIGHT
	turn_head DOWN
	turn_head LEFT
	turn_head UP
	turn_head RIGHT
	turn_head DOWN
	step_end

JanineText_DisappointYou:
	text "Fufufufu…"

	para "I'm sorry to dis-"
	line "appoint you…"

	para "I'm only joking!"

	para "I'm the real deal!"

	para "JANINE of FUCHSIA"
	line "GYM, that's me!"
	done

JanineText_ToughOne:
	text "JANINE: You're a"
	line "tough one. You"
	cont "definitely won…"

	para "Here's SOULBADGE."
	line "Take it."
	done

Text_ReceivedSoulBadge:
	text "<PLAYER> received"
	line "SOULBADGE."
	done

JanineText_ToxicSpeech:
	text "JANINE: You're so"
	line "tough! I have a"
	cont "special gift!"

	para "It's TOXIC, a pow-"
	line "erful poison that"

	para "steadily saps the"
	line "victim's HP."
	done

JanineText_ApplyMyself:
	text "JANINE: I'm going"
	line "to really apply"

	para "myself and improve"
	line "my skills."

	para "I want to become"
	line "better than both"
	cont "Father and you!"
	done

JanineRematchText:
	text "Fufufufu…"

	para "Wow, you did it!"

	para "You're the KANTO"
	line "CHAMPION now!"

	para "I'm so proud of"
	line "you! But don't"
	cont "think I'll go easy"
	cont "on you."

	para "Want to have a"
	line "rematch with me?"
	done

Janine_RematchDefeatText:
	text "JANINE: You're"
	line "still just as"
	cont "tough!"

	para "You definitely"
	line "won…"
	done

LassAliceBeforeText:
	text "Fufufu!"

	para "I'm JANINE, the"
	line "GYM LEADER!"

	para "No, I'm not!"
	line "Gotcha, sucker!"
	done

LassAliceBeatenText:
	text "I had you fooled…"
	done

LassAliceAfterText:
	text "How will you dis-"
	line "tinguish our real"
	cont "LEADER?"
	done

LassLindaBeforeText:
	text "Fooled you!"
	line "Hahaha!"
	done

LassLindaBeatenText:
	text "Ooh… I lost…"
	line "You're not weak…"
	done

LassLindaAfterText:
	text "Well? Wasn't my"
	line "disguise perfect?"
	done

PicnickerCindyBeforeText:
	text "I'm JANINE!"

	para "How did you know I"
	line "was real?"

	para "Let's battle!"
	done

PicnickerCindyBeatenText:
	text "Darn it!"
	line "I wanted to win!"
	done

PicnickerCindyAfterText:
	text "You must be"
	line "getting tired."
	done

CamperBarryBeforeText:
	text "Wahahaha!"

	para "You betcha!"
	line "I'm JANINE!"
	done

CamperBarryBeatenText:
	text "My disguise was"
	line "right on! Dang!"
	done

CamperBarryAfterText:
	text "Hey, you. Was my"
	line "disguise cute or"
	cont "what, huh?"
	done

FuchsiaGymGuideText:
	text "Yo, CHAMP in"
	line "making!"

	para "Whoops! Take a"
	line "good look around"

	para "you. The trainers"
	line "all look like the"
	cont "LEADER, JANINE."

	para "Which of them is"
	line "the real JANINE?"
	done

FuchsiaGymGuideGuestText:
	text "Yo, CHAMP in"
	line "making!"

	para "The trainers here"
	line "all dress up like"
	cont "JANINE…"

	para "but the LEADER"
	line "this year is CHUCK"
	cont "from JOHTO!"
	done

ChuckGuestIntroText:
	text "CHUCK: WAHAHAH!"

	para "JANINE and I"
	line "traded GYMS for a"
	cont "while."

	para "All this spinning"
	line "makes me dizzy!"

	para "Forget tricks."
	line "Let's do battle!"
	done

ChuckGuestWinLossText:
	text "Wha? Huh?"
	line "I lost?"

	para "Fine! You've"
	line "earned SOULBADGE!"
	done

ChuckGuestToxicSpeechText:
	text "CHUCK: Take this"
	line "too! JANINE left"
	cont "it for the winner."

	para "It's TOXIC, a pow-"
	line "erful poison that"

	para "steadily saps the"
	line "victim's HP."
	done

ChuckGuestFightDoneText:
	text "CHUCK: These ninja"
	line "kids never sit"
	cont "still!"

	para "I'm going to train"
	line "24 hours a day to"
	cont "keep up! WAHAHAH!"
	done

ChuckGuestRematchText:
	text "WAHAHAH!"
	line "KANTO CHAMPION!"

	para "My fists have been"
	line "itching for this!"

	para "Ready to see who's"
	line "stronger?"
	done

FuchsiaGymGuideWinText:
	text "That was a great"
	line "battle, trainer"
	cont "from JOHTO!"
	done

FuchsiaGym_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 17, FUCHSIA_CITY, 3
	warp_event  5, 17, FUCHSIA_CITY, 3

	def_coord_events

	def_bg_events
	bg_event  3, 15, BGEVENT_READ, FuchsiaGymStatue
	bg_event  6, 15, BGEVENT_READ, FuchsiaGymStatue

	def_object_events
	object_event  1, 10, SPRITE_GYM_LEADER, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, FuchsiaGymJanineScript, -1
	object_event  5,  7, SPRITE_FUCHSIA_GYM_1, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, LassAliceScript, -1
	object_event  5, 11, SPRITE_FUCHSIA_GYM_2, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, LassLindaScript, -1
	object_event  9,  4, SPRITE_FUCHSIA_GYM_3, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, PicnickerCindyScript, -1
	object_event  4,  2, SPRITE_FUCHSIA_GYM_4, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, CamperBarryScript, -1
	object_event  7, 15, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, FuchsiaGymGuideScript, -1
