# Changelog

Format inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This file serves the repository and the Steam release notes; RimWorld does not display it in game.

## [1.0.0] — unreleased

First release. RimWorld 1.6. Original work, Ideology required, Odyssey optional.

### Pre-release corrections — 2026-09-13

- Disabling preparation still allows borrowers to return clothes and remove temporary face
  paint at the next eligible job change, including during a ritual. A pending dressing trip
  no longer equips an outfit after the option was disabled.
- Added an optional MainButtons shortcut, hidden by default and using the same native settings
  dialog as Mod options. RIMMSQOL is not required; its interactive integration awaits game tests.
- Numeric settings normalize old/out-of-range/nonfinite values. Saving settings invalidates
  the anticipation cache and reapplies the quality budget. Added English/French scope guidance.
- Corrected the Preview's linking-word typography and added the description's GitHub link.
- Matched optional-item gates to current 1.6 definitions: anima perfume needs Perfumes plus
  Anima Expansion; VBE cider also needs Vanilla Plants Expanded or its supported copy package.
- Extended the out-of-game harness from 30 to 38 tests, including settings serialization and
  regression checks. Final in-game scenarios remain unexecuted.

### Offerings

- New building, the **offering table** (Ideology tab): a 1x2 `Building_Storage` to stand beside
  the altar. No art produced — the vanilla `Table1x2` texture path is reused as it is.
- What is laid out on it, inside the ritual's gathering area, raises the quality of the rite:
  0 → 0, 1 → 4 %, 2 → 7 %, 3 → 10 %, 4 → 12 %.
- **What counts is the number of distinct categories, not the quantity.** Four categories ship:
  scent, fine food, drink, treasure. Three hundred beers are still three hundred beers.
- Offerings that counted are **consumed** when the ritual ends. Without that step you would build
  the table once and every ritual in the game would be better forever. A cancelled ritual takes
  nothing.
- An item counts towards at most one category: a stack of chocolate cannot fill both "fine food"
  and "treasure".
- The table's storage filter is **built at startup** from the union of the `OfferingCategoryDef`s.
  The list of acceptable items therefore exists in exactly one place, and a mod adding a category
  of its own makes its items storable without patching anything.
- Modded items are wired in through individual `MayRequire` entries: incense from **RimScent
  Extended - Incense Plus**, perfumes from **RimScent: Perfume Expansion**, drinks from **Vanilla
  Brewing Expanded**, rum from **Rum and Shanties**. A category whose items are all absent still
  loads; it simply never gets satisfied.

### Preparation

- Participants put on **ceremonial clothes**, and change back afterwards.
- Preferred path, Odyssey's **outfit stand**: a "Set ceremonial owner" button makes it a
  colonist's wardrobe. They park their own clothes there and get everything back exactly as it
  was, **force-worn flags included** — which vanilla's own stand driver does not do: it hands
  everything to whoever arrives first and force-flags everything it returns, street clothes
  included.
- Fallback path, no building: the colonist puts on the finest garment tagged `FTO_Ceremonial`
  they can reach. Their displaced clothes fall on the floor, exactly as they do when an apparel
  policy is changed by hand. Changing back on this path is **free**: dropping the force-worn flag
  is enough, and `JobGiver_OptimizeApparel` re-dresses the pawn on its own.
- The tag is applied **by criterion**, on tags the game already ships — `Royal`, `RoyalRobe`,
  `Robe`, `Cape`, `BestowerHood`, `HoraxianCeremonial`. No `defName` is named anywhere, and a mod
  can join in by adding `FTO_Ceremonial` to its garment's apparel tags.
- **Adornment**: a colonist wearing no tattoo gets one drawn from their own ideoligion's style.
  No art to produce — a `TattooDef` has no permanence in the engine, setting and clearing one is
  instant. A colonist who already has a tattoo is left alone.
- Two triggers, both configurable:
  - **when an obligation is announced** — free, nothing is running yet. The window opens on the
    announcement and lasts the configured number of hours (12 by default), not the obligation's
    full nine days of life: nobody stands around in evening dress for nine days;
  - **when a ritual is launched** — a detour at the moment of departure, which **costs progress**
    (`ProgressPerTick` is 1, `LordJobTick` advances unconditionally), hence a maximum distance.
- A single comp counts clothes and adornment together: one comp is one number in the budget, and
  one figure for the player to read.

### Quality budget

- **+0.25 in total at most**, on a scale the game caps at 1.0
  (`RitualOutcomeEffectDef.maxQuality`). Slider from 0 to x2 in the settings.
- This is also the reason for the split: the ritual mechanics live in a single mod because three
  mods each adding their own bonus without seeing one another would blow the cap. The pyjama
  mechanic is separate (**Night Change**) because it depends on Odyssey rather than Ideology.
- Both bonuses appear on their own line in the "Begin ritual" window, with a tooltip listing which
  offering categories are filled and which are missing.

### Technical notes

- The quality comps are attached **in C#** at startup, never by XML patch. `PatchOperation`s are
  applied before def inheritance is resolved, and an XML list *merges* with its parent's: an xpath
  catching both `Trial` and `TrialMentalState` would install the comp twice and count it twice.
- The prefix on `Pawn_JobTracker.StartJob` runs when every job of every pawn starts: **fail open**,
  every hook catches, logs once and disables the mod for the session.
- The map-danger gate sits **below the return trip and above both dress paths**. Above both, a raid
  would freeze everyone in evening dress with no way to walk back for their flak vest.
- Records are reaped on `Pawn_Ownership.UnclaimAll` (death, trade, kidnapping, leaving the map)
  **and** on `PawnBanishUtility.Banish`, which the former does not reach.
- Cohabitation with **Shift Change** on the outfit stand: `FTO_`-prefixed save keys
  (`CompAssignableToPawn` scribes `assignedPawns` flat), no hotkey on the gizmo (`Misc4` = N
  collides with the storage settings clipboard), no owner overlay.
- No vanilla altar is modified.

## [0.1.0] — 2026-09-23

Creation of the `PublishedFileId.txt` file (`Mod/About/PublishedFileId.txt`). The Workshop item,
3806761333, was created by the first upload from the game's own button, and it stays private until
it is switched to public by hand: Steam creates every item private and RimWorld never sets its
visibility.

This is a pre-publication, not a release. It says nothing about the mod being tested, and it is
not the `prepublished` state of the workflow: it is the act that creates the item.

What went up is `Mod/` as it stood at commit `5053f5d` (2026-09-20), and nothing in `Mod/` has
changed between that commit and the upload (the id file was written on 2026-09-23). The content
is the one described under 1.0.0 above, including its pre-release corrections of 2026-09-13.
