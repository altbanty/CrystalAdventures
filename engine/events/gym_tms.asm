; Randomized Gym TM Rewards
; Called via callasm from map scripts, so can be in any bank.
; Init flag: bit 7 of wGymTeamChoices2. Bits 6-4 = weird tree choice (0-4).
; wGymTMChoices byte 0: bits 7-6 = Morty, bits 5-4 = Whitney, bits 3-2 = Bugsy, bits 1-0 = Falkner
; wGymTMChoices byte 1: bits 7-6 = Clair, bits 5-4 = Pryce, bits 3-2 = Jasmine, bits 1-0 = Chuck

InitGymTMs:
	ld a, [wGymTeamChoices2]
	bit 7, a
	ret nz

	; Byte 0: 4 gyms (Morty/Whitney/Bugsy/Falkner)
	ld c, 4
	call BuildRandomByte
	ld [wGymTMChoices], a

	; Byte 1: 4 gyms (Clair/Pryce/Jasmine/Chuck)
	ld c, 4
	call BuildRandomByte
	ld [wGymTMChoices + 1], a

	; Set init flag
	ld a, [wGymTeamChoices2]
	or %10000000
	ld [wGymTeamChoices2], a
	ret

BuildRandomByte:
; Build a byte with c packed 2-bit random values (0-2).
; DelayFrame between draws: back-to-back Random calls advance the seed
; by a near-constant rDIV delta, correlating the packed fields. A frame
; apart, the VBlank RNG stir makes each draw independent.
	xor a
	ld b, a
.loop:
	ld a, b
	rlca
	rlca
	ld b, a
	call DelayFrame
	ld a, 3
	call RandomRange
	or b
	ld b, a
	dec c
	jr nz, .loop
	ret

GetGymTM::
; Input: wScriptVar = gym index (1-8).
; Output: wScriptVar = TM item constant.
	call InitGymTMs
	ld a, [wScriptVar]
	dec a               ; 0-based gym index (0-7)
	push af             ; save for table lookup
	; Gyms 0-3 -> byte 0, gyms 4-7 -> byte 1
	cp 4
	jr c, .byte0
	sub 4
	ld b, a
	ld a, [wGymTMChoices + 1]
	jr .extract
.byte0:
	ld b, a
	ld a, [wGymTMChoices]
.extract:
	; b = position within byte (0-3), a = packed byte
	inc b
.shift:
	dec b
	jr z, .done
	rrca
	rrca
	jr .shift
.done:
	and %00000011       ; 2-bit TM pool index (0-2)
	; Look up TM: offset = gym_index * 3 + pool_index
	ld c, a
	pop af              ; a = 0-based gym index
	ld b, a
	add a, a
	add a, b            ; a = gym_index * 3
	add a, c            ; + pool_index
	ld e, a
	ld d, 0
	ld hl, GymTMPools
	add hl, de
	ld a, [hl]
	ld [wScriptVar], a
	ret

GymTMPools:
; 3 TMs per gym, 8 gyms
	db TM_MUD_SLAP,      TM_SKY_ATTACK,  TM_ROAR         ; Falkner
	db TM_FURY_CUTTER,   TM_MEGA_DRAIN,  TM_HIDDEN_POWER  ; Bugsy
	db TM_ATTRACT,       TM_BODY_SLAM,   TM_TRI_ATTACK    ; Whitney
	db TM_SHADOW_BALL,   TM_DREAM_EATER, TM_NIGHTMARE     ; Morty
	db TM_DYNAMICPUNCH,  TM_COUNTER,     TM_SUBMISSION    ; Chuck
	db TM_IRON_TAIL,     TM_STEEL_WING,  TM_ROCK_SLIDE    ; Jasmine
	db TM_ICY_WIND,      TM_SUBSTITUTE,  TM_REFLECT       ; Pryce
	db TM_DRAGONBREATH,  TM_DRAGON_RAGE, TM_THUNDER_WAVE  ; Clair

; --- Randomized Scaled Gym Teams (Chuck, Jasmine, Pryce) ---

InitScaledGymTeams:
	ld a, [wScaledGymTeamChoices]
	bit 7, a
	ret nz
	ld c, 3
	call BuildRandomByte
	or %10000000             ; set init flag
	ld [wScaledGymTeamChoices], a
	ret

