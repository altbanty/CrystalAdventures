#!/usr/bin/env python3
"""Generate and integrate trainer variant data for Pokemon Crystal Adventures.

Directly modifies:
1. constants/trainer_constants.asm — adds variant const definitions
2. data/trainers/parties.asm — adds variant party entries
3. engine/battle/trainer_variants.asm — populates TrainerVariantTable

Run from project root: python3 tools/gen_variants.py
"""

import re
import os
import sys

# Setup paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
os.chdir(PROJECT_ROOT)

# Class name -> group label in parties.asm
CLASS_TO_GROUP = {
    "YOUNGSTER": "YoungsterGroup",
    "BUG_CATCHER": "BugCatcherGroup",
    "SAGE": "SageGroup",
    "CAMPER": "CamperGroup",
    "PICNICKER": "PicnickerGroup",
    "FISHER": "FisherGroup",
    "HIKER": "HikerGroup",
    "BIRD_KEEPER": "BirdKeeperGroup",
    "LASS": "LassGroup",
    "SAILOR": "SailorGroup",
    "MEDIUM": "MediumGroup",
    "BOARDER": "BoarderGroup",
    "SKIER": "SkierGroup",
    "BLACKBELT_T": "BlackbeltGroup",
    "SCHOOLBOY": "SchoolboyGroup",
    "SUPER_NERD": "SuperNerdGroup",
    "PSYCHIC_T": "PsychicGroup",
    "BEAUTY": "BeautyGroup",
    "GENTLEMAN": "GentlemanGroup",
    "POKEMANIAC": "PokemaniacGroup",
    "POKEFANM": "PokefanMGroup",
    "POKEFANF": "PokefanFGroup",
    "FIREBREATHER": "FirebreatherGroup",
    "SWIMMERM": "SwimmerMGroup",
    "SWIMMERF": "SwimmerFGroup",
    "JUGGLER": "JugglerGroup",
    "TWINS": "TwinsGroup",
    "COOLTRAINERM": "CooltrainerMGroup",
    "COOLTRAINERF": "CooltrainerFGroup",
    "BURGLAR": "BurglarGroup",
}

# ============================================================
# VARIANT DATA
# ============================================================
# Format per entry: (const_name, display_name, orig_type, [V1, V2])
# V1/V2: [("TRAINERTYPE", [(level, "SPECIES", ...), ...])]
#   NORMAL mons: (level, "SPECIES")
#   MOVES mons:  (level, "SPECIES", "M1", "M2", "M3", "M4")
#   ITEM mons:   (level, "SPECIES", "ITEM")

