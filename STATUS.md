---
mod:          For the Occasion
packageId:    nelim.fortheoccasion
repo:         Rimworld-For-The-Occasion
visibility:   public
detached:     yes
stage:        preTest
licence:      open
licence_at:   written from scratch, MIT, sources shipped, and nothing is reused; the wardrobe path was shaped by Shift Change's design document, a named debt, and that mod is MIT
dependencies: declared
showcase:     complete
tested_on:
workshop:
remaining:
  - unverified: never seen running; no scenario in docs/TESTING.md has been observed, though the
    out-of-game harness passes 30 of 30
session:      local_06821e6c-e45a-492a-99fd-d6a96d00f8af
updated:      2026-09-12, held by hand from here on
---

# For the Occasion — status

Read by a sweep across every mod, rather than by asking each thread in turn. It lives at the
root, never inside `Mod/`, so Steam never receives it.

The fields above were read off the disk on 2026-09-12. Four cannot be, and wait for whoever
holds this mod:

- **`stage`** — one of `port`, `showcase`, `preTest`, `done`, `tested`, `published`. Filled in
  from the session group where one exists; confirm it.
- **`tested_on`** — the date of the last run in game. Empty means never.
- **`dependencies`** — `declared` when every mod this one needs is named in the About's
  `modDependencies`, `to check` when a non-vanilla `loadAfter` suggests a dependency that is not
  declared, `none` when the mod needs nothing. An undeclared dependency is not cosmetic: on
  2026-09-11 Reequilibrage animaux took 47 vanilla animals down with it, Muffalo included, because
  the class it injects belongs to a mod that was not declared and not loaded.
- **`remaining`** — what is left, in three kinds: `feature` for something missing from a first
  release, `defect` for a known fault left unfixed, `unverified` for what could not be checked.
  The line already there is true of nearly the whole repository; replace it once it stops being.

`licence` vocabulary: `open` an explicit licence, `silent` no licence and a dead source,
`alive` no licence but a living source, `forbidden` a written refusal, `original` owing nothing
to anyone — not a name, not an idea traceable to one mod, not a value derived from its assets.

## What is known about this mod, and how

Held here by hand, so that the next thread does not have to re-derive it.

**Nothing has been observed in game.** `docs/TESTING.md` holds ten scenarios, none of them run.
The one thing that has been seen is the load, on 2026-09-04, and it produced its three expected
lines. Read that file before playing: this mod fails open, so a failure shows up as silence
rather than as an error, and a clean `Player.log` is not evidence that anything worked.

**One defect was found and fixed without the game, on 2026-09-12.** The outfit stand patch's two
operations were not disjoint over time; every stand was getting the ceremonial owner comp twice.
It was found by rebuilding the real `PatchOperation` objects from the mod's own XML and running
them against Odyssey's `Buildings_Furniture.xml` outside the game. Nobody would have seen it in
play: two comps of the same class look like one until a save is written.

**The out-of-game harness is written and green.** `_tools/Run-Functional-Tests.ps1`, thirty tests
in a couple of seconds: the mod's own C# instantiated and called, the vanilla classes it entrusts
its conduct to interrogated by reflection and by reading their IL, and its patch operations run
against the game's real defs. Thirty-four mutations were needed before any of it counted, since a
test never seen to fail is a guess. Only the harness guard, test 1, has never been seen red, and
the file says so.

**Two constraints the harness had to be built around**, both of which cost an hour to find:

- Loading the mod assembly locks the file, so a build that runs after a test run fails on a copy
  it cannot overwrite. The harness loads a copy taken to a scratch folder for that reason.
- `RitualOutcomeEffectDef` instantiates, but PowerShell refuses to read any property off it: the
  type has both `description` and `Description`, which its type system rejects. Reach its fields
  by reflection rather than by property access.