LoadChuckTrainer::
	ld c, %00110000          ; Chuck mask (bits 5-4)
	ld b, 4                  ; shift count
	ld d, CHUCK1             ; first party of the 3x3 grid
	ld e, CHUCK
	jr _LoadScaledGymTrainer

; Janine holding Cianwood Gym (swap pair 5): same badge tiers and the same
; per-save variant roll as Chuck's slot, her own 3x3 grid of parties.
LoadJanineGuestTrainer::
	ld c, %00110000          ; Chuck's slot (bits 5-4)
	ld b, 4
	ld d, JANINE4
	ld e, JANINE
	jr _LoadScaledGymTrainer

LoadJasmineTrainer::
	ld c, %00001100          ; Jasmine mask (bits 3-2)
	ld b, 2                  ; shift count
	ld d, JASMINE1
	ld e, JASMINE
	jr _LoadScaledGymTrainer

; Sabrina holding Olivine Gym (swap pair 6).
LoadSabrinaGuestTrainer::
	ld c, %00001100          ; Jasmine's slot (bits 3-2)
	ld b, 2
	ld d, SABRINA4
	ld e, SABRINA
	jr _LoadScaledGymTrainer

; Blaine holding Mahogany Gym (swap pair 7).
LoadBlaineGuestTrainer::
	ld c, %00000011          ; Pryce's slot (bits 1-0)
	ld b, 0
	ld d, BLAINE4
	ld e, BLAINE
	jr _LoadScaledGymTrainer

LoadPryceTrainer::
	ld c, %00000011          ; Pryce mask (bits 1-0)
	ld b, 0                  ; shift count
	ld d, PRYCE1
	ld e, PRYCE
	; fall through

_LoadScaledGymTrainer:
; b = shift count, c = variant mask, d = first party ID of the 3x3
; (tier x variant) grid, e = trainer class, wScriptVar = tier base (0/3/6)
	push bc
	push de
	call InitScaledGymTeams
	pop de
	pop bc
	; Extract variant (0-2) from wScaledGymTeamChoices
	ld a, [wScaledGymTeamChoices]
	and c                    ; mask the relevant bits
	; Shift right by b positions
	inc b
.shift_loop:
	dec b
	jr z, .shift_done
	srl a
	jr .shift_loop
.shift_done:
	ld b, a                  ; b = variant (0-2)
	ld a, [wScriptVar]       ; tier base from setval
	add b                    ; + variant
	add d                    ; + first party ID of the grid
	ld [wOtherTrainerID], a
	ld a, e
	ld [wOtherTrainerClass], a
	ld a, (1 << 7) | 1
	ld [wBattleScriptFlags], a
	ret

; --- Randomized Mania's Gift Pokemon ---
; 40% Shuckle, 30% Corsola, 20% Delibird, 10% Seel
; Output: wScriptVar = species constant (for GiveShuckle to read)
PickManiasPokemon::
	ld a, 100
	call RandomRange ; a = 0-99
	cp 40
	jr c, .shuckle     ; 0-39 (40%)
	cp 70
	jr c, .corsola     ; 40-69 (30%)
	cp 90
	jr c, .delibird    ; 70-89 (20%)
	; 90-99 (10%)
	ld a, SEEL
	jr .done_mania
.shuckle:
	ld a, SHUCKLE
	jr .done_mania
.corsola:
	ld a, CORSOLA
	jr .done_mania
.delibird:
	ld a, DELIBIRD
.done_mania:
	ld [wScriptVar], a
	ret

; --- Randomized Kiyo's Gift Pokemon ---
; 30% Hitmonlee, 30% Hitmonchan, 30% Hitmontop, 10% Mr. Mime
; Output: wScriptVar = 0-3 index
PickKiyoPokemon::
	ld a, 100
	call RandomRange ; a = 0-99
	cp 30
	jr c, .hitmonlee    ; 0-29 (30%)
	cp 60
	jr c, .hitmonchan   ; 30-59 (30%)
	cp 90
	jr c, .hitmontop    ; 60-89 (30%)
	; 90-99 (10%)
	ld a, 3
	jr .done_kiyo
.hitmonlee:
	xor a ; 0
	jr .done_kiyo
.hitmonchan:
	ld a, 1
	jr .done_kiyo
.hitmontop:
	ld a, 2
.done_kiyo:
	ld [wScriptVar], a
	ret