VARIANTS = {
    # ===== YOUNGSTER =====
    "YOUNGSTER": [
        ("JOEY1", "JOEY", "NORMAL", [
            [("NORMAL", [(5, "SENTRET")])],
            [("NORMAL", [(4, "PIDGEY"), (4, "CATERPIE")])],
        ]),
        ("MIKEY", "MIKEY", "NORMAL", [
            [("NORMAL", [(4, "PIDGEY"), (4, "RATTATA")])],
            [("NORMAL", [(5, "SPINARAK")])],
        ]),
        ("ALBERT", "ALBERT", "NORMAL", [
            [("NORMAL", [(7, "RATTATA"), (7, "GEODUDE")])],
            [("NORMAL", [(8, "EKANS")])],
        ]),
        ("GORDON", "GORDON", "NORMAL", [
            [("NORMAL", [(10, "POLIWAG")])],
            [("NORMAL", [(9, "MARILL"), (9, "GEODUDE")])],
        ]),
        ("SAMUEL", "SAMUEL", "NORMAL", [
            [("NORMAL", [(12, "NIDORAN_M"), (10, "GEODUDE"), (12, "PIDGEOTTO")])],
            [("NORMAL", [(13, "RATICATE"), (12, "SPEAROW")])],
        ]),
        ("IAN", "IAN", "NORMAL", [
            [("NORMAL", [(12, "MACHOP"), (14, "SANDSHREW")])],
            [("NORMAL", [(14, "NIDORAN_M"), (12, "GEODUDE"), (12, "ZUBAT")])],
        ]),
    ],

    # ===== BUG_CATCHER =====
    "BUG_CATCHER": [
        ("DON", "DON", "NORMAL", [
            [("NORMAL", [(5, "CATERPIE"), (5, "WEEDLE")])],
            [("NORMAL", [(6, "PINECO")])],
        ]),
        ("WADE1", "WADE", "NORMAL", [
            [("NORMAL", [(5, "SPINARAK"), (5, "LEDYBA"), (6, "WEEDLE")])],
            [("NORMAL", [(6, "KAKUNA"), (6, "METAPOD")])],
        ]),
        ("BUG_CATCHER_BENNY", "BENNY", "NORMAL", [
            [("NORMAL", [(13, "BUTTERFREE"), (14, "ARIADOS")])],
            [("NORMAL", [(15, "PARASECT")])],
        ]),
        ("AL", "AL", "NORMAL", [
            [("NORMAL", [(13, "LEDIAN"), (14, "BEEDRILL")])],
            [("NORMAL", [(15, "VENONAT")])],
        ]),
        ("JOSH", "JOSH", "NORMAL", [
            [("NORMAL", [(15, "PINSIR")])],
            [("NORMAL", [(13, "LEDIAN"), (13, "SPINARAK")])],
        ]),
        ("ARNIE1", "ARNIE", "NORMAL", [
            [("NORMAL", [(18, "PINSIR"), (17, "PARAS")])],
            [("NORMAL", [(19, "SCYTHER")])],
        ]),
        ("WAYNE", "WAYNE", "NORMAL", [
            [("NORMAL", [(16, "VENONAT"), (17, "BELLSPROUT")])],
            [("NORMAL", [(18, "PARASECT")])],
        ]),
    ],

    # ===== SAGE =====
    "SAGE": [
        ("CHOW", "CHOW", "NORMAL", [
            [("NORMAL", [(5, "HOPPIP"), (5, "ODDISH"), (6, "HOPPIP")])],
            [("NORMAL", [(6, "BELLSPROUT"), (6, "SUNKERN")])],
        ]),
        ("NICO", "NICO", "NORMAL", [
            [("NORMAL", [(5, "SUNKERN"), (6, "BELLSPROUT"), (6, "ODDISH")])],
            [("NORMAL", [(7, "BELLSPROUT")])],
        ]),
        ("EDMOND", "EDMOND", "NORMAL", [
            [("NORMAL", [(5, "ODDISH"), (6, "HOPPIP"), (7, "SUNKERN")])],
            [("NORMAL", [(7, "BELLSPROUT"), (7, "ODDISH")])],
        ]),
        ("JIN", "JIN", "NORMAL", [
            [("NORMAL", [(8, "ODDISH")])],
            [("NORMAL", [(7, "HOPPIP"), (7, "SUNKERN")])],
        ]),
        ("TROY", "TROY", "NORMAL", [
            [("NORMAL", [(7, "SUNKERN"), (8, "ODDISH")])],
            [("NORMAL", [(9, "BELLSPROUT")])],
        ]),
        ("NEAL", "NEAL", "NORMAL", [
            [("NORMAL", [(8, "HOPPIP")])],
            [("NORMAL", [(7, "BELLSPROUT"), (7, "ODDISH")])],
        ]),
        ("LI", "LI", "NORMAL", [
            [("NORMAL", [(7, "HOPPIP"), (8, "BELLSPROUT"), (9, "ODDISH")])],
            [("NORMAL", [(9, "BELLSPROUT"), (9, "SUNKERN")])],
        ]),
        ("JEFFREY", "JEFFREY", "NORMAL", [
            [("NORMAL", [(21, "MISDREAVUS"), (21, "HAUNTER"), (21, "GASTLY")])],
            [("NORMAL", [(22, "HAUNTER"), (22, "HAUNTER")])],
        ]),
        ("PING", "PING", "NORMAL", [
            [("NORMAL", [(22, "HAUNTER")])],
            [("NORMAL", [(21, "GASTLY"), (21, "GASTLY")])],
        ]),
    ],

    # ===== CAMPER =====
    "CAMPER": [
        ("ROLAND", "ROLAND", "NORMAL", [
            [("NORMAL", [(9, "GEODUDE")])],
            [("NORMAL", [(8, "NIDORAN_M"), (8, "ZUBAT")])],
        ]),
        ("TODD1", "TODD", "NORMAL", [
            [("NORMAL", [(15, "QUAGSIRE")])],
            [("NORMAL", [(14, "PSYDUCK"), (14, "GEODUDE")])],
        ]),
        ("IVAN", "IVAN", "NORMAL", [
            [("NORMAL", [(16, "GROWLITHE"), (16, "SANDSHREW")])],
            [("NORMAL", [(17, "FURRET")])],
        ]),
        ("ELLIOT", "ELLIOT", "NORMAL", [
            [("NORMAL", [(16, "GEODUDE"), (16, "POLIWAG")])],
            [("NORMAL", [(17, "QUAGSIRE")])],
        ]),
        ("SPENCER", "SPENCER", "NORMAL", [
            [("NORMAL", [(25, "PRIMEAPE"), (25, "NIDORINO")])],
            [("NORMAL", [(26, "URSARING")])],
        ]),
        ("TED", "TED", "NORMAL", [
            [("NORMAL", [(40, "TAUROS"), (40, "DONPHAN"), (40, "SANDSLASH")])],
            [("NORMAL", [(41, "MACHAMP"), (41, "NIDOKING")])],
        ]),
        ("QUENTIN", "QUENTIN", "NORMAL", [
            [("NORMAL", [(38, "DODRIO"), (38, "MACHOKE"), (38, "URSARING"), (38, "DONPHAN")])],
            [("NORMAL", [(39, "NIDOKING"), (39, "TAUROS"), (39, "PRIMEAPE")])],
        ]),
    ],

    # ===== PICNICKER =====
    "PICNICKER": [
        ("LIZ1", "LIZ", "NORMAL", [
            [("NORMAL", [(9, "ODDISH")])],
            [("NORMAL", [(8, "NIDORAN_F"), (8, "BELLSPROUT")])],
        ]),
        ("GINA1", "GINA", "NORMAL", [
            [("NORMAL", [(14, "GLOOM"), (14, "CHIKORITA")])],
            [("NORMAL", [(15, "BAYLEEF")])],
        ]),
        ("BROOKE", "BROOKE", "MOVES", [
            [("MOVES", [(18, "CLEFAIRY", "POUND", "GROWL", "ENCORE", "DOUBLESLAP")])],
            [("NORMAL", [(17, "PIKACHU"), (17, "MAREEP")])],
        ]),
        ("KIM", "KIM", "NORMAL", [
            [("NORMAL", [(18, "GROWLITHE")])],
            [("NORMAL", [(17, "VULPIX"), (17, "PONYTA")])],
        ]),
        ("TIFFANY1", "TIFFANY", "MOVES", [
            [("MOVES", [(34, "WIGGLYTUFF", "SING", "BODY_SLAM", "DEFENSE_CURL", "ROLLOUT"),
                        (34, "CLEFABLE", "METRONOME", "ENCORE", "DOUBLESLAP", "MOONLIGHT")])],
            [("MOVES", [(35, "GRANBULL", "HEADBUTT", "BITE", "SCARY_FACE", "STRENGTH")])],
        ]),
        ("ERIN1", "ERIN", "NORMAL", [
            [("NORMAL", [(40, "ARCANINE"), (38, "NIDOKING"), (38, "AMPHAROS"), (40, "RAPIDASH")])],
            [("NORMAL", [(39, "NIDOQUEEN"), (39, "RAICHU"), (40, "ARCANINE")])],
        ]),
    ],

    # ===== FISHER =====
    "FISHER": [
        ("JUSTIN", "JUSTIN", "NORMAL", [
            [("NORMAL", [(10, "POLIWAG")])],
            [("NORMAL", [(9, "MAGIKARP"), (9, "GOLDEEN")])],
        ]),
        ("RALPH1", "RALPH", "NORMAL", [
            [("NORMAL", [(10, "TENTACOOL")])],
            [("NORMAL", [(9, "POLIWAG"), (9, "MAGIKARP")])],
        ]),
        ("HENRY", "HENRY", "NORMAL", [
            [("NORMAL", [(9, "GOLDEEN"), (9, "TENTACOOL")])],
            [("NORMAL", [(10, "MARILL")])],
        ]),
        ("TULLY1", "TULLY", "NORMAL", [
            [("NORMAL", [(24, "SEAKING")])],
            [("NORMAL", [(23, "GOLDEEN"), (23, "STARYU")])],
        ]),
        ("MARVIN", "MARVIN", "NORMAL", [
            [("NORMAL", [(25, "OCTILLERY"), (25, "QWILFISH")])],
            [("NORMAL", [(26, "GYARADOS")])],
        ]),
        ("ANDRE", "ANDRE", "NORMAL", [
            [("NORMAL", [(27, "SEAKING")])],
            [("NORMAL", [(26, "QWILFISH"), (26, "GOLDEEN")])],
        ]),
        ("RAYMOND", "RAYMOND", "NORMAL", [
            [("NORMAL", [(28, "LANTURN")])],
            [("NORMAL", [(27, "POLIWHIRL"), (27, "GYARADOS")])],
        ]),
        ("WILTON1", "WILTON", "NORMAL", [
            [("NORMAL", [(38, "GYARADOS"), (36, "LANTURN"), (36, "TENTACRUEL")])],
            [("NORMAL", [(38, "SEAKING"), (37, "OCTILLERY")])],
        ]),
        ("EDGAR", "EDGAR", "MOVES", [
            [("MOVES", [(38, "LANTURN", "THUNDERBOLT", "SURF", "CONFUSE_RAY", "THUNDER_WAVE"),
                        (36, "QWILFISH", "PIN_MISSILE", "SURF", "TOXIC", "MINIMIZE"),
                        (36, "TENTACRUEL", "SURF", "SLUDGE_BOMB", "BARRIER", "WRAP")])],
            [("MOVES", [(38, "GYARADOS", "SURF", "DRAGON_RAGE", "BITE", "TWISTER"),
                        (37, "SEAKING", "WATERFALL", "HORN_ATTACK", "FURY_ATTACK", "SUPERSONIC")])],
        ]),
    ],

    # ===== HIKER =====
    "HIKER": [
        ("RUSSELL", "RUSSELL", "NORMAL", [
            [("NORMAL", [(9, "SANDSHREW"), (10, "ONIX")])],
            [("NORMAL", [(10, "GEODUDE")])],
        ]),
        ("DANIEL", "DANIEL", "NORMAL", [
            [("NORMAL", [(12, "GEODUDE")])],
            [("NORMAL", [(11, "MACHOP"), (11, "GEODUDE")])],
        ]),
        ("ANTHONY1", "ANTHONY", "NORMAL", [
            [("NORMAL", [(25, "SANDSLASH"), (25, "ONIX")])],
            [("NORMAL", [(26, "GOLEM")])],
        ]),
        ("PHILLIP", "PHILLIP", "NORMAL", [
            [("NORMAL", [(23, "SANDSHREW"), (23, "CUBONE"), (23, "ONIX")])],
            [("NORMAL", [(24, "GRAVELER"), (24, "MACHOKE")])],
        ]),
        ("LEONARD", "LEONARD", "NORMAL", [
            [("NORMAL", [(23, "CUBONE"), (25, "GRAVELER")])],
            [("NORMAL", [(25, "ONIX")])],
        ]),
        ("BENJAMIN", "BENJAMIN", "NORMAL", [
            [("NORMAL", [(24, "SANDSLASH"), (24, "MACHOKE")])],
            [("NORMAL", [(25, "GOLEM")])],
        ]),
        ("ERIK", "ERIK", "NORMAL", [
            [("NORMAL", [(37, "DONPHAN"), (38, "STEELIX"), (37, "GRAVELER")])],
            [("NORMAL", [(38, "MACHAMP"), (38, "GOLEM")])],
        ]),
        ("MICHAEL", "MICHAEL", "NORMAL", [
            [("NORMAL", [(38, "STEELIX"), (38, "SANDSLASH"), (38, "MACHAMP")])],
            [("NORMAL", [(39, "RHYDON"), (39, "GOLEM")])],
        ]),
        ("TIMOTHY", "TIMOTHY", "MOVES", [
            [("MOVES", [(38, "SANDSLASH", "SLASH", "EARTHQUAKE", "SAND_ATTACK", "SWIFT"),
                        (39, "DONPHAN", "ROLLOUT", "EARTHQUAKE", "DEFENSE_CURL", "TAKE_DOWN"),
                        (38, "GOLEM", "MAGNITUDE", "ROCK_THROW", "ROLLOUT", "DEFENSE_CURL"),
                        (38, "MAROWAK", "BONEMERANG", "HEADBUTT", "LEER", "THRASH")])],
            [("MOVES", [(39, "STEELIX", "IRON_TAIL", "DIG", "ROCK_THROW", "SANDSTORM"),
                        (39, "MACHAMP", "KARATE_CHOP", "VITAL_THROW", "ROCK_SLIDE", "SCARY_FACE"),
                        (39, "GOLEM", "MAGNITUDE", "ROCK_THROW", "ROLLOUT", "SELFDESTRUCT")])],
        ]),
    ],

    # ===== BIRD_KEEPER =====
    "BIRD_KEEPER": [
        ("PETER", "PETER", "NORMAL", [
            [("NORMAL", [(8, "PIDGEY"), (8, "HOOTHOOT")])],
            [("NORMAL", [(9, "SPEAROW")])],
        ]),
        ("BRYAN", "BRYAN", "NORMAL", [
            [("NORMAL", [(16, "HOOTHOOT"), (18, "NOCTOWL"), (18, "MURKROW")])],
            [("NORMAL", [(18, "PIDGEOTTO"), (18, "FEAROW")])],
        ]),
        ("THEO", "THEO", "NORMAL", [
            [("NORMAL", [(23, "NOCTOWL")])],
            [("NORMAL", [(22, "PIDGEOTTO"), (22, "NATU")])],
        ]),
        ("TOBY", "TOBY", "NORMAL", [
            [("NORMAL", [(22, "PIDGEOTTO"), (22, "NATU")])],
            [("NORMAL", [(23, "FEAROW")])],
        ]),
        ("DENIS", "DENIS", "NORMAL", [
            [("NORMAL", [(24, "NOCTOWL"), (24, "MURKROW")])],
            [("NORMAL", [(25, "FEAROW")])],
        ]),
        ("VANCE1", "VANCE", "NORMAL", [
            [("NORMAL", [(36, "NOCTOWL"), (36, "FEAROW"), (36, "DODRIO"), (37, "XATU")])],
            [("NORMAL", [(37, "SKARMORY"), (37, "PIDGEOT"), (37, "FEAROW")])],
        ]),
    ],

    # ===== LASS =====
    "LASS": [
        ("CARRIE", "CARRIE", "MOVES", [
            [("MOVES", [(18, "CLEFAIRY", "GROWL", "ENCORE", "DOUBLESLAP", "METRONOME")])],
            [("NORMAL", [(17, "JIGGLYPUFF"), (17, "SNUBBULL")])],
        ]),
        ("BRIDGET", "BRIDGET", "NORMAL", [
            [("NORMAL", [(16, "SENTRET"), (16, "CLEFAIRY")])],
            [("NORMAL", [(17, "FURRET")])],
        ]),
        ("KRISE", "KRISE", "NORMAL", [
            [("NORMAL", [(17, "GLOOM"), (16, "MARILL")])],
            [("NORMAL", [(18, "WEEPINBELL")])],
        ]),
        ("DANA1", "DANA", "MOVES", [
            [("MOVES", [(19, "CLEFAIRY", "POUND", "ENCORE", "DOUBLESLAP", "METRONOME"),
                        (20, "GLOOM", "ABSORB", "POISONPOWDER", "STUN_SPORE", "SLEEP_POWDER")])],
            [("MOVES", [(20, "AMPHAROS", "HEADBUTT", "THUNDERSHOCK", "THUNDER_WAVE", "COTTON_SPORE")])],
        ]),
        ("CONNIE1", "CONNIE", "NORMAL", [
            [("NORMAL", [(21, "GROWLITHE"), (22, "GLOOM")])],
            [("NORMAL", [(22, "RAPIDASH")])],
        ]),
    ],

    # ===== SAILOR =====
    "SAILOR": [
        ("EUGENE", "EUGENE", "NORMAL", [
            [("NORMAL", [(20, "MACHOKE"), (22, "QUAGSIRE")])],
            [("NORMAL", [(22, "POLIWRATH")])],
        ]),
        ("HUEY1", "HUEY", "NORMAL", [
            [("NORMAL", [(20, "KINGLER"), (22, "POLIWHIRL")])],
            [("NORMAL", [(22, "MACHOKE")])],
        ]),
        ("TERRELL", "TERRELL", "NORMAL", [
            [("NORMAL", [(24, "MACHOKE")])],
            [("NORMAL", [(23, "POLIWHIRL"), (23, "TENTACOOL")])],
        ]),
        ("KENT", "KENT", "NORMAL", [
            [("NORMAL", [(23, "KRABBY"), (23, "TENTACOOL")])],
            [("NORMAL", [(24, "LANTURN")])],
        ]),
        ("ERNEST", "ERNEST", "NORMAL", [
            [("NORMAL", [(22, "TENTACOOL"), (24, "MACHOKE"), (24, "KINGLER")])],
            [("NORMAL", [(24, "POLIWRATH"), (24, "QUAGSIRE")])],
        ]),
        ("HARRY", "HARRY", "NORMAL", [
            [("NORMAL", [(23, "POLIWHIRL")])],
            [("NORMAL", [(22, "MACHOP"), (22, "SHELLDER")])],
        ]),
    ],

    # ===== MEDIUM =====
    "MEDIUM": [
        ("MARTHA", "MARTHA", "NORMAL", [
            [("NORMAL", [(20, "GASTLY"), (20, "MISDREAVUS")])],
            [("NORMAL", [(21, "HAUNTER")])],
        ]),
        ("GRACE", "GRACE", "NORMAL", [
            [("NORMAL", [(20, "MISDREAVUS"), (20, "GASTLY")])],
            [("NORMAL", [(21, "HAUNTER"), (20, "HOUNDOUR")])],
        ]),
    ],

    # ===== BOARDER =====
    "BOARDER": [
        ("RONALD", "RONALD", "NORMAL", [
            [("NORMAL", [(29, "SNEASEL"), (30, "SEEL")])],
            [("NORMAL", [(30, "CLOYSTER")])],
        ]),
        ("BRAD", "BRAD", "NORMAL", [
            [("NORMAL", [(30, "SHELLDER"), (30, "DEWGONG")])],
            [("NORMAL", [(31, "PILOSWINE")])],
        ]),
        ("DOUGLAS", "DOUGLAS", "NORMAL", [
            [("NORMAL", [(28, "SWINUB"), (28, "SNEASEL"), (30, "DEWGONG")])],
            [("NORMAL", [(30, "CLOYSTER"), (30, "PILOSWINE")])],
        ]),
    ],

    # ===== SKIER =====
    "SKIER": [
        ("ROXANNE", "ROXANNE", "NORMAL", [
            [("NORMAL", [(30, "CLOYSTER")])],
            [("NORMAL", [(29, "DEWGONG"), (29, "SEEL")])],
        ]),
        ("CLARISSA", "CLARISSA", "NORMAL", [
            [("NORMAL", [(31, "PILOSWINE")])],
            [("NORMAL", [(30, "SNEASEL"), (30, "SEEL")])],
        ]),
    ],

    # ===== BLACKBELT_T =====
    "BLACKBELT_T": [
        ("YOSHI", "YOSHI", "MOVES", [
            [("MOVES", [(29, "MACHOKE", "KARATE_CHOP", "SEISMIC_TOSS", "LEER", "ROCK_SLIDE")])],
            [("MOVES", [(28, "MACHOP", "KARATE_CHOP", "LOW_KICK", "LEER", "SEISMIC_TOSS"),
                        (28, "PRIMEAPE", "LOW_KICK", "FURY_SWIPES", "KARATE_CHOP", "RAGE")])],
        ]),
        ("LAO", "LAO", "MOVES", [
            [("MOVES", [(29, "PRIMEAPE", "LOW_KICK", "KARATE_CHOP", "FURY_SWIPES", "SEISMIC_TOSS")])],
            [("MOVES", [(28, "MACHOKE", "VITAL_THROW", "KARATE_CHOP", "LEER", "ROCK_SLIDE"),
                        (28, "MANKEY", "LOW_KICK", "KARATE_CHOP", "FURY_SWIPES", "RAGE")])],
        ]),
        ("NOB", "NOB", "MOVES", [
            [("MOVES", [(27, "PRIMEAPE", "LOW_KICK", "FURY_SWIPES", "KARATE_CHOP", "SEISMIC_TOSS"),
                        (27, "MANKEY", "LOW_KICK", "KARATE_CHOP", "FURY_SWIPES", "RAGE")])],
            [("MOVES", [(28, "MACHOKE", "KARATE_CHOP", "SEISMIC_TOSS", "LEER", "VITAL_THROW")])],
        ]),
        ("LUNG", "LUNG", "NORMAL", [
            [("NORMAL", [(27, "MACHOP"), (27, "PRIMEAPE"), (27, "MACHOKE")])],
            [("NORMAL", [(28, "HITMONTOP"), (27, "MANKEY")])],
        ]),
        ("KENJI3", "KENJI", "MOVES", [
            [("MOVES", [(33, "PRIMEAPE", "LOW_KICK", "FURY_SWIPES", "KARATE_CHOP", "SEISMIC_TOSS"),
                        (33, "MACHOKE", "VITAL_THROW", "ROCK_SLIDE", "LEER", "SEISMIC_TOSS")])],
            [("MOVES", [(34, "MACHAMP", "CROSS_CHOP", "ROCK_SLIDE", "SCARY_FACE", "VITAL_THROW")])],
        ]),
    ],

    # ===== SCHOOLBOY =====
    "SCHOOLBOY": [
        ("JACK1", "JACK", "NORMAL", [
            [("NORMAL", [(16, "GROWLITHE"), (17, "MAGNEMITE")])],
            [("NORMAL", [(17, "ELECTRODE")])],
        ]),
        ("ALAN1", "ALAN", "NORMAL", [
            [("NORMAL", [(20, "WEEPINBELL"), (20, "VULPIX")])],
            [("NORMAL", [(21, "ARCANINE")])],
        ]),
        ("CHAD1", "CHAD", "NORMAL", [
            [("NORMAL", [(22, "KADABRA"), (22, "VOLTORB")])],
            [("NORMAL", [(23, "MAGNETON")])],
        ]),
    ],

    # ===== SUPER_NERD =====
    "SUPER_NERD": [
        ("ERIC", "ERIC", "NORMAL", [
            [("NORMAL", [(15, "MAGNEMITE"), (15, "VOLTORB")])],
            [("NORMAL", [(16, "PORYGON")])],
        ]),
        ("TERU", "TERU", "NORMAL", [
            [("NORMAL", [(14, "GRIMER"), (14, "KOFFING"), (14, "CUBONE")])],
            [("NORMAL", [(15, "MAGNEMITE"), (15, "VOLTORB")])],
        ]),
        ("MARKUS", "MARKUS", "MOVES", [
            [("MOVES", [(19, "MAGNEMITE", "THUNDERSHOCK", "SUPERSONIC", "SONICBOOM", "THUNDER_WAVE")])],
            [("NORMAL", [(18, "VOLTORB"), (18, "GRIMER")])],
        ]),
        ("HUGH", "HUGH", "MOVES", [
            [("MOVES", [(39, "LANTURN", "SURF", "THUNDERBOLT", "CONFUSE_RAY", "THUNDER_WAVE")])],
            [("MOVES", [(38, "TENTACRUEL", "SURF", "SLUDGE_BOMB", "BARRIER", "WRAP"),
                        (38, "CHINCHOU", "SURF", "SPARK", "CONFUSE_RAY", "THUNDER_WAVE")])],
        ]),
    ],

    # ===== PSYCHIC_T =====
    "PSYCHIC_T": [
        ("GREG", "GREG", "MOVES", [
            [("MOVES", [(22, "DROWZEE", "HYPNOSIS", "DREAM_EATER", "HEADBUTT", "DISABLE")])],
            [("NORMAL", [(21, "ABRA"), (21, "SLOWPOKE")])],
        ]),
        ("NORMAN", "NORMAN", "MOVES", [
            [("MOVES", [(22, "DROWZEE", "HYPNOSIS", "DISABLE", "HEADBUTT", "CONFUSION"),
                        (23, "GIRAFARIG", "STOMP", "PSYBEAM", "AGILITY", "CONFUSION")])],
            [("MOVES", [(23, "KADABRA", "CONFUSION", "PSYBEAM", "KINESIS", "RECOVER")])],
        ]),
        ("MARK", "MARK", "MOVES", [
            [("MOVES", [(15, "DROWZEE", "HYPNOSIS", "POUND", "DISABLE", "NO_MOVE"),
                        (15, "SLOWPOKE", "TACKLE", "GROWL", "WATER_GUN", "NO_MOVE"),
                        (16, "ABRA", "TELEPORT", "FLASH", "NO_MOVE", "NO_MOVE")])],
            [("MOVES", [(16, "KADABRA", "CONFUSION", "KINESIS", "TELEPORT", "NO_MOVE"),
                        (16, "DROWZEE", "HYPNOSIS", "POUND", "DISABLE", "CONFUSION")])],
        ]),
        ("PHIL", "PHIL", "MOVES", [
            [("MOVES", [(36, "HYPNO", "HYPNOSIS", "DREAM_EATER", "HEADBUTT", "PSYCHIC_M"),
                        (36, "ALAKAZAM", "PSYCHIC_M", "RECOVER", "SHADOW_BALL", "NO_MOVE"),
                        (36, "SLOWBRO", "SURF", "PSYCHIC_M", "AMNESIA", "HEADBUTT")])],
            [("MOVES", [(37, "ESPEON", "PSYCHIC_M", "SWIFT", "MORNING_SUN", "SHADOW_BALL"),
                        (37, "MR__MIME", "PSYCHIC_M", "LIGHT_SCREEN", "REFLECT", "ENCORE")])],
        ]),
    ],

    # ===== BEAUTY =====
    "BEAUTY": [
        ("VICTORIA", "VICTORIA", "NORMAL", [
            [("NORMAL", [(15, "CLEFAIRY"), (17, "SNUBBULL")])],
            [("NORMAL", [(17, "JIGGLYPUFF")])],
        ]),
        ("SAMANTHA", "SAMANTHA", "MOVES", [
            [("MOVES", [(18, "AIPOM", "SCRATCH", "TAIL_WHIP", "FURY_SWIPES", "SAND_ATTACK")])],
            [("NORMAL", [(17, "MEOWTH"), (17, "SENTRET")])],
        ]),
        ("VALERIE", "VALERIE", "NORMAL", [
            [("NORMAL", [(22, "SUNFLORA"), (21, "FURRET")])],
            [("NORMAL", [(22, "CLEFABLE")])],
        ]),
        ("OLIVIA", "OLIVIA", "NORMAL", [
            [("NORMAL", [(21, "STARYU")])],
            [("NORMAL", [(20, "SHELLDER"), (20, "HORSEA")])],
        ]),
    ],

    # ===== GENTLEMAN =====
    "GENTLEMAN": [
        ("PRESTON", "PRESTON", "NORMAL", [
            [("NORMAL", [(22, "PONYTA"), (22, "NOCTOWL")])],
            [("NORMAL", [(23, "NINETALES")])],
        ]),
        ("ALFRED", "ALFRED", "NORMAL", [
            [("NORMAL", [(22, "PONYTA")])],
            [("NORMAL", [(21, "GROWLITHE"), (21, "NOCTOWL")])],
        ]),
    ],

    # ===== POKEMANIAC =====
    "POKEMANIAC": [
        ("LARRY", "LARRY", "NORMAL", [
            [("NORMAL", [(12, "CUBONE")])],
            [("NORMAL", [(11, "SLOWPOKE"), (11, "NIDORAN_M")])],
        ]),
        ("ANDREW", "ANDREW", "NORMAL", [
            [("NORMAL", [(24, "RHYDON"), (24, "NIDORINO")])],
            [("NORMAL", [(25, "KANGASKHAN")])],
        ]),
        ("CALVIN", "CALVIN", "NORMAL", [
            [("NORMAL", [(26, "LICKITUNG")])],
            [("NORMAL", [(25, "NIDORINO"), (25, "SLOWBRO")])],
        ]),
        ("SHANE", "SHANE", "NORMAL", [
            [("NORMAL", [(24, "MAROWAK"), (24, "RHYDON")])],
            [("NORMAL", [(25, "NIDOKING")])],
        ]),
        ("BEN", "BEN", "NORMAL", [
            [("NORMAL", [(26, "LICKITUNG"), (26, "NIDOKING")])],
            [("NORMAL", [(27, "SLOWBRO")])],
        ]),
        ("BRENT1", "BRENT", "NORMAL", [
            [("NORMAL", [(26, "KANGASKHAN"), (26, "CHARMELEON")])],
            [("NORMAL", [(27, "LICKITUNG")])],
        ]),
        ("RON", "RON", "NORMAL", [
            [("NORMAL", [(26, "RHYDON"), (26, "WARTORTLE")])],
            [("NORMAL", [(27, "NIDOKING")])],
        ]),
        ("ISSAC", "ISSAC", "MOVES", [
            [("MOVES", [(14, "SLOWPOKE", "TACKLE", "GROWL", "WATER_GUN", "CONFUSION")])],
            [("NORMAL", [(13, "CUBONE"), (13, "NIDORAN_M")])],
        ]),
        ("DONALD", "DONALD", "NORMAL", [
            [("NORMAL", [(15, "LICKITUNG"), (15, "CUBONE")])],
            [("NORMAL", [(16, "SLOWPOKE")])],
        ]),
        ("MILLER", "MILLER", "NORMAL", [
            [("NORMAL", [(20, "MAROWAK"), (20, "KANGASKHAN")])],
            [("NORMAL", [(21, "RHYDON")])],
        ]),
        ("ZACH", "ZACH", "NORMAL", [
            [("NORMAL", [(40, "KANGASKHAN"), (37, "NIDOKING"), (38, "PINSIR")])],
            [("NORMAL", [(39, "RHYDON"), (39, "TYRANITAR")])],
        ]),
    ],

    # ===== POKEFANM =====
    "POKEFANM": [
        ("WILLIAM", "WILLIAM", "ITEM", [
            [("ITEM", [(15, "PIKACHU", "BERRY")])],
            [("ITEM", [(14, "PIKACHU", "BERRY"), (14, "MARILL", "BERRY")])],
        ]),
        ("DEREK1", "DEREK", "ITEM", [
            [("ITEM", [(22, "RAICHU", "BERRY"), (22, "GROWLITHE", "BERRY")])],
            [("ITEM", [(23, "PIKACHU", "BERRY")])],
        ]),
        ("BRANDON", "BRANDON", "ITEM", [
            [("ITEM", [(15, "TEDDIURSA", "BERRY")])],
            [("ITEM", [(14, "SNUBBULL", "BERRY"), (14, "SENTRET", "BERRY")])],
        ]),
    ],

    # ===== POKEFANF =====
    "POKEFANF": [
        ("BEVERLY1", "BEVERLY", "ITEM", [
            [("ITEM", [(20, "CLEFAIRY", "BERRY")])],
            [("ITEM", [(19, "SNUBBULL", "BERRY"), (19, "SENTRET", "BERRY")])],
        ]),
        ("RUTH", "RUTH", "ITEM", [
            [("ITEM", [(23, "MARILL", "BERRY")])],
            [("ITEM", [(22, "PIKACHU", "BERRY"), (22, "CLEFAIRY", "BERRY")])],
        ]),
    ],

    # ===== FIREBREATHER =====
    "FIREBREATHER": [
        ("BILL", "BILL", "NORMAL", [
            [("NORMAL", [(12, "VULPIX")])],
            [("NORMAL", [(11, "KOFFING"), (11, "SLUGMA")])],
        ]),
        ("WALT", "WALT", "NORMAL", [
            [("NORMAL", [(15, "GROWLITHE"), (15, "VULPIX")])],
            [("NORMAL", [(16, "MAGMAR")])],
        ]),
        ("RAY", "RAY", "NORMAL", [
            [("NORMAL", [(11, "KOFFING")])],
            [("NORMAL", [(10, "SLUGMA"), (10, "GROWLITHE")])],
        ]),
    ],

    # ===== SWIMMERM =====
    "SWIMMERM": [
        ("SIMON", "SIMON", "NORMAL", [
            [("NORMAL", [(25, "HORSEA"), (25, "STARYU")])],
            [("NORMAL", [(26, "TENTACRUEL")])],
        ]),
        ("RANDALL", "RANDALL", "NORMAL", [
            [("NORMAL", [(25, "HORSEA"), (25, "STARYU")])],
            [("NORMAL", [(26, "CLOYSTER")])],
        ]),
        ("CHARLIE", "CHARLIE", "NORMAL", [
            [("NORMAL", [(26, "SEADRA"), (26, "STARMIE")])],
            [("NORMAL", [(27, "TENTACRUEL")])],
        ]),
        ("GEORGE", "GEORGE", "NORMAL", [
            [("NORMAL", [(26, "HORSEA"), (26, "SHELLDER"), (26, "CHINCHOU")])],
            [("NORMAL", [(27, "STARMIE"), (27, "TENTACRUEL")])],
        ]),
        ("BERKE", "BERKE", "NORMAL", [
            [("NORMAL", [(27, "SEADRA")])],
            [("NORMAL", [(26, "HORSEA"), (26, "REMORAID")])],
        ]),
        ("KIRK", "KIRK", "NORMAL", [
            [("NORMAL", [(24, "TENTACRUEL"), (24, "SEADRA")])],
            [("NORMAL", [(25, "GYARADOS")])],
        ]),
        ("MATHEW", "MATHEW", "NORMAL", [
            [("NORMAL", [(26, "STARYU"), (26, "SHELLDER")])],
            [("NORMAL", [(27, "KINGLER")])],
        ]),
    ],

    # ===== SWIMMERF =====
    "SWIMMERF": [
        ("ELAINE", "ELAINE", "NORMAL", [
            [("NORMAL", [(25, "GOLDUCK")])],
            [("NORMAL", [(24, "STARYU"), (24, "SHELLDER")])],
        ]),
        ("PAULA", "PAULA", "NORMAL", [
            [("NORMAL", [(25, "HORSEA"), (26, "GOLDEEN")])],
            [("NORMAL", [(26, "STARMIE")])],
        ]),
        ("KAYLEE", "KAYLEE", "NORMAL", [
            [("NORMAL", [(24, "CORSOLA"), (24, "STARYU"), (24, "TENTACRUEL")])],
            [("NORMAL", [(25, "LANTURN"), (25, "GOLDUCK")])],
        ]),
        ("SUSIE", "SUSIE", "MOVES", [
            [("MOVES", [(27, "STARMIE", "SURF", "SWIFT", "RECOVER", "CONFUSE_RAY"),
                        (26, "CORSOLA", "BUBBLEBEAM", "ROCK_THROW", "RECOVER", "MIRROR_COAT")])],
            [("MOVES", [(28, "GOLDUCK", "SURF", "CONFUSION", "SCRATCH", "DISABLE")])],
        ]),
        ("DENISE", "DENISE", "NORMAL", [
            [("NORMAL", [(27, "DEWGONG")])],
            [("NORMAL", [(26, "SEEL"), (26, "SHELLDER")])],
        ]),
        ("KARA", "KARA", "NORMAL", [
            [("NORMAL", [(25, "TENTACOOL"), (26, "SEAKING")])],
            [("NORMAL", [(26, "LANTURN")])],
        ]),
        ("WENDY", "WENDY", "MOVES", [
            [("MOVES", [(26, "STARYU", "SWIFT", "BUBBLEBEAM", "RECOVER", "RAPID_SPIN"),
                        (27, "TENTACRUEL", "SURF", "BARRIER", "WRAP", "ACID")])],
            [("MOVES", [(28, "SEADRA", "SURF", "SMOKESCREEN", "TWISTER", "DRAGON_RAGE")])],
        ]),
    ],

    # ===== JUGGLER =====
    "JUGGLER": [
        ("IRWIN1", "IRWIN", "NORMAL", [
            [("NORMAL", [(16, "MAGNEMITE"), (16, "VOLTORB"), (16, "MAGNEMITE")])],
            [("NORMAL", [(17, "ELECTRODE"), (16, "PINECO")])],
        ]),
    ],

    # ===== TWINS =====
    "TWINS": [
        ("AMYANDMAY1", "AMY & MAY", "NORMAL", [
            [("NORMAL", [(13, "SPINARAK"), (14, "LEDYBA")])],
            [("NORMAL", [(14, "BUTTERFREE")])],
        ]),
        ("ANNANDANNE1", "ANN & ANNE", "MOVES", [
            [("MOVES", [(18, "JIGGLYPUFF", "SING", "POUND", "DEFENSE_CURL", "ROLLOUT"),
                        (18, "SENTRET", "QUICK_ATTACK", "DEFENSE_CURL", "FURY_SWIPES", "NO_MOVE")])],
            [("MOVES", [(19, "CLEFABLE", "METRONOME", "ENCORE", "DOUBLESLAP", "GROWL")])],
        ]),
    ],

    # ===== COOLTRAINERM =====
    "COOLTRAINERM": [
        ("NICK", "NICK", "MOVES", [
            [("MOVES", [(26, "EEVEE", "QUICK_ATTACK", "SAND_ATTACK", "BITE", "TAKE_DOWN"),
                        (26, "LARVITAR", "BITE", "ROCK_THROW", "SCREECH", "SANDSTORM"),
                        (26, "DRATINI", "TWISTER", "THUNDER_WAVE", "DRAGON_RAGE", "SLAM")])],
            [("MOVES", [(27, "CHARMELEON", "EMBER", "SLASH", "SCARY_FACE", "RAGE"),
                        (27, "WARTORTLE", "WATER_GUN", "BITE", "WITHDRAW", "RAPID_SPIN")])],
        ]),
        ("AARON", "AARON", "NORMAL", [
            [("NORMAL", [(27, "DRAGONAIR"), (27, "PUPITAR"), (27, "TOGETIC")])],
            [("NORMAL", [(28, "CHARMELEON"), (28, "WARTORTLE")])],
        ]),
        ("ALLEN", "ALLEN", "MOVES", [
            [("MOVES", [(35, "ARCANINE", "FLAMETHROWER", "BITE", "TAKE_DOWN", "NO_MOVE"),
                        (37, "AMPHAROS", "THUNDERPUNCH", "THUNDER_WAVE", "HEADBUTT", "NO_MOVE")])],
            [("MOVES", [(37, "MAGMAR", "FIRE_PUNCH", "CONFUSE_RAY", "SMOKESCREEN", "THUNDERPUNCH")])],
        ]),
        ("RYAN", "RYAN", "MOVES", [
            [("MOVES", [(37, "NOCTOWL", "HYPNOSIS", "DREAM_EATER", "WING_ATTACK", "REFLECT"),
                        (37, "AMPHAROS", "THUNDERPUNCH", "THUNDER_WAVE", "SWIFT", "NO_MOVE"),
                        (37, "ARCANINE", "FLAMETHROWER", "BITE", "TAKE_DOWN", "NO_MOVE")])],
            [("MOVES", [(38, "PIDGEOT", "WING_ATTACK", "QUICK_ATTACK", "STEEL_WING", "MUD_SLAP"),
                        (38, "MAGMAR", "FIRE_PUNCH", "THUNDERPUNCH", "CONFUSE_RAY", "SMOKESCREEN")])],
        ]),
    ],

    # ===== COOLTRAINERF =====
    "COOLTRAINERF": [
        ("IRENE", "IRENE", "NORMAL", [
            [("NORMAL", [(22, "HORSEA"), (24, "STARMIE")])],
            [("NORMAL", [(24, "SEAKING")])],
        ]),
        ("JENN", "JENN", "NORMAL", [
            [("NORMAL", [(24, "SHELLDER"), (26, "CLOYSTER")])],
            [("NORMAL", [(26, "STARMIE")])],
        ]),
        ("KATE", "KATE", "NORMAL", [
            [("NORMAL", [(26, "STARYU"), (28, "STARMIE")])],
            [("NORMAL", [(28, "CLOYSTER")])],
        ]),
        ("GWEN", "GWEN", "NORMAL", [
            [("NORMAL", [(26, "TOGETIC"), (23, "ESPEON"), (24, "UMBREON"), (25, "FLAREON")])],
            [("NORMAL", [(25, "FLAREON"), (25, "VAPOREON"), (25, "JOLTEON")])],
        ]),
        ("EMMA", "EMMA", "NORMAL", [
            [("NORMAL", [(28, "QUAGSIRE")])],
            [("NORMAL", [(27, "POLIWAG"), (27, "MARILL")])],
        ]),
        ("LOIS", "LOIS", "MOVES", [
            [("MOVES", [(28, "SUNFLORA", "SUNNY_DAY", "MEGA_DRAIN", "GROWTH", "RAZOR_LEAF"),
                        (27, "ARCANINE", "FLAMETHROWER", "BITE", "TAKE_DOWN", "ROAR")])],
            [("MOVES", [(28, "VICTREEBEL", "RAZOR_LEAF", "SLEEP_POWDER", "ACID", "GROWTH")])],
        ]),
    ],

    # ===== BURGLAR =====
    "BURGLAR": [
        ("DUNCAN", "DUNCAN", "NORMAL", [
            [("NORMAL", [(35, "WEEZING"), (35, "HOUNDOOM")])],
            [("NORMAL", [(36, "MAGMAR")])],
        ]),
        ("EDDIE", "EDDIE", "MOVES", [
            [("MOVES", [(35, "HOUNDOOM", "FLAMETHROWER", "BITE", "SMOG", "ROAR"),
                        (35, "KOFFING", "SLUDGE", "SMOKESCREEN", "SELFDESTRUCT", "TACKLE")])],
            [("MOVES", [(36, "ARCANINE", "FLAMETHROWER", "BITE", "TAKE_DOWN", "ROAR")])],
        ]),
    ],
}


