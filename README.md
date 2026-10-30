# 2D Game: Group 3

A top-down 2D action roguelike set in an elven forest, made in Godot 4.

**Team:** Joshua Juarez, Mahad Jamil, Zeinab Soumahoro II

## The Game

**Premise.** Pick a class and survive five waves of orcs in a forest arena. You get stronger during the run by leveling up. Clear all five waves to win. If you die, the run is over and you start fresh from class select.

**What it's about.** Short, replayable runs built on challenging but fair combat. The game is built around three stats: **HP**, **Speed** and **Strength**. Each class starts with a different spread of them, and every level-up lets you raise one. Nothing carries over between runs, so how far you get comes down to your class, your choices and your skill.

### How a run works

1. **Choose a class** on the start screen.
2. **Fight 5 waves of orcs.** Each wave has more orcs, and they get tougher and faster. Orcs come from every direction.
3. **Level up.** Each orc you defeat gives 1 XP and heals you a little. Each level-up pauses the game and lets you pick **+25 Max HP** (and heal 25), **+25 Speed** or **+5 Strength**.
4. **Win or die.** The result screen shows how far you got, and **Play again** takes you back to class select.

If you go 20 seconds without being hit, your health slowly regenerates.

### Classes

| Class | HP | Speed | Strength | Playstyle |
| --- | --- | --- | --- | --- |
| **Brawler** (knight) | 150 | 160 | 15 | Tanky with the longest sword reach, and can **block**. Wins by outlasting. |
| **Assassin** (hooded) | 80 | 260 | 15 | Fastest movement and attacks, and can **dash**. Darts in and out. |
| **Mage** | 90 | 200 | 25 | Hits hardest, every attack also launches a **fireball**, and she can cast a **tornado** to blow orcs away. Dies fast. |

### Controls

| Action | Keys |
| --- | --- |
| Move | WASD or arrow keys |
| Attack | Space or left mouse button |
| Block (Brawler) | Hold right mouse button: can't move or attack, takes no damage |
| Dash (Assassin) | Shift: quick dash in the direction you're moving, briefly invincible |
| Tornado (Mage) | Right mouse button: a tornado wraps around her for 1.5 s and blows orcs away (4 s cooldown) |

### Aesthetic

A traditional fantasy RPG look with an elves-and-woods feel, in 2D pixel art. The arena is a grassy forest clearing with varied trees, bushes, stumps and mushrooms. Characters and orcs are fully animated: idle, run, attack, hurt and death, plus the knight's block, the assassin's dash and the mage's tornado. Visual inspirations are classic Final Fantasy, and Hades for readable, punchy combat.

## Who made what

- **Joshua:** the core game loop. Player movement and combat, hitboxes and i-frames, the shared game state and class stats, orc enemies, the wave spawner, the level-up popup, class select and result screens, and the forest arena.
- **Mahad:** the three playable characters (knight, mage and hooded assassin) with their animation sets, the fireball and tornado abilities, and the spell effects art.
- **Zeinab:** the HUD's health and XP bars, the level display, and health regeneration.

## Project layout

```
2d-game/
├── assets/     art: soldier, orc, knight, mage, hooded, effects, environment, frames
├── scenes/     class_select, main_scene (the arena), result, level_up, orc, tree, decoration
│   ├── abilities/    fire_ball, tornado, explosion
│   ├── characters/   assassin (Mahad's original)
│   └── test/         Mahad's test arenas for the characters
└── scripts/    character (player), game_state, orc, wave_spawner, level_up, class_select, result, ...
    ├── abilities/    fire_ball, tornado, explosion
    └── characters/   brawler, mage, assassin (Mahad's original controllers)
```

Open `project.godot` in Godot 4 and press **Cmd + B** (Mac) or **F5** (Windows) to play from class select.

## Art credits

- Knight: *FREE Knight 2D Pixel Art*
- Mage: *Foozle Pointy Hat Mage*
- Assassin: *Dark Hooded Player*
- Spell effects: *Pixel Magic Effects*
- Soldier and Orc: *Tiny RPG Character* sprites
- Trees and decorations: *Trees+* sprite sheet
