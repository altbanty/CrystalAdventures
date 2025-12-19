# Kyle's Dynamic Trade System - Technical Documentation

## Overview

This document explains the implementation of Kyle's randomized trade system in Violet City, which offers 30 possible trade combinations while using only 1 byte of save RAM. This approach bypasses the WRAMX memory constraints that would normally prevent adding multiple NPC trade entries.

## The Problem: WRAMX Memory Overflow

### Original Approach: Multiple Trade Entries

The naive approach to randomized trades would be adding multiple entries to the `NPCTrades` table:

```asm
; This approach FAILS due to memory constraints
npctrade TRADE_DIALOGSET_COLLECTOR, BELLSPROUT, ONIX, ...
npctrade TRADE_DIALOGSET_COLLECTOR, BELLSPROUT, GEODUDE, ...
npctrade TRADE_DIALOGSET_COLLECTOR, RATTATA, ONIX, ...
; ... 30 entries total
```

### Why It Fails: The wTradeFlags Array

The game tracks trade completion using `wTradeFlags` in save RAM:

```asm
; wram.asm
wTradeFlags:: flag_array NUM_NPC_TRADES
```

The `flag_array` macro allocates bytes based on trade count:

```asm
; macros/wram.asm
flag_array: MACRO
    ds ((\1) + 7) / 8
ENDM
```

**Size calculation:**
| NUM_NPC_TRADES | Bytes Required |
|----------------|----------------|
| 1-8 trades     | 1 byte         |
| 9-16 trades    | 2 bytes        |
| 17-24 trades   | 3 bytes        |

### The Memory Boundary

The "Party" section in WRAMX Bank 1 (`$D000-$DFFF`) contains all persistent save data. Before our changes:

```
wTradeFlags   = $D96B (1 byte for 7 trades)
[padding]     = $D96C (1 byte)
wGameDataEnd  = $E000 (exactly at WRAMX boundary)
```

**The section uses exactly all 4KB of WRAMX Bank 1.** Any additional bytes cause:

```
error: layout.link: Sections would extend past the end of WRAMX ($e001 > $dfff)
```

Adding 30 trade variants would require:
- 7 original + 30 new = 37 trades
- `flag_array(37)` = 5 bytes
- **4 bytes over the limit**

## The Solution: Dynamic Trade Generation

Instead of multiple trade entries, we use a single entry with runtime species selection.

### Memory Layout (After Implementation)

```
wTradeFlags        = $D96B (1 byte - still 7 trades)
wKyleTradeVariant  = $D96C (1 byte - repurposed padding)
wGameDataEnd       = $E000 (unchanged - still fits!)
```

**Total additional memory used: 0 bytes** (repurposed existing padding)

### The wKyleTradeVariant Byte

A single byte encodes the random selection:

```
Bit 7:     Initialized flag (1 = variant has been set)
Bits 5-3:  Requested species index (0-4)
Bits 2-0:  Offered species index (0-5)
```

Example values:
| Value  | Binary     | Meaning                    |
|--------|------------|----------------------------|
| `$00`  | `00000000` | Uninitialized              |
| `$80`  | `10000000` | Bellsprout (0) → Onix (0)  |
| `$89`  | `10001001` | Rattata (1) → Geodude (1)  |
| `$BD`  | `10111101` | Sunkern (4) → Wooper (5)   |

### ROM Lookup Tables

Species and nicknames are stored in ROM (no RAM cost):

```asm
; Sprout Tower Pokemon (requested from player) - 5 options
KyleRequestedSpecies:
    db BELLSPROUT   ; 0
    db RATTATA      ; 1
    db HOOTHOOT     ; 2
    db GASTLY       ; 3
    db SUNKERN      ; 4

; Union Cave Pokemon (offered to player) - 6 options
KyleOfferedSpecies:
    db ONIX         ; 0
    db GEODUDE      ; 1
    db CUBONE       ; 2
    db SLUGMA       ; 3
    db SANDSHREW    ; 4
    db WOOPER       ; 5

; Nicknames (11 bytes each)
KyleNicknames:
    db "ROCKY@@@@@@"     ; Onix
    db "BOULDER@@@@"     ; Geodude
    db "SKULLY@@@@@"     ; Cubone
    db "MAGGY@@@@@@"     ; Slugma
    db "DIGGER@@@@@"     ; Sandshrew
    db "WHOOPER@@@@"     ; Wooper
```

## Implementation Details

### Modified GetTradeAttr Function

The core trade engine function `GetTradeAttr` is modified to intercept Kyle's trade:

```asm
GetTradeAttr:
    ld d, 0
    push de
    ; Check if this is Kyle's dynamic trade
    ld a, [wJumptableIndex]
    cp NPC_TRADE_KYLE
    jr nz, .normal_trade

    ; Kyle's trade - ensure variant is initialized
    call EnsureKyleTradeVariantInitialized

    ; Check which attribute is being requested
    pop de
    push de
    ld a, e
    cp NPCTRADE_GIVEMON
    jr z, .kyle_givemon
    cp NPCTRADE_GETMON
    jr z, .kyle_getmon
    cp NPCTRADE_NICKNAME
    jr z, .kyle_nickname
    jr .kyle_base_entry    ; Other attrs use base entry
```

### Dynamic Attribute Returns

