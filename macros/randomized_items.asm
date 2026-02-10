; Randomized Item System Macros
; Each macro picks one item at random from the pool and gives it to the player.
; Uses a shared assembly function (PickRandomItems) to select the item
; and a shared script (GiveRandomItemScript) to present and give it.
; Total per-instance cost: callasm(4) + count+items(N+1) + farsjump(4) bytes.

; 3-item randomized item script
randomized_item_3: MACRO
	callasm PickRandomItems
	db 3, \1, \2, \3
	farsjump GiveRandomItemScript
ENDM

; 4-item randomized item script
randomized_item_4: MACRO
	callasm PickRandomItems
	db 4, \1, \2, \3, \4
	farsjump GiveRandomItemScript
ENDM

; 5-item randomized item script
randomized_item_5: MACRO
	callasm PickRandomItems
	db 5, \1, \2, \3, \4, \5
	farsjump GiveRandomItemScript
ENDM
