; Pokémon traded from RBY do not have held items, so GSC usually interprets the
; catch rate as an item. However, if the catch rate appears in this table, the
; item associated with the table entry is used instead.
; The first byte of each pair is the raw catch rate value from Gen 1.

TimeCapsule_CatchRateItems:
	db $19, LEFTOVERS
	db $2d, BITTER_BERRY
	db $32, GOLD_BERRY
	db $5a, BERRY
	db $64, BERRY
	db $78, BERRY
	db $87, BERRY
	db $be, BERRY
	db $c3, BERRY
	db $dc, BERRY
	db $fa, BERRY
	db -1,  BERRY
	db 0 ; end
