; Nuzlocke encounter tracking functions
; Uses a collision-free lookup table mapping 114 encounter maps to unique bit indices

GetNuzlockeMapIndex::
; Look up current map in the encounter map table
; Returns: a = map index (0-113), carry set if found
;          carry clear if map not in table
	ld a, [wMapGroup]
	ld d, a
	ld a, [wMapNumber]
	ld e, a
	ld hl, NuzlockeEncounterMapTable
	ld b, 0 ; index counter
.loop
	ld a, [hli]
	cp $FF
	jr z, .not_found
	cp d
	jr nz, .next
	ld a, [hl]
	cp e
	jr nz, .next
	; Found the map
	ld a, b
	scf
	ret
.next
	inc hl
	inc b
	jr .loop
.not_found
	and a ; clear carry
	ret

CheckNuzlockeEncounter::
; Check if we've already encountered a Pokemon on this map
; Returns z if no encounter yet, nz if already encountered
	call GetNuzlockeMapIndex
	jr nc, .not_encounter_map

	; a = map index (0-113)
	; Calculate byte offset (index / 8) and bit position (index & 7)
	ld b, a
	srl a
	srl a
	srl a

	; a = byte offset (0-14)
	ld hl, wNuzlockeEncounterFlags
	ld e, a
	ld d, 0
	add hl, de

	; Calculate bit position (index & 7)
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

.not_encounter_map
	; Map not in encounter table - return nz (treat as already encountered)
	or 1
	ret

SetNuzlockeEncounter::
; Mark that we've encountered a Pokemon on this map
	call GetNuzlockeMapIndex
	ret nc ; Map not in encounter table, nothing to set

	; a = map index (0-113)
	ld b, a
	srl a
	srl a
	srl a

	; a = byte offset (0-14)
	ld hl, wNuzlockeEncounterFlags
	ld e, a
	ld d, 0
	add hl, de

	; Calculate bit position (index & 7)
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
	ld bc, 15
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
	cp BATTLETYPE_FISH
	ret z
	; Check if already encountered on this map
	call CheckNuzlockeEncounter
	ret nz ; Already encountered
	; This is the first encounter
	ld a, 1
	ld [wNuzlockeFirstEncounter], a
	ret

