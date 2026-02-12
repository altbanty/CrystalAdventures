#!/usr/bin/env python3
"""
Update Pokemon base stats files to add Phase 2 Gen 1 TM learnsets (TM78-TM83).

The 6 new TMs:
  TM78 = RAGE           TM79 = BIDE           TM80 = RAZOR_WIND
  TM81 = SKULL_BASH     TM82 = BUBBLEBEAM     TM83 = WATER_GUN
"""

import os
import re

BASE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                        "data", "pokemon", "base_stats")

NEW_TM_MOVES = ["RAGE", "BIDE", "RAZOR_WIND", "SKULL_BASH", "BUBBLEBEAM", "WATER_GUN"]

# Gen 1 TM compatibility for these moves (from RBY):
# TM20=Rage (nearly everything), TM34=Bide (nearly everything),
# TM02=Razor Wind, TM40=Skull Bash
# Bubblebeam and Water Gun were NOT Gen 1 TMs (they were level-up moves)
# But we're adding them as TMs, so we design learnsets for them

# Rage (TM20 in Gen 1): Almost every Pokemon could learn it
# Bide (TM34 in Gen 1): Almost every Pokemon could learn it
# These two were extremely widely distributed in Gen 1

# For simplicity and accuracy:
# - Rage: Give to all Pokemon that had it in Gen 1 (nearly all except some)
# - Bide: Give to all Pokemon that had it in Gen 1 (nearly all except some)
# - Razor Wind: Give to Pokemon that had TM02 in Gen 1
# - Skull Bash: Give to Pokemon that had TM40 in Gen 1
# - Bubblebeam: Give to Water types and those that naturally learn water moves
# - Water Gun: Give to Water types and those that naturally learn water moves

# Pokemon that could NOT learn Rage in Gen 1:
RAGE_EXCLUDE = {
    "caterpie", "metapod", "weedle", "kakuna", "magikarp", "ditto",
    "unown", "smeargle", "wobbuffet",
}

# Pokemon that could NOT learn Bide in Gen 1:
BIDE_EXCLUDE = {
    "caterpie", "metapod", "weedle", "kakuna", "magikarp", "ditto",
    "unown", "smeargle", "wobbuffet",
}

# Pokemon that could learn Razor Wind (TM02) in Gen 1:
RAZOR_WIND_GEN1 = {
    "bulbasaur", "ivysaur", "venusaur", "charmander", "charmeleon", "charizard",
    "butterfree", "beedrill", "pidgey", "pidgeotto", "pidgeot",
    "spearow", "fearow", "zubat", "golbat",
    "oddish", "gloom", "vileplume", "venonat", "venomoth",
    "farfetch_d", "scyther",
    "bellsprout", "weepinbell", "victreebel",
    "tangela", "doduo", "dodrio",
    "articuno", "zapdos", "moltres",
    "aerodactyl", "dragonite", "mew",
}
# Gen 2 additions for Razor Wind:
RAZOR_WIND_GEN2 = {
    "chikorita", "bayleef", "meganium",
    "hoothoot", "noctowl", "crobat",
    "ledyba", "ledian", "yanma",
    "togetic", "natu", "xatu",
    "murkrow", "gligar", "skarmory",
    "delibird", "mantine",
    "lugia", "ho_oh", "celebi",
    "hoppip", "skiploom", "jumpluff",
    "bellossom", "sunflora", "sunkern",
}

# Pokemon that could learn Skull Bash (TM40) in Gen 1:
SKULL_BASH_GEN1 = {
    "bulbasaur", "ivysaur", "venusaur",
    "charmander", "charmeleon", "charizard",
    "squirtle", "wartortle", "blastoise",
    "rattata", "raticate", "nidoran_f", "nidorina", "nidoqueen",
    "nidoran_m", "nidorino", "nidoking",
    "pikachu", "raichu", "sandshrew", "sandslash",
    "clefairy", "clefable", "jigglypuff", "wigglytuff",
    "psyduck", "golduck", "poliwag", "poliwhirl", "poliwrath",
    "slowpoke", "slowbro",
    "seel", "dewgong", "shellder", "cloyster",
    "krabby", "kingler", "cubone", "marowak",
    "lickitung", "rhyhorn", "rhydon", "chansey",
    "kangaskhan", "horsea", "seadra", "goldeen", "seaking",
    "staryu", "starmie", "tauros",
    "lapras", "eevee", "vaporeon", "jolteon", "flareon",
    "omanyte", "omastar", "kabuto", "kabutops",
    "snorlax", "dratini", "dragonair", "dragonite",
    "mew",
}
# Gen 2 additions for Skull Bash:
SKULL_BASH_GEN2 = {
    "chikorita", "bayleef", "meganium",
    "totodile", "croconaw", "feraligatr",
    "sentret", "furret", "marill", "azumarill",
    "wooper", "quagsire", "slowking",
    "pichu", "cleffa", "igglybuff",
    "teddiursa", "ursaring", "swinub", "piloswine",
    "corsola", "remoraid", "octillery",
    "mantine", "phanpy", "donphan",
    "miltank", "blissey",
    "larvitar", "pupitar", "tyranitar",
    "lugia", "suicune",
}

