	object_const_def
	const VIRIDIANGYM_BLUE
	const VIRIDIANGYM_GYM_GUIDE

ViridianGym_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_SPRITES, .LeaderSprite
	callback MAPCALLBACK_OBJECTS, .LeaderSpriteObjects

; Gym swap pair 8 (see BlackthornGym1F.asm). The leader object stays
; hidden until Blue's Cinnabar scene whoever holds the gym.
.LeaderSpriteObjects:
	callasm ApplyViridianGymLeaderSprite
	endcallback

.LeaderSprite:
	checkevent EVENT_GYM_PAIR_8_ROLLED
	iftrue .SetSprite
	setevent EVENT_GYM_PAIR_8_ROLLED
	random 2
	ifequal 0, .SetSprite
	setevent EVENT_GYM_PAIR_8_SWAPPED
.SetSprite:
	callasm ApplyViridianGymLeaderSprite
	endcallback

ViridianGymBlueScript:
	faceplayer
	opentext
	checkflag ENGINE_EARTHBADGE
	iftrue .FightDone
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestClair
	writetext LeaderBlueBeforeText
	waitbutton
	closetext
	winlosstext LeaderBlueWinText, 0
	setval 11
	callasm LoadKantoGymTrainer
	sjump .BlueLoadEnd

; Clair holds Viridian Gym this run; she minds Articuno for Blue, so
; every guest team carries it and the slot's Articuno release still fits.
.GuestClair:
	writetext ClairGuestIntroText
	waitbutton
	closetext
	winlosstext ClairGuestWinText, 0
	setval 15
	callasm LoadKantoGymTrainer
.BlueLoadEnd:
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_BLUE1
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_BLUE1
	startbattle
	reloadmapafterbattle
	clearevent EVENT_CAUGHT_ARTICUNO
	opentext
	writetext Text_ReceivedEarthBadge
	playsound SFX_GET_BADGE
	waitsfx
	setflag ENGINE_EARTHBADGE
	jumpstd KantoLevelCapUpdateScript

; 	checkevent EVENT_BEAT_BLUE
; 	iftrue .ArticunoAlreadyReleased
; 	setval ARTICUNO
;     special ShowPokedexEntry
; .ArticunoAlreadyReleased

	setevent EVENT_BEAT_BLUE
	writetext LeaderBlueAfterText
	waitbutton
	closetext
	end

.FightDone:
	checkevent EVENT_ELITE_4_REMATCH
	iffalse .NotBeatE4Rematch
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestRematchAsk
	writetext BlueRematchText
	yesorno
	iftrue .BlueRematch
	sjump .SaidNo
.GuestRematchAsk:
	writetext ClairGuestRematchText
	yesorno
	iftrue .GuestClairRematch
	sjump .SaidNo
.NotBeatE4Rematch
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestTalk
	writetext LeaderBlueEpilogueText
	waitbutton
.SaidNo
	closetext
	end

.GuestTalk:
	writetext ClairGuestEpilogueText
	waitbutton
	closetext
	end

.GuestClairRematch:
	special HealParty
	winlosstext ClairGuestWinText, 0
	setval 15
	callasm LoadKantoGymTrainer
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_guest
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_guest
	startbattle
	reloadmapafterbattle
	end

.BlueRematch:
	special HealParty
	winlosstext Blue_RematchDefeatText, 0
	loadtrainer BLUE, 2
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_2
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
	.normalmode_2
	startbattle
	reloadmapafterbattle
	end

ViridianGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_BLUE
	iftrue .ViridianGymGuideWinScript
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestGuide
	writetext ViridianGymGuideText
	waitbutton
	closetext
	end

.GuestGuide:
	writetext ViridianGymGuideGuestText
	waitbutton
	closetext
	end

.ViridianGymGuideWinScript:
	writetext ViridianGymGuideWinText
	waitbutton
	closetext
	end

ViridianGymStatue:
	checkflag ENGINE_EARTHBADGE
	iftrue .Beaten
	jumpstd GymStatue1Script

.Beaten:
	gettrainername STRING_BUFFER_4, BLUE, BLUE1
	jumpstd GymStatue2Script

