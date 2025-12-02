HealParty:
	xor a
	ld [wCurPartyMon], a
	ld hl, wPartySpecies
.loop
	ld a, [hli]
	cp -1
	jr z, .done
	cp EGG
	jr z, .next

	push hl
	call HealPartyMon
	pop hl

.next
	ld a, [wCurPartyMon]
	inc a
	ld [wCurPartyMon], a
	jr .loop

.done
	ret

HealPartyMon:
	ld a, MON_SPECIES
	call GetPartyParamLocation
	ld d, h
	ld e, l

	ld hl, MON_STATUS
	add hl, de
	xor a
	ld [hli], a
	ld [hl], a

	ld hl, MON_MAXHP
	add hl, de

	; bc = MON_HP
	ld b, h
	ld c, l
	dec bc
	dec bc
	; Hardcore mode, don't heal fainted pokemon
	call CheckHardcoreMode
	jr z, .notHardcore
	inc bc
	ld a, [bc]
	dec bc
	cp 0
	ret z
.notHardcore
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hl]
	ld [bc], a

	farcall RestoreAllPP
	ret

HealPartyMonDaycare: ; yes this suplicate code is inefficient but ehh, we're not using the extra space
	ld a, MON_SPECIES
	call GetPartyParamLocation
	ld d, h
	ld e, l
	ld hl, MON_STATUS
	add hl, de
	xor a
	ld [hli], a
	ld [hl], a
	ld hl, MON_MAXHP
	add hl, de
	; bc = MON_HP
	ld b, h
	ld c, l
	dec bc
	dec bc
	ld a, [hli]
	ld [bc], a
	inc bc
	ld a, [hl]
	ld [bc], a
	farcall RestoreAllPP
	ret

CalculateHealingCost_Debug:
; Calculate the cost to heal the party
; Returns cost in wScriptVar (capped at 9999)
	; For debugging, only calculate first Pokemon
	xor a
	ld [wStringBuffer1], a     ; Low byte
	ld [wStringBuffer1 + 1], a ; High byte
	ld [wCurPartyMon], a
	
	; Check if first Pokemon is an egg
	ld a, [wPartySpecies]
	cp EGG
	jr z, .done
	
	; Calculate cost for first Pokemon only
	call CalculateMonHealingCost
	
.done
	; Get total from wStringBuffer1
	ld a, [wStringBuffer1]
	ld l, a
	ld a, [wStringBuffer1 + 1]
	ld h, a
	
	; Store in wScriptVar (big-endian for display)
	ld a, h
	ld [wScriptVar], a     ; High byte
	ld a, l
	ld [wScriptVar + 1], a ; Low byte
	ret
	
CalculateHealingCost:
; Calculate the cost to heal the party
; Returns cost in wScriptVar (capped at 9999)
	xor a
	ld [wStringBuffer1], a     ; Low byte
	ld [wStringBuffer1 + 1], a ; High byte
	ld [wCurPartyMon], a
	
	; Loop through party
	ld hl, wPartySpecies
.loop
	ld a, [hli]
	cp -1
	jr z, .done
	cp EGG
	jr z, .next

	push hl
	call CalculateMonHealingCost
	pop hl

.next
	ld a, [wCurPartyMon]
	inc a
	ld [wCurPartyMon], a
	jr .loop

.done
	; Get total from wStringBuffer1
	ld a, [wStringBuffer1]
	ld l, a
	ld a, [wStringBuffer1 + 1]
	ld h, a
	
	; Store in wScriptVar (big-endian for display)
	ld a, h
	ld [wScriptVar], a     ; High byte
	ld a, l
	ld [wScriptVar + 1], a ; Low byte
	ret

CalculateMonHealingCost:
; Calculate cost for current party mon
; Add result to running total in wStringBuffer1
	; Get pointer to party mon data
	ld a, MON_SPECIES
	call GetPartyParamLocation
	ld d, h
	ld e, l
	
	push de ; Save Pokemon data pointer
	
	; First, check if Pokemon is fainted and needs revive cost
	; Get current HP (big-endian: high byte, then low byte)
	ld hl, MON_HP
	add hl, de
	ld a, [hli]
	ld b, a     ; b = current HP high
	ld a, [hl]
	ld c, a     ; c = current HP low
	
	; Check if Pokemon is fainted (HP = 0)
	ld a, b
	or c
	jr nz, .not_fainted
	
	; Pokemon is fainted, add revive cost (level × 10)
	push bc
	ld hl, MON_LEVEL
	add hl, de
	ld a, [hl]  ; a = level
	
	; Multiply level by 25 using simple method
	ld b, a     ; Save original level
	
	; Calculate level × 25 = level × 20 + level × 5
	; First calculate level × 5
	add a, a    ; a = level × 2
	add a, a    ; a = level × 4  
	add b       ; a = level × 4 + level = level × 5
	ld c, a     ; c = level × 5
	
	; Calculate level × 20 = (level × 5) × 4
	add a, a    ; a = level × 10
	add a, a    ; a = level × 20
	add c       ; a = level × 20 + level × 5 = level × 25
	
	; Result is in a, move to bc for 16-bit addition
	ld c, a     ; c = level × 25 (low byte)
	ld b, 0     ; b = 0 (high byte, level × 25 < 256 for level ≤ 10)
	
	; Add revive cost to running total
	ld a, [wStringBuffer1]
	add c
	ld [wStringBuffer1], a
	ld a, [wStringBuffer1 + 1]
	adc b
	ld [wStringBuffer1 + 1], a
	pop bc
	