; --- Randomized Bill's Gift Pokemon ---
; 30% Farfetch'd, 30% Exeggcute, 15% Vulpix, 15% Eevee, 10% Magikarp
; Output: wScriptVar = 0-4 index
PickBillPokemon::
	ld a, 100
	call RandomRange ; a = 0-99
	cp 30
	jr c, .farfetchd   ; 0-29 (30%)
	cp 60
	jr c, .exeggcute   ; 30-59 (30%)
	cp 75
	jr c, .vulpix       ; 60-74 (15%)
	cp 90
	jr c, .eevee        ; 75-89 (15%)
	; 90-99 (10%)
	ld a, 4
	jr .done
.farfetchd:
	xor a ; 0
	jr .done
.exeggcute:
	ld a, 1
	jr .done
.vulpix:
	ld a, 2
	jr .done
.eevee:
	ld a, 3
.done:
	ld [wScriptVar], a
	ret

; --- Randomized Weird Tree Encounter ---
; 40% Sudowoodo, 30% Muk, 20% Tauros, 5% Snorlax, 5% Chansey
; Output: wScriptVar = 0-4 index
PickWeirdTree::
	ld a, 100
	call RandomRange ; a = 0-99
	cp 40
	jr c, .sudowoodo    ; 0-39 (40%)
	cp 70
	jr c, .muk          ; 40-69 (30%)
	cp 90
	jr c, .tauros       ; 70-89 (20%)
	cp 95
	jr c, .snorlax      ; 90-94 (5%)
	; 95-99 (5%)
	ld a, 4
	jr .done_tree
.sudowoodo:
	xor a ; 0
	jr .done_tree
.muk:
	ld a, 1
	jr .done_tree
.tauros:
	ld a, 2
	jr .done_tree
.snorlax:
	ld a, 3
.done_tree:
	ld [wScriptVar], a
	ret

; Pick random weird tree, store choice in wGymTeamChoices2 bits 6-4, set variable sprite.
; Only called for the roll that locks the choice (see Route 36's map callbacks —
; EVENT_ROUTE_36_WEIRD_TREE_CHOICE_LOCKED gates rerolls).
SetWeirdTreeSprite::
	call PickWeirdTree       ; result in wScriptVar (0-4)
	ld a, [wScriptVar]
	ld c, a                  ; c = choice (0-4)
	; Store choice in wGymTeamChoices2 bits 6-4
	swap a                   ; shift into bits 4-6
	ld b, a
	ld a, [wGymTeamChoices2]
	and %10001111            ; clear bits 6-4
	or b
	ld [wGymTeamChoices2], a
	jr ApplyWeirdTreeSprite.set_sprite

; Re-apply the stored weird tree choice to the variable sprite without rerolling.
; Called on later Route 36 entries once the choice is locked.
ApplyWeirdTreeSprite::
	ld a, [wGymTeamChoices2]
	and %01110000            ; isolate bits 6-4
	swap a
	ld c, a                  ; c = stored choice (0-4)
.set_sprite
	; Map choice to sprite
	ld hl, .SpriteTable
	ld b, 0
	add hl, bc
	ld a, [hl]
	ld [wVariableSprites + SPRITE_WEIRD_TREE - SPRITE_VARS], a
	ret

.SpriteTable:
	db SPRITE_SUDOWOODO  ; 0
	db SPRITE_GRIMER     ; 1
	db SPRITE_TAUROS     ; 2
	db SPRITE_SNORLAX    ; 3
	db SPRITE_BLISSEY    ; 4

; Read the stored weird tree choice back into wScriptVar.
; Called from Route 36 battle script.
GetWeirdTreeChoice::
	ld a, [wGymTeamChoices2]
	and %01110000            ; isolate bits 6-4
	swap a                   ; shift to bits 2-0
	ld [wScriptVar], a
	ret

; --- Randomized Tin Tower Legendary Beast ---
; The Tin Tower static encounter is a random beast (Suicune/Raikou/Entei),
; rolled once when the beasts awaken in the Burned Tower; the other two
; become the roamers. Choice encoding: 0 Suicune / 1 Raikou / 2 Entei,
; stored as (choice+1) across two saved event flags so old saves (flags
; clear) resolve to Suicune. All results returned via wScriptVar because
; farcall does not preserve a across the return.

RollLegendaryBeast::
; Roll the beast and store the choice. Leaves the roll in wScriptVar.
	ld a, 3
	call RandomRange         ; a = 0-2, equal odds
	ld [wScriptVar], a
	inc a                    ; encode as choice+1 (1-3)
	and 1
	jr z, .bit1
	ld b, SET_FLAG
	ld de, EVENT_TIN_TOWER_BEAST_CHOICE_BIT0
	call EventFlagAction
