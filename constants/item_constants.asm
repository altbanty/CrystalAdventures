; item ids
; indexes for:
; - ItemNames (see data/items/names.asm)
; - ItemDescriptions (see data/items/descriptions.asm)
; - ItemAttributes (see data/items/attributes.asm)
; - ItemEffects (see engine/items/item_effects.asm)
	const_def
	const NO_ITEM      ; 00
	const MASTER_BALL  ; 01
	const ULTRA_BALL   ; 02
	const BRIGHTPOWDER ; 03
	const GREAT_BALL   ; 04
	const POKE_BALL    ; 05
	const TOWN_MAP     ; 06
	const BICYCLE      ; 07
	const MOON_STONE   ; 08
	const ANTIDOTE     ; 09
	const BURN_HEAL    ; 0a
	const ICE_HEAL     ; 0b
	const AWAKENING    ; 0c
	const PARLYZ_HEAL  ; 0d
	const FULL_RESTORE ; 0e
	const MAX_POTION   ; 0f
	const HYPER_POTION ; 10
	const SUPER_POTION ; 11
	const POTION       ; 12
	const ESCAPE_ROPE  ; 13
	const REPEL        ; 14
	const MAX_ELIXER   ; 15
	const FIRE_STONE   ; 16
	const THUNDERSTONE ; 17
	const WATER_STONE  ; 18
	const HP_UP        ; 19
	const PROTEIN      ; 1a
	const IRON         ; 1b
	const CARBOS       ; 1c
	const LUCKY_PUNCH  ; 1d
	const CALCIUM      ; 1e
	const RARE_CANDY   ; 1f
	const LEAF_STONE   ; 20
	const METAL_POWDER ; 22
	const NUGGET       ; 23
	const POKE_DOLL    ; 24
	const FULL_HEAL    ; 25
	const REVIVE       ; 26
	const MAX_REVIVE   ; 27
	const SUPER_REPEL  ; 28
	const MAX_REPEL    ; 29
	const FRESH_WATER  ; 2a
	const SODA_POP     ; 2d
	const LEMONADE     ; 2c
	const COIN_CASE    ; 2d
	const ITEMFINDER   ; 34
	const POKE_FLUTE   ; 35
	const EXP_SHARE    ; 36
	const OLD_ROD      ; 37
	const GOOD_ROD     ; 38
	const SUPER_ROD    ; 39
	const PP_UP        ; 3b
	const ETHER        ; 3c
	const MAX_ETHER    ; 3d
	const ELIXER       ; 3e
	const RED_SCALE    ; 3f
	const SECRETPOTION ; 40
	const S_S_TICKET   ; 41
	const MYSTERY_EGG  ; 42
	const CLEAR_BELL   ; 43
	const SILVER_WING  ; 44
	const MOOMOO_MILK  ; 45
	const QUICK_CLAW   ; 46
	const PSNCUREBERRY ; 47
	const SOFT_SAND    ; 48
	const SHARP_BEAK   ; 4a
	const PRZCUREBERRY ; 4b
	const BURNT_BERRY  ; 4c
	const ICE_BERRY    ; 4d
	const POISON_BARB  ; 4e
	const KINGS_ROCK   ; 4f
	const BITTER_BERRY ; 50
	const MINT_BERRY   ; 51
	const RED_APRICORN ; 52
	const TINYMUSHROOM ; 53
	const BIG_MUSHROOM ; 54
	const SILVERPOWDER ; 55
	const BLU_APRICORN ; 56
	const AMULET_COIN  ; 57
	const YLW_APRICORN ; 58
	const GRN_APRICORN ; 59
	const CLEANSE_TAG  ; 5a
	const MYSTIC_WATER ; 5b
	const TWISTEDSPOON ; 5c
	const WHT_APRICORN ; 5d
	const BLACKBELT_I  ; 5e
	const BLK_APRICORN ; 5f
	const PNK_APRICORN ; 60
	const BLACKGLASSES ; 61
	const SLOWPOKETAIL ; 62
	const PINK_BOW     ; 63
	const STICK        ; 64
	const SMOKE_BALL   ; 65
	const NEVERMELTICE ; 66
	const MAGNET       ; 67
	const MIRACLEBERRY ; 68
	const PEARL        ; 69
	const BIG_PEARL    ; 6a
	const EVERSTONE    ; 6b
	const SPELL_TAG    ; 6c
	const RAGECANDYBAR ; 6d
	const GS_BALL      ; 6e
	const BLUE_CARD    ; 6f
	const MIRACLE_SEED ; 70
	const THICK_CLUB   ; 71
	const FOCUS_BAND   ; 72
	const ENERGYPOWDER ; 73
	const ENERGY_ROOT  ; 74
	const HEAL_POWDER  ; 75
	const REVIVAL_HERB ; 76
	const HARD_STONE   ; 77
	const LUCKY_EGG    ; 78
	const CARD_KEY     ; 79
	const MACHINE_PART ; 7a
	const EGG_TICKET   ; 7b
	const LOST_ITEM    ; 7c
	const STARDUST     ; 7d
	const STAR_PIECE   ; 7e
	const BASEMENT_KEY ; 7f
	const PASS         ; 80
	const CHARCOAL     ; 81
	const BERRY_JUICE  ; 82
	const SCOPE_LENS   ; 83
	const METAL_COAT   ; 84
	const DRAGON_FANG  ; 85
	const LEFTOVERS    ; 86
	const OLD_AMBER    ; 87
	const DOME_FOSSIL  ; 88
	const HELIX_FOSSIL ; 89
	const MYSTERYBERRY ; 8a
	const DRAGON_SCALE ; 8b
	const BERSERK_GENE ; 8c
	const SACRED_ASH   ; 8d
	const HEAVY_BALL   ; 8e
	const FLOWER_MAIL  ; 8f
	const LEVEL_BALL   ; 90
	const LURE_BALL    ; 91
	const FAST_BALL    ; 92
	const LIGHT_BALL   ; 93
	const FRIEND_BALL  ; 94
	const MOON_BALL    ; 95
	const LOVE_BALL    ; 96
	const SUN_STONE    ; 97
	const UP_GRADE     ; 98
	const BERRY        ; 9c
	const GOLD_BERRY   ; 9d
	const SQUIRTBOTTLE ; 9e
	const PARK_BALL    ; 9f
	const RAINBOW_WING ; a0
	const BRICK_PIECE  ; a1
	const SURF_MAIL    ; a2
	const LITEBLUEMAIL ; a3
	const PORTRAITMAIL ; a4
	const LOVELY_MAIL  ; a5
	const EON_MAIL     ; a6
	const MORPH_MAIL   ; a7
	const BLUESKY_MAIL ; a8
	const MUSIC_MAIL   ; a9
	const MIRAGE_MAIL  ; aa
