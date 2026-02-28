# Pokemon Crystal Adventures

**A roguelike reimagining of Pokemon Crystal Legacy — different every time you play.**

Crystal Adventures transforms [Pokemon Crystal Legacy](https://github.com/cRz-Shadows/Pokemon_Crystal_Legacy) into a strategic, replayable adventure. Nuzlocke rules are built into the game, shops and gym teams are randomized, and healing costs money — every decision matters, and no two playthroughs are the same.

## Design Goals

- **High replayability** — Randomized starters, gym teams, shops, TM rewards, NPC trades, gift Pokemon, and overworld items mean each run feels fresh
- **Strategic resource management** — Paid healing and one-catch-per-route force you to think carefully about every battle and every Pokeball
- **Streamlined experience** — Faster early-game dialogue, optional tutorials, and a single balanced difficulty with no mode selection
- **Built on Crystal Legacy** — All of Legacy's polish, rebalanced learnsets, improved sprites, and quality-of-life fixes carry over

## Features

### Nuzlocke Catch Rule
Only the first wild Pokemon you encounter on each route can be caught. You get multiple Pokeball attempts during that encounter, but once it's over, that route is done. Static encounters (legendaries, gifts, special events) bypass this restriction. Every team you build is unique.

### Paid Healing
Pokemon Centers charge for their services:
- **1¥ per HP** restored
- **2¥ per PP** point restored
- **10¥** per status condition cured
- **Level x 25¥** to revive a fainted Pokemon (includes PP restoration)

The cost is shown before you commit. Budget wisely — running low on money with a battered team is a real danger.

### Randomized Starters
Three starters are randomly selected from a pool of eight: Chikorita, Totodile, Cyndaquil, Aipom, Sudowoodo, Smeargle, Swinub, and Mareep. Each starts at level 5 holding a Berry.

### Randomized Gym Leaders
All eight Johto Gym Leaders have multiple possible team configurations. Even if you know Crystal inside and out, you won't know exactly what Falkner, Whitney, or Clair will throw at you.

### Randomized Shops & TMs
Mart inventories change between playthroughs. Gym TM rewards and fixed TM pickups throughout Johto are drawn from randomized pools. 34 Gen 1 TMs (TM51–TM84) have been added, expanding the move options available.

### Randomized Trades, Gifts & Items
NPC trades, gift Pokemon (Karate King, Mania, Bill), and overworld item pickups all draw from randomized pools. The Route 36 weird tree encounter is randomized too.

### Catch Experience Bonus
Catching a wild Pokemon awards 2x experience, rewarding you for building your team rather than just knocking everything out.

### Improved Shiny Pokemon
Shininess is based on a Pokemon's combined DVs (stats). A higher DV total means a shiny Pokemon genuinely has stronger stats than average. The shiny threshold has been lowered for a roughly 3% encounter rate — rare enough to be exciting, common enough that you'll see them.

### Mystery Egg
Professor Elm's egg randomly contains one of eight baby Pokemon: Togepi, Pichu, Cleffa, Igglybuff, Smoochum, Elekid, Magby, or Tyrogue.

### Rival Teams
Your rival's team composition adapts based on which starter you chose, keeping the matchup dynamic across playthroughs.

### Quality of Life
- Skippable Prof. Oak intro explaining the game's mechanics
- Shortened early-game dialogue for faster pacing
- Optional Route 29 catching tutorial
- Elm's aide gives Poke Balls alongside the Potion for immediate catching
- Wild encounter distribution rebalanced for Nuzlocke play
- Rebalanced catch rates and repel prices

## Base Crystal Legacy Features

All improvements from Crystal Legacy are included:
- Refined Pokemon learnsets and stats
- Improved wild Pokemon distribution
- Enhanced Team Rocket storyline
- Balanced trainer and gym leader teams
- Quality of life improvements
- Custom sprites and animations
- Full Legacy documentation: [Crystal Legacy Docs](https://docs.google.com/document/d/1nFzUWtrQm85oQlPp_cxL-b2-WB2Igs9E1PmJQ23SQwQ/)

## Building

1. **Prerequisites**: RGBDS version 0.5.2
2. **Setup**: See [INSTALL.md](INSTALL.md)
3. **Build**: Run `make` — outputs `CrystalAdventures.gbc`

## Credits

### Crystal Adventures
- **Design & Development**: altbanty

### Crystal Legacy Team
- **Creator**: TheSmithPlays
- **Developer**: cRz Shadows
- **Video Editor**: Weebra
- **Project Manager**: Jaashouh

### Playtesters
Aerogod, Disq, Karlos, ZuperZACH, Regi, Isona, Bricemck, Daily, Tiberios, Sable, Niftimo, Tavros, Reader Dragon, Half1sch, Talos, Wootonmajr, Obelisk

### Sprite Artists
- **Overworld**: Katt, Karlos
- **Party**: Chamber, Soloo993, Blue Emerald, Lake, Neslug, Pikachu25, Tom Wang, Seasick

### Code Contributors
Rangi42, Idain, DamienDoury, Sylvie, aaaaaa123456789, SonicRay100, Edtv-thevoid, coco-bandicoot, MajorAgnostic, KDLPro, Nick-PC, XaeroChill, NobodySociety, Nayru62

### Foundation
Built on the [pret/pokecrystal](https://github.com/pret/pokecrystal) disassembly.

## Community

### Crystal Legacy
- [YouTube](https://www.youtube.com/@smithplayspokemon)
- [Discord](https://discord.gg/Wupx8tHRVS)
- [Twitter](https://twitter.com/TheSmithPlays)

### Pret
- [Discord][discord]
- [IRC][irc]
- [Tutorials][tutorials]

## Related Projects
- [Pokemon Yellow Legacy](https://github.com/cRz-Shadows/Pokemon_Yellow_Legacy)
- [Pokemon Cursed Yellow](https://github.com/cRz-Shadows/Pokemon_Cursed_Yellow)
- [Pokemon Battle Simulator](https://github.com/cRz-Shadows/Pokemon_Trainer_Tournament_Simulator)

---

*Crystal Adventures is an unofficial modification. Please support the original Crystal Legacy project and its creators.*

[discord]: https://discord.gg/d5dubZ3
[irc]: https://web.libera.chat/?#pret
[tutorials]: https://github.com/pret/pokecrystal/wiki/Tutorials