.bit1
	ld a, [wScriptVar]
	inc a
	and 2
	ret z
	ld b, SET_FLAG
	ld de, EVENT_TIN_TOWER_BEAST_CHOICE_BIT1
	call EventFlagAction
	ret

GetLegendaryBeastChoice::
; Read the stored choice into wScriptVar (0 Suicune / 1 Raikou / 2 Entei).
	ld b, CHECK_FLAG
	ld de, EVENT_TIN_TOWER_BEAST_CHOICE_BIT1
	call EventFlagAction
	ld a, c
	and a
	ld a, 0
	jr z, .noBit1
	ld a, 2
.noBit1
	ld [wScriptVar], a
	ld b, CHECK_FLAG
	ld de, EVENT_TIN_TOWER_BEAST_CHOICE_BIT0
	call EventFlagAction
	ld a, c
	and a
	jr z, .noBit0
	ld a, [wScriptVar]
	inc a
	ld [wScriptVar], a
.noBit0
	ld a, [wScriptVar]
	and a
	ret z                    ; 0 = never rolled -> Suicune
	dec a
	ld [wScriptVar], a
	ret

ApplyLegendaryBeastSprite::
; Point the legendary variable sprite at the chosen beast.
	call GetLegendaryBeastChoice
	ld a, [wScriptVar]
	ld c, a
	ld b, 0
	ld hl, .BeastSpriteTable
	add hl, bc
	ld a, [hl]
	ld [wVariableSprites + SPRITE_LEGENDARY_BEAST - SPRITE_VARS], a
	ret

.BeastSpriteTable:
	db SPRITE_SUICUNE ; 0
	db SPRITE_RAIKOU  ; 1
	db SPRITE_ENTEI   ; 2

; --- Randomized Union Cave B2F Water Visitor ---
; A one-time encounter that waits in the B2F pool until fought (the old
; Friday-only Lapras). Rolled at first sight and locked via saved event
; flags: choice 0-5 in three bits, plus a "rolled" flag so old saves
; (all clear) roll on their next visit. Choice order: Lapras, Poliwrath,
; Slowking, Azumarill, Golduck, Corsola.

RollWaterVisitor::
; Roll the visitor (equal odds) and store the choice. Leaves it in wScriptVar.
	ld a, 6
	call RandomRange         ; a = 0-5
	ld [wScriptVar], a
	and 1
	jr z, .bit1
	ld b, SET_FLAG
	ld de, EVENT_UNION_CAVE_VISITOR_CHOICE_BIT0
	call EventFlagAction
.bit1
	ld a, [wScriptVar]
	and 2
	jr z, .bit2
	ld b, SET_FLAG
	ld de, EVENT_UNION_CAVE_VISITOR_CHOICE_BIT1
	call EventFlagAction
.bit2
	ld a, [wScriptVar]
	and 4
	ret z
	ld b, SET_FLAG
	ld de, EVENT_UNION_CAVE_VISITOR_CHOICE_BIT2
	call EventFlagAction
	ret

GetWaterVisitorChoice::
; Read the stored choice into wScriptVar (0-5).
	xor a
	ld [wScriptVar], a
	ld b, CHECK_FLAG
	ld de, EVENT_UNION_CAVE_VISITOR_CHOICE_BIT0
	call EventFlagAction
	ld a, c
	and a
	jr z, .no0
	ld a, [wScriptVar]
	inc a
	ld [wScriptVar], a
.no0
	ld b, CHECK_FLAG
	ld de, EVENT_UNION_CAVE_VISITOR_CHOICE_BIT1
	call EventFlagAction
	ld a, c
	and a
	jr z, .no1
	ld a, [wScriptVar]
	add 2
	ld [wScriptVar], a
.no1
	ld b, CHECK_FLAG
	ld de, EVENT_UNION_CAVE_VISITOR_CHOICE_BIT2
	call EventFlagAction
	ld a, c
	and a
	ret z
	ld a, [wScriptVar]
	add 4
	ld [wScriptVar], a
	ret

ApplyWaterVisitorSprite::
; Point the water visitor variable sprite at the chosen species' icon.
	call GetWaterVisitorChoice
	ld a, [wScriptVar]
	ld c, a
	ld b, 0
	ld hl, .VisitorSpriteTable
	add hl, bc
	ld a, [hl]
	ld [wVariableSprites + SPRITE_WATER_VISITOR - SPRITE_VARS], a
	ret