# ============================================================
# PARTY ENTRY FORMATTER
# ============================================================

def fmt_party_entry(const_name, display_name, ttype, mons):
    """Format a single party entry as assembly lines."""
    lines = [
        f"\t; {const_name}",
        f'\tdb "{display_name}@", TRAINERTYPE_{ttype}',
    ]
    for mon in mons:
        if ttype == "NORMAL":
            lines.append(f"\tdb {mon[0]}, {mon[1]}")
        elif ttype == "MOVES":
            lines.append(f"\tdb {mon[0]}, {mon[1]}, {mon[2]}, {mon[3]}, {mon[4]}, {mon[5]}")
        elif ttype == "ITEM":
            lines.append(f"\tdb {mon[0]}, {mon[1]}, {mon[2]}")
    lines.append("\tdb -1 ; end")
    return "\n".join(lines)


# ============================================================
# INTEGRATION FUNCTIONS
# ============================================================

def integrate_constants():
    """Insert variant const lines at end of each class block in trainer_constants.asm."""
    path = "constants/trainer_constants.asm"
    with open(path) as f:
        lines = f.readlines()

    # Safety check: don't run twice
    if any("_V1" in line for line in lines):
        print(f"SKIP: {path} already contains variant consts")
        return

    # Find the last const line index for each trainerclass block
    class_last_const = {}
    current_class = None
    for i, line in enumerate(lines):
        m = re.match(r'\s+trainerclass\s+(\w+)', line)
        if m:
            current_class = m.group(1)
        elif current_class and re.match(r'\s+const\s+', line):
            class_last_const[current_class] = i

    # Build insertions: {line_index: [new_lines]}
    insertions = {}
    total = 0
    for class_name, trainers in VARIANTS.items():
        if not trainers or class_name not in class_last_const:
            print(f"WARN: class '{class_name}' not found in constants")
            continue
        new_lines = []
        for entry in trainers:
            cname = entry[0]
            new_lines.append(f"\tconst {cname}_V1\n")
            new_lines.append(f"\tconst {cname}_V2\n")
            total += 2
        insertions[class_last_const[class_name]] = new_lines

    # Apply insertions in reverse order (so line numbers don't shift)
    for pos in sorted(insertions.keys(), reverse=True):
        for j, line in enumerate(insertions[pos]):
            lines.insert(pos + 1 + j, line)

    with open(path, "w") as f:
        f.writelines(lines)
    print(f"Updated {path} ({total} new const lines)")