NUM_ITEMS EQU const_value - 1

__tmhm_value__ = 1

add_tmnum: MACRO
\1_TMNUM EQU __tmhm_value__
__tmhm_value__ += 1
ENDM

add_tm: MACRO
; Defines three constants:
; - TM_\1: the item id, starting at NUM_ITEMS + 1
; - \1_TMNUM: the learnable TM/HM flag, starting at 1
; - TM##_MOVE: alias for the move id, equal to the value of \1
	const TM_\1
TM{02d:__tmhm_value__}_MOVE = \1
	add_tmnum \1
ENDM

; see data/moves/tmhm_moves.asm for moves
TM01 EQU const_value
	add_tm DYNAMICPUNCH ; TM01
	add_tm HEADBUTT     ; TM02
	add_tm CURSE        ; TM03
	add_tm ROLLOUT      ; TM04
	add_tm ROAR         ; TM05
	add_tm TOXIC        ; TM06
	add_tm ZAP_CANNON   ; TM07
	add_tm ROCK_SMASH   ; TM08
	add_tm PSYCH_UP     ; TM09
	add_tm HIDDEN_POWER ; TM10
	add_tm SUNNY_DAY    ; TM11
	add_tm SWEET_SCENT  ; TM12
	add_tm SNORE        ; TM13
	add_tm BLIZZARD     ; TM14
	add_tm HYPER_BEAM   ; TM15
	add_tm ICY_WIND     ; TM16
	add_tm PROTECT      ; TM17
	add_tm RAIN_DANCE   ; TM18
	add_tm GIGA_DRAIN   ; TM19
	add_tm ENDURE       ; TM20
	add_tm FRUSTRATION  ; TM21
	add_tm SOLARBEAM    ; TM22
	add_tm IRON_TAIL    ; TM23
	add_tm DRAGONBREATH ; TM24
	add_tm THUNDER      ; TM25
	add_tm EARTHQUAKE   ; TM26
	add_tm RETURN       ; TM27
	add_tm DIG          ; TM28
	add_tm PSYCHIC_M    ; TM29
	add_tm SHADOW_BALL  ; TM30
	add_tm MUD_SLAP     ; TM31
	add_tm DOUBLE_TEAM  ; TM32
	add_tm ICE_PUNCH    ; TM33
	add_tm SWAGGER      ; TM34
	add_tm SLEEP_TALK   ; TM35
	add_tm SLUDGE_BOMB  ; TM36
	add_tm SANDSTORM    ; TM37
	add_tm FIRE_BLAST   ; TM38
	add_tm SWIFT        ; TM39
	add_tm DEFENSE_CURL ; TM40
	add_tm THUNDERPUNCH ; TM41
	add_tm DREAM_EATER  ; TM42
	add_tm DETECT       ; TM43
	add_tm REST         ; TM44
	add_tm ATTRACT      ; TM45
	add_tm THIEF        ; TM46
	add_tm STEEL_WING   ; TM47
	add_tm FIRE_PUNCH   ; TM48
	add_tm FURY_CUTTER  ; TM49
	add_tm NIGHTMARE    ; TM50
	; Gen 1 TMs
	add_tm BODY_SLAM    ; TM51
	add_tm SWORDS_DANCE ; TM52
	add_tm THUNDER_WAVE ; TM53
	add_tm ROCK_SLIDE   ; TM54
	add_tm SUBSTITUTE   ; TM55
	add_tm DOUBLE_EDGE  ; TM56
	add_tm REFLECT      ; TM57
	add_tm EXPLOSION    ; TM58
	add_tm COUNTER      ; TM59
	add_tm SEISMIC_TOSS ; TM60
	add_tm SOFTBOILED   ; TM61
	add_tm SELFDESTRUCT ; TM62
	add_tm SKY_ATTACK   ; TM63
	add_tm TRI_ATTACK   ; TM64
	add_tm SUBMISSION   ; TM65
	add_tm MIMIC        ; TM66
	add_tm MEGA_DRAIN   ; TM67
	add_tm PAY_DAY      ; TM68
	add_tm METRONOME    ; TM69
	add_tm MEGA_PUNCH   ; TM70
	add_tm MEGA_KICK    ; TM71
	add_tm TAKE_DOWN    ; TM72
	add_tm DRAGON_RAGE  ; TM73
	add_tm WHIRLWIND    ; TM74
	add_tm TELEPORT     ; TM75
	add_tm PSYWAVE      ; TM76
	add_tm HORN_DRILL   ; TM77
	add_tm RAGE         ; TM78
	add_tm BIDE         ; TM79
	add_tm RAZOR_WIND   ; TM80
	add_tm SKULL_BASH   ; TM81
	add_tm BUBBLEBEAM   ; TM82
	add_tm WATER_GUN    ; TM83
	add_tm EGG_BOMB     ; TM84
