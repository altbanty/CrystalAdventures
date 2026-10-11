	object_const_def
	const BLACKTHORNGYM1F_CLAIR
	const BLACKTHORNGYM1F_COOLTRAINER_M1
	const BLACKTHORNGYM1F_COOLTRAINER_M2
	const BLACKTHORNGYM1F_COOLTRAINER_F
	const BLACKTHORNGYM1F_GYM_GUIDE

BlackthornGym1F_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_TILES, .Boulders
	callback MAPCALLBACK_SPRITES, .LeaderSprite
	callback MAPCALLBACK_OBJECTS, .LeaderSpriteObjects

; Gym swap pair 8 (Clair <-> Blue; see CianwoodGym.asm). The Dragon's Den
; test and Clair's shrine scene are the slot's and run unchanged: a guest
; Blue sends you to the den, and Clair still comes back to judge it.
.LeaderSpriteObjects:
	callasm ApplyBlackthornGymLeaderSprite
	endcallback

.LeaderSprite:
	checkevent EVENT_GYM_PAIR_8_ROLLED
	iftrue .SetSprite
	setevent EVENT_GYM_PAIR_8_ROLLED
	random 2
	ifequal 0, .SetSprite
	setevent EVENT_GYM_PAIR_8_SWAPPED
.SetSprite:
	callasm ApplyBlackthornGymLeaderSprite
	endcallback

.Boulders:
	checkevent EVENT_BOULDER_IN_BLACKTHORN_GYM_1
	iffalse .skip1
	changeblock 8, 2, $3b ; fallen boulder 2
.skip1
	checkevent EVENT_BOULDER_IN_BLACKTHORN_GYM_2
	iffalse .skip2
	changeblock 2, 4, $3a ; fallen boulder 1
.skip2
	checkevent EVENT_BOULDER_IN_BLACKTHORN_GYM_3
	iffalse .skip3
	changeblock 8, 6, $3b ; fallen boulder 2
.skip3
	endcallback

BlackthornGymClairScript:
	faceplayer
	opentext
	checkflag ENGINE_RISINGBADGE
	iftrue .AlreadyGotBadge
	checkevent EVENT_BEAT_CLAIR
	iftrue .FightDone
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestBlue
	writetext ClairIntroText
	waitbutton
	closetext
	winlosstext ClairWinText, 0
	callasm GetClairTeam
	ifequal 3, .Team3
	ifequal 2, .Team2
	loadtrainer CLAIR, CLAIR1
	sjump .ClairLoadEnd
.Team2:
	loadtrainer CLAIR, CLAIR2
	sjump .ClairLoadEnd
.Team3:
	loadtrainer CLAIR, CLAIR3
	sjump .ClairLoadEnd

; Blue holds Blackthorn Gym this run; the slot's per-save roll picks his
; variant and the Dragon's Den badge flow is untouched.
.GuestBlue:
	writetext BlueGuestIntroText
	waitbutton
	closetext
	winlosstext BlueGuestWinText, 0
	callasm GetClairTeam
	ifequal 3, .BlueTeam3
	ifequal 2, .BlueTeam2
	loadtrainer BLUE, BLUE5
	sjump .ClairLoadEnd
.BlueTeam2:
	loadtrainer BLUE, BLUE6
	sjump .ClairLoadEnd
.BlueTeam3:
	loadtrainer BLUE, BLUE7
.ClairLoadEnd:
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_CLAIR1
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_CLAIR1
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_CLAIR
	opentext
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestGoToDen
	writetext ClairText_GoToDragonsDen
	sjump .AfterGoToDen
.GuestGoToDen:
	writetext BlueGuestGoToDragonsDenText
.AfterGoToDen:
	waitbutton
	closetext
	setevent EVENT_BEAT_COOLTRAINERM_PAUL
	setevent EVENT_BEAT_COOLTRAINERM_CODY
	setevent EVENT_BEAT_COOLTRAINERM_MIKE
	setevent EVENT_BEAT_COOLTRAINERF_FRAN
	setevent EVENT_BEAT_COOLTRAINERF_LOLA
	clearevent EVENT_MAHOGANY_MART_OWNERS
	setevent EVENT_BLACKTHORN_CITY_GRAMPS_BLOCKS_DRAGONS_DEN
	clearevent EVENT_BLACKTHORN_CITY_GRAMPS_NOT_BLOCKING_DRAGONS_DEN
	end