def integrate_parties():
    """Insert variant party entries at end of each group in parties.asm."""
    path = "data/trainers/parties.asm"
    with open(path) as f:
        text = f.read()

    if "_V1\n" in text:
        print(f"SKIP: {path} already contains variant entries")
        return

    total = 0
    for class_name, trainers in VARIANTS.items():
        if not trainers:
            continue
        group = CLASS_TO_GROUP.get(class_name)
        if not group:
            print(f"WARN: no group mapping for '{class_name}'")
            continue

        # Find all group labels and their positions (recalculate each iteration)
        group_positions = [(m.group(1), m.start()) for m in
                           re.finditer(r'^(\w+Group):', text, re.MULTILINE)]

        # Find this group's position
        gpos = None
        for gl, gp in group_positions:
            if gl == group:
                gpos = gp
                break
        if gpos is None:
            print(f"WARN: '{group}' not found in parties")
            continue

        # Find next group after this one
        next_pos = len(text)
        for gl, gp in group_positions:
            if gp > gpos:
                next_pos = gp
                break

        # Build party entries
        new_text = ""
        for entry in trainers:
            cname = entry[0]
            dname = entry[1]
            v1_type, v1_mons = entry[3][0][0]
            v2_type, v2_mons = entry[3][1][0]
            new_text += "\n" + fmt_party_entry(f"{cname}_V1", dname, v1_type, v1_mons)
            new_text += "\n" + fmt_party_entry(f"{cname}_V2", dname, v2_type, v2_mons)
            total += 2
        new_text += "\n\n"

        # Insert before the next group
        text = text[:next_pos] + new_text + text[next_pos:]

    with open(path, "w") as f:
        f.write(text)
    print(f"Updated {path} ({total} new party entries)")


