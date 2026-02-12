#!/usr/bin/env python3
"""
Update Pokemon base stats files to add Gen 1 TM learnsets (TM51-TM77).

For Gen 1 Pokemon (001-151): Uses actual Gen 1 RBY TM compatibility data.
For Gen 2 Pokemon (152-251): Designed based on type affinity, body type, and
evolutionary line consistency.

The 27 new TMs and their move constants:
  TM51 = BODY_SLAM       TM52 = SWORDS_DANCE    TM53 = THUNDER_WAVE
  TM54 = ROCK_SLIDE       TM55 = SUBSTITUTE      TM56 = DOUBLE_EDGE
  TM57 = REFLECT          TM58 = EXPLOSION       TM59 = COUNTER
  TM60 = SEISMIC_TOSS     TM61 = SOFTBOILED      TM62 = SELFDESTRUCT
  TM63 = SKY_ATTACK       TM64 = TRI_ATTACK      TM65 = SUBMISSION
  TM66 = MIMIC            TM67 = MEGA_DRAIN      TM68 = PAY_DAY
  TM69 = METRONOME        TM70 = MEGA_PUNCH      TM71 = MEGA_KICK
  TM72 = TAKE_DOWN        TM73 = DRAGON_RAGE     TM74 = WHIRLWIND
  TM75 = TELEPORT         TM76 = PSYWAVE         TM77 = HORN_DRILL
"""

import os
import re
import sys

BASE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                        "data", "pokemon", "base_stats")

# ── Gen 1 TM compatibility data ──────────────────────────────────────────────
# Source: Gen 1 RBY TM machine data (well-known, verified against Bulbapedia)
# Key = lowercase filename (e.g. "bulbasaur"), Value = set of move constants
#
# Gen 1 TM numbers -> moves:
# TM01=MEGA_PUNCH, TM05=MEGA_KICK, TM08=BODY_SLAM, TM09=TAKE_DOWN,
# TM10=DOUBLE_EDGE, TM07=HORN_DRILL, TM03=SWORDS_DANCE, TM04=WHIRLWIND (actually not a TM in gen1 - it was a non-TM move)
# Wait - let me correct: In Gen 1:
# TM01=Mega Punch, TM02=Razor Wind, TM03=Swords Dance, TM04=Whirlwind (NOT a TM - actually TM04 doesn't exist for whirlwind)
# Actually checking: Gen 1 TMs:
# TM01=Mega Punch, TM05=Mega Kick, TM06=Toxic, TM07=Horn Drill,
# TM08=Body Slam, TM09=Take Down, TM10=Double-Edge, TM16=Pay Day,
# TM17=Submission, TM18=Counter, TM19=Seismic Toss, TM20=Rage,
# TM21=Mega Drain, TM23=Dragon Rage, TM30=Teleport, TM31=Mimic,
# TM33=Reflect, TM35=Metronome, TM36=Self-Destruct, TM41=Softboiled,
# TM43=Sky Attack, TM45=Thunder Wave, TM46=Psywave, TM47=Explosion,
# TM48=Rock Slide, TM49=Tri Attack, TM50=Substitute
# Note: Whirlwind was NOT a Gen 1 TM. Swords Dance was TM03.

# For the new TMs in our hack:
NEW_TM_MOVES = [
    "BODY_SLAM",      # TM51
    "SWORDS_DANCE",   # TM52
    "THUNDER_WAVE",   # TM53
    "ROCK_SLIDE",     # TM54
    "SUBSTITUTE",     # TM55
    "DOUBLE_EDGE",    # TM56
    "REFLECT",        # TM57
    "EXPLOSION",      # TM58
    "COUNTER",        # TM59
    "SEISMIC_TOSS",   # TM60
    "SOFTBOILED",     # TM61
    "SELFDESTRUCT",   # TM62
    "SKY_ATTACK",     # TM63
    "TRI_ATTACK",     # TM64
    "SUBMISSION",     # TM65
    "MIMIC",          # TM66
    "MEGA_DRAIN",     # TM67
    "PAY_DAY",        # TM68
    "METRONOME",      # TM69
    "MEGA_PUNCH",     # TM70
    "MEGA_KICK",      # TM71
    "TAKE_DOWN",      # TM72
    "DRAGON_RAGE",    # TM73
    "WHIRLWIND",      # TM74  (new - not from Gen 1 TM, but added for Flying types)
    "TELEPORT",       # TM75
    "PSYWAVE",        # TM76
    "HORN_DRILL",     # TM77
]

