; Randomized Item System Macros
; Provides maintainable randomization for overworld items

; 3-item randomized item script (most common)
randomized_item_3: MACRO
	random 3
	ifequal 0, .Give\@Item1
	ifequal 1, .Give\@Item2
	ifequal 2, .Give\@Item3

.Give\@Item1:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \1, 1
	closetext
	disappear LAST_TALKED
	end

.Give\@Item2:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \2, 1
	closetext
	disappear LAST_TALKED
	end

.Give\@Item3:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \3, 1
	closetext
	disappear LAST_TALKED
	end

.Found\@ItemText:
	text "You found an item!"
	done
ENDM

; 4-item randomized item script
randomized_item_4: MACRO
	random 4
	ifequal 0, .Give\@Item1
	ifequal 1, .Give\@Item2
	ifequal 2, .Give\@Item3
	ifequal 3, .Give\@Item4
	; Fallback - should never reach here, but just in case
	sjump .Give\@Item1

.Give\@Item1:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \1, 1
	closetext
	disappear LAST_TALKED
	end

.Give\@Item2:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \2, 1
	closetext
	disappear LAST_TALKED
	end

.Give\@Item3:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \3, 1
	closetext
	disappear LAST_TALKED
	end

.Give\@Item4:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \4, 1
	closetext
	disappear LAST_TALKED
	end

.Found\@ItemText:
	text "You found an item!"
	done
ENDM

; 5-item randomized item script
randomized_item_5: MACRO
	random 5
	ifequal 0, .Give\@Item1
	ifequal 1, .Give\@Item2
	ifequal 2, .Give\@Item3
	ifequal 3, .Give\@Item4
	ifequal 4, .Give\@Item5
	; Fallback - should never reach here, but just in case
	sjump .Give\@Item1

.Give\@Item1:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \1, 1
	closetext
	disappear LAST_TALKED
	end

.Give\@Item2:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \2, 1
	closetext
	disappear LAST_TALKED
	end

.Give\@Item3:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \3, 1
	closetext
	disappear LAST_TALKED
	end

.Give\@Item4:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \4, 1
	closetext
	disappear LAST_TALKED
	end

.Give\@Item5:
	opentext
	writetext .Found\@ItemText
	waitbutton
	verbosegiveitem \5, 1
	closetext
	disappear LAST_TALKED
	end

.Found\@ItemText:
	text "You found an item!"
	done
ENDM