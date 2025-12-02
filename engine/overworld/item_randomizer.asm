SECTION "Item Randomization Engine", ROMX

; Item pool data - actual item lists for each location
Route29ItemPool:
	db POTION
	db POKE_BALL
	db ETHER
	db ROUTE29_POOL_SIZE

Route30ItemPool:
	db POTION
	db ANTIDOTE
	db POKE_BALL
	db ETHER
	db ROUTE30_POOL_SIZE

Route31ItemPool:
	db POTION
	db POKE_BALL
	db ETHER
	db BERRY
	db ROUTE31_POOL_SIZE

Route32ItemPool:
	db SUPER_POTION
	db GREAT_BALL
	db MAX_ETHER
	db REPEL
	db ROUTE32_POOL_SIZE

UnionCaveItemPool:
	db SUPER_POTION
	db GREAT_BALL
	db X_ATTACK
	db ESCAPE_ROPE
	db MAX_ETHER
	db UNIONCAVE_POOL_SIZE

SproutTowerItemPool:
	db POTION
	db POKE_BALL
	db ANTIDOTE
	db BERRY
	db SPROUTTOWER_POOL_SIZE

IlexForestItemPool:
	db SUPER_POTION
	db GREAT_BALL
	db ESCAPE_ROPE
	db BERRY
	db PSNCUREBERRY
	db ILEXFOREST_POOL_SIZE

Route36ItemPool:
	db SUPER_POTION
	db GREAT_BALL
	db X_SPEED
	db REPEL
	db MAX_ETHER
	db ROUTE36_POOL_SIZE

IcePathItemPool:
	db HYPER_POTION
	db ULTRA_BALL
	db FULL_HEAL
	db X_SPECIAL
	db ELIXER
	db ICEPATH_POOL_SIZE

VictoryRoadItemPool:
	db HYPER_POTION
	db ULTRA_BALL
	db FULL_RESTORE
	db MAX_REVIVE
	db X_ATTACK
	db X_DEFEND
	db VICTORYROAD_POOL_SIZE

; Gets a random item from the specified pool
; Input: hl = pointer to item pool (pool items followed by pool size)
; Output: a = randomly selected item
GetRandomItemFromPool::
	push hl
	push bc
	push de
	
	; Store starting address
	ld d, h
	ld e, l
	
	; Find the pool size (scan for value >= 10)
	ld b, 0   ; counter
.FindPoolSizeLoop:
	ld a, [hl]
	cp 10     ; If value >= 10, it's the pool size
	jr nc, .FoundPoolSize
	inc hl
	inc b
	jr .FindPoolSizeLoop
	
.FoundPoolSize:
	ld c, a   ; c = pool size
	
	; Generate random number 0 to (pool_size - 1)
	call Random
	
	; Simple modulo operation
.ModuloLoop:
	cp c
	jr c, .ValidIndex
	sub c
	jr .ModuloLoop
	
.ValidIndex:
	; a now contains valid index (0 to pool_size-1)
	; Reset to start of pool and add offset
	ld h, d
	ld l, e
	ld b, 0
	ld c, a
	add hl, bc
	ld a, [hl]   ; Load the random item
	
	pop de
	pop bc
	pop hl
	ret

; Route-specific randomizer functions for easy extension
GetRoute29RandomItem::
	ld hl, Route29ItemPool
	call GetRandomItemFromPool
	ld [wScriptVar], a
	ret

GetRoute30RandomItem::
	ld hl, Route30ItemPool
	call GetRandomItemFromPool
	ld [wScriptVar], a
	ret

GetRoute31RandomItem::
	ld hl, Route31ItemPool
	call GetRandomItemFromPool
	ld [wScriptVar], a
	ret

GetUnionCaveRandomItem::
	ld hl, UnionCaveItemPool
	call GetRandomItemFromPool
	ld [wScriptVar], a
	ret

GetSproutTowerRandomItem::
	ld hl, SproutTowerItemPool
	call GetRandomItemFromPool
	ld [wScriptVar], a
	ret

GetIlexForestRandomItem::
	ld hl, IlexForestItemPool
	call GetRandomItemFromPool
	ld [wScriptVar], a
	ret

; Generic function for any pool - for future expansion
; Input: hl = pool pointer
GetGenericRandomItem::
	call GetRandomItemFromPool
	ld [wScriptVar], a
	ret

; Function to give the randomized item from callasm context
; Called from script system - item is in wScriptVar
GiveRandomizedItem::
	ld a, [wScriptVar]
	ld [wCurItem], a
	ld a, 1
	ld [wItemQuantity], a
	ld hl, wNumItems
	call ReceiveItem
	ret c   ; Return if bag full
	
	; Item received successfully - show item name
	ld a, [wScriptVar]
	ld [wNamedObjectIndex], a
	call GetItemName
	ld hl, wStringBuffer1
	ld de, wStringBuffer3
	ld bc, ITEM_NAME_LENGTH
	call CopyBytes
	
	; Show received item text  
	ld hl, .ReceivedItemText
	call PrintText
	call WaitPressAorB_BlinkCursor
	ret

.ReceivedItemText:
	text "<PLAYER> found"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done