.VisitorSpriteTable:
	db SPRITE_LAPRAS    ; 0
	db SPRITE_POLIWRATH ; 1
	db SPRITE_SLOWKING  ; 2
	db SPRITE_AZUMARILL ; 3
	db SPRITE_GOLDUCK   ; 4
	db SPRITE_CORSOLA   ; 5

; --- Gym Leader Swap ---
; Each swapped gym pair rolls a coin once per save (script-side, via the
; EVENT_GYM_PAIR_N_ROLLED/SWAPPED flags). The gym SLOT keeps its badge,
; TM, level cap, and story events; only the person differs. One shared
; variable sprite serves every gym, since only one gym map is loaded at
; a time: each gym's SPRITES callback calls its Apply function below.

ApplyVioletGymLeaderSprite::
	ld a, SPRITE_FALKNER
	ld b, SPRITE_BROCK
	ld de, EVENT_GYM_PAIR_1_SWAPPED
	jr ApplyGymLeaderSprite

ApplyPewterGymLeaderSprite::
	ld a, SPRITE_BROCK
	ld b, SPRITE_FALKNER
	ld de, EVENT_GYM_PAIR_1_SWAPPED
	jr ApplyGymLeaderSprite

ApplyAzaleaGymLeaderSprite::
	ld a, SPRITE_BUGSY
	ld b, SPRITE_MISTY
	ld de, EVENT_GYM_PAIR_2_SWAPPED
	jr ApplyGymLeaderSprite

ApplyCeruleanGymLeaderSprite::
	ld a, SPRITE_MISTY
	ld b, SPRITE_BUGSY
	ld de, EVENT_GYM_PAIR_2_SWAPPED
	jr ApplyGymLeaderSprite

ApplyGoldenrodGymLeaderSprite::
	ld a, SPRITE_WHITNEY
	ld b, SPRITE_SURGE
	ld de, EVENT_GYM_PAIR_3_SWAPPED
	jr ApplyGymLeaderSprite

ApplyVermilionGymLeaderSprite::
	ld a, SPRITE_SURGE
	ld b, SPRITE_WHITNEY
	ld de, EVENT_GYM_PAIR_3_SWAPPED
	jr ApplyGymLeaderSprite

ApplyEcruteakGymLeaderSprite::
	ld a, SPRITE_MORTY
	ld b, SPRITE_ERIKA
	ld de, EVENT_GYM_PAIR_4_SWAPPED
	jr ApplyGymLeaderSprite

ApplyCeladonGymLeaderSprite::
	ld a, SPRITE_ERIKA
	ld b, SPRITE_MORTY
	ld de, EVENT_GYM_PAIR_4_SWAPPED
	jr ApplyGymLeaderSprite

ApplyCianwoodGymLeaderSprite::
	ld a, SPRITE_CHUCK
	ld b, SPRITE_JANINE
	ld de, EVENT_GYM_PAIR_5_SWAPPED
	jr ApplyGymLeaderSprite

ApplyFuchsiaGymLeaderSprite::
	ld a, SPRITE_JANINE
	ld b, SPRITE_CHUCK
	ld de, EVENT_GYM_PAIR_5_SWAPPED
	jr ApplyGymLeaderSprite

ApplyOlivineGymLeaderSprite::
	ld a, SPRITE_JASMINE
	ld b, SPRITE_SABRINA
	ld de, EVENT_GYM_PAIR_6_SWAPPED
	jr ApplyGymLeaderSprite

ApplySaffronGymLeaderSprite::
	ld a, SPRITE_SABRINA
	ld b, SPRITE_JASMINE
	ld de, EVENT_GYM_PAIR_6_SWAPPED
	jr ApplyGymLeaderSprite

ApplyMahoganyGymLeaderSprite::
	ld a, SPRITE_PRYCE
	ld b, SPRITE_BLAINE
	ld de, EVENT_GYM_PAIR_7_SWAPPED
	jr ApplyGymLeaderSprite

ApplySeafoamGymLeaderSprite::
	ld a, SPRITE_BLAINE
	ld b, SPRITE_PRYCE
	ld de, EVENT_GYM_PAIR_7_SWAPPED
	; fallthrough

