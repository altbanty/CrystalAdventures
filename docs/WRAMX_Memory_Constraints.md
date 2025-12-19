# WRAMX Memory Constraints and Trade Flags Array

## Overview

This document explains the memory constraints encountered when implementing randomized NPC trades for Kyle in Violet City, specifically regarding the WRAMX memory bank and the `wTradeFlags` array.

## Game Boy Color Memory Architecture

The Game Boy Color has a limited memory architecture with specific constraints:

### WRAMX (Work RAM Extended)
- **Location**: Bank-switchable RAM from `$D000` to `$DFFF`
- **Size per bank**: 4KB (4,096 bytes)
- **Banks**: 8 banks (0-7), though bank 0 is mapped separately as WRAM0

In Pokemon Crystal Legacy, **WRAMX Bank 1** (`$D000-$DFFF`) contains critical game state data including:
- String buffers
- Battle menu data
- Party cursor positions
- Enemy party data
- **Player's party and save data** (the "Party" section)

## The Party Section

The "Party" section in `wram.asm` contains all persistent game data that gets saved, including:

```
wram.asm:3281  SECTION "Party", WRAMX
```

This section includes:
- Player's party Pokemon (6 slots)
- Pokemon nicknames and OT data
- Player name, ID, money, badges
- Event flags and scene IDs
- Box data pointers
- **Trade completion flags (`wTradeFlags`)**
- Roaming Pokemon data
- Various game state variables

### Current Memory Usage

Based on the compiled symbol map:
```
wTradeFlags   = $D96B (in WRAMX bank 1)
wGameDataEnd  = $E000 (exactly at WRAMX boundary)
```

The "Party" section currently uses **exactly** all available space in WRAMX bank 1, ending precisely at `$DFFF` (the last valid byte before `$E000`).

## The Trade Flags Array

### Definition

Located in `wram.asm:3004`:
```asm
wTradeFlags:: flag_array NUM_NPC_TRADES
```

### The `flag_array` Macro

Defined in `macros/wram.asm:3-5`:
```asm
flag_array: MACRO
    ds ((\1) + 7) / 8
ENDM
```

This macro allocates enough bytes to store N individual bit flags:
- **Formula**: `ceiling(N / 8)` bytes
- Each trade needs 1 bit to track if it has been completed
- 8 bits fit in 1 byte

### Size Calculation Examples

| NUM_NPC_TRADES | Calculation | Bytes Required |
|----------------|-------------|----------------|
| 1-8 trades     | (8+7)/8 = 1 | **1 byte**     |
| 9-16 trades    | (16+7)/8 = 2| **2 bytes**    |
| 17-24 trades   | (24+7)/8 = 3| **3 bytes**    |

### Current State (8 trades)

With the current 8 NPC trades:
- `NUM_NPC_TRADES = 8`
- `flag_array` allocates: `(8 + 7) / 8 = 1 byte`

The 8 trades are:
1. Mike (Goldenrod) - Abra for Machop
2. Kyle (Violet) - Bellsprout for Onix (legacy, used for randomization option 1)
3. Tim (Olivine) - Krabby for Voltorb
4. Emy (Blackthorn) - Dodrio for Mr. Mime
5. Chris (Pewter) - Xatu for Haunter
6. Kim (Route 14) - Chansey for Aerodactyl
7. Forest (Power Plant) - Dugtrio for Magneton
8. Kyle variant (Violet) - Rattata for Geodude (randomization option 2)

## Why 4 Trade Variants Would Overflow

### The Problem

Adding 4 Kyle trade variants would mean:
- Original 7 trades + 4 new variants = **11 total trades**
- `flag_array(11)` = `(11 + 7) / 8 = 2 bytes`

This adds **1 extra byte** to the "Party" section.

### Memory Overflow

When attempting to build with 11 trades:
```
error: layout.link(339): Sections would extend past the end of WRAMX ($e001 > $dfff)
```

The section would need to extend to `$E001`, but WRAMX bank 1 ends at `$DFFF`. Even 1 byte over is a fatal error.

### Progressive Reduction Attempts

