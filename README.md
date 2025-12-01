# Pokémon Crystal Adventures

**A roguelike enhancement mod built on top of Pokémon Crystal Legacy**

This project extends [Pokémon Crystal Legacy](https://github.com/cRz-Shadows/Pokemon_Crystal_Legacy) by TheSmithPlays with additional gameplay mechanics that transform the experience into a roguelike adventure. Crystal Adventures maintains all the polish and balance improvements of Crystal Legacy while adding strategic depth through limited resources and randomized encounters.

## What is Crystal Adventures?

Crystal Adventures takes the refined Crystal Legacy experience and adds:
- **Nuzlocke Encounter System** - One catch per route creates roguelike team building
- **Paid Healing** - Resource management through Pokémon Center fees
- **Random Starter Eggs** - Each playthrough begins with a different baby Pokémon
- **Adventure Mode** - Single balanced difficulty for consistent challenge

## New Features in Crystal Adventures

### 🎲 Nuzlocke Encounter System
- Only the first wild Pokémon encountered on each route can be caught
- Multiple Poké Ball attempts allowed during that first encounter
- Static encounters (legendaries, gifts) bypass this restriction
- Creates unique team compositions each playthrough

### 💰 Pokémon Center Economics
- Healing now costs money based on:
  - 1¥ per HP restored
  - 1¥ per PP restored  
  - 1¥ per status condition cured
  - Level × 10¥ for reviving fainted Pokémon
- Cost displayed before accepting treatment
- Adds resource management strategy

### 🥚 Random Mystery Eggs
- Professor Elm's egg randomly contains one of 8 baby Pokémon:
  - Togepi, Pichu, Cleffa, Igglybuff, Smoochum, Elekid, Magby, or Tyrogue
- Each playthrough starts with a different support Pokémon
- Story progression unchanged regardless of which Pokémon hatches

### ⚖️ Streamlined Difficulty
- Removed Normal/Hardcore modes
- "Adventure Mode" (formerly Hard mode) is always active
- Provides consistent, balanced challenge for all players

### 🎒 Early Game Improvements
- Elm's aide now provides 5 Poké Balls with the Potion
- Enables catching on Route 29 immediately
- Moveset adjustments for early gym viability:
  - Totodile learns Rage at level 10
  - Geodude learns Rock Throw at level 10

## Base Crystal Legacy Features

This mod includes all improvements from Crystal Legacy v1.3.11:
- Refined Pokémon learnsets and stats
- Improved wild Pokémon distribution
- Enhanced Team Rocket storyline
- Balanced gym leader teams
- Quality of life improvements
- Custom sprites and animations
- Full documentation at: https://docs.google.com/document/d/1nFzUWtrQm85oQlPp_cxL-b2-WB2Igs9E1PmJQ23SQwQ/

## Installation

1. **Prerequisites**: Requires RGBDS version 0.5.2
2. **Setup**: Follow instructions in [INSTALL.md](INSTALL.md)
3. **Building**: Use `make` to compile the ROM

## Technical Implementation

Crystal Adventures modifies the Crystal Legacy codebase with:
- 8-byte Nuzlocke tracking system (64 encounter zones)
- WRAM modifications for encounter flags
- Script system integration for healing costs
- Modified item effect handlers for catch restrictions

## Credits

### Crystal Adventures Development
- **Design & Implementation**: Community contribution
- **Based on**: Pokémon Crystal Legacy v1.3.11

### Crystal Legacy Team
- **Creator**: TheSmithPlays
- **Developers**: cRz Shadows
- **Video Editor**: Weebra
- **Project Manager**: Jaashouh
- Full Legacy credits preserved below

### Original Crystal Legacy Credits

#### Playtesters:
Aerogod, Disq, Karlos, ZuperZACH, Regi, Isona, Bricemck, Daily, Tiberios, Sable, Niftimo, Tavros, Reader Dragon, Half1sch, Talos, Wootonmajr, Obelisk

#### Sprite Artists:
- **Overworld sprites**: Katt, Karlos
- **Party sprites**: Chamber, Soloo993, Blue Emerald, Lake, Neslug, Pikachu25, Tom Wang, Seasick

#### Code Contributors:
Rangi42, Idain, DamienDoury, Sylvie, aaaaaa123456789, SonicRay100, Edtv-thevoid, coco-bandicoot, MajorAgnostic, KDLPro, Nick-PC, XaeroChill, NobodySociety, Nayru62

### Foundation
Built on [pret/pokecrystal](https://github.com/pret/pokecrystal) disassembly

## Community

### Crystal Legacy Community:
- **YouTube**: https://www.youtube.com/@smithplayspokemon
- **Discord**: https://discord.gg/Wupx8tHRVS
- **Twitter**: https://twitter.com/TheSmithPlays

### Pret Community:
- **Discord**: [pret][discord]
- **IRC**: [libera#pret][irc]
- **Wiki**: [tutorials][tutorials]

## Related Projects
- **Pokémon Yellow Legacy**: https://github.com/cRz-Shadows/Pokemon_Yellow_Legacy
- **Pokémon Cursed Yellow**: https://github.com/cRz-Shadows/Pokemon_Cursed_Yellow
- **Pokémon Battle Simulator**: https://github.com/cRz-Shadows/Pokemon_Trainer_Tournament_Simulator

---

*Crystal Adventures is an unofficial modification. Please support the original Crystal Legacy project and its creators.*

[docs]: https://github.com/pret/pokecrystal/tree/master/docs
[wiki]: https://github.com/pret/pokecrystal/wiki
[tutorials]: https://github.com/pret/pokecrystal/wiki/Tutorials
[discord]: https://discord.gg/d5dubZ3
[irc]: https://web.libera.chat/?#pret