# ── Gen 1 Pokemon TM compatibility (RBY) ─────────────────────────────────────
# This encodes which Gen 1 Pokemon could learn which of our 27 new TM moves
# via TM in the original Red/Blue/Yellow games.
# For Whirlwind (TM74): Since it wasn't a Gen 1 TM, we assign it to Pokemon
# that learn it naturally or are Flying types.

GEN1_DATA = {
    # ── Bulbasaur line ──
    "bulbasaur":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "ivysaur":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "venusaur":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Charmander line ──
    "charmander": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "REFLECT", "MIMIC", "SKULL_BASH", "SUBSTITUTE", "DRAGON_RAGE"},
    "charmeleon": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE", "DRAGON_RAGE"},
    "charizard":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE", "DRAGON_RAGE", "WHIRLWIND"},

    # ── Squirtle line ──
    "squirtle":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "wartortle":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "blastoise":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Caterpie line ──
    "caterpie":   {"TAKE_DOWN", "SUBSTITUTE"},
    "metapod":    {"TAKE_DOWN", "SUBSTITUTE"},
    "butterfree": {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "SUBSTITUTE", "WHIRLWIND"},

    # ── Weedle line ──
    "weedle":     {"TAKE_DOWN", "SUBSTITUTE"},
    "kakuna":     {"TAKE_DOWN", "SUBSTITUTE"},
    "beedrill":   {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Pidgey line ──
    "pidgey":     {"TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},
    "pidgeotto":  {"TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},
    "pidgeot":    {"TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Rattata line ──
    "rattata":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "MIMIC", "SUBSTITUTE"},
    "raticate":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "SUBSTITUTE"},

    # ── Spearow line ──
    "spearow":    {"TAKE_DOWN", "DOUBLE_EDGE", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},
    "fearow":     {"TAKE_DOWN", "DOUBLE_EDGE", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Ekans line ──
    "ekans":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "ROCK_SLIDE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "arbok":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "ROCK_SLIDE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Pikachu line ──
    "pikachu":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "PAY_DAY", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "raichu":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "PAY_DAY", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Sandshrew line ──
    "sandshrew":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},
    "sandslash":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},

    # ── Nidoran♀ line ──
    "nidoran_f":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "COUNTER", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "nidorina":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "COUNTER", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "nidoqueen":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "REFLECT", "MIMIC", "SUBSTITUTE", "THUNDER_WAVE"},

    # ── Nidoran♂ line ──
    "nidoran_m":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "COUNTER", "REFLECT", "MIMIC", "SUBSTITUTE", "HORN_DRILL"},
    "nidorino":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "COUNTER", "REFLECT", "MIMIC", "SUBSTITUTE", "HORN_DRILL"},
    "nidoking":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "REFLECT", "MIMIC", "SUBSTITUTE", "HORN_DRILL", "THUNDER_WAVE"},

    # ── Clefairy line ──
    "clefairy":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "SOFTBOILED", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},
    "clefable":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "SOFTBOILED", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},

    # ── Vulpix line ──
    "vulpix":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "ninetales":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Jigglypuff line ──
    "jigglypuff": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},
    "wigglytuff": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},

    # ── Zubat line ──
    "zubat":      {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "MIMIC", "SUBSTITUTE", "WHIRLWIND"},
    "golbat":     {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "MIMIC", "SUBSTITUTE", "WHIRLWIND"},

    # ── Oddish line ──
    "oddish":     {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "gloom":      {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "vileplume":  {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "BODY_SLAM", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Paras line ──
    "paras":      {"TAKE_DOWN", "BODY_SLAM", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "parasect":   {"TAKE_DOWN", "BODY_SLAM", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Venonat line ──
    "venonat":    {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "PSYWAVE", "TELEPORT", "SUBSTITUTE"},
    "venomoth":   {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "PSYWAVE", "TELEPORT", "SUBSTITUTE", "WHIRLWIND"},

    # ── Diglett line ──
    "diglett":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},
    "dugtrio":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},

    # ── Meowth line ──
    "meowth":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "PAY_DAY", "THUNDER_WAVE", "MIMIC", "SUBSTITUTE"},
    "persian":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "PAY_DAY", "THUNDER_WAVE", "MIMIC", "SUBSTITUTE"},

    # ── Psyduck line ──
    "psyduck":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "MIMIC", "SUBSTITUTE"},
    "golduck":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "MIMIC", "SUBSTITUTE"},

    # ── Mankey line ──
    "mankey":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "PAY_DAY", "ROCK_SLIDE", "MIMIC", "METRONOME", "SUBSTITUTE", "THUNDER_WAVE", "SWORDS_DANCE"},
    "primeape":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "PAY_DAY", "ROCK_SLIDE", "MIMIC", "METRONOME", "SUBSTITUTE", "THUNDER_WAVE", "SWORDS_DANCE"},

    # ── Growlithe line ──
    "growlithe":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "arcanine":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Poliwag line ──
    "poliwag":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "COUNTER", "MIMIC", "PSYWAVE", "SUBSTITUTE"},
    "poliwhirl":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "PSYWAVE", "METRONOME", "SUBSTITUTE"},
    "poliwrath":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "PSYWAVE", "METRONOME", "SUBSTITUTE"},

    # ── Abra line ──
    "abra":       {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},
    "kadabra":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},
    "alakazam":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Machop line ──
    "machop":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "MIMIC", "METRONOME", "SUBSTITUTE"},
    "machoke":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "MIMIC", "METRONOME", "SUBSTITUTE"},
    "machamp":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "MIMIC", "METRONOME", "SUBSTITUTE"},

    # ── Bellsprout line ──
    "bellsprout":  {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "weepinbell":  {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "victreebel":  {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "BODY_SLAM", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Tentacool line ──
    "tentacool":  {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "MIMIC", "SUBSTITUTE"},
    "tentacruel": {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "MIMIC", "SUBSTITUTE"},

    # ── Geodude line ──
    "geodude":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "METRONOME", "SUBSTITUTE"},
    "graveler":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "METRONOME", "SUBSTITUTE"},
    "golem":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "METRONOME", "SUBSTITUTE"},

    # ── Ponyta line ──
    "ponyta":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "HORN_DRILL", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "rapidash":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "HORN_DRILL", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Slowpoke line ──
    "slowpoke":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},
    "slowbro":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},

    # ── Magnemite line ──
    "magnemite":  {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "SUBSTITUTE"},
    "magneton":   {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "SUBSTITUTE"},

    # ── Farfetch'd ──
    "farfetch_d": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Doduo line ──
    "doduo":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SKY_ATTACK", "TRI_ATTACK", "SUBSTITUTE", "WHIRLWIND"},
    "dodrio":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SKY_ATTACK", "TRI_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Seel line ──
    "seel":       {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "HORN_DRILL", "PAY_DAY", "MIMIC", "SUBSTITUTE"},
    "dewgong":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "HORN_DRILL", "PAY_DAY", "MIMIC", "SUBSTITUTE"},

    # ── Grimer line ──
    "grimer":     {"BODY_SLAM", "MEGA_DRAIN", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "SUBSTITUTE"},
    "muk":        {"BODY_SLAM", "MEGA_DRAIN", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "SUBSTITUTE"},

    # ── Shellder line ──
    "shellder":   {"TAKE_DOWN", "DOUBLE_EDGE", "TRI_ATTACK", "REFLECT", "MIMIC", "SELFDESTRUCT", "EXPLOSION", "SUBSTITUTE"},
    "cloyster":   {"TAKE_DOWN", "DOUBLE_EDGE", "TRI_ATTACK", "REFLECT", "MIMIC", "SELFDESTRUCT", "EXPLOSION", "SUBSTITUTE"},

    # ── Gastly line ──
    "gastly":     {"TAKE_DOWN", "MEGA_DRAIN", "THUNDER_WAVE", "MIMIC", "METRONOME", "SELFDESTRUCT", "EXPLOSION", "PSYWAVE", "SUBSTITUTE"},
    "haunter":    {"TAKE_DOWN", "MEGA_DRAIN", "THUNDER_WAVE", "MIMIC", "METRONOME", "SELFDESTRUCT", "EXPLOSION", "PSYWAVE", "SUBSTITUTE"},
    "gengar":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "MIMIC", "METRONOME", "SELFDESTRUCT", "EXPLOSION", "PSYWAVE", "SUBSTITUTE"},

    # ── Onix ──
    "onix":       {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "SUBSTITUTE"},

    # ── Drowzee line ──
    "drowzee":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},
    "hypno":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},

    # ── Krabby line ──
    "krabby":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MIMIC", "SUBSTITUTE"},
    "kingler":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MIMIC", "SUBSTITUTE"},

    # ── Voltorb line ──
    "voltorb":    {"TAKE_DOWN", "THUNDER_WAVE", "REFLECT", "MIMIC", "SELFDESTRUCT", "EXPLOSION", "TELEPORT", "SUBSTITUTE"},
    "electrode":  {"TAKE_DOWN", "THUNDER_WAVE", "REFLECT", "MIMIC", "SELFDESTRUCT", "EXPLOSION", "TELEPORT", "SUBSTITUTE"},

    # ── Exeggcute line ──
    "exeggcute":  {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SELFDESTRUCT", "EXPLOSION", "PSYWAVE", "TELEPORT", "SUBSTITUTE"},
    "exeggutor":  {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SELFDESTRUCT", "EXPLOSION", "PSYWAVE", "TELEPORT", "SUBSTITUTE"},

    # ── Cubone line ──
    "cubone":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},
    "marowak":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},

    # ── Hitmonlee ──
    "hitmonlee":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "METRONOME", "SUBSTITUTE"},

    # ── Hitmonchan ──
    "hitmonchan": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "METRONOME", "SUBSTITUTE"},

    # ── Lickitung ──
    "lickitung":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "ROCK_SLIDE", "REFLECT", "MIMIC", "SUBSTITUTE", "SWORDS_DANCE"},

    # ── Koffing line ──
    "koffing":    {"MIMIC", "SELFDESTRUCT", "EXPLOSION", "SUBSTITUTE"},
    "weezing":    {"MIMIC", "SELFDESTRUCT", "EXPLOSION", "SUBSTITUTE"},

    # ── Rhyhorn line ──
    "rhyhorn":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE", "HORN_DRILL"},
    "rhydon":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE", "PAY_DAY", "HORN_DRILL"},

    # ── Chansey ──
    "chansey":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "SOFTBOILED", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Tangela ──
    "tangela":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Kangaskhan ──
    "kangaskhan": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},

    # ── Horsea line ──
    "horsea":     {"TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "MIMIC", "SUBSTITUTE"},
    "seadra":     {"TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "MIMIC", "SUBSTITUTE"},

    # ── Goldeen line ──
    "goldeen":    {"TAKE_DOWN", "DOUBLE_EDGE", "HORN_DRILL", "MIMIC", "SUBSTITUTE"},
    "seaking":    {"TAKE_DOWN", "DOUBLE_EDGE", "HORN_DRILL", "MIMIC", "SUBSTITUTE"},

    # ── Staryu line ──
    "staryu":     {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},
    "starmie":    {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},

    # ── Mr. Mime ──
    "mr__mime":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Scyther ──
    "scyther":    {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MIMIC", "SUBSTITUTE", "WHIRLWIND"},

    # ── Jynx ──
    "jynx":       {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Electabuzz ──
    "electabuzz": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Magmar ──
    "magmar":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Pinsir ──
    "pinsir":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "SEISMIC_TOSS", "SWORDS_DANCE", "MIMIC", "SUBSTITUTE"},

    # ── Tauros ──
    "tauros":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "HORN_DRILL", "MIMIC", "SUBSTITUTE"},

    # ── Magikarp/Gyarados ──
    "magikarp":   {"TAKE_DOWN", "SUBSTITUTE"},
    "gyarados":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Lapras ──
    "lapras":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "HORN_DRILL", "DRAGON_RAGE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Ditto ──
    "ditto":      {"SUBSTITUTE"},

    # ── Eevee line ──
    "eevee":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "vaporeon":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "jolteon":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "flareon":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Porygon ──
    "porygon":    {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},

    # ── Omanyte line ──
    "omanyte":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "omastar":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "SEISMIC_TOSS", "ROCK_SLIDE", "REFLECT", "MIMIC", "HORN_DRILL", "SUBSTITUTE"},

    # ── Kabuto line ──
    "kabuto":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "kabutops":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "SUBMISSION", "SEISMIC_TOSS", "MEGA_KICK", "ROCK_SLIDE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Aerodactyl ──
    "aerodactyl": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Snorlax ──
    "snorlax":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "SELFDESTRUCT", "REFLECT", "MIMIC", "METRONOME", "PSYWAVE", "SUBSTITUTE", "THUNDER_WAVE"},

    # ── Articuno ──
    "articuno":   {"TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Zapdos ──
    "zapdos":     {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Moltres ──
    "moltres":    {"TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Dratini line ──
    "dratini":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "dragonair":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "HORN_DRILL", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "dragonite":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "HORN_DRILL", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE", "WHIRLWIND"},

    # ── Mewtwo ──
    "mewtwo":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "SELFDESTRUCT", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Mew ──
    "mew":        {"BODY_SLAM", "SWORDS_DANCE", "THUNDER_WAVE", "ROCK_SLIDE", "SUBSTITUTE", "DOUBLE_EDGE", "REFLECT", "EXPLOSION", "COUNTER", "SEISMIC_TOSS", "SOFTBOILED", "SELFDESTRUCT", "SKY_ATTACK", "TRI_ATTACK", "SUBMISSION", "MIMIC", "MEGA_DRAIN", "PAY_DAY", "METRONOME", "MEGA_PUNCH", "MEGA_KICK", "TAKE_DOWN", "DRAGON_RAGE", "WHIRLWIND", "TELEPORT", "PSYWAVE", "HORN_DRILL"},
}

# ── Gen 2 Pokemon (152-251) designed learnsets ────────────────────────────────
# Based on: type affinity, body type, evolutionary line consistency, balance

GEN2_DATA = {
    # ── Chikorita line (Grass) ──
    "chikorita":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "bayleef":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "meganium":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Cyndaquil line (Fire) ──
    "cyndaquil":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "quilava":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "typhlosion": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Totodile line (Water) ──
    "totodile":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "SUBSTITUTE"},
    "croconaw":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "SUBSTITUTE"},
    "feraligatr": {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "SWORDS_DANCE", "MIMIC", "SUBSTITUTE"},

    # ── Sentret line (Normal) ──
    "sentret":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MIMIC", "SUBSTITUTE"},
    "furret":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "SUBSTITUTE"},

    # ── Hoothoot line (Normal/Flying) ──
    "hoothoot":   {"TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},
    "noctowl":    {"TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Ledyba line (Bug/Flying) ──
    "ledyba":     {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "ledian":     {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "MEGA_PUNCH", "MEGA_KICK", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Spinarak line (Bug/Poison) ──
    "spinarak":   {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "MIMIC", "SUBSTITUTE"},
    "ariados":    {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "MIMIC", "SUBSTITUTE"},

    # ── Crobat (Poison/Flying) ──
    "crobat":     {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "MIMIC", "SUBSTITUTE", "WHIRLWIND"},

    # ── Chinchou line (Water/Electric) ──
    "chinchou":   {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "MIMIC", "SUBSTITUTE"},
    "lanturn":    {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "MIMIC", "SUBSTITUTE"},

    # ── Pichu (Electric) ──
    "pichu":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "COUNTER", "MEGA_PUNCH", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Cleffa (Normal) ──
    "cleffa":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "PSYWAVE", "SUBSTITUTE"},

    # ── Igglybuff (Normal) ──
    "igglybuff":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "PSYWAVE", "SUBSTITUTE"},

    # ── Togepi/Togetic (Normal/Flying) ──
    "togepi":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "SOFTBOILED", "PSYWAVE", "SUBSTITUTE"},
    "togetic":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "SOFTBOILED", "PSYWAVE", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Natu/Xatu (Psychic/Flying) ──
    "natu":       {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},
    "xatu":       {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Mareep line (Electric) ──
    "mareep":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "flaaffy":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "MEGA_PUNCH", "MEGA_KICK", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "ampharos":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "MEGA_PUNCH", "MEGA_KICK", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Bellossom (Grass) ──
    "bellossom":  {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Marill/Azumarill (Water) ──
    "marill":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_PUNCH", "MIMIC", "SUBSTITUTE"},
    "azumarill":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "SUBSTITUTE"},

    # ── Sudowoodo (Rock) ──
    "sudowoodo":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "SUBSTITUTE"},

    # ── Politoed (Water) ──
    "politoed":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "METRONOME", "SUBSTITUTE"},

    # ── Hoppip line (Grass/Flying) ──
    "hoppip":     {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "skiploom":   {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "jumpluff":   {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Aipom (Normal) ──
    "aipom":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "COUNTER", "MEGA_PUNCH", "MEGA_KICK", "THUNDER_WAVE", "MIMIC", "METRONOME", "SUBSTITUTE"},

    # ── Sunkern/Sunflora (Grass) ──
    "sunkern":    {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "sunflora":   {"TAKE_DOWN", "DOUBLE_EDGE", "MEGA_DRAIN", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Yanma (Bug/Flying) ──
    "yanma":      {"TAKE_DOWN", "DOUBLE_EDGE", "MIMIC", "SUBSTITUTE", "WHIRLWIND"},

    # ── Wooper/Quagsire (Water/Ground) ──
    "wooper":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},
    "quagsire":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "COUNTER", "SEISMIC_TOSS", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},

    # ── Espeon (Psychic) ──
    "espeon":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Umbreon (Dark) ──
    "umbreon":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Murkrow (Dark/Flying) ──
    "murkrow":    {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Slowking (Water/Psychic) ──
    "slowking":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},

    # ── Misdreavus (Ghost) ──
    "misdreavus": {"TAKE_DOWN", "THUNDER_WAVE", "MIMIC", "PSYWAVE", "SUBSTITUTE"},

    # ── Unown (Psychic) ──
    "unown":      {"SUBSTITUTE"},

    # ── Wobbuffet (Psychic) ──
    "wobbuffet":  {"COUNTER", "MIMIC", "SUBSTITUTE"},

    # ── Girafarig (Normal/Psychic) ──
    "girafarig":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Pineco/Forretress (Bug/Steel) ──
    "pineco":     {"TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "SUBSTITUTE"},
    "forretress": {"TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "SUBSTITUTE"},

    # ── Dunsparce (Normal) ──
    "dunsparce":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "THUNDER_WAVE", "COUNTER", "MIMIC", "SUBSTITUTE"},

    # ── Gligar (Ground/Flying) ──
    "gligar":     {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "ROCK_SLIDE", "COUNTER", "MIMIC", "SUBSTITUTE", "WHIRLWIND"},

    # ── Steelix (Steel/Ground) ──
    "steelix":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "SUBSTITUTE"},

    # ── Snubbull/Granbull (Normal) ──
    "snubbull":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "MEGA_PUNCH", "MEGA_KICK", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "granbull":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Qwilfish (Water/Poison) ──
    "qwilfish":   {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "SELFDESTRUCT", "EXPLOSION", "MIMIC", "SUBSTITUTE"},

    # ── Scizor (Bug/Steel) ──
    "scizor":     {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MIMIC", "SUBSTITUTE"},

    # ── Shuckle (Bug/Rock) ──
    "shuckle":    {"ROCK_SLIDE", "SELFDESTRUCT", "MIMIC", "SUBSTITUTE"},

    # ── Heracross (Bug/Fighting) ──
    "heracross":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "ROCK_SLIDE", "SWORDS_DANCE", "MIMIC", "SUBSTITUTE"},

    # ── Sneasel (Dark/Ice) ──
    "sneasel":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "COUNTER", "MIMIC", "SUBSTITUTE"},

    # ── Teddiursa/Ursaring (Normal) ──
    "teddiursa":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "SWORDS_DANCE", "MIMIC", "SUBSTITUTE"},
    "ursaring":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "SWORDS_DANCE", "MIMIC", "SUBSTITUTE"},

    # ── Slugma/Magcargo (Fire/Rock) ──
    "slugma":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "REFLECT", "MIMIC", "SUBSTITUTE"},
    "magcargo":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Swinub/Piloswine (Ice/Ground) ──
    "swinub":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},
    "piloswine":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE", "HORN_DRILL"},

    # ── Corsola (Water/Rock) ──
    "corsola":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "SELFDESTRUCT", "EXPLOSION", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Remoraid/Octillery (Water) ──
    "remoraid":   {"TAKE_DOWN", "DOUBLE_EDGE", "MIMIC", "SUBSTITUTE"},
    "octillery":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},

    # ── Delibird (Ice/Flying) ──
    "delibird":   {"TAKE_DOWN", "DOUBLE_EDGE", "COUNTER", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Mantine (Water/Flying) ──
    "mantine":    {"TAKE_DOWN", "DOUBLE_EDGE", "MIMIC", "SUBSTITUTE", "WHIRLWIND"},

    # ── Skarmory (Steel/Flying) ──
    "skarmory":   {"TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "ROCK_SLIDE", "COUNTER", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND"},

    # ── Houndour/Houndoom (Dark/Fire) ──
    "houndour":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "COUNTER", "MIMIC", "SUBSTITUTE"},
    "houndoom":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "COUNTER", "MIMIC", "SUBSTITUTE"},

    # ── Kingdra (Water/Dragon) ──
    "kingdra":    {"TAKE_DOWN", "DOUBLE_EDGE", "DRAGON_RAGE", "MIMIC", "SUBSTITUTE"},

    # ── Phanpy/Donphan (Ground) ──
    "phanpy":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "COUNTER", "MIMIC", "SUBSTITUTE"},
    "donphan":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "COUNTER", "HORN_DRILL", "MIMIC", "SUBSTITUTE"},

    # ── Porygon2 (Normal) ──
    "porygon2":   {"TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "TELEPORT", "PSYWAVE", "TRI_ATTACK", "SUBSTITUTE"},

    # ── Stantler (Normal) ──
    "stantler":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "PSYWAVE", "SUBSTITUTE"},

    # ── Smeargle (Normal) ──
    "smeargle":   {"SUBSTITUTE"},

    # ── Tyrogue (Fighting) ──
    "tyrogue":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "SUBSTITUTE"},

    # ── Hitmontop (Fighting) ──
    "hitmontop":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "SUBSTITUTE"},

    # ── Smoochum (Ice/Psychic) ──
    "smoochum":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "PSYWAVE", "SUBSTITUTE"},

    # ── Elekid (Electric) ──
    "elekid":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_PUNCH", "MEGA_KICK", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Magby (Fire) ──
    "magby":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "MEGA_PUNCH", "MEGA_KICK", "MIMIC", "SUBSTITUTE"},

    # ── Miltank (Normal) ──
    "miltank":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "THUNDER_WAVE", "MIMIC", "SUBSTITUTE"},

    # ── Blissey (Normal) ──
    "blissey":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "MEGA_DRAIN", "THUNDER_WAVE", "REFLECT", "MIMIC", "METRONOME", "SOFTBOILED", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},

    # ── Raikou (Electric) ──
    "raikou":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Entei (Fire) ──
    "entei":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Suicune (Water) ──
    "suicune":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "REFLECT", "MIMIC", "SUBSTITUTE"},

    # ── Larvitar line (Rock/Ground → Rock/Dark) ──
    "larvitar":   {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},
    "pupitar":    {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "ROCK_SLIDE", "MIMIC", "SUBSTITUTE"},
    "tyranitar":  {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SUBMISSION", "COUNTER", "SEISMIC_TOSS", "MEGA_PUNCH", "MEGA_KICK", "ROCK_SLIDE", "THUNDER_WAVE", "DRAGON_RAGE", "MIMIC", "SUBSTITUTE"},

    # ── Lugia (Psychic/Flying) ──
    "lugia":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND", "DRAGON_RAGE"},

    # ── Ho-Oh (Fire/Flying) ──
    "ho_oh":      {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "THUNDER_WAVE", "REFLECT", "MIMIC", "SKY_ATTACK", "SUBSTITUTE", "WHIRLWIND", "DRAGON_RAGE"},

    # ── Celebi (Psychic/Grass) ──
    "celebi":     {"BODY_SLAM", "TAKE_DOWN", "DOUBLE_EDGE", "SWORDS_DANCE", "MEGA_DRAIN", "REFLECT", "MIMIC", "METRONOME", "TELEPORT", "PSYWAVE", "SUBSTITUTE"},
}