ApplyGymLeaderSprite:
; a = home leader sprite, b = guest sprite, de = pair's SWAPPED event flag.
	ld [wVariableSprites + SPRITE_GYM_LEADER - SPRITE_VARS], a
	ld a, b
	ld [wScriptVar], a       ; stash the guest across EventFlagAction
	ld b, CHECK_FLAG
	call EventFlagAction
	ld a, c
	and a
	ret z                    ; not swapped: home leader stays
	ld a, [wScriptVar]
	ld [wVariableSprites + SPRITE_GYM_LEADER - SPRITE_VARS], a
	ret

RollGymSwaps::
; Roll every gym swap pair at new game, before the player can observe or
; save-scum any outcome. The lazy rolls in the gym SPRITES callbacks remain
; only as a migration fallback for saves from before this feature.
;
; All the coin flips come from separate bits of ONE mixed byte.
; Back-to-back Random calls are correlated (rDIV barely advances between
; them, and RandomRange 2 reduces to parity), which used to make all four
; pairs swap - or stay home - together far too often.
;
; A lone Random sample here depends only on the frame count since power-on,
; so two new games played through with the same button timing (a save state
; at the title screen, held fast-forward, or just a well-rehearsed intro)
; land on the same flips. XOR in sources that vary on their own: the
; cartridge clock's seconds and minutes (wall-clock time, never written by
; the game), the player ID (rolled at a different moment of the intro), and
; the RNG's second accumulator. A missing or stuck clock just XORs a
; constant and costs nothing.
	call GetClock            ; refresh hRTCSeconds/hRTCMinutes
	call Random
	ld c, a
	ldh a, [hRandomAdd]
	swap a
	xor c
	ld c, a
	ldh a, [hRTCSeconds]
	xor c
	ld c, a
	ldh a, [hRTCMinutes]
	swap a
	xor c
	ld c, a
	ld a, [wPlayerID]
	xor c
	ld c, a
	ld a, [wPlayerID + 1]
	swap a
	xor c
	ld c, a                  ; c = flip bits; pair N uses bit N
	ld hl, .PairFlags
.loop
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	and e
	inc a
	jr z, .done              ; dw -1 sentinel
	push bc
	push hl
	ld b, SET_FLAG
	call EventFlagAction     ; mark pair rolled
	pop hl
	pop bc
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	srl c                    ; this pair's flip -> carry
	jr nc, .next             ; heads: home leaders
	push bc
	push hl
	ld b, SET_FLAG
	call EventFlagAction     ; tails: swapped
	pop hl
	pop bc
.next
	jr .loop
.done
	ret

.PairFlags:
	dw EVENT_GYM_PAIR_1_ROLLED, EVENT_GYM_PAIR_1_SWAPPED
	dw EVENT_GYM_PAIR_2_ROLLED, EVENT_GYM_PAIR_2_SWAPPED
	dw EVENT_GYM_PAIR_3_ROLLED, EVENT_GYM_PAIR_3_SWAPPED
	dw EVENT_GYM_PAIR_4_ROLLED, EVENT_GYM_PAIR_4_SWAPPED
	dw EVENT_GYM_PAIR_5_ROLLED, EVENT_GYM_PAIR_5_SWAPPED
	dw EVENT_GYM_PAIR_6_ROLLED, EVENT_GYM_PAIR_6_SWAPPED
	dw EVENT_GYM_PAIR_7_ROLLED, EVENT_GYM_PAIR_7_SWAPPED
	dw -1, -1

; --- Elite Four / Champion team variants ---
; Rolled once per save (same pattern as InitScaledGymTeams). Party IDs within
; each class: 1 = original first fight, 2 = badge-16 rematch, 3/4 = variants.
InitEliteFourTeams:
	ld a, [wEliteFourTeamChoices]
	bit 7, a
	ret nz
	ld c, 3
	call BuildRandomByte
	or %10000000             ; set init flag
	ld [wEliteFourTeamChoices], a
	ld c, 2
	call BuildRandomByte
	ld [wEliteFourTeamChoices2], a
	ret

LoadWillTrainer::
	ld hl, wEliteFourTeamChoices
	ld c, %00110000          ; Will mask (bits 5-4)
	ld b, 4                  ; shift count
	ld e, WILL
	jr _LoadEliteFourTrainer

LoadKogaTrainer::
	ld hl, wEliteFourTeamChoices
	ld c, %00001100          ; Koga mask (bits 3-2)
	ld b, 2
	ld e, KOGA
	jr _LoadEliteFourTrainer