.FightDone:
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestTooMuch
	writetext ClairText_TooMuchToExpect
	waitbutton
	closetext
	end

.GuestTooMuch:
	writetext BlueGuestTooMuchText
	waitbutton
	closetext
	end

.AlreadyGotBadge:
	checkevent EVENT_GOT_TM24_DRAGONBREATH
	iftrue .GotTM24
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestKeptWaiting
	writetext BlackthornGymClairText_YouKeptMeWaiting
	sjump .GiveTM24
.GuestKeptWaiting:
	writetext BlueGuestTMText
.GiveTM24:
	promptbutton
	setval 8
	callasm GetGymTM
	verbosegiveitem ITEM_FROM_MEM, 1
	iffalse .BagFull
	setevent EVENT_GOT_TM24_DRAGONBREATH
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestDescribeTM
	writetext BlackthornGymClairText_DescribeTM24
	promptbutton
	sjump .GotTM24
.GuestDescribeTM:
	writetext BlueGuestDescribeTMText
	promptbutton
	sjump .GotTM24

.BagFull:
	writetext BlackthornGymClairText_BagFull
	waitbutton
	closetext
	end

.GotTM24:
	checkevent EVENT_BEAT_ELITE_FOUR
	iffalse .NotBeatE4
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestRematchAsk
	writetext ClairRematchText
	yesorno
	iftrue .ClairRematch
	sjump .CantRematchYet
.GuestRematchAsk:
	writetext BlueGuestRematchText
	yesorno
	iftrue .GuestBlueRematch
	sjump .CantRematchYet
.NotBeatE4
	writetext BlackthornGymClairText_League
	waitbutton
.CantRematchYet:
	closetext
	end

; Swapped rematch: Blue brings his real (Kanto-tier) team.
.GuestBlueRematch:
	special HealParty
	winlosstext BlueGuestWinText, 0
	setval 11
	callasm LoadKantoGymTrainer
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_guest_rematch
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_guest_rematch
	startbattle
	reloadmapafterbattle
	end

.ClairRematch:
	special HealParty
	winlosstext Clair_RematchDefeatText, 0
	loadtrainer CLAIR, CLAIR4
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_2
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_2
	startbattle
	reloadmapafterbattle
	end

TrainerCooltrainermPaul:
	trainer COOLTRAINERM, PAUL, EVENT_BEAT_COOLTRAINERM_PAUL, CooltrainermPaulSeenText, CooltrainermPaulBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext CooltrainermPaulAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainermMike:
	trainer COOLTRAINERM, MIKE, EVENT_BEAT_COOLTRAINERM_MIKE, CooltrainermMikeSeenText, CooltrainermMikeBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext CooltrainermMikeAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainerfLola:
	trainer COOLTRAINERF, LOLA, EVENT_BEAT_COOLTRAINERF_LOLA, CooltrainerfLolaSeenText, CooltrainerfLolaBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext CooltrainerfLolaAfterBattleText
	waitbutton
	closetext
	end

BlackthornGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_CLAIR
	iftrue .BlackthornGymGuideWinScript
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestGuide
	writetext BlackthornGymGuideText
	waitbutton
	closetext
	end

.GuestGuide:
	writetext BlackthornGymGuideGuestText
	waitbutton
	closetext
	end

.BlackthornGymGuideWinScript:
	checkevent EVENT_GYM_PAIR_8_SWAPPED
	iftrue .GuestGuideWin
	writetext BlackthornGymGuideWinText
	waitbutton
	closetext
	end

.GuestGuideWin:
	writetext BlackthornGymGuideGuestWinText
	waitbutton
	closetext
	end

BlackthornGymStatue:
	checkflag ENGINE_RISINGBADGE
	iftrue .Beaten
	jumpstd GymStatue1Script
.Beaten:
	gettrainername STRING_BUFFER_4, CLAIR, CLAIR1
	jumpstd GymStatue2Script

ClairIntroText:
	text "I am CLAIR."

	para "The world's best"
	line "dragon master."

	para "I can hold my own"
	line "against even the"

	para "#MON LEAGUE's"
	line "ELITE FOUR."

	para "Do you still want"
	line "to take me on?"

	para "…Fine."
	line "Let's do it!"

	para "As a GYM LEADER,"
	line "I will use my full"

	para "power against any"
	line "opponent!"
	done

ClairWinText:
	text "I lost?"

	para "I don't believe"
	line "it. There must be"
	cont "some mistake…"
	done

ClairText_GoToDragonsDen:
	text "I won't admit"
	line "this."

	para "I may have lost,"
	line "but you're still"

	para "not ready for the"
	line "#MON LEAGUE."

	para "I know. You should"
	line "take the dragon"
	cont "user challenge."

	para "Behind this GYM is"
	line "a place called"
	cont "DRAGON'S DEN."

	para "There is a small"
	line "shrine at its"

	para "center."
	line "Go there."

	para "If you can prove"
	line "that you've lost"

	para "your lazy ideals,"
	line "I will recognize"

	para "you as a trainer"
	line "worthy of a GYM"
	cont "BADGE!"
	done

ClairText_TooMuchToExpect:
	text "What's the matter?"

	para "Is it too much to"
	line "expect of you?"
	done

BlackthornGymClairText_YouKeptMeWaiting:
	text "You've kept me"
	line "waiting!"

	para "Here! Take this!"
	done

BlackthornGymText_ReceivedTM24:
	text "<PLAYER> received"
	line "TM24 DRAGONBREATH."
	done

BlackthornGymClairText_DescribeTM24:
	text "Hmph. You should"
	line "be grateful I'm"
	cont "giving that to"
	cont "you."
	done

BlackthornGymClairText_BagFull:
	text "What is this? You"
	line "don't have room?"
	done

BlackthornGymClairText_League:
	text "What's the matter?"

	para "Aren't you headed"
	line "to the #MON"
	cont "LEAGUE?"

	para "Don't you know"
	line "where it is?"

	para "From here, go to"
	line "NEW BARK TOWN."

	para "Then SURF east."
	line "The route there is"
	cont "very tough."

	para "Don't you dare"
	line "lose at the #-"
	cont "MON LEAGUE!"

	para "If you do, I'll"
	line "feel even worse"

	para "about having lost"
	line "to you!"

	para "Give it every-"
	line "thing you've got."
	done

ClairRematchText:
	text "You did it, huh?"

	para "You are now the"
	line "JOHTO CHAMP."

	para "You've proven"
	line "your strength"

	para "but can you"
	line "handle me again?"

	para "As a Dragon"
	line "Master, I won't"
	cont "hold back."

	para "Not this time."

	para "Want to have a"
	line "rematch with me?"
	done

Clair_RematchDefeatText:
	text "I lost?"

	para "Again?"

	para "I don't believe"
	line "it. There must be"
	cont "some mistake…"
	done

CooltrainermPaulSeenText:
	text "Your first battle"
	line "against dragons?"

	para "I'll show you how"
	line "tough they are!"
	done

CooltrainermPaulBeatenText:
	text "My dragon #MON"
	line "lost?"
	done

CooltrainermPaulAfterBattleText:
	text "LANCE told you"
	line "that he'd like to"

	para "see you again?"
	line "Not a chance!"
	done

CooltrainermMikeSeenText:
	text "My chance of"
	line "losing? Not even"
	cont "one percent!"
	done

CooltrainermMikeBeatenText:
	text "That's odd."
	done

CooltrainermMikeAfterBattleText:
	text "I know my short-"
	line "comings now."

	para "Thanks for showing"
	line "me!"
	done

CooltrainerfLolaSeenText:
	text "Dragons are sacred"
	line "#MON."

	para "They are full of"
	line "life energy."

	para "If you're not"
	line "serious, you won't"

	para "be able to beat"
	line "them."
	done

CooltrainerfLolaBeatenText:
	text "Way to go!"
	done