def integrate_table():
    """Populate TrainerVariantTable in trainer_variants.asm."""
    path = "engine/battle/trainer_variants.asm"
    with open(path) as f:
        text = f.read()

    # Build table entries
    entries = []
    for class_name, trainers in VARIANTS.items():
        if not trainers:
            continue
        for entry in trainers:
            cname = entry[0]
            entries.append(f"\tdb {class_name}, {cname}, {cname}_V1, {cname}_V2")

    table_content = "\n".join(entries)

    # Replace everything from TrainerVariantTable: to the $FF terminator
    new_table = (
        "TrainerVariantTable:\n"
        "; Format: db CLASS, BASE_ID, VARIANT1_ID, VARIANT2_ID\n"
        "; Terminated by $FF\n\n"
        f"{table_content}\n\n"
        "\tdb $FF ; end of table"
    )

    text = re.sub(
        r'TrainerVariantTable:.*?db \$FF[^\n]*',
        new_table,
        text,
        flags=re.DOTALL,
    )

    with open(path, "w") as f:
        f.write(text)
    print(f"Updated {path} ({len(entries)} table entries)")


# ============================================================
# MAIN
# ============================================================

def main():
    count = sum(len(t) for t in VARIANTS.values() if t)
    print(f"Processing {count} trainers across {sum(1 for t in VARIANTS.values() if t)} classes...")
    integrate_constants()
    integrate_parties()
    integrate_table()
    print(f"\nDone! {count} trainers x 2 variants = {count * 2} new party entries")
    print("Run 'make' to verify the build.")


if __name__ == "__main__":
    main()