; Lookup table of all 114 maps with wild encounters
; Each entry: db GROUP_X, MAP_X
; Terminated by $FF sentinel
NuzlockeEncounterMapTable:
; --- Johto grass maps (indices 0-60) ---
	db GROUP_SPROUT_TOWER_2F, MAP_SPROUT_TOWER_2F
	db GROUP_SPROUT_TOWER_3F, MAP_SPROUT_TOWER_3F
	db GROUP_TIN_TOWER_2F, MAP_TIN_TOWER_2F
	db GROUP_TIN_TOWER_3F, MAP_TIN_TOWER_3F
	db GROUP_TIN_TOWER_4F, MAP_TIN_TOWER_4F
	db GROUP_TIN_TOWER_5F, MAP_TIN_TOWER_5F
	db GROUP_TIN_TOWER_6F, MAP_TIN_TOWER_6F
	db GROUP_TIN_TOWER_7F, MAP_TIN_TOWER_7F
	db GROUP_TIN_TOWER_8F, MAP_TIN_TOWER_8F
	db GROUP_TIN_TOWER_9F, MAP_TIN_TOWER_9F
	db GROUP_BURNED_TOWER_1F, MAP_BURNED_TOWER_1F
	db GROUP_BURNED_TOWER_B1F, MAP_BURNED_TOWER_B1F
	db GROUP_NATIONAL_PARK, MAP_NATIONAL_PARK
	db GROUP_RUINS_OF_ALPH_OUTSIDE, MAP_RUINS_OF_ALPH_OUTSIDE
	db GROUP_RUINS_OF_ALPH_INNER_CHAMBER, MAP_RUINS_OF_ALPH_INNER_CHAMBER
	db GROUP_UNION_CAVE_1F, MAP_UNION_CAVE_1F
	db GROUP_UNION_CAVE_B1F, MAP_UNION_CAVE_B1F
	db GROUP_UNION_CAVE_B2F, MAP_UNION_CAVE_B2F
	db GROUP_SLOWPOKE_WELL_B1F, MAP_SLOWPOKE_WELL_B1F
	db GROUP_SLOWPOKE_WELL_B2F, MAP_SLOWPOKE_WELL_B2F
	db GROUP_ILEX_FOREST, MAP_ILEX_FOREST
	db GROUP_MOUNT_MORTAR_1F_OUTSIDE, MAP_MOUNT_MORTAR_1F_OUTSIDE
	db GROUP_MOUNT_MORTAR_1F_INSIDE, MAP_MOUNT_MORTAR_1F_INSIDE
	db GROUP_MOUNT_MORTAR_2F_INSIDE, MAP_MOUNT_MORTAR_2F_INSIDE
	db GROUP_MOUNT_MORTAR_B1F, MAP_MOUNT_MORTAR_B1F
	db GROUP_ICE_PATH_1F, MAP_ICE_PATH_1F
	db GROUP_ICE_PATH_B1F, MAP_ICE_PATH_B1F
	db GROUP_ICE_PATH_B2F_MAHOGANY_SIDE, MAP_ICE_PATH_B2F_MAHOGANY_SIDE
	db GROUP_ICE_PATH_B2F_BLACKTHORN_SIDE, MAP_ICE_PATH_B2F_BLACKTHORN_SIDE
	db GROUP_ICE_PATH_B3F, MAP_ICE_PATH_B3F
	db GROUP_WHIRL_ISLAND_NW, MAP_WHIRL_ISLAND_NW
	db GROUP_WHIRL_ISLAND_NE, MAP_WHIRL_ISLAND_NE
	db GROUP_WHIRL_ISLAND_SW, MAP_WHIRL_ISLAND_SW
	db GROUP_WHIRL_ISLAND_CAVE, MAP_WHIRL_ISLAND_CAVE
	db GROUP_WHIRL_ISLAND_SE, MAP_WHIRL_ISLAND_SE
	db GROUP_WHIRL_ISLAND_B1F, MAP_WHIRL_ISLAND_B1F
	db GROUP_WHIRL_ISLAND_B2F, MAP_WHIRL_ISLAND_B2F
	db GROUP_WHIRL_ISLAND_LUGIA_CHAMBER, MAP_WHIRL_ISLAND_LUGIA_CHAMBER
	db GROUP_SILVER_CAVE_ROOM_1, MAP_SILVER_CAVE_ROOM_1
	db GROUP_SILVER_CAVE_ROOM_2, MAP_SILVER_CAVE_ROOM_2
	db GROUP_SILVER_CAVE_ROOM_3, MAP_SILVER_CAVE_ROOM_3
	db GROUP_SILVER_CAVE_ITEM_ROOMS, MAP_SILVER_CAVE_ITEM_ROOMS
	db GROUP_DARK_CAVE_VIOLET_ENTRANCE, MAP_DARK_CAVE_VIOLET_ENTRANCE
	db GROUP_DARK_CAVE_BLACKTHORN_ENTRANCE, MAP_DARK_CAVE_BLACKTHORN_ENTRANCE
	db GROUP_ROUTE_29, MAP_ROUTE_29
	db GROUP_ROUTE_30, MAP_ROUTE_30
	db GROUP_ROUTE_31, MAP_ROUTE_31
	db GROUP_ROUTE_32, MAP_ROUTE_32
	db GROUP_ROUTE_33, MAP_ROUTE_33
	db GROUP_ROUTE_34, MAP_ROUTE_34
	db GROUP_ROUTE_35, MAP_ROUTE_35
	db GROUP_ROUTE_36, MAP_ROUTE_36
	db GROUP_ROUTE_37, MAP_ROUTE_37
	db GROUP_ROUTE_38, MAP_ROUTE_38
	db GROUP_ROUTE_39, MAP_ROUTE_39
	db GROUP_ROUTE_42, MAP_ROUTE_42
	db GROUP_ROUTE_43, MAP_ROUTE_43
	db GROUP_ROUTE_44, MAP_ROUTE_44
	db GROUP_ROUTE_45, MAP_ROUTE_45
	db GROUP_ROUTE_46, MAP_ROUTE_46
	db GROUP_SILVER_CAVE_OUTSIDE, MAP_SILVER_CAVE_OUTSIDE