.not_fainted
	; Calculate HP restoration cost
	; Get max HP (big-endian: high byte, then low byte)
	ld hl, MON_MAXHP
	add hl, de
	ld a, [hli]
	ld d, a     ; d = max HP high
	ld a, [hl]
	ld e, a     ; e = max HP low
	; de = max HP, bc = current HP
	
	; Calculate max - current
	; We need to do de - bc
	ld a, e
	sub c
	ld c, a     ; c = low byte of difference
	ld a, d
	sbc b
	ld b, a     ; b = high byte of difference
	
	; Check if result is negative (would mean Pokemon is already at full HP or over)
	jr nc, .hp_ok
	; If negative, set to 0
	ld bc, 0
	
.hp_ok
	; bc now contains HP to restore
	; Add HP cost to running total
	ld a, [wStringBuffer1]
	add c
	ld [wStringBuffer1], a
	ld a, [wStringBuffer1 + 1]
	adc b
	ld [wStringBuffer1 + 1], a
	
	pop de ; Restore Pokemon data pointer
	
	; Check status (add 1 if status != 0)
	ld hl, MON_STATUS
	add hl, de
	ld a, [hl]
	or a
	jr z, .check_pp
	
	; Add 10 for status condition
	ld a, [wStringBuffer1]
	add 10
	ld [wStringBuffer1], a
	ld a, [wStringBuffer1 + 1]
	adc 0
	ld [wStringBuffer1 + 1], a
	
.check_pp
	; Add fixed cost of 40 for PP restoration per Pokemon (2 per PP point, ~20 PP per Pokemon)
	ld a, [wStringBuffer1]
	add 40
	ld [wStringBuffer1], a
	ld a, [wStringBuffer1 + 1]
	adc 0
	ld [wStringBuffer1 + 1], a
	
	ret

SimpleDivide:
; Divide a by b, return quotient in a
; This is a simple division for small numbers
	push bc
	ld c, 0
.loop
	sub b
	jr c, .done
	inc c
	jr .loop
.done
	ld a, c
	pop bc
	ret

CheckHealingPayment:
; Check if player can afford healing cost in wScriptVar
; Returns result in wScriptVar: 1 if can afford, 0 if not
	; Get cost from wScriptVar (2 bytes, big-endian)
	ld a, [wScriptVar]
	ld h, a  ; High byte
	ld a, [wScriptVar + 1]
	ld l, a  ; Low byte
	; hl = cost
	
	; Compare with player's money
	ld de, wMoney + 2
	ld a, [de]
	cp l
	jr c, .cant_afford
	jr nz, .can_afford
	dec de
	ld a, [de]
	cp h
	jr c, .cant_afford
	
.can_afford
	ld a, 1
	ld [wScriptVar], a
	ret
	
.cant_afford
	xor a
	ld [wScriptVar], a
	ret

TakeHealingPayment:
; Take the healing cost from player's money
; Cost should be in wScriptVar (2 bytes, big-endian)
	; Get cost
	ld a, [wScriptVar]
	ld h, a  ; High byte
	ld a, [wScriptVar + 1]
	ld l, a  ; Low byte
	
	; Subtract from money (wMoney is 3 bytes: high, mid, low)
	ld de, wMoney + 2
	ld a, [de]
	sub l
	ld [de], a
	dec de
	ld a, [de]
	sbc h
	ld [de], a
	dec de
	ld a, [de]
	sbc 0
	ld [de], a
	ret

ComputeHPBarPixels:
; e = bc * (6 * 8) / de
	ld a, b
	or c
	jr z, .zero
	push hl
	xor a
	ldh [hMultiplicand + 0], a
	ld a, b
	ldh [hMultiplicand + 1], a
	ld a, c
	ldh [hMultiplicand + 2], a
	ld a, 6 * 8
	ldh [hMultiplier], a
	call Multiply
	; We need de to be under 256 because hDivisor is only 1 byte.
	ld a, d
	and a
	jr z, .divide
	; divide de and hProduct by 4
	srl d
	rr e
	srl d
	rr e
	ldh a, [hProduct + 2]
	ld b, a
	ldh a, [hProduct + 3]
	srl b
	rr a
	srl b
	rr a
	ldh [hDividend + 3], a
	ld a, b
	ldh [hDividend + 2], a
.divide
	ld a, e
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ldh a, [hQuotient + 3]
	ld e, a
	pop hl
	and a
	ret nz
	ld e, 1
	ret

.zero
	ld e, 0
	ret

AnimateHPBar:
	call WaitBGMap
	call _AnimateHPBar
	call WaitBGMap
	ret
