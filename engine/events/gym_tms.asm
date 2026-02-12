; Randomized Gym TM Rewards
; Called via callasm from map scripts, so can be in any bank.
; Init flag: bit 7 of wGymTeamChoices2 (bits 4-7 unused by gym teams).
; wGymTMChoices byte 0: bits 7-6 = Morty, bits 5-4 = Whitney, bits 3-2 = Bugsy, bits 1-0 = Falkner
; wGymTMChoices byte 1: bits 7-6 = Clair, bits 5-4 = Pryce, bits 3-2 = Jasmine, bits 1-0 = Chuck

InitGymTMs:
	ld a, [wGymTeamChoices2]
	bit 7, a
	ret nz

	; Byte 0: 4 gyms (Morty/Whitney/Bugsy/Falkner)
	ld c, 4
	call .BuildByte
	ld [wGymTMChoices], a

	; Byte 1: 4 gyms (Clair/Pryce/Jasmine/Chuck)
	ld c, 4
	call .BuildByte
	ld [wGymTMChoices + 1], a

	; Set init flag
	ld a, [wGymTeamChoices2]
	or %10000000
	ld [wGymTeamChoices2], a
	ret

.BuildByte:
; Build a byte with c packed 2-bit random values (0-2).
	xor a
	ld b, a
.loop:
	ld a, b
	rlca
	rlca
	ld b, a
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
	db TM_MUD_SLAP,      TM_SWIFT,       TM_ROAR         ; Falkner
	db TM_FURY_CUTTER,   TM_CURSE,       TM_HIDDEN_POWER  ; Bugsy
	db TM_ATTRACT,       TM_RETURN,      TM_ROLLOUT       ; Whitney
	db TM_SHADOW_BALL,   TM_DREAM_EATER, TM_NIGHTMARE     ; Morty
	db TM_DYNAMICPUNCH,  TM_ICE_PUNCH,   TM_ROCK_SMASH    ; Chuck
	db TM_IRON_TAIL,     TM_STEEL_WING,  TM_SANDSTORM     ; Jasmine
	db TM_ICY_WIND,      TM_BLIZZARD,    TM_REST          ; Pryce
	db TM_DRAGONBREATH,  TM_FIRE_BLAST,  TM_THUNDERPUNCH  ; Clair
