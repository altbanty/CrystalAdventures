; Instant Day-Care training: pay to level a party Pokemon on the spot.
; Called via callasm from maps/DayCare.asm.
;
; Cost: each level gained costs (the level being reached) x 50, summed.
; 24-bit money math - training a low-level mon to a high cap can exceed
; the 16-bit healing-cost buffers, so this has its own payment functions.
; The level cap (wLevelCap) bounds every purchase.
;
; Buffer contract (survives across the script commands between steps):
;   wStringBuffer1+0..2  cost, big-endian (same layout as hMoneyTemp)
;   wStringBuffer2+0..2  cost copy, for text_decimal display
;   wStringBuffer2+3     levels to gain (display + apply)
;   wStringBuffer2+4     target level   (display + apply)

TrainingSelectMon::
; Open the party menu. wScriptVar: 0 = cancelled, 2 = egg chosen, 1 = ok.
	farcall SelectMonFromParty
	jr c, .cancel
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .egg
	ld a, 1
	ld [wScriptVar], a
	ret
.egg
	ld a, 2
	ld [wScriptVar], a
	ret
.cancel
	xor a
	ld [wScriptVar], a
	ret

CalculateTrainingCost::
; Input: wScriptVar = requested levels (255 = train to the cap).
; Output: wScriptVar = 0 if the mon is already at the cap, else 1 with
; the buffer contract above filled (request clamped to the cap).
	ld a, MON_LEVEL
	call GetPartyParamLocation
	ld a, [hl]
	ld b, a                  ; b = current level
	ld a, [wLevelCap]
	cp b
	jr z, .at_cap
	jr c, .at_cap            ; cap somehow below current level
	sub b                    ; a = max gainable levels
	ld c, a
	ld a, [wScriptVar]
	cp c
	jr c, .use_request
	ld a, c                  ; clamp request to the cap
.use_request
	ld [wStringBuffer2 + 3], a
	add b
	ld [wStringBuffer2 + 4], a
	; cost = sum over each level bought of (level x 50), 24-bit
	xor a
	ld [wStringBuffer1], a
	ld [wStringBuffer1 + 1], a
	ld [wStringBuffer1 + 2], a
	ld a, [wStringBuffer2 + 3]
	ld c, a                  ; c = loop count
	ld d, b                  ; d = level being purchased
.cost_loop
	inc d
	push bc
	; hl = d * 50  (50 = 32 + 16 + 2)
	ld h, 0
	ld l, d
	add hl, hl               ; 2L
	push hl
	add hl, hl               ; 4L
	add hl, hl               ; 8L
	add hl, hl               ; 16L
	push hl
	add hl, hl               ; 32L
	pop bc                   ; 16L
	add hl, bc               ; 48L
	pop bc                   ; 2L
	add hl, bc               ; 50L
	; 24-bit acc += hl
	ld a, [wStringBuffer1 + 2]
	add l
	ld [wStringBuffer1 + 2], a
	ld a, [wStringBuffer1 + 1]
	adc h
	ld [wStringBuffer1 + 1], a
	ld a, [wStringBuffer1]
	adc 0
	ld [wStringBuffer1], a
	pop bc
	dec c
	jr nz, .cost_loop
	; copy cost to the display buffer
	ld a, [wStringBuffer1]
	ld [wStringBuffer2], a
	ld a, [wStringBuffer1 + 1]
	ld [wStringBuffer2 + 1], a
	ld a, [wStringBuffer1 + 2]
	ld [wStringBuffer2 + 2], a
	ld a, 1
	ld [wScriptVar], a
	ret
.at_cap
	xor a
	ld [wScriptVar], a
	ret

CheckTrainingPayment::
; wScriptVar = 1 if the player can afford wStringBuffer1's cost, else 0.
	call Training_CostToMoneyTemp
	ld de, wMoney
	ld bc, hMoneyTemp
	farcall CompareMoney
	jr c, .broke
	ld a, 1
	ld [wScriptVar], a
	ret
.broke
	xor a
	ld [wScriptVar], a
	ret

TakeTrainingPayment::
	call Training_CostToMoneyTemp
	ld de, wMoney
	ld bc, hMoneyTemp
	farcall TakeMoney
	ret

Training_CostToMoneyTemp:
	ld a, [wStringBuffer1]
	ld [hMoneyTemp], a
	ld a, [wStringBuffer1 + 1]
	ld [hMoneyTemp + 1], a
	ld a, [wStringBuffer1 + 2]
	ld [hMoneyTemp + 2], a
	ret

ApplyTraining::
; Level wCurPartyMon up to wStringBuffer2+4, one level at a time, with
; the standard prompted move learning after each level - the Rare Candy
; experience (mirrors RareCandyEffect exactly, minus the stats textbox).
; HP rises by the max-HP delta only; no free heal. EXP and stats are
; kept in sync at every level so nothing can desync mid-parade.
; The move-learn prompts clobber the wStringBuffer scratch, so the
; target level is stashed in hMoneyTemp (payment is already complete).
	ld a, [wStringBuffer2 + 4]
	ldh [hMoneyTemp], a
.level_loop
	ld a, MON_LEVEL
	call GetPartyParamLocation
	ld a, [hl]
	ld b, a
	ldh a, [hMoneyTemp]
	cp b
	jp z, .levels_done
	jp c, .levels_done       ; safety: never exceed the target
	; +1 level
	inc b
	ld a, b
	ld [hl], a
	ld [wCurPartyLevel], a
	; refresh species context - the prompts can clobber it between laps
	ld a, MON_SPECIES
	call GetPartyParamLocation
	ld a, [hl]
	ld [wCurSpecies], a
	ld [wCurPartySpecies], a
	call GetBaseData
	; exp = exact threshold of this level
	ld a, [wCurPartyLevel]
	ld d, a
	farcall CalcExpAtLevel
	ld a, MON_EXP
	call GetPartyParamLocation
	ldh a, [hMultiplicand]
	ld [hli], a
	ldh a, [hMultiplicand + 1]
	ld [hli], a
	ldh a, [hMultiplicand + 2]
	ld [hl], a
	; save old max HP, recalculate stats, add the delta to current HP
	ld a, MON_MAXHP
	call GetPartyParamLocation
	ld a, [hli]
	ld d, a
	ld a, [hl]
	ld e, a
	push de
	ld a, MON_MAXHP
	call GetPartyParamLocation
	ld d, h
	ld e, l
	ld a, MON_EXP + 2
	call GetPartyParamLocation
	ld b, TRUE
	predef CalcMonStats
	pop de
	ld a, MON_MAXHP
	call GetPartyParamLocation
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld c, a
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc d
	ld d, a
	ld a, MON_HP
	call GetPartyParamLocation
	inc hl
	ld a, [hl]
	add e
	ld [hld], a
	ld a, [hl]
	adc d
	ld [hl], a
	; happiness, then the prompted move learning (Rare Candy path)
	farcall LevelUpHappinessMod
	xor a ; PARTYMON
	ld [wMonType], a
	ld a, [wCurPartySpecies]
	ld [wTempSpecies], a
	predef LearnLevelMoves
	jp .level_loop

.levels_done
	; the prompts clobber the string buffers; restore the level byte
	; that TrainingDoneText displays
	ld a, MON_LEVEL
	call GetPartyParamLocation
	ld a, [hl]
	ld [wStringBuffer2 + 4], a
	ret

TrainingEvolveCheck::
; Run the standard evolution ceremony for the trained mon, if due.
	xor a
	ld [wForceEvolution], a
	farcall EvolvePokemon
	ret
