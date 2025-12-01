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

CalculateHealingCost::
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
	
CalculateHealingCost_Real::
	; Initialize total to 0 using temporary storage
	xor a
	ld [wStringBuffer1], a     ; Low byte
	ld [wStringBuffer1 + 1], a ; High byte
	
	; Loop through party
	ld a, [wPartyCount]
	and a
	ret z ; No Pokemon in party
	
	ld b, a ; b = number of Pokemon
	ld c, 0 ; c = index
	
.party_loop
	push bc
	
	; Get pointer to current Pokemon
	ld a, c
	ld [wCurPartyMon], a
	
	; Check if it's an egg
	ld hl, wPartySpecies
	ld d, 0
	ld e, c
	add hl, de
	ld a, [hl]
	cp EGG
	jr z, .skip_mon
	
	; Calculate cost for this Pokemon
	call CalculateMonHealingCost
	
.skip_mon
	pop bc
	inc c
	dec b
	jr nz, .party_loop
	
	; Get final total from wStringBuffer1
	ld a, [wStringBuffer1]
	ld l, a
	ld a, [wStringBuffer1 + 1]
	ld h, a
	
	; Cap at 9999 if needed
	ld de, 9999
	; Compare hl with de
	ld a, h
	cp d
	jr c, .store_result ; h < d, so total < 9999
	jr nz, .cap_max ; h > d, so total > 9999
	ld a, l
	cp e
	jr c, .store_result ; l < e, so total < 9999
	
.cap_max
	ld hl, 9999
	
.store_result
	; Store in wScriptVar in BIG-ENDIAN for text_decimal
	ld a, h
	ld [wScriptVar], a     ; High byte first
	ld a, l
	ld [wScriptVar + 1], a ; Low byte second
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
	
	; Multiply level by 10
	ld b, a
	add a, a    ; ×2
	add a, a    ; ×4
	add a, b    ; ×5
	add a, a    ; ×10
	ld c, a     ; c = level × 10 (low byte)
	ld b, 0     ; b = 0 (high byte, assuming level × 10 < 256)
	
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
	
	; Add 1 for status condition
	ld a, [wStringBuffer1]
	add 1
	ld [wStringBuffer1], a
	ld a, [wStringBuffer1 + 1]
	adc 0
	ld [wStringBuffer1 + 1], a
	
.check_pp
	; Calculate PP cost
	; Each move can have missing PP that needs to be restored
	ld hl, MON_MOVES
	add hl, de
	; hl now points to moves array
	
	ld b, NUM_MOVES ; 4 moves
	ld c, 0 ; Move index
.pp_loop
	push bc
	push hl
	
	; Check if move exists (not 0)
	ld a, [hl]
	and a
	jr z, .skip_move ; No move in this slot
	
	; Calculate PP difference for this move
	push hl
	push bc
	push de
	
	; Save move ID
	ld [wNamedObjectIndex], a
	
	; Get PP-Up count for this move
	ld hl, MON_PP
	add hl, de ; hl = PP array start
	ld d, 0
	ld e, c   ; c = move index
	add hl, de ; hl = current move's PP byte
	
	ld a, [hl] ; Get PP byte (includes PP-Up bits)
	ld b, a    ; Save full PP byte
	and PP_MASK ; Mask to get just current PP (0-63)
	ld e, a    ; e = current PP
	
	; Get PP-Up count (0-3)
	ld a, b
	and PP_UP_MASK ; Get PP-Up bits
	swap a
	swap a        ; Move bits 6-7 to bits 0-1
	and %00000011 ; Mask to get just the count
	ld d, a       ; d = PP-Up count
	
	; Get base max PP for this move from moves table
	push de       ; Save current PP and PP-Up count
	ld a, [wNamedObjectIndex]
	dec a         ; Move IDs start at 1
	ld hl, Moves + MOVE_PP
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld a, BANK(Moves)
	call GetFarByte ; a = base PP
	pop de        ; Restore current PP (e) and PP-Up count (d)
	
	; Calculate actual max PP = base + (base * PP-Ups / 5)
	ld b, a       ; b = base PP
	ld c, a       ; c = base PP (for calculation)
	
	; Add PP-Up bonus if any
	ld a, d       ; PP-Up count
	and a
	jr z, .no_pp_ups
	
	; Each PP-Up adds 20% of base PP (1/5)
	; Total bonus = base * pp_ups / 5
.pp_up_loop
	ld a, c       ; Base PP
	push bc
	ld b, 5
	call SimpleDivide ; a = base / 5
	pop bc
	add b         ; Add to running total
	ld b, a       ; Update max PP
	dec d
	jr nz, .pp_up_loop
	
.no_pp_ups
	; b = max PP, e = current PP
	ld a, b
	sub e         ; a = max - current
	jr c, .pp_done ; If negative (shouldn't happen), skip
	jr z, .pp_done ; If zero, PP is full
	
	; Add PP difference to total
	ld b, 0
	ld c, a       ; bc = PP difference
	ld hl, wStringBuffer1
	ld a, [hl]
	add c
	ld [hl], a
	inc hl
	ld a, [hl]
	adc b
	ld [hl], a
	
.pp_done
	pop de
	pop bc
	pop hl
	
.skip_move
	pop hl
	pop bc
	inc hl ; Next move
	inc c  ; Next move index
	dec b
	jr nz, .pp_loop
	
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

CheckHealingPayment::
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

TakeHealingPayment::
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