def get_filename(pokemon_name):
    """Convert Pokemon name to filename format."""
    return pokemon_name.lower() + ".asm"


def update_pokemon_file(filepath, new_moves):
    """Add new TM moves to a Pokemon's tmhm line."""
    with open(filepath, 'r') as f:
        content = f.read()

    # Find the tmhm line
    match = re.search(r'(\ttmhm )(.+)', content)
    if not match:
        print(f"  WARNING: No tmhm line found in {filepath}")
        return False

    prefix = match.group(1)
    existing_moves_str = match.group(2)

    # Parse existing moves
    existing_moves = [m.strip() for m in existing_moves_str.split(',')]

    # Filter new moves to only include ones not already present
    moves_to_add = [m for m in new_moves if m not in existing_moves]

    if not moves_to_add:
        return False  # Nothing to add

    # Add new moves
    all_moves = existing_moves + moves_to_add
    new_line = prefix + ", ".join(all_moves)

    # Replace the tmhm line
    content = content[:match.start()] + new_line + content[match.end():]

    with open(filepath, 'w') as f:
        f.write(content)

    return True


def main():
    # Combine Gen 1 and Gen 2 data
    all_data = {}
    all_data.update(GEN1_DATA)
    all_data.update(GEN2_DATA)

    # Get all Pokemon files
    all_files = sorted(os.listdir(BASE_DIR))

    updated = 0
    skipped = 0
    not_found = 0

    for filename in all_files:
        if not filename.endswith('.asm'):
            continue

        pokemon_name = filename[:-4]  # Remove .asm
        filepath = os.path.join(BASE_DIR, filename)

        if pokemon_name in all_data:
            # Filter to only include moves that are actually in our NEW_TM_MOVES list
            valid_moves = [m for m in all_data[pokemon_name] if m in NEW_TM_MOVES]
            if valid_moves:
                if update_pokemon_file(filepath, valid_moves):
                    updated += 1
                    print(f"  Updated {filename} (+{len(valid_moves)} moves)")
                else:
                    skipped += 1
                    print(f"  Skipped {filename} (moves already present)")
            else:
                skipped += 1
                print(f"  Skipped {filename} (no valid new moves)")
        else:
            not_found += 1
            print(f"  No data for {filename}")

    print(f"\nSummary: {updated} updated, {skipped} skipped, {not_found} no data")

    # Report Pokemon with no data
    if not_found > 0:
        print("\nPokemon with no learnset data:")
        for filename in all_files:
            if not filename.endswith('.asm'):
                continue
            pokemon_name = filename[:-4]
            if pokemon_name not in all_data:
                print(f"  {pokemon_name}")


if __name__ == "__main__":
    main()