; --- Johto water-only maps (indices 61-72) ---
	db GROUP_DRAGONS_DEN_B1F, MAP_DRAGONS_DEN_B1F
	db GROUP_OLIVINE_PORT, MAP_OLIVINE_PORT
	db GROUP_ROUTE_40, MAP_ROUTE_40
	db GROUP_ROUTE_41, MAP_ROUTE_41
	db GROUP_NEW_BARK_TOWN, MAP_NEW_BARK_TOWN
	db GROUP_CHERRYGROVE_CITY, MAP_CHERRYGROVE_CITY
	db GROUP_VIOLET_CITY, MAP_VIOLET_CITY
	db GROUP_CIANWOOD_CITY, MAP_CIANWOOD_CITY
	db GROUP_OLIVINE_CITY, MAP_OLIVINE_CITY
	db GROUP_ECRUTEAK_CITY, MAP_ECRUTEAK_CITY
	db GROUP_LAKE_OF_RAGE, MAP_LAKE_OF_RAGE
	db GROUP_BLACKTHORN_CITY, MAP_BLACKTHORN_CITY
; --- Kanto grass maps (indices 73-102) ---
	db GROUP_DIGLETTS_CAVE, MAP_DIGLETTS_CAVE
	db GROUP_MOUNT_MOON, MAP_MOUNT_MOON
	db GROUP_ROCK_TUNNEL_1F, MAP_ROCK_TUNNEL_1F
	db GROUP_ROCK_TUNNEL_B1F, MAP_ROCK_TUNNEL_B1F
	db GROUP_VICTORY_ROAD, MAP_VICTORY_ROAD
	db GROUP_TOHJO_FALLS, MAP_TOHJO_FALLS
	db GROUP_ROUTE_1, MAP_ROUTE_1
	db GROUP_ROUTE_2, MAP_ROUTE_2
	db GROUP_ROUTE_3, MAP_ROUTE_3
	db GROUP_ROUTE_4, MAP_ROUTE_4
	db GROUP_ROUTE_5, MAP_ROUTE_5
	db GROUP_ROUTE_6, MAP_ROUTE_6
	db GROUP_ROUTE_7, MAP_ROUTE_7
	db GROUP_ROUTE_8, MAP_ROUTE_8
	db GROUP_ROUTE_9, MAP_ROUTE_9
	db GROUP_ROUTE_10_NORTH, MAP_ROUTE_10_NORTH
	db GROUP_ROUTE_11, MAP_ROUTE_11
	db GROUP_ROUTE_13, MAP_ROUTE_13
	db GROUP_ROUTE_14, MAP_ROUTE_14
	db GROUP_ROUTE_15, MAP_ROUTE_15
	db GROUP_ROUTE_16, MAP_ROUTE_16
	db GROUP_ROUTE_17, MAP_ROUTE_17
	db GROUP_ROUTE_18, MAP_ROUTE_18
	db GROUP_ROUTE_21, MAP_ROUTE_21
	db GROUP_ROUTE_22, MAP_ROUTE_22
	db GROUP_ROUTE_24, MAP_ROUTE_24
	db GROUP_ROUTE_25, MAP_ROUTE_25
	db GROUP_ROUTE_26, MAP_ROUTE_26
	db GROUP_ROUTE_27, MAP_ROUTE_27
	db GROUP_ROUTE_28, MAP_ROUTE_28
; --- Kanto water-only maps (indices 103-113) ---
	db GROUP_VERMILION_PORT, MAP_VERMILION_PORT
	db GROUP_ROUTE_12, MAP_ROUTE_12
	db GROUP_ROUTE_19, MAP_ROUTE_19
	db GROUP_ROUTE_20, MAP_ROUTE_20
	db GROUP_PALLET_TOWN, MAP_PALLET_TOWN
	db GROUP_VIRIDIAN_CITY, MAP_VIRIDIAN_CITY
	db GROUP_CERULEAN_CITY, MAP_CERULEAN_CITY
	db GROUP_VERMILION_CITY, MAP_VERMILION_CITY
	db GROUP_CELADON_CITY, MAP_CELADON_CITY
	db GROUP_FUCHSIA_CITY, MAP_FUCHSIA_CITY
	db GROUP_CINNABAR_ISLAND, MAP_CINNABAR_ISLAND
	db $FF ; sentinel
