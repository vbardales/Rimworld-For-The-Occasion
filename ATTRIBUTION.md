# Attribution

## What this mod is

An **original work**. It is not a port, not an extraction, and not a continuation. Every def,
every patch, every line of C# and every string in it was written for this mod.

That is why it carries neither the `Nelim's` prefix nor a ` 1.6` suffix: there is no upstream mod
whose place it could take, and nothing here needs anyone's permission to be redistributed.

## Where this mod started

**There is no origin repository.** `PUBLISHING.md` asks to start from the origin project's repository
when it has one, and to say so when it does not. This is an original work: there is no upstream mod to
clone or fork, no code to base this one on, and no pull request to send to anyone. The provenance
actually used is the one described in this file: RimWorld's own classes, called and never copied, and
the design notes of one MIT mod, read and not reused (see Shift Change below).

## RimWorld

- **Author:** Ludeon Studios.
- **Used how:** called, never copied.

The mod builds on vanilla classes and defs — `RitualOutcomeComp_Quality`, `LordJob_Ritual`,
`RitualBehaviorWorker`, `Pawn_JobTracker`, `Building_OutfitStand`, `CompAssignableToPawn`,
`Pawn_StyleTracker`, `PawnStyleItemChooser`, `GatheringsUtility`, `Building_Storage`. They are
subclassed, patched with Harmony or read; none of their code is reproduced here.

**One vanilla asset is referenced by path, not copied:** the offering table's `texPath` is
`Things/Building/Furniture/Table1x2`, the vanilla 1x2 table's own texture, loaded from the game's
own content at runtime. The mod ships no `Textures/` folder at all.

Two vanilla tag values are used as criteria rather than as content: the apparel tags `Royal`,
`RoyalRobe`, `Robe`, `Cape`, `BestowerHood` and `HoraxianCeremonial` decide which garments get
marked ceremonial. Reading a tag is not reproducing anything.

## Harmony

- **Author:** Andreas Pardeike.
- **Licence:** MIT.
- **Used how:** referenced as a NuGet package (`Lib.Harmony`), never redistributed. The assembly
  ships with the Harmony mod, which is declared as a dependency.

## Mods referenced by `MayRequire`, and nothing else

The offering categories name items from other mods so that those items count as offerings. A
`MayRequire` reference is a **name in a filter**: no file, def, texture or line of code is taken
from any of them, and each entry simply does not exist when its mod is absent.

| Mod | Referenced defs |
|---|---|
| RimScent Extended - Incense Plus (`nelim.rimscent.extended.incenseplus`) | the six `RimScentExtended_Incense_*` |
| Perfumes (`Romyashi.Perfumes`), by Romyashi | four `Romy_*Perfume` and `Romy_AromaflowerPetals` |
| Perfumes with Anima Expansion (`Romyashi.Perfumes` + `Romyashi.AnimaExpansion`), by Romyashi | `Romy_AnimaPerfume`, defined by Perfumes and gated on Anima Expansion |
| Vanilla Brewing Expanded (`VanillaExpanded.VBrewE`), by Oskar Potocki and team | ten `VBE_*` drinks; cider additionally requires Vanilla Plants Expanded (or its supported `_copy` package), matching VBE's LoadFolders |
| Rum and Shanties (`nelim.rumandshanties`) | `VFEP_Rum` |

## Shift Change

- **Author:** MrBeverage.
- **Source:** Steam Workshop [3783456242](https://steamcommunity.com/sharedfiles/filedetails/?id=3783456242),
  and its repository, [beverage/shift-change](https://github.com/beverage/shift-change).
- **Licence:** MIT, with sources and a `docs/DESIGN.md` shipped inside the mod.

**Nothing from it is reused.** Its design document was read before writing the wardrobe path, and
three facts it documents saved this mod from repeating its mistakes in play:

| What it documented | What this mod does with it |
|---|---|
| The `StartJob` insertion pattern, and the necessity of a re-entrancy guard | the same pattern, arrived at from the same vanilla source (`Pawn_JobTracker`'s opportunistic-haul path) |
| That the map-danger gate must sit **below** the return trip and **above** the dress paths, learned the hard way in a raid | the gate is placed there from the first version |
| That `CompAssignableToPawn` scribes flat, and that its gizmo's `Misc4` hotkey collides with the storage clipboard on a stand | prefixed scribe keys and a gizmo rebuilt without a hotkey |

Both mods put a `CompAssignableToPawn` subclass on the same `Building_OutfitStand` def. They are
written to cohabit: this one prefixes its save keys, drops the hotkey, and disables its own
assignment overlay so the two never draw two labels on one building. Shift Change dresses for work
and recreation and ignores rituals; this one dresses for rituals and nothing else. Neither
requires the other.

## RimFeast

- **Source:** Steam Workshop [3771681153](https://steamcommunity.com/sharedfiles/filedetails/?id=3771681153).

Not used, not read, not copied. Named here for honesty about where the idea comes from: RimFeast
applies "variety, not quantity" to its own bespoke medieval event. This mod applies the same idea
to vanilla rituals, from vanilla's own `RitualOutcomeComp` extension point.

## Tooling

The code was written with **Claude Code** (Anthropic), under human direction, review and testing.
Said openly in the mod's own description, not only here.

## Licence

MIT (`LICENSE`).

**Publishable as it stands.** No third-party file is redistributed, the only art referenced is the
game's own by path, and every mod interaction is a name in a filter or a Harmony hook on RimWorld
itself.
