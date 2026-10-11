PUSHS
SECTION "Kanto Gym Team Variants", ROMX

; Per-save Kanto gym leader team variants, mirroring the Johto gym rolls.
; One roll per gym slot indexes BOTH the native leader's and the exchange
; guest's variants, so "Pewter's team this save" is consistent whoever
; holds the gym - including the guest rematch back at the Johto gym.

InitKantoGymTeams:
	ld a, [wKantoGymTeamChoices]
	bit 7, a
	ret nz
	ld c, 3
	call .BuildRandomByte
	or %10000000             ; set init flag
	ld [wKantoGymTeamChoices], a
	ld c, 4
	call .BuildRandomByte
	ld [wKantoGymTeamChoices2], a
	ld c, 1
	call .BuildRandomByte
	ld [wKantoGymTeamChoices3], a
	ret

.BuildRandomByte:
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

; Load the rolled team for a Kanto gym battle slot.
; input: wScriptVar = row index into .Table (set with setval)
LoadKantoGymTrainer::
	call InitKantoGymTeams
	ld a, [wScriptVar]
	ld hl, .Table
	ld bc, 5
	call AddNTimes
	ld a, [hli]              ; gym slot 0-7
	push hl
	call .GetVariant
	pop hl
	ld c, a
	ld a, [hli]              ; trainer class
	ld [wOtherTrainerClass], a
	ld b, 0
	add hl, bc
	ld a, [hl]               ; party ID for this variant
	ld [wOtherTrainerID], a
	ld a, (1 << 7) | 1
	ld [wBattleScriptFlags], a
	ret

.GetVariant:
; a = gym slot 0-7 -> a = variant 0-2
	ld e, a
	cp 3
	jr c, .firstByte
	cp 7
	jr c, .secondByte
	ld a, [wKantoGymTeamChoices3]
	and %11
	jr .clamp
.firstByte:
	ld a, [wKantoGymTeamChoices]
	ld d, a
	ld a, 2
	sub e
	jr .extract
.secondByte:
	ld a, [wKantoGymTeamChoices2]
	ld d, a
	ld a, 6
	sub e
.extract:
	add a                    ; shift = slots-from-low * 2
	ld e, a
	ld a, d
	inc e
.shift:
	dec e
	jr z, .shifted
	srl a
	jr .shift
.shifted:
	and %11
.clamp:
	cp 3
	ret c
	xor a                    ; corrupt-save guard
	ret

.Table:
; gym slot, trainer class, party IDs for variants 1/2/3
	db 0, BROCK,    1, 5, 6  ; 0: Pewter - Brock
	db 0, FALKNER,  5, 6, 7  ; 1: Pewter - guest Falkner
	db 1, MISTY,    1, 5, 6  ; 2: Cerulean - Misty
	db 1, BUGSY,    5, 6, 7  ; 3: Cerulean - guest Bugsy
	db 2, LT_SURGE, 1, 5, 6  ; 4: Vermilion - Lt. Surge
	db 2, WHITNEY,  5, 6, 7  ; 5: Vermilion - guest Whitney
	db 3, ERIKA,    1, 5, 6  ; 6: Celadon - Erika
	db 3, MORTY,    5, 6, 7  ; 7: Celadon - guest Morty
	db 4, JANINE,   1, 2, 3  ; 8: Fuchsia - Janine
	db 5, SABRINA,  1, 2, 3  ; 9: Saffron - Sabrina
	db 6, BLAINE,   1, 2, 3  ; 10: Seafoam - Blaine
	db 7, BLUE,     1, 3, 4  ; 11: Viridian - Blue
	db 4, CHUCK,    11, 12, 13 ; 12: Fuchsia - guest Chuck

; --- Game Corner prize rolls ---
; Goldenrod stocks one prize per price tier, each rolled independently
; per save (27 combinations); Celadon rolls one of three fixed lineups.
InitGameCornerRolls:
	ld a, [wGameCornerLineups]
	bit 7, a
	ret nz
	ld c, 3
	call InitKantoGymTeams.BuildRandomByte
	or %10000000             ; set init flag
	ld [wGameCornerLineups], a
	ld c, 1
	call InitKantoGymTeams.BuildRandomByte
	ld [wGameCornerLineups2], a
	ret

; input:  wScriptVar = Goldenrod price tier 0-2 (500/800/1500 coins)
; output: wScriptVar = 1-3 (which prize this save stocks in that tier)
GetGoldenrodPrizeSlot::
	call InitGameCornerRolls
	ld a, [wGameCornerLineups]
	ld d, a
	ld a, [wScriptVar]
	ld b, a
	ld a, 2
	sub b                    ; tiers-from-low
	add a                    ; *2 = shift
	ld e, a
	ld a, d
	inc e
.shift:
	dec e
	jr z, .shifted
	srl a
	jr .shift
.shifted:
	and %11
	cp 3
	jr c, .ok
	xor a                    ; corrupt-save guard
.ok:
	inc a
	ld [wScriptVar], a
	ret

; output: wScriptVar = 1-3 (Celadon lineup for this save)
GetGameCornerLineup::
	call InitGameCornerRolls
	ld a, [wGameCornerLineups2]
	and %11
	cp 3
	jr c, .ok
	xor a                    ; corrupt-save guard
.ok:
	inc a
	ld [wScriptVar], a
	ret

; --- Red's team variant roll ---
; Rolls one of five first-fight teams per save and loads it directly.
; Party IDs: variant 0 -> 1 (original); variants 1-4 -> 3-6 (2 is the rematch).
LoadRedTrainer::
	ld a, [wRedTeamChoice]
	bit 7, a
	jr nz, .rolled
	ld a, 5
	call RandomRange
	or %10000000             ; set init flag
	ld [wRedTeamChoice], a
.rolled:
	and %111
	cp 5
	jr c, .valid
	xor a                    ; corrupt-save guard
.valid:
	and a
	jr z, .original
	add 2                    ; skip the rematch slot
	jr .store
.original:
	ld a, 1
.store:
	ld [wOtherTrainerID], a
	ld a, RED
	ld [wOtherTrainerClass], a
	ld a, (1 << 7) | 1
	ld [wBattleScriptFlags], a
	ret

; --- Global exp pacing ---
; Wild battles +5% (x21/20), trainer battles +10% (x22/20).
; Farcalled from GiveExperiencePoints right after the base
; BaseExp * Level / 7 step; the 16-bit exp value lives in
; hProduct+2/+3 (hMultiplicand/hQuotient share the same registers).
ApplyExpTuning::
	push bc
	ldh a, [hProduct + 2]
	ld b, a
	ldh a, [hProduct + 3]
	ld c, a
	xor a
	ldh [hMultiplicand + 0], a
	ld a, b
	ldh [hMultiplicand + 1], a
	ld a, c
	ldh [hMultiplicand + 2], a
	ld a, [wBattleMode]
	dec a
	ld a, 21
	jr z, .got_multiplier    ; wild battle
	inc a                    ; trainer battle: 22
.got_multiplier:
	ldh [hMultiplier], a
	call Multiply
	ld a, 20
	ldh [hDivisor], a
	ld b, 4
	call Divide
	pop bc
	ret

POPS
