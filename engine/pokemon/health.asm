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
; Calculate total healing cost for all party Pokemon
; Store in wStringBuffer2 for display (big-endian)
; Store in wStringBuffer1 for payment functions (little-endian)
	push hl
	push de
	push bc
	
	; Initialize total cost to 0
	xor a
	ld [wStringBuffer1], a
	ld [wStringBuffer1 + 1], a
	
	; Loop through party Pokemon
	ld a, 0
	ld [wCurPartyMon], a
	ld hl, wPartySpecies
	
.loop
	ld a, [hli]
	cp -1  ; End of party
	jr z, .done_calculating
	cp EGG
	jr z, .next  ; Skip eggs
	
	push hl
	call CalculateMonHealingCost
	pop hl
	
.next
	ld a, [wCurPartyMon]
	inc a
	ld [wCurPartyMon], a
	jr .loop
	
.done_calculating
	; Copy result to StringBuffer2 for display (convert to big-endian)
	ld a, [wStringBuffer1 + 1]  ; High byte (little-endian)
	ld [wStringBuffer2], a       ; High byte (big-endian)
	ld a, [wStringBuffer1]       ; Low byte (little-endian)
	ld [wStringBuffer2 + 1], a   ; Low byte (big-endian)
	
	pop bc
	pop de
	pop hl
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
	
	; Track if any healing was needed (for PP cost decision)
	xor a
	ld [wCurItem], a  ; Use as temp flag: 0 = no healing needed
	
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
	
	; Pokemon is fainted, add revive cost (level × 25 + PP restoration included)
	ld a, 1
	ld [wCurItem], a  ; Mark that healing is needed
	
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
	
	; Fainted Pokemon gets PP restored with revive, skip PP check later
	jp .done
	
.not_fainted
	; Calculate HP restoration cost (1 per HP)
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
	; bc now contains HP to restore (cost = 1 per HP)
	; Check if > 0
	ld a, b
	or c
	jr z, .check_status
	
	; HP needs healing, mark it
	ld a, 1
	ld [wCurItem], a
	
	; Add HP cost to running total
	ld a, [wStringBuffer1]
	add c
	ld [wStringBuffer1], a
	ld a, [wStringBuffer1 + 1]
	adc b
	ld [wStringBuffer1 + 1], a
	
.check_status
	pop de ; Restore Pokemon data pointer
	push de ; Save it again for PP check
	
	; Check status (add 10 if status != 0)
	ld hl, MON_STATUS
	add hl, de
	ld a, [hl]
	or a
	jr z, .check_pp
	
	; Status needs healing, mark it
	ld a, 1
	ld [wCurItem], a
	
	; Add 10 for status condition
	ld a, [wStringBuffer1]
	add 10
	ld [wStringBuffer1], a
	ld a, [wStringBuffer1 + 1]
	adc 0
	ld [wStringBuffer1 + 1], a
	
.check_pp
	; Use the game's existing GetMaxPPOfMove to properly check PP
	
	; Save current values we'll be modifying
	push de
	ld a, [wMonType]
	push af
	ld a, [wMenuCursorY]
	push af
	
	; Set up for GetMaxPPOfMove
	xor a  ; PARTYMON
	ld [wMonType], a
	
	; Track total PP to restore across all moves
	ld hl, 0  ; hl will accumulate total PP deficit
	push hl   ; Save it on stack
	
	; Check all 4 move slots
	ld b, 0  ; Move slot counter
	
.pp_loop
	push bc
	push de
	
	; Check if this slot has a move
	ld hl, MON_MOVES
	add hl, de
	ld e, b
	ld d, 0
	add hl, de
	ld a, [hl]  ; Get move ID
	or a
	jr z, .skip_slot  ; No move in this slot
	
	; Set up for GetMaxPPOfMove
	ld a, b
	ld [wMenuCursorY], a  ; Move slot
	
	; Get max PP for this move
	push bc
	farcall GetMaxPPOfMove  ; Returns max PP in [hl]
	ld a, [hl]  ; a = max PP
	ld c, a     ; c = max PP
	pop bc
	
	; Get current PP
	pop de
	push de
	ld hl, MON_PP
	add hl, de
	ld e, b
	ld d, 0
	add hl, de
	ld a, [hl]  ; Get PP byte
	and $3f     ; Get current PP (lower 6 bits)
	
	; Calculate PP deficit (max - current)
	ld e, a     ; e = current PP
	ld a, c     ; a = max PP
	sub e       ; a = max - current
	jr c, .pp_full  ; If negative (shouldn't happen), skip
	jr z, .pp_full  ; If zero, PP is full
	
	; Add this move's PP deficit to total
	ld e, a
	ld d, 0     ; de = PP deficit for this move
	pop hl      ; Get running total
	add hl, de  ; Add this move's deficit
	push hl     ; Save updated total
	
	pop de
	pop bc
	jr .next_slot
	
.pp_full
.skip_slot
	pop de
	pop bc
	
.next_slot
	inc b
	ld a, b
	cp NUM_MOVES
	jr nz, .pp_loop
	
	; Get total PP deficit from stack
	pop hl  ; hl = total PP to restore
	
	; Check if any PP restoration is needed
	ld a, h
	or l
	jr z, .cleanup  ; No PP restoration needed
	
	; Calculate cost: PP deficit × 2
	add hl, hl  ; hl = PP deficit × 2
	
	; Add to running total cost
	ld a, [wStringBuffer1]
	add l
	ld [wStringBuffer1], a
	ld a, [wStringBuffer1 + 1]
	adc h
	ld [wStringBuffer1 + 1], a
	
.cleanup
	; Restore original values
	pop af
	ld [wMenuCursorY], a
	pop af
	ld [wMonType], a
	pop de
	
.done
	pop de ; Restore Pokemon data pointer
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
; Check if player can afford healing cost stored in wStringBuffer1
; Returns result in wScriptVar: 1 if can afford, 0 if not
	push hl
	push de
	push bc
	
	; Get cost from wStringBuffer1 (where CalculateHealingCost stored it)
	ld a, 0
	ld [hMoneyTemp], a     ; High byte (we're dealing with small amounts)
	ld a, [wStringBuffer1 + 1] ; High byte of cost
	ld [hMoneyTemp + 1], a ; Mid byte
	ld a, [wStringBuffer1]     ; Low byte of cost
	ld [hMoneyTemp + 2], a ; Low byte
	
	; Use the game's standard money comparison function
	ld de, wMoney
	ld bc, hMoneyTemp
	farcall CompareMoney
	
	jr c, .cant_afford
	; Can afford
	ld a, 1
	ld [wScriptVar], a
	jr .done
	
.cant_afford
	xor a
	ld [wScriptVar], a
	
.done
	pop bc
	pop de
	pop hl
	ret

TakeHealingPayment::
; Take the healing cost from player's money
; Cost is stored in wStringBuffer1 by CalculateHealingCost
	push hl
	push de
	push bc
	
	; Get cost from wStringBuffer1
	ld a, 0
	ld [hMoneyTemp], a     ; High byte (we're dealing with small amounts)
	ld a, [wStringBuffer1 + 1] ; High byte of cost
	ld [hMoneyTemp + 1], a ; Mid byte
	ld a, [wStringBuffer1]     ; Low byte of cost
	ld [hMoneyTemp + 2], a ; Low byte
	
	; Use the game's standard money subtraction function
	ld de, wMoney
	ld bc, hMoneyTemp
	farcall TakeMoney
	
	pop bc
	pop de
	pop hl
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