LeaderBlueBeforeText:
	text "BLUE: Yo! Finally"
	line "got here, huh?"

	para "I wasn't in the"
	line "mood at CINNABAR,"

	para "but now I'm ready"
	line "to battle you."

	para "…"

	para "You're telling me"
	line "you conquered all"
	cont "the GYMS in JOHTO?"

	para "Heh! JOHTO's GYMS"
	line "must be pretty"
	cont "pathetic then."

	para "Hey, don't worry"
	line "about it."

	para "I'll know if you"
	line "are good or not by"

	para "battling you right"
	line "now."

	para "Ready, JOHTO"
	line "CHAMP?"
	done

LeaderBlueWinText:
	text "BLUE: What?"

	para "How the heck did I"
	line "lose to you?"

	para "…"

	para "Tch, all right…"
	line "Here, take this--"
	cont "it's EARTHBADGE."
	done

Text_ReceivedEarthBadge:
	text "<PLAYER> received"
	line "EARTHBADGE."
	done

LeaderBlueAfterText:
	text "BLUE: …"

	para "All right, I was"
	line "wrong. You're the"

	para "real deal. You are"
	line "a good trainer."

	para "But I'm going to"
	line "beat you someday."

	para "Don't you forget"
	line "it!"
	done

LeaderBlueEpilogueText:
	text "BLUE: Listen, you."

	para "You'd better not"
	line "lose until I beat"
	cont "you. Got it?"
	done

BlueRematchText:
	text "BLUE: Well, well."
	line "KANTO CHAMPION!"

	para "Looks like you've"
	line "come a long way."

	para "I used to have"
	line "that title too,"
	cont "you know. But I"
	cont "won't go easy."

	para "Let's see if you"
	line "can keep it up."

	para "Want to have a"
	line "rematch with me?"
	done

Blue_RematchDefeatText:
	text "BLUE: What?"

	para "How the heck did I"
	line "lose again?"
	done

ViridianGymGuideText:
	text "Yo, CHAMP in"
	line "making!"

	para "How's it going?"
	line "Looks like you're"
	cont "on a roll."

	para "The GYM LEADER is"
	line "a guy who battled"

	para "the CHAMPION three"
	line "years ago."

	para "He's no pushover."

	para "Give it everything"
	line "you've got!"
	done

ViridianGymGuideGuestText:
	text "Yo, CHAMP in"
	line "making!"

	para "CLAIR from JOHTO"
	line "holds this GYM"
	cont "for now."

	para "Dragons shrug off"
	line "most attacks."

	para "ICE moves and"
	line "DRAGON moves are"
	cont "the way to win!"
	done

ClairGuestIntroText:
	text "CLAIR: So. BLUE"
	line "said you'd come."

	para "He and I traded"
	line "GYMS for a while."

	para "He also left me"
	line "ARTICUNO to mind."

	para "A bird of ice,"
	line "among my dragons…"

	para "As a GYM LEADER,"
	line "I will use my full"

	para "power against any"
	line "opponent!"
	done

ClairGuestWinText:
	text "I lost?"

	para "I don't believe"
	line "it. There must be"
	cont "some mistake…"

	para "…Take the"
	line "EARTHBADGE."
	done

ClairGuestEpilogueText:
	text "CLAIR: Don't you"
	line "dare lose at the"
	cont "#MON LEAGUE."

	para "I'd feel even"
	line "worse about"
	cont "losing to you!"
	done

ClairGuestRematchText:
	text "CLAIR: KANTO"
	line "CHAMPION, hm?"

	para "As a Dragon"
	line "Master, I won't"
	cont "hold back."

	para "Want to have a"
	line "rematch with me?"
	done

ViridianGymGuideWinText:
	text "Man, you are truly"
	line "tough…"

	para "That was a heck of"
	line "an inspirational"

	para "battle. It brought"
	line "tears to my eyes."
	done

ViridianGym_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 17, VIRIDIAN_CITY, 1
	warp_event  5, 17, VIRIDIAN_CITY, 1

	def_coord_events

	def_bg_events
	bg_event  3, 13, BGEVENT_READ, ViridianGymStatue
	bg_event  6, 13, BGEVENT_READ, ViridianGymStatue

	def_object_events
	object_event  5,  3, SPRITE_GYM_LEADER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ViridianGymBlueScript, EVENT_VIRIDIAN_GYM_BLUE
	object_event  7, 13, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ViridianGymGuideScript, EVENT_VIRIDIAN_GYM_BLUE
