GiveDratini:
; If the Dragon-master quiz was aced (wScriptVar == 0), teach the shrine gift
; Pokemon (the last mon in the party) its special reward moveset.
; Otherwise (wScriptVar >= 1) leave its natural level-up moves alone.

	ld a, [wScriptVar]
	and a
	ret nz
	ld a, [wPartyCount]
	ld hl, MON_SPECIES
	call .GetNthPartyMon
	ret c
	ld a, [hl]
	push hl
	ld hl, .DratiniMoveset
	cp DRATINI
	jr z, .GiveMoveset
	ld hl, .LarvitarMoveset
	cp LARVITAR
	jr z, .GiveMoveset
	ld hl, .HorseaMoveset
	cp HORSEA
	jr z, .GiveMoveset
	pop hl
	ret

.GiveMoveset:
	; get address of mon's first move
	pop de
	inc de
	inc de

.GiveMoves:
	ld a, [hl]
	and a ; is the move 00?
	ret z ; if so, we're done here

	push hl
	push de
	ld [de], a ; give the Pokémon the new move

	; get the PP of the new move
	dec a
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte

	; get the address of the move's PP and update the PP
	ld hl, MON_PP - MON_MOVES
	add hl, de
	ld [hl], a

	pop de
	pop hl
	inc de
	inc hl
	jr .GiveMoves

.DratiniMoveset:
; Dratini does not normally learn Extremespeed. This is a special gift.
	db WRAP
	db THUNDER_WAVE
	db TWISTER
	db EXTREMESPEED
	db 0
.LarvitarMoveset:
; Rock Slide normally comes at level 40. This is a special gift.
	db BITE
	db ROCK_THROW
	db SANDSTORM
	db ROCK_SLIDE
	db 0
.HorseaMoveset:
; Water Gun and Twister normally come at levels 18 and 29.
	db BUBBLE
	db SMOKESCREEN
	db WATER_GUN
	db TWISTER
	db 0

.GetNthPartyMon:
; inputs:
; hl must be set to 0 before calling this function.
; a must be set to the number of Pokémon in the party.

; outputs:
; returns the address of the last Pokémon in the party in hl.
; sets carry if a is 0.

	ld de, wPartyMon1
	add hl, de
	and a
	jr z, .EmptyParty
	dec a
	ret z
	ld de, PARTYMON_STRUCT_LENGTH
.loop
	add hl, de
	dec a
	jr nz, .loop
	ret

.EmptyParty:
	scf
	ret
