#!/usr/bin/env python3
"""
Post-build verification: ensures critical ROM sections and symbols are in
their expected banks.

The linker can silently move floating ROMX sections when bank space is tight,
or when a stray SECTION directive inside an INCLUDEd file accidentally absorbs
subsequent code into a new section. If a function that's called via intra-bank
`call` ends up in the wrong bank, the call jumps to whatever data lives at
that address — usually causing a hard crash.

This script catches both failure modes:
  1. Named sections placed in the wrong bank.
  2. Specific symbols ending up in the wrong bank.

Usage: python3 tools/verify_bank_layout.py CrystalAdventures.map
"""

import re
import sys

# Critical section -> required bank mappings.
# Add new entries here when a section MUST stay in a specific bank.
REQUIRED_BANK_ASSIGNMENTS = {
    "Goldenrod Dept Store Marts": 3,  # Battle engine in bank3 makes intra-bank calls into this section
}

# Critical SYMBOL -> required bank mappings.
# These functions are called by intra-bank `call` (not `farcall`) from code in
# the listed bank, so they MUST live in the same bank as their caller. If a
# SECTION directive accidentally moves them, the call jumps to garbage data.
#
# All of these were originally placed by main.asm's `SECTION "bank4", ROMX`
# block. pack.asm (bank 4) uses plain `call TryGiveItemToPartymon` to reach
# mon_menu.asm's give-item code, so the entire chain must stay together.
REQUIRED_SYMBOL_BANKS = {
    "GiveItem": 4,                # pack.asm — anchors bank 4
    "TryGiveItemToPartymon": 4,   # called by `call` from pack.asm GiveItem
    "GivePartyItem": 4,           # called by `call` from TryGiveItemToPartymon
    "GiveItemToPokemon": 4,       # called by `call` from TryGiveItemToPartymon
    "PartyMonItemName": 4,        # called by `call` from TryGiveItemToPartymon
    "GiveTakePartyMonItem": 4,    # called from PokemonActionSubmenu jumptable
    "PokemonActionSubmenu": 4,    # called by `call` from StartMenu_Pokemon
    "StartMenu_Pokemon": 4,       # start_menu.asm entry — anchors menu code
}

SECTION_HEADER_RE = re.compile(r'\s+SECTION: \$[0-9a-fA-F]+-\$[0-9a-fA-F]+.*\["(.+?)"\]')
BANK_HEADER_RE = re.compile(r'ROMX bank #(\d+):')
SYMBOL_RE = re.compile(r'\s+\$([0-9a-fA-F]+) = (\S+)$')


def parse_map(map_path):
    """Parse the .map file and return (section_to_bank, symbol_to_bank)."""
    sections = {}
    symbols = {}
    current_bank = None
    with open(map_path) as f:
        for line in f:
            m = BANK_HEADER_RE.match(line)
            if m:
                current_bank = int(m.group(1))
                continue
            m = SECTION_HEADER_RE.match(line)
            if m and current_bank is not None:
                sections[m.group(1)] = current_bank
                continue
            m = SYMBOL_RE.match(line)
            if m and current_bank is not None:
                # Don't overwrite if symbol appears multiple times (use first occurrence)
                symbols.setdefault(m.group(2), current_bank)
    return sections, symbols


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <map_file>", file=sys.stderr)
        sys.exit(1)

    map_path = sys.argv[1]
    sections, symbols = parse_map(map_path)

    errors = 0

    for section_name, required_bank in REQUIRED_BANK_ASSIGNMENTS.items():
        actual_bank = sections.get(section_name)
        if actual_bank is None:
            print(f"ERROR: Section \"{section_name}\" not found in {map_path}")
            errors += 1
        elif actual_bank != required_bank:
            print(f"ERROR: Section \"{section_name}\" is in bank #{actual_bank}, "
                  f"but MUST be in bank #{required_bank}!")
            print(f"  This will cause crashes. The section likely grew too large.")
            print(f"  Move new code to a separate SECTION in another bank.")
            errors += 1
        else:
            print(f"OK: section \"{section_name}\" is in bank #{actual_bank}")

    for symbol, required_bank in REQUIRED_SYMBOL_BANKS.items():
        actual_bank = symbols.get(symbol)
        if actual_bank is None:
            print(f"ERROR: Symbol {symbol} not found in {map_path}")
            errors += 1
        elif actual_bank != required_bank:
            print(f"ERROR: Symbol {symbol} is in bank #{actual_bank}, "
                  f"but MUST be in bank #{required_bank}!")
            print(f"  Intra-bank `call {symbol}` from bank #{required_bank} "
                  f"will jump to garbage data and crash.")
            print(f"  Likely cause: a stray SECTION directive inside an INCLUDEd")
            print(f"  file absorbed subsequent code into a new floating section.")
            print(f"  Fix: wrap the offending SECTION in PUSHS/POPS so it doesn't")
            print(f"  leak into the next INCLUDE.")
            errors += 1
        else:
            print(f"OK: symbol {symbol} is in bank #{actual_bank}")

    if errors:
        print(f"\n{errors} bank layout error(s) detected! Build is broken.")
        sys.exit(1)
    else:
        print("\nAll critical sections and symbols are in their correct banks.")
        sys.exit(0)


if __name__ == "__main__":
    main()