| Variants | Total Trades | flag_array Size | Result |
|----------|--------------|-----------------|--------|
| 30       | 37           | 5 bytes         | $E004 > $DFFF (5 over) |
| 16       | 23           | 3 bytes         | $E002 > $DFFF (3 over) |
| 4        | 11           | 2 bytes         | $E001 > $DFFF (1 over) |
| 1        | 8            | 1 byte          | $E000 = $DFFF (fits!) |

## Is Expanding to 4 Trades Realistically Possible?

### Short Answer: Yes, but it requires freeing 1 byte elsewhere.

### Options to Free Memory

#### Option 1: Remove an Existing NPC Trade
If one of the existing 7 trades is deemed unnecessary, removing it would allow:
- 6 original + 4 Kyle variants = 10 trades
- `flag_array(10)` = 2 bytes
- **Still 1 byte over** (same as 11 trades)

This doesn't help because 9-16 trades all require 2 bytes.

#### Option 2: Remove 2 Existing NPC Trades
Removing 2 trades would allow:
- 5 original + 4 Kyle variants = 9 trades
- `flag_array(9)` = 2 bytes
- **Still 1 byte over**

#### Option 3: Find 1 Byte to Remove Elsewhere in the Party Section

The Party section contains many data fields. Potential candidates:
- `ds 1` padding bytes after various fields
- Unused or deprecated variables
- Scene ID bytes for unused features

If **any single byte** could be removed or repurposed elsewhere in the Party section, 4 trade variants would fit.

#### Option 4: Reduce Kyle Variants to 3

With 3 Kyle variants:
- 7 original + 3 variants = 10 trades
- Still requires 2 bytes
- **Still overflows by 1 byte**

The critical threshold is 8 trades (1 byte) vs 9+ trades (2 bytes).

#### Option 5: Use the Legacy Kyle Trade Slot

The current implementation already does this optimally:
- Uses `NPC_TRADE_KYLE` (index 1) for Bellsprout -> Onix
- Adds only 1 new entry for Rattata -> Geodude
- Total: 8 trades = 1 byte

### Recommended Approach for 4 Variants

To support 4 Kyle trade variants, you would need to:

1. **Audit the Party section** in `wram.asm` (lines 2706-3373) for:
   - Any `ds 1` padding that could be removed
   - Deprecated mobile/link features that are never used
   - Unused scene IDs or state variables

2. **Check for unused bytes** in the symbol map:
   ```bash
   grep "01:d" CrystalAdventures.sym | sort
   ```

3. **Remove exactly 1 byte** from the Party section

4. **Add 3 more Kyle trade variants** (bringing total to 4)

### Technical Implementation for 4 Variants

If 1 byte is freed, the changes would be:

**constants/npc_trade_constants.asm:**
```asm
const NPC_TRADE_KYLE_BELLSPROUT_GEODUDE   ; 7
const NPC_TRADE_KYLE_RATTATA_ONIX         ; 8
const NPC_TRADE_KYLE_RATTATA_GEODUDE      ; 9
; Total: 10 trades (uses NPC_TRADE_KYLE for Bellsprout->Onix)
```

Wait - this would still be 10 trades = 2 bytes = overflow.

**The only way to have 4 variants within 1 byte** is to:
- Remove 3 of the original 7 trades, OR
- Completely replace the legacy Kyle trade (making it one of the 4 variants)

If we replace the legacy Kyle slot entirely:
- Remove NPC_TRADE_KYLE from being a real trade entry
- Use indices 1, 7, 8, 9 for the 4 Kyle variants
- But this breaks the table structure...

### Conclusion

**Realistically, expanding to 4 trade variants is very difficult** because:

1. The memory is at exactly 0 bytes free
2. Going from 8 to 9+ trades requires 1 extra byte
3. Finding 1 byte to remove in the Party section requires careful analysis to avoid breaking save compatibility or game functionality
4. The Party section data is all actively used for saves

**The current 2-variant solution** (Bellsprout->Onix OR Rattata->Geodude) is the maximum that fits within existing memory constraints without modifying other parts of the codebase.

## Files Referenced

- `wram.asm` - WRAM definitions including wTradeFlags
- `macros/wram.asm` - flag_array macro definition
- `layout.link` - Memory section layout
- `constants/npc_trade_constants.asm` - Trade constant definitions
- `data/events/npc_trades.asm` - Trade data entries