CooltrainerfLolaAfterBattleText:
	text "Dragons are weak"
	line "against DRAGON-"
	cont "type moves."
	done

BlackthornGymGuideText:
	text "Yo! CHAMP in"
	line "making!"

	para "It's been a long"
	line "journey, but we"

	para "are almost done!"
	line "Count on me!"
	
	para "While CLAIR looks"
	line "up to the Dragon"
	cont "Master, LANCE,"
	
	para "she's managed to"
	line "create her own"
	cont "identity with a"

	para "team consisting"
	line "of dragons from"
	cont "the sea."

	para "Dragons are"
	line "supposed to be"

	para "weak against"
	line "ICE-type moves,"
	
	para "but you'll need"
	line "some DRAGON-type"
	
	para "moves of your own"
	line "if you want to"
	cont "win."
	
	para "You got this!"
	done

BlackthornGymGuideWinText:
	text "You were great to"
	line "beat CLAIR!"

	para "All that's left is"
	line "the #MON LEAGUE"
	cont "challenge."

	para "You're on the way"
	line "to becoming the"
	cont "#MON CHAMPION!"
	done

BlueGuestIntroText:
	text "BLUE: Yo! So you"
	line "made it up here."

	para "CLAIR and I traded"
	line "GYMS for a while."

	para "Dragons, huh? I"
	line "brought my own"
	cont "team. Let's go!"
	done

BlueGuestWinText:
	text "BLUE: What?"

	para "How the heck did I"
	line "lose to you?"
	done

BlueGuestGoToDragonsDenText:
	text "BLUE: Tch. You"
	line "beat me, fine."

	para "But CLAIR's rules:"
	line "nobody gets the"

	para "RISINGBADGE until"
	line "they pass the test"
	cont "at DRAGON'S DEN."

	para "It's behind this"
	line "GYM. Go on."
	done

BlueGuestTooMuchText:
	text "BLUE: The DRAGON'S"
	line "DEN. Behind the"
	cont "GYM. Get going."
	done

BlueGuestTMText:
	text "BLUE: Took you"
	line "long enough!"

	para "CLAIR left this"
	line "for the winner."
	done

BlueGuestDescribeTMText:
	text "BLUE: Don't thank"
	line "me. Thank her."
	done

BlueGuestRematchText:
	text "BLUE: Well, well."
	line "JOHTO CHAMPION!"

	para "My real team's"
	line "here. Rematch?"
	done

BlackthornGymGuideGuestText:
	text "Yo! CHAMP in"
	line "making!"

	para "BLUE from KANTO"
	line "holds this GYM"
	cont "for now."

	para "No single type to"
	line "plan around, so"

	para "bring a balanced"
	line "team and watch"
	cont "his ARCANINE!"
	done

BlackthornGymGuideGuestWinText:
	text "You were great to"
	line "beat BLUE!"

	para "All that's left is"
	line "the #MON LEAGUE"
	cont "challenge."

	para "You're on the way"
	line "to becoming the"
	cont "#MON CHAMPION!"
	done

BlackthornGym1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 17, BLACKTHORN_CITY, 1
	warp_event  5, 17, BLACKTHORN_CITY, 1
	warp_event  1,  7, BLACKTHORN_GYM_2F, 1
	warp_event  7,  9, BLACKTHORN_GYM_2F, 2
	warp_event  2,  6, BLACKTHORN_GYM_2F, 3
	warp_event  7,  7, BLACKTHORN_GYM_2F, 4
	warp_event  7,  6, BLACKTHORN_GYM_2F, 5

	def_coord_events

	def_bg_events
	bg_event  3, 15, BGEVENT_READ, BlackthornGymStatue
	bg_event  6, 15, BGEVENT_READ, BlackthornGymStatue

	def_object_events
	object_event  5,  3, SPRITE_GYM_LEADER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, BlackthornGymClairScript, -1
	object_event  6,  6, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerCooltrainermMike, -1
	object_event  1, 14, SPRITE_COOLTRAINER_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerCooltrainermPaul, -1
	object_event  9,  2, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 1, TrainerCooltrainerfLola, -1
	object_event  7, 15, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, BlackthornGymGuideScript, -1