# Water types and Pokemon that naturally learn water moves for Bubblebeam/Water Gun:
WATER_POKEMON = {
    "squirtle", "wartortle", "blastoise",
    "psyduck", "golduck", "poliwag", "poliwhirl", "poliwrath",
    "tentacool", "tentacruel", "slowpoke", "slowbro",
    "seel", "dewgong", "shellder", "cloyster",
    "krabby", "kingler", "horsea", "seadra",
    "goldeen", "seaking", "staryu", "starmie",
    "magikarp", "gyarados", "lapras", "vaporeon",
    "omanyte", "omastar", "kabuto", "kabutops",
    "dratini", "dragonair", "dragonite",
    # Gen 2 Water types
    "totodile", "croconaw", "feraligatr",
    "chinchou", "lanturn", "marill", "azumarill",
    "politoed", "wooper", "quagsire", "slowking",
    "corsola", "remoraid", "octillery",
    "mantine", "kingdra", "suicune",
    # Mew learns everything
    "mew",
}

# Additional Pokemon that learn Bubblebeam but aren't pure Water:
BUBBLEBEAM_EXTRA = {
    "nidoqueen", "nidoking",  # Learn water moves via TM
}


def update_pokemon_file(filepath, new_moves):
    """Add new TM moves to a Pokemon's tmhm line."""
    with open(filepath, 'r') as f:
        content = f.read()

    match = re.search(r'(\ttmhm )(.+)', content)
    if not match:
        return False

    prefix = match.group(1)
    existing_moves_str = match.group(2)
    existing_moves = [m.strip() for m in existing_moves_str.split(',')]
    moves_to_add = [m for m in new_moves if m not in existing_moves]

    if not moves_to_add:
        return False

    all_moves = existing_moves + moves_to_add
    new_line = prefix + ", ".join(all_moves)
    content = content[:match.start()] + new_line + content[match.end():]

    with open(filepath, 'w') as f:
        f.write(content)

    return True


def main():
    all_files = sorted(os.listdir(BASE_DIR))
    updated = 0
    skipped = 0

    for filename in all_files:
        if not filename.endswith('.asm'):
            continue

        pokemon_name = filename[:-4]
        filepath = os.path.join(BASE_DIR, filename)

        moves_to_add = []

        # Rage - almost everything
        if pokemon_name not in RAGE_EXCLUDE:
            moves_to_add.append("RAGE")

        # Bide - almost everything
        if pokemon_name not in BIDE_EXCLUDE:
            moves_to_add.append("BIDE")

        # Razor Wind - flying/grass types from Gen 1 + Gen 2 additions
        if pokemon_name in RAZOR_WIND_GEN1 or pokemon_name in RAZOR_WIND_GEN2:
            moves_to_add.append("RAZOR_WIND")

        # Skull Bash - many Pokemon from Gen 1 + Gen 2 additions
        if pokemon_name in SKULL_BASH_GEN1 or pokemon_name in SKULL_BASH_GEN2:
            moves_to_add.append("SKULL_BASH")

        # Bubblebeam - Water types + extras
        if pokemon_name in WATER_POKEMON or pokemon_name in BUBBLEBEAM_EXTRA:
            moves_to_add.append("BUBBLEBEAM")

        # Water Gun - Water types only (more restrictive)
        if pokemon_name in WATER_POKEMON:
            moves_to_add.append("WATER_GUN")

        # Filter to only valid new TM moves
        valid_moves = [m for m in moves_to_add if m in NEW_TM_MOVES]

        if valid_moves:
            if update_pokemon_file(filepath, valid_moves):
                updated += 1
                print(f"  Updated {filename} (+{len(valid_moves)} moves: {', '.join(valid_moves)})")
            else:
                skipped += 1
        else:
            skipped += 1

    print(f"\nSummary: {updated} updated, {skipped} skipped")


if __name__ == "__main__":
    main()
