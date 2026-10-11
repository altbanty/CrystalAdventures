	object_const_def
	const SEAFOAMGYM_BLAINE
	const SEAFOAMGYM_GYM_GUIDE

SeafoamGym_MapScripts:
	def_scene_scripts
	scene_script .DummyScene

	def_callbacks
	callback MAPCALLBACK_SPRITES, .LeaderSprite
	callback MAPCALLBACK_OBJECTS, .LeaderSpriteObjects

.DummyScene:
	end

; Gym swap pair 7 (see MahoganyGym.asm).
.LeaderSpriteObjects:
	callasm ApplySeafoamGymLeaderSprite
	endcallback

.LeaderSprite:
	checkevent EVENT_GYM_PAIR_7_ROLLED
	iftrue .SetSprite
	setevent EVENT_GYM_PAIR_7_ROLLED
	random 2
	ifequal 0, .SetSprite
	setevent EVENT_GYM_PAIR_7_SWAPPED
.SetSprite:
	callasm ApplySeafoamGymLeaderSprite
	endcallback

SeafoamGymBlaineScript:
	faceplayer
	opentext
	checkflag ENGINE_VOLCANOBADGE
	iftrue .FightDone
	checkevent EVENT_GYM_PAIR_7_SWAPPED
	iftrue .GuestPryce
	writetext BlaineIntroText
	waitbutton
	closetext
	winlosstext BlaineWinLossText, 0
	setval 10
	callasm LoadKantoGymTrainer
	sjump .BlaineLoadEnd

; Pryce holds the cave this run. He minds Moltres for Blaine, so every
; guest team carries it and the slot's Moltres release still fits.
.GuestPryce:
	writetext PryceGuestIntroText
	waitbutton
	closetext
	winlosstext PryceGuestWinLossText, 0
	setval 14
	callasm LoadKantoGymTrainer
.BlaineLoadEnd:
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_BLAINE1
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_BLAINE1
	startbattle
	iftrue .ReturnAfterBattle
	appear SEAFOAMGYM_GYM_GUIDE
.ReturnAfterBattle:
	reloadmapafterbattle
	clearevent EVENT_CAUGHT_MOLTRES
	opentext
	writetext ReceivedVolcanoBadgeText
	playsound SFX_GET_BADGE
	waitsfx
	setflag ENGINE_VOLCANOBADGE

; 	checkevent EVENT_BEAT_BLAINE
; 	iftrue .MoltresAlreadyReleased
; 	setval MOLTRES
;     special ShowPokedexEntry
; .MoltresAlreadyReleased

	setevent EVENT_BEAT_BLAINE
	checkevent EVENT_GYM_PAIR_7_SWAPPED
	iftrue .GuestAfterBattle
	writetext BlaineAfterBattleText
	waitbutton
	closetext
	jumpstd KantoLevelCapUpdateScript
	end

.GuestAfterBattle:
	writetext PryceGuestAfterBattleText
	waitbutton
	closetext
	jumpstd KantoLevelCapUpdateScript
	end

.FightDone:
	checkevent EVENT_ELITE_4_REMATCH
	iffalse .NotBeatE4Rematch
	checkevent EVENT_GYM_PAIR_7_SWAPPED
	iftrue .GuestRematchAsk
	writetext BlaineRematchText
	yesorno
	iftrue .BlaineRematch
	sjump .SaidNo
.GuestRematchAsk:
	writetext PryceGuestRematchText
	yesorno
	iftrue .GuestPryceRematch
	sjump .SaidNo
.NotBeatE4Rematch
	checkevent EVENT_GYM_PAIR_7_SWAPPED
	iftrue .GuestTalk
	writetext BlaineFightDoneText
	waitbutton
.SaidNo
	closetext
	end

.GuestTalk:
	writetext PryceGuestFightDoneText
	waitbutton
	closetext
	end

.GuestPryceRematch:
	special HealParty
	winlosstext PryceGuestWinLossText, 0
	setval 14
	callasm LoadKantoGymTrainer
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_guest
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
.normalmode_guest
	startbattle
	reloadmapafterbattle
	end

.BlaineRematch:
	special HealParty
	winlosstext Blaine_RematchDefeatText, 0
	setval 10
	callasm LoadKantoGymTrainer
	checkflag ENGINE_ADVENTURE_MODE
	iffalse .normalmode_2
	loadvar VAR_BATTLETYPE, BATTLETYPE_SETNOITEMS
	.normalmode_2
	startbattle
	reloadmapafterbattle
	end

SeafoamGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_TALKED_TO_SEAFOAM_GYM_GUIDE_ONCE
	iftrue .TalkedToSeafoamGymGuideScript
	writetext SeafoamGymGuideWinText
	waitbutton
	closetext
	setevent EVENT_TALKED_TO_SEAFOAM_GYM_GUIDE_ONCE
	end

.TalkedToSeafoamGymGuideScript:
	writetext SeafoamGymGuideWinText2
	waitbutton
	closetext
	end

BlaineIntroText:
	text "BLAINE: Waaah!"

	para "My GYM in CINNABAR"
	line "burned down."
	
	para "But I'm back in"
	line "business as a GYM"

	para "LEADER here in"
	line "this cave."

	para "It's fine though,"
	line "I have faced"

	para "hardship like"
	line "this before."

	para "Long ago I was"
	line "lost in the"
	
	para "mountains until"
	line "a fiery bird"
	
	para "#MON appeared"
	line "to lead me down."
	
	para "All these years"
	line "later and now"
	
	para "RED has entrusted"
	line "me to look over"

	para "that same"
	line "legendary bird,"

	para "MOLTRES."
	
	para "Ha! You'd better"
	line "have BURN HEAL,"
	
	para "It's even hotter"
	line "than your mom!"
	done

BlaineWinLossText:
	text "BLAINE: Awesome."
	line "I've burned out…"

	para "You've earned"
	line "VOLCANOBADGE!"
	done

ReceivedVolcanoBadgeText:
	text "<PLAYER> received"
	line "VOLCANOBADGE."
	done

BlaineAfterBattleText:
	text "BLAINE: I did lose"
	line "this time, but I'm"

	para "going to win the"
	line "next time."

	para "When I rebuild my"
	line "CINNABAR GYM,"

	para "we'll have to have"
	line "a rematch."
	done

BlaineFightDoneText:
	text "BLAINE: My fire"
	line "#MON will be"

	para "even stronger."
	line "Just you watch!"
	done

BlaineRematchText:
	text "BLAINE: Whoa!"

	para "I see you've"
	line "become the"
	cont "KANTO CHAMPION!"

	para "That's blazing!"

	para "Your skills are"
	line "top-notch."

	para "I'm always"
	line "up for a battle."

	para "Want to have a"
	line "rematch with me?"
	done

Blaine_RematchDefeatText:
	text "BLAINE: Your"
	line "skills are truly"
	cont "fiery!"

	para "You've burned"
	line "right through"
	cont "my defenses."
	done

PryceGuestIntroText:
	text "PRYCE: Hm. So you"
	line "found this cave."

	para "BLAINE and I"
	line "traded GYMS for a"
	cont "while."

	para "He left MOLTRES in"
	line "my care. A fire"

	para "bird with an ice"
	line "trainer… It has"
	cont "much to teach me."

	para "I do not lose"
	line "easily. Come!"
	done

PryceGuestWinLossText:
	text "Ah, I am impressed"
	line "by your prowess."

	para "You are worthy of"
	line "VOLCANOBADGE!"
	done

PryceGuestAfterBattleText:
	text "PRYCE: MOLTRES"
	line "flies free again."

	para "When the ice and"
	line "snow melt, spring"
	cont "arrives."

	para "Go. Your journey"
	line "is not over."
	done

PryceGuestFightDoneText:
	text "PRYCE: This cave"
	line "is pleasantly"
	cont "cool."

	para "I may stay a"
	line "while longer."
	done

PryceGuestRematchText:
	text "PRYCE: Ah, KANTO"
	line "CHAMPION!"

	para "I still have a"
	line "few tricks left."

	para "Want to have a"
	line "rematch with me?"
	done

SeafoamGymGuideWinText:
	text "Yo!"

	para "… Huh? It's over"
	line "already?"

	para "Sorry, sorry!"

	para "CINNABAR GYM was"
	line "gone, so I didn't"

	para "know where to find"
	line "you."

	para "But, hey, you're"
	line "plenty strong even"

	para "without my advice."
	line "I knew you'd win!"
	done

SeafoamGymGuideWinText2:
	text "A #MON GYM can"
	line "be anywhere as"

	para "long as the GYM"
	line "LEADER is there."

	para "There's no need"
	line "for a building."
	done

SeafoamGym_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  5,  5, ROUTE_20, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  2, SPRITE_GYM_LEADER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SeafoamGymBlaineScript, -1
	object_event  6,  5, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, SeafoamGymGuideScript, EVENT_SEAFOAM_GYM_GYM_GUIDE
