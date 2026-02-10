	object_const_def
	const RUINSOFALPHOMANYTEITEMROOM_POKE_BALL1
	const RUINSOFALPHOMANYTEITEMROOM_POKE_BALL2
	const RUINSOFALPHOMANYTEITEMROOM_POKE_BALL3
	const RUINSOFALPHOMANYTEITEMROOM_POKE_BALL4

RuinsOfAlphOmanyteItemRoom_MapScripts:
	def_scene_scripts

	def_callbacks

RuinsOfAlphOmanyteItemRoomMysteryberry:
	randomized_item_5 MYSTERYBERRY, MIRACLEBERRY, GOLD_BERRY, MAX_ELIXER, PP_UP

RuinsOfAlphOmanyteItemRoomMysticWater:
	randomized_item_5 TWISTEDSPOON, MYSTIC_WATER, MAGNET, CHARCOAL, MIRACLE_SEED

RuinsOfAlphOmanyteItemRoomStardust:
	randomized_item_5 NUGGET, STAR_PIECE, BIG_PEARL, BIG_MUSHROOM, RARE_CANDY

RuinsOfAlphOmanyteItemRoomStarPiece:
	randomized_item_5 MIRACLEBERRY, GOLD_BERRY, FULL_RESTORE, BERRY_JUICE, ELIXER

RuinsOfAlphOmanyteItemRoomAncientReplica:
	jumptext RuinsOfAlphOmanyteItemRoomAncientReplicaText

RuinsOfAlphOmanyteItemRoomAncientReplicaText:
	text "It's a replica of"
	line "an ancient #-"
	cont "MON."
	done

RuinsOfAlphOmanyteItemRoom_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  9, RUINS_OF_ALPH_OMANYTE_CHAMBER, 5
	warp_event  4,  9, RUINS_OF_ALPH_OMANYTE_CHAMBER, 5
	warp_event  3,  1, RUINS_OF_ALPH_OMANYTE_WORD_ROOM, 1
	warp_event  4,  1, RUINS_OF_ALPH_OMANYTE_WORD_ROOM, 2

	def_coord_events

	def_bg_events
	bg_event  2,  1, BGEVENT_READ, RuinsOfAlphOmanyteItemRoomAncientReplica
	bg_event  5,  1, BGEVENT_READ, RuinsOfAlphOmanyteItemRoomAncientReplica

	def_object_events
	object_event  2,  6, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphOmanyteItemRoomMysteryberry, EVENT_PICKED_UP_MYSTERYBERRY_FROM_OMANYTE_ITEM_ROOM
	object_event  5,  6, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphOmanyteItemRoomMysticWater, EVENT_PICKED_UP_MYSTIC_WATER_FROM_OMANYTE_ITEM_ROOM
	object_event  2,  4, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphOmanyteItemRoomStardust, EVENT_PICKED_UP_STARDUST_FROM_OMANYTE_ITEM_ROOM
	object_event  5,  4, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RuinsOfAlphOmanyteItemRoomStarPiece, EVENT_PICKED_UP_STAR_PIECE_FROM_OMANYTE_ITEM_ROOM
