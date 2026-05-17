	object_const_def
	const SLOWPOKEWELLB2F_POKE_BALL1
	const SLOWPOKEWELLB2F_POKE_BALL2

SlowpokeWellB2F_MapScripts:
	def_scene_scripts

	def_callbacks

SlowpokeWellB2FItem1:
	randomized_item_5 KINGS_ROCK, MYSTIC_WATER, WATER_STONE, RARE_CANDY, NUGGET

SlowpokeWellB2FItem2:
	randomized_item_5 TM_RAIN_DANCE, TM_ICY_WIND, KINGS_ROCK, MYSTIC_WATER, NUGGET

SlowpokeWellB2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9, 11, SLOWPOKE_WELL_B1F, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  5,  4, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SlowpokeWellB2FItem1, EVENT_GOT_KINGS_ROCK_IN_SLOWPOKE_WELL
	object_event 15,  5, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, SlowpokeWellB2FItem2, EVENT_SLOWPOKE_WELL_B2F_TM_RAIN_DANCE