NUM_TMS EQU __tmhm_value__ - 1

add_hm: MACRO
; Defines three constants:
; - HM_\1: the item id
; - \1_TMNUM: the learnable TM/HM flag
; - HM##_MOVE: alias for the move id, equal to the value of \1
	const HM_\1
HM_VALUE = __tmhm_value__ - NUM_TMS
HM{02d:HM_VALUE}_MOVE = \1
	add_tmnum \1
ENDM

HM01 EQU const_value
	add_hm CUT
	add_hm FLY
	add_hm SURF
	add_hm STRENGTH
	add_hm FLASH
	add_hm WHIRLPOOL
	add_hm WATERFALL
NUM_HMS EQU __tmhm_value__ - NUM_TMS - 1

add_mt: MACRO
; Defines two constants:
; - \1_TMNUM: the learnable TM/HM flag
; - MT##_MOVE: alias for the move id, equal to the value of \1
MT_VALUE = __tmhm_value__ - NUM_TMS - NUM_HMS
MT{02d:MT_VALUE}_MOVE = \1
	add_tmnum \1
ENDM

MT01 EQU const_value
	add_mt FLAMETHROWER
	add_mt THUNDERBOLT
	add_mt ICE_BEAM
NUM_TUTORS = __tmhm_value__ - NUM_TMS - NUM_HMS - 1

NUM_TM_HM_TUTOR EQU NUM_TMS + NUM_HMS + NUM_TUTORS

USE_SCRIPT_VAR EQU $00
ITEM_FROM_MEM  EQU $ff

; leftovers from red
SAFARI_BALL    EQU $08 ; MOON_STONE
MOON_STONE_RED EQU $0a ; BURN_HEAL
FULL_HEAL_RED  EQU $34 ; X_SPEED