For each intercepted attribute, the function returns a pointer to the appropriate ROM data:

**NPCTRADE_GIVEMON (requested species):**
```asm
.kyle_givemon:
    ld a, [wKyleTradeVariant]
    and %00111000      ; mask bits 3-5
    rrca
    rrca
    rrca               ; shift right by 3
    ld e, a
    ld d, 0
    ld hl, KyleRequestedSpecies
    add hl, de         ; hl = &KyleRequestedSpecies[index]
    pop de
    ret
```

**NPCTRADE_GETMON (offered species):**
```asm
.kyle_getmon:
    ld a, [wKyleTradeVariant]
    and %00000111      ; mask bits 0-2
    ld e, a
    ld d, 0
    ld hl, KyleOfferedSpecies
    add hl, de         ; hl = &KyleOfferedSpecies[index]
    pop de
    ret
```

**NPCTRADE_NICKNAME:**
```asm
.kyle_nickname:
    ld a, [wKyleTradeVariant]
    and %00000111      ; index 0-5
    ld e, a
    ld d, 0
    ld hl, KyleNicknames
    ; Multiply index by 11 (MON_NAME_LENGTH)
    add hl, de         ; ×1
    add hl, de         ; ×2
    ; ... (repeated 11 times total)
    add hl, de         ; ×11
    pop de
    ret
```

### Variant Initialization

On first interaction, the variant is randomly generated:

```asm
EnsureKyleTradeVariantInitialized:
    ld a, [wKyleTradeVariant]
    bit 7, a
    ret nz             ; Already initialized

    push de
    ; Random 0-5 for offered species
    ld a, 6
    call RandomRange   ; Returns 0-5 in a
    ld d, a

    ; Random 0-4 for requested species
    ld a, 5
    call RandomRange   ; Returns 0-4 in a

    ; Combine: (requested << 3) | offered | 0x80
    rlca
    rlca
    rlca               ; Shift left by 3
    or d               ; Combine with offered
    or %10000000       ; Set initialized flag
    ld [wKyleTradeVariant], a
    pop de
    ret
```

### Base Entry Fallback

For attributes not overridden (DVs, held item, OT name, etc.), the original Kyle entry in NPCTrades is used:

```asm
.kyle_base_entry:
    pop de
    push de
    ld a, NPC_TRADE_KYLE
    ; Falls through to normal_trade...
```

## Control Flow

```
Player talks to Kyle
        ↓
Kyle script: "trade NPC_TRADE_KYLE"
        ↓
NPCTrade:: called
        ↓
Trade_GetDialog → GetTradeAttr(NPCTRADE_DIALOG)
        ↓
GetTradeAttr checks: Is this Kyle's trade?
        ↓ YES
EnsureKyleTradeVariantInitialized
        ↓
wKyleTradeVariant == 0? → RandomRange × 2 → Store with bit 7 set
        ↓
NPCTRADE_DIALOG requested → Return base Kyle entry (not overridden)
        ↓
PrintTradeText → GetTradeMonNames
        ↓
GetTradeAttr(NPCTRADE_GETMON) → Return KyleOfferedSpecies[bits 0-2]
GetTradeAttr(NPCTRADE_GIVEMON) → Return KyleRequestedSpecies[bits 3-5]
        ↓
Trade proceeds with dynamic species names displayed
        ↓
DoNPCTrade → GetTradeAttr for species, nickname, DVs, item, etc.
        ↓
Trade completes, wTradeFlags bit set for NPC_TRADE_KYLE
```

## Comparison: Multiple Entries vs Dynamic Generation

| Aspect | Multiple Entries | Dynamic Generation |
|--------|------------------|-------------------|
| Trade variants | 30 entries | 1 entry + lookup |
| wTradeFlags size | 5 bytes (+4) | 1 byte (unchanged) |
| Additional save RAM | 4 bytes (overflow!) | 0 bytes (reused padding) |
| ROM space | ~960 bytes (30×32) | ~100 bytes (tables + code) |
| Code complexity | Simple | Moderate |
| WRAMX overflow | YES | NO |

## Files Modified

| File | Changes |
|------|---------|
| `wram.asm` | Added `wKyleTradeVariant` (repurposed padding byte) |
| `engine/events/npc_trade.asm` | Modified `GetTradeAttr`, added initialization and lookup tables |
| `constants/npc_trade_constants.asm` | Updated comment for NPC_TRADE_KYLE |
| `data/events/npc_trades.asm` | Added comment noting dynamic behavior |
| `maps/VioletKylesHouse.asm` | Simplified Kyle script |
| `constants/event_flags.asm` | Removed unused variant selection flags |
| `data/wild/non_wildmon_locations.asm` | Removed extra location entry |

## Persistence Behavior

- **Same save file:** Trade variant stays constant (bit 7 prevents re-randomization)
- **New game:** `wKyleTradeVariant` initialized to 0, new random variant on first talk
- **Trade completion:** Tracked in `wTradeFlags` bit for `NPC_TRADE_KYLE`

## Possible Extensions

This pattern could be applied to other NPCs to add variety without memory cost:
1. Add a variant byte (find/repurpose padding in save RAM)
2. Create ROM lookup tables for species/nicknames
3. Intercept in `GetTradeAttr` with similar logic

The limiting factor is finding available bytes in the save RAM section, not the number of variants (which are stored in ROM).
