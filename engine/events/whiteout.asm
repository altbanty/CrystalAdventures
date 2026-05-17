Script_BattleWhiteout::
	callasm BattleBGMap
	sjump Script_Whiteout

OverworldWhiteoutScript::
	refreshscreen
	callasm OverworldBGMap

Script_Whiteout:
	writetext .WhitedOutText
	waitbutton
	special FadeOutPalettes
	pause 40
	callasm WhiteoutReviveOne
	checkflag ENGINE_BUG_CONTEST_TIMER
	iftrue .bug_contest
	; Adventure Mode uses paid healing as the punishment, so skip HalveMoney
	checkflag ENGINE_ADVENTURE_MODE
	iftrue .skip_halve
	callasm HalveMoney
.skip_halve
	checkflag ENGINE_UNUSED_DIFFICULTY
	iftrue .reset
	callasm GetWhiteoutSpawn
	farscall Script_AbortBugContest
	special WarpToSpawnPoint
	newloadmap MAPSETUP_WARP
	endall
.reset
	callasm Reset

.bug_contest
	jumpstd BugContestResultsWarpScript

.WhitedOutText:
	text_far _WhitedOutText
	text_end

OverworldBGMap:
	call ClearPalettes
	call ClearScreen
	call WaitBGMap2
	call HideSprites
	call RotateThreePalettesLeft
	ret

BattleBGMap:
	ld b, SCGB_BATTLE_GRAYSCALE
	call GetSGBLayout
	call SetPalettes
	ret

HalveMoney:
	farcall StubbedTrainerRankings_WhiteOuts

; Halve the player's money.
	ld hl, wMoney
	ld a, [hl]
	srl a
	ld [hli], a
	ld a, [hl]
	rra
	ld [hli], a
	ld a, [hl]
	rra
	ld [hl], a
	ret

GetWhiteoutSpawn:
	ld a, [wLastSpawnMapGroup]
	ld d, a
	ld a, [wLastSpawnMapNumber]
	ld e, a
	farcall IsSpawnPoint
	ld a, c
	jr c, .yes
	xor a ; SPAWN_HOME

.yes
	ld [wDefaultSpawnpoint], a
	ret

PUSHS
SECTION "Whiteout Revive One", ROMX

WhiteoutReviveOne::
; After a whiteout, revive ONLY the first non-egg party mon to 1 HP.
; All other mons stay at 0 HP, forcing the player to pay for healing.
; PP is intentionally NOT restored.
	xor a
	ld [wCurPartyMon], a
	ld hl, wPartySpecies
.find_loop
	ld a, [hl]
	cp -1
	ret z              ; end of party — nothing to revive (shouldn't happen)
	cp EGG
	jr nz, .found
	inc hl
	ld a, [wCurPartyMon]
	inc a
	ld [wCurPartyMon], a
	jr .find_loop
.found
	; wCurPartyMon is the slot of the first non-egg
	ld a, MON_SPECIES
	call GetPartyParamLocation
	ld d, h
	ld e, l
	; Clear status
	ld hl, MON_STATUS
	add hl, de
	xor a
	ld [hl], a
	; Set HP to 1 (big-endian: high=0, low=1)
	ld hl, MON_HP
	add hl, de
	xor a
	ld [hli], a
	ld a, 1
	ld [hl], a
	ret
POPS