LoadBrunoTrainer::
	ld hl, wEliteFourTeamChoices
	ld c, %00000011          ; Bruno mask (bits 1-0)
	ld b, 0
	ld e, BRUNO
	jr _LoadEliteFourTrainer

LoadKarenTrainer::
	ld hl, wEliteFourTeamChoices2
	ld c, %00001100          ; Karen mask (bits 3-2)
	ld b, 2
	ld e, KAREN
	jr _LoadEliteFourTrainer

LoadLanceTrainer::
	ld hl, wEliteFourTeamChoices2
	ld c, %00000011          ; Lance mask (bits 1-0)
	ld b, 0
	ld e, CHAMPION
	; fall through

_LoadEliteFourTrainer:
	push bc
	push de
	push hl
	call InitEliteFourTeams
	pop hl
	pop de
	pop bc
	ld a, [hl]
	and c                    ; mask the relevant bits
	inc b
.shift_loop:
	dec b
	jr z, .shift_done
	srl a
	jr .shift_loop
.shift_done:
	cp 3                     ; guard against corrupt saves
	jr c, .valid
	xor a
.valid:
	; a = variant (0-2) -> party ID: 0 -> 1, 1 -> 3, 2 -> 4
	and a
	jr z, .first
	inc a                    ; skip the rematch slot (ID 2)
.first:
	inc a                    ; 1-based trainer ID
	ld [wOtherTrainerID], a
	ld a, e
	ld [wOtherTrainerClass], a
	ld a, (1 << 7) | 1
	ld [wBattleScriptFlags], a
	ret

; --- Randomized Dragon Shrine Gift Pokemon ---
; 40% Dratini, 30% Larvitar, 30% Horsea
; Output: wScriptVar = 0-2 index; species name in wStringBuffer1
PickShrineDragon::
	ld a, 100
	call RandomRange ; a = 0-99
	cp 40
	jr c, .dratini     ; 0-39 (40%)
	cp 70
	jr c, .larvitar    ; 40-69 (30%)
	; 70-99 (30%)
	ld b, 2
	ld a, HORSEA
	jr .done_shrine
.dratini:
	ld b, 0
	ld a, DRATINI
	jr .done_shrine
.larvitar:
	ld b, 1
	ld a, LARVITAR
.done_shrine:
	ld [wNamedObjectIndex], a
	ld a, b
	ld [wScriptVar], a
	call GetPokemonName
	ret

; --- Fossil revival bonus roll ---
; Called right after the revived fossil Pokemon is added to the party.
; Uses the save's trainer ID as a per-save roll (no save-scumming):
; bits 1-0 pick the held item, bit 2 awards the "awakened" AncientPower
; moveset (50% of saves).
FinishFossilRevival::
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1Species
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	; hl = species byte of the revived mon
	push hl
	ld a, [wPlayerID + 1]
	and %11
	ld c, a
	ld b, 0
	ld hl, .ItemPool
	add hl, bc
	ld a, [hl]
	pop hl
	push hl
	inc hl                   ; MON_ITEM
	ld [hl], a
	pop hl
	ld a, [wPlayerID + 1]
	bit 2, a
	ret z                    ; this save keeps natural level-up moves
	ld a, [hl]
	push hl
	ld hl, .KabutoMoves
	cp KABUTO
	jr z, .apply
	ld hl, .OmanyteMoves
	cp OMANYTE
	jr z, .apply
	ld hl, .AerodactylMoves
	cp AERODACTYL
	jr z, .apply
	pop hl
	ret

.apply:
	pop de
	inc de
	inc de                   ; MON_MOVES

.CopyMoves:
	ld a, [hl]
	and a ; end of moveset?
	ret z
	push hl
	push de
	ld [de], a
	; look up and set the move's PP
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte
	ld hl, MON_PP - MON_MOVES
	add hl, de
	ld [hl], a
	pop de
	pop hl
	inc de
	inc hl
	jr .CopyMoves

.ItemPool:
	db HARD_STONE, MYSTIC_WATER, QUICK_CLAW, GOLD_BERRY

.KabutoMoves:
	db ABSORB, SLASH, ANCIENTPOWER, HARDEN, 0
.OmanyteMoves:
	db WATER_GUN, ANCIENTPOWER, BITE, WITHDRAW, 0
.AerodactylMoves:
	db WING_ATTACK, ANCIENTPOWER, BITE, AGILITY, 0
