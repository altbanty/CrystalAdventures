	object_const_def
	const UNIONCAVEB2F_ROCKER
	const UNIONCAVEB2F_COOLTRAINER_F1
	const UNIONCAVEB2F_COOLTRAINER_F2
	const UNIONCAVEB2F_POKE_BALL1
	const UNIONCAVEB2F_POKE_BALL2
	const UNIONCAVEB2F_LAPRAS

UnionCaveB2F_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, .Visitor
	callback MAPCALLBACK_SPRITES, .VisitorSprite

; A random water Pokemon lives in the B2F pool until fought - a one-time
; encounter (formerly the Friday-only Lapras).
.Visitor:
	checkevent EVENT_FOUGHT_UNION_CAVE_VISITOR
	iftrue .NoAppear
	appear UNIONCAVEB2F_LAPRAS
	endcallback

.NoAppear:
	disappear UNIONCAVEB2F_LAPRAS
	endcallback

; Roll once the first time the player could see it, then re-apply the
; locked choice (weird-tree pattern).
.VisitorSprite:
	checkevent EVENT_FOUGHT_UNION_CAVE_VISITOR
	iftrue .SkipSprite
	checkevent EVENT_UNION_CAVE_VISITOR_ROLLED
	iftrue .ApplySprite
	setevent EVENT_UNION_CAVE_VISITOR_ROLLED
	callasm RollWaterVisitor
.ApplySprite:
	callasm ApplyWaterVisitorSprite
.SkipSprite:
	endcallback

UnionCaveLapras:
	faceplayer
	callasm GetWaterVisitorChoice
	ifequal 1, .Poliwrath
	ifequal 2, .Slowking
	ifequal 3, .Azumarill
	ifequal 4, .Golduck
	ifequal 5, .Corsola
	cry LAPRAS
	loadwildmon LAPRAS, 20
	sjump .StartVisitorBattle

.Poliwrath:
	cry POLIWRATH
	loadwildmon POLIWRATH, 20
	sjump .StartVisitorBattle

.Slowking:
	cry SLOWKING
	loadwildmon SLOWKING, 20
	sjump .StartVisitorBattle

.Azumarill:
	cry AZUMARILL
	loadwildmon AZUMARILL, 20
	sjump .StartVisitorBattle

.Golduck:
	cry GOLDUCK
	loadwildmon GOLDUCK, 20
	sjump .StartVisitorBattle

.Corsola:
	cry CORSOLA
	loadwildmon CORSOLA, 20

.StartVisitorBattle:
	; Static encounter: bypass the Nuzlocke route rule without consuming
	; this map's catch slot (same pattern as the Route 36 weird tree)
	loadmem wNuzlockeFirstEncounter, 1
	startbattle
	loadmem wNuzlockeFirstEncounter, 0
	disappear UNIONCAVEB2F_LAPRAS
	setevent EVENT_FOUGHT_UNION_CAVE_VISITOR
	reloadmapafterbattle
	end

TrainerCooltrainermNick:
	trainer COOLTRAINERM, NICK, EVENT_BEAT_COOLTRAINERM_NICK, CooltrainermNickSeenText, CooltrainermNickBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext CooltrainermNickAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainerfGwen:
	trainer COOLTRAINERF, GWEN, EVENT_BEAT_COOLTRAINERF_GWEN, CooltrainerfGwenSeenText, CooltrainerfGwenBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext CooltrainerfGwenAfterBattleText
	waitbutton
	closetext
	end

TrainerCooltrainerfEmma:
	trainer COOLTRAINERF, EMMA, EVENT_BEAT_COOLTRAINERF_EMMA, CooltrainerfEmmaSeenText, CooltrainerfEmmaBeatenText, 0, .Script

.Script:
	endifjustbattled
	opentext
	writetext CooltrainerfEmmaAfterBattleText
	waitbutton
	closetext
	end

UnionCaveB2FElixer:
	randomized_item_5 ELIXER, MAX_ETHER, HYPER_POTION, ULTRA_BALL, NUGGET

UnionCaveB2FHyperPotion:
	randomized_item_5 HYPER_POTION, MAX_POTION, REVIVE, FULL_HEAL, RARE_CANDY

CooltrainermNickSeenText:
	text "There are two"
	line "kinds of people."

	para "Those who have"
	line "style, and those"
	cont "who don't."

	para "What kind of"
	line "person are you?"
	done

CooltrainermNickBeatenText:
	text "You've got"
	line "dazzling style!"
	done

CooltrainermNickAfterBattleText:
	text "Your #MON style"
	line "is stunning and"
	cont "colorful, I admit."

	para "You'll just keep"
	line "getting better!"
	done

CooltrainerfGwenSeenText:
	text "I'm in training."
	line "Care for a round?"
	done

CooltrainerfGwenBeatenText:
	text "Aww, no! You're"
	line "too good for me."
	done

CooltrainerfGwenAfterBattleText:
	text "I'm going to train"
	line "by myself until I"
	cont "improve."
	done

CooltrainerfEmmaSeenText:
	text "If the #MON I"
	line "liked were there,"
	cont "I'd go anywhere."

	para "That's what a real"
	line "trainer does."
	done

CooltrainerfEmmaBeatenText:
	text "I'd rather pet my"
	line "babies than this!"
	done

CooltrainerfEmmaAfterBattleText:
	text "Just once a week,"
	line "a #MON comes to"
	cont "the water's edge."

	para "I wanted to see"
	line "that #MON…"
	done

UnionCaveB2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  5,  3, UNION_CAVE_B1F, 5

	def_coord_events

	def_bg_events

	def_object_events
	object_event 15, 19, SPRITE_ROCKER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerCooltrainermNick, -1
	object_event  5, 13, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_SPINRANDOM_FAST, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 1, TrainerCooltrainerfGwen, -1
	object_event  3, 30, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_TRAINER, 3, TrainerCooltrainerfEmma, -1
	object_event 16,  2, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, UnionCaveB2FElixer, EVENT_UNION_CAVE_B2F_ELIXER
	object_event 12, 19, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, UnionCaveB2FHyperPotion, EVENT_UNION_CAVE_B2F_HYPER_POTION
	object_event 11, 31, SPRITE_WATER_VISITOR, SPRITEMOVEDATA_SWIM_WANDER, 1, 1, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, UnionCaveLapras, EVENT_UNION_CAVE_B2F_LAPRAS
