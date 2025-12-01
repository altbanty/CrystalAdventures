; Nuzlocke encounter tracking functions

GetSimplifiedMapIndex::
; Returns a simplified map index in a (0-63)  
; Uses XOR hash to distribute 390 maps across 64 bits
; Will have collisions but aims to keep routes separate
	ld a, [wMapGroup]
	ld b, a
	ld a, [wMapNumber]
	xor b  ; XOR for better distribution
	ld b, a
	ld a, [wMapGroup]
	rlca   ; Rotate group bits
	rlca
	add b  ; Combine
	and 63 ; Cap at 0-63
	ret

CheckNuzlockeEncounter::
; Check if we've already encountered a Pokemon on this map
; Returns z if no encounter yet, nz if already encountered
	call GetSimplifiedMapIndex
	
	; Calculate byte offset (map_index / 8)
	ld b, a
	srl a
	srl a
	srl a
	
	; a now contains byte offset (0-7)
	ld hl, wNuzlockeEncounterFlags
	ld e, a
	ld d, 0
	add hl, de
	
	; Calculate bit position (map_index & 7)
	ld a, b
	and 7
	
	; Create bit mask
	ld b, a
	ld a, 1
	inc b
.shift_loop
	dec b
	jr z, .got_mask
	rlca
	jr .shift_loop
.got_mask
	
	; Check the bit
	and [hl]
	ret

SetNuzlockeEncounter::
; Mark that we've encountered a Pokemon on this map
	call GetSimplifiedMapIndex
	
	; Calculate byte offset (map_index / 8)
	ld b, a
	srl a
	srl a
	srl a
	
	; a now contains byte offset (0-7)
	ld hl, wNuzlockeEncounterFlags
	ld e, a
	ld d, 0
	add hl, de
	
	; Calculate bit position (map_index & 7)
	ld a, b
	and 7
	
	; Create bit mask
	ld b, a
	ld a, 1
	inc b
.shift_loop
	dec b
	jr z, .got_mask
	rlca
	jr .shift_loop
.got_mask
	
	; Set the bit
	or [hl]
	ld [hl], a
	ret

ClearAllNuzlockeEncounters::
; Clear all Nuzlocke encounter flags (for new game)
	ld hl, wNuzlockeEncounterFlags
	ld bc, 8
	xor a
	call ByteFill
	ret

CheckNuzlockeForBattle::
; Check if this battle is the first encounter for Nuzlocke
; Sets wNuzlockeFirstEncounter if it is
	ld a, [wBattleType]
	cp BATTLETYPE_SHINY
	ret z ; Skip for special battles
	cp BATTLETYPE_SUICUNE
	ret z
	cp BATTLETYPE_ROAMING
	ret z
	cp BATTLETYPE_TREE
	ret z
	cp BATTLETYPE_TRAP
	ret z
	cp BATTLETYPE_CELEBI
	ret z
	cp BATTLETYPE_TUTORIAL
	ret z
	; Check if already encountered on this map
	call CheckNuzlockeEncounter
	ret nz ; Already encountered
	; This is the first encounter
	ld a, 1
	ld [wNuzlockeFirstEncounter], a
	ret