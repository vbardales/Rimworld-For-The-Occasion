# For the Occasion

Colonists get ready for a ceremony instead of turning up to it in work clothes, and an offering
table lets you put something beside the altar that the rite actually consumes. RimWorld 1.6,
Ideology required, Odyssey optional.

Written from scratch. Nothing is reproduced from any other mod, and the one texture it uses is
vanilla's own 1x2 table.

## The problem

A ritual's quality is not only the room's impressiveness. Vanilla exposes twenty-one
`RitualOutcomeComp` — participant count, room stats, a seat, a building used, drums played,
loudspeakers running, a loved one present, indoors, a consumable destroyed. It is an open
extension point.

Nothing in it rewards either of the two things a ceremony is actually made of: **what you laid
out**, and **how you turned up**. So a colony that has held forty weddings in the same hall gets
the same forty out of forty every time, and the only lever the player has is furniture — which is
permanent. This mod adds two levers that are not.

## The budget, and why it is one number

`RitualOutcomeEffectDef.maxQuality` defaults to `1f`. The quality budget of a ritual is **one
number, capped**. Three mods each quietly adding their own bonus would blow the cap and none of
them would know.

So this mod ships **both** ritual mechanics together and spends at most **+0.25 in total** —
about +0.12 for offerings, +0.13 for preparation — with a slider running from nothing to double.
That is also why the pyjama mechanic lives in a separate mod ([Night
Change](https://github.com/vbardales/Rimworld-Night-Change)): it depends on Odyssey rather than
Ideology, and it does not touch ritual quality at all.

Both bonuses appear as their own line in the **Begin ritual** window, before you commit.

## 1. Offerings

A new building, the **offering table** (Ideology tab), to stand beside your altar. What is laid
out on it and inside the ritual's gathering area counts, and is taken away when the rite ends.

What counts is **variety**, never quantity:

| Category | Default requirement |
|---|---|
| scent | 2 units of incense, perfume, or leaves |
| fine food | 4 fine/lavish meals, chocolate, insect jelly, berries |
| drink | 4 beer, ambrosia, milk, or a modded drink |
| treasure | 50 gold, silver or jade |

The bonus is read off the number of **distinct satisfied categories**: 0 → 0, 1 → 4 %, 2 → 7 %,
3 → 10 %, 4 → 12 %. Three hundred beers are three hundred beers.

**The consumption is the point.** Without it you would build the table once and every ritual in
the game would be better forever, which is not a mechanic, it is a permanent stat. A cancelled
ritual takes nothing.

An item counts for at most one category, so a stack of chocolate cannot fill both *fine food* and
*treasure* at once.

### Where the item list lives

In `Defs/OfferingCategoryDefs/`, once. The table's storage filter is **built at startup** from the
union of the categories (`OfferingTableFilter`), so the table always accepts exactly what it can
count. A filter that had been written out again by hand would eventually drift, and the drift's
worst case is an offering the game counts but the player cannot put down.

Modded items are listed per `<li>` with their own `MayRequire`: RimScent Extended's incense,
RimScent: Perfume Expansion's perfumes, Vanilla Brewing Expanded's drinks, Rum and Shanties' rum.
A category whose items are all absent still loads; it simply never gets satisfied.

Another mod adding an `OfferingCategoryDef` of its own gets both the counting and the storage
filter for free.

## 2. Getting dressed

Two ways in, tried in order.

**The outfit stand.** Odyssey's `Building_OutfitStand` gains a *Set ceremonial owner* button. A
colonist with one assigned walks to it, parks their own clothes and takes the outfit; on the way
back they get their clothes returned **exactly as they were, force-worn flags included**.

Vanilla's own stand driver cannot be reused for this. `JobDriver_UseOutfitStand` is anonymous: it
hands every wearable item to whoever arrives first, pushes their displaced clothes into the same
undifferentiated bag, and force-flags everything it gives back — street clothes included, whether
or not they were force-worn before.

**Anything ceremonial within reach.** Otherwise the colonist puts on the finest garment tagged
`FTO_Ceremonial` they can get to, and their displaced clothes fall on the floor exactly as they do
when you change an apparel policy by hand. Changing back on this path is **free**: drop the
force-worn flag and `JobGiver_OptimizeApparel` re-dresses the pawn on its own.

The tag is applied **by criterion**, on tags the game already ships — `Royal`, `RoyalRobe`,
`Robe`, `Cape`, `BestowerHood`, `HoraxianCeremonial`. A modded garment carrying any of them joins
in with no patch of its own, and a mod author who wants theirs to count only has to add
`<li>FTO_Ceremonial</li>` to its apparel tags. Nothing in the mod reads a defName.

**Face paint.** A colonist who normally wears no tattoo gets one drawn from their own ideoligion's
style (`PawnStyleItemChooser.RandomTattooFor`), cleared when they change back. A `TattooDef` has
no permanence in the engine — setting one and clearing it is instant and free — so this ships zero
new art. Anyone who already has a tattoo is left alone: you do not erase somebody's mark for an
evening.

### When

| Trigger | Cost | Distance |
|---|---|---|
| a ritual obligation is announced | none — nothing is running yet | unlimited |
| a ritual is launched cold | ritual progress | capped, default 40 cells |

An obligation lives for up to nine days (`RitualObligation.StageDays`), but nobody stands around
in evening dress for nine days. The window opens when the news arrives and lasts a set number of
hours (12 by default). Past it, colonists change back and a ritual launched later pays for a
last-minute detour instead. That gives "hold the ceremony soon" a mechanical meaning it never had.

The last-minute detour genuinely costs you. `RitualStage.ProgressPerTick` is 1 and
`LordJob_Ritual.LordJobTick` advances progress unconditionally — the clock does **not** stop for
latecomers.

## How it hooks in

| Hook | Method | Kind |
|---|---|---|
| a ritual starts | `RitualBehaviorWorker.TryExecuteOn` | postfix |
| the wardrobe detour | `Pawn_JobTracker.StartJob` | prefix |
| offerings are consumed | `LordJob_Ritual.ApplyOutcome` | prefix + postfix |
| records are reaped | `Pawn_Ownership.UnclaimAll` | postfix |
| records are reaped | `PawnBanishUtility.Banish` | postfix |

### Why the comps are attached in C#, not by XML patch

`PatchOperation`s run **before** def inheritance is resolved, and a list node **merges** with its
parent's rather than replacing it (`XmlInheritance.RecursiveNodeCopyOverwriteElements` appends the
child's `<li>` elements). Several concrete `RitualOutcomeEffectDef`s inherit from another
*concrete* one — `TrialMentalState` from `Trial`, the three `DestroyConsumableBuilding_*` from
`DestroyConsumableBuilding`. An xpath catching both parent and child would install the comp
**twice** in the child and double the bonus: precisely the cap-busting this design exists to
avoid.

Walking `DefDatabase<RitualOutcomeEffectDef>` once, after resolution, removes the problem, picks
up other mods' ritual outcomes without naming them, and lets the settings slider rescale the
curves live. Comps are installed only where they can be read: on defs whose worker derives from
`RitualOutcomeEffectWorker_FromQuality`, which is the only consumer of `RitualOutcomeComp_Quality`.

### Why the prefix on StartJob, and what protects it

`JobGiver_OptimizeApparel` sits **below** the lord-duty node in the humanlike think tree
(`Humanlike.xml`): during a ritual it never runs, so changing a participant's apparel policy would
produce nothing at all. A job has to be inserted, and the only place that sees every job is
`StartJob`.

That is also the method that starts every job for every pawn, where an unhandled exception is a
bricked colony. **Fail open, non-negotiable**: every hook catches, logs once, disables the mod for
the session, and lets vanilla proceed.

The insertion pattern is vanilla's own opportunistic-haul path: reserve the deferred job's targets
(with `curJob` temporarily set, because several drivers reserve against `pawn.CurJob` rather than
their own field), **start the detour first, enqueue the displaced job second**, return `false`. A
static re-entrancy guard is mandatory — starting a job from inside a `StartJob` prefix re-enters
the prefix.

The gates: drafted, downed or in a mental state; `job.playerForced`; `workGiverDef.emergency`; not
standing; and a per-pawn 300-tick cooldown so a pawn whose jobs keep getting interrupted cannot
loop on the wardrobe trip.

**The map-danger gate sits below the return trip and above both dress paths.** Above both, a raid
would freeze everyone in evening dress with their armour parked in a wardrobe they were not
allowed to walk to. It has to mean "no dressing up under threat", never "no changing".

### The forced-apparel flag

`Pawn_ApparelTracker.Notify_ApparelRemoved` calls `SetForced(ap, false)` unconditionally: **every
removal destroys the flag**. So the record captures forced-ness *before* `Remove` — the last
moment the fact exists anywhere in the game — and restores it *after* `Wear`. Garments that were
force-worn come back force-worn; garments that were not stay policy-managed.

### Sharing the outfit stand def

`CompAssignableToPawn` scribes `assignedPawns` **flat** into the thing's save node, so two
subclasses on the same def read each other's owners on load. `PostExposeData` is therefore
overridden **without calling base**, with `FTO_`-prefixed keys. The base comp's gizmo is also
hardcoded to `KeyBindingDefOf.Misc4` — **N** — which on a storage building collides with the
storage settings clipboard; the gizmo is rebuilt here without a hotkey.

The def is patched as a **commons**: the `<comps>` node is ensured first and appended into second,
in two disjoint `PatchOperationConditional`s rather than a `match`/`nomatch` pair, because at patch
time neither stand def carries a `<comps>` node of its own — they inherit one — and a `match`/
`nomatch` would only ever catch half of them.

### Save footprint

The preparation records live in a `GameComponent` — not in a comp patched onto the `Human` def,
which would miss every modded race.

The two ritual comps are attached to defs at runtime and are never scribed. Their **data** is:
`null` for offerings, and vanilla's own `RitualOutcomeComp_DataThingPresence` for preparation.
That is deliberate — `compDatas` *is* scribed, and a class of our own in there would leave an
unreadable node behind the day the mod is uninstalled. On uninstall the count mismatch makes
`RitualOutcomeEffectWorker.FillCompData` rebuild the list by itself.

Outfit stands revert to plain outfit stands. A colonist mid-change keeps wearing the outfit
(unforce it by hand) and their own clothes are sitting in the stand.

## Compatibility

**Shift Change** ([3783456242](https://steamcommunity.com/sharedfiles/filedetails/?id=3783456242),
MIT) dresses colonists for **work and recreation** by room role, excludes beds, and ignores
rituals entirely. It is the natural companion, not a competitor, and this mod is written for
cohabitation on the shared outfit stand def: prefixed scribe keys, no hotkey, no overlay label of
its own.

No vanilla altar is modified. Giving an altar storage would mean changing its `thingClass` — a
shared def that other mods patch too — so the mod ships a table instead.

## Building

```
dotnet build Source/ForTheOccasion.csproj
```

## Validating after a change

Thirty-eight functional tests, which need RimWorld installed but never start it:

```
powershell -ExecutionPolicy Bypass -File _tools\Run-Functional-Tests.ps1
```

They execute the mod's own C# and read the game's compiled code, so they catch what a compiler
cannot: a vanilla method that stopped doing what this mod delegates to it, a patch operation that
stopped matching, a save key that started colliding, a translation key with no translation. Run
them before a release. `-ListTests` prints the list, `-Only 8,22` runs a few. What they do NOT do
is play the mod: `docs/TESTING.md` holds the game scenarios for that, and neither half replaces the
other.

The settings tests cover defaults, numeric limits, real Scribe round trips and older files,
the hidden shortcut's native definition/dialog contract, preparation-disable regressions,
and actual quality curves after closing settings. They do not simulate Unity's GUI or certify
RIMMSQOL interaction. See `docs/VALIDATION-2026-09-13.md` for results and remaining game checks.

Settings are accessible through **Mod options -> For the Occasion** and apply globally.
The optional `FTO_Settings` MainButton is hidden by default; customization tools can reveal
it to open the same settings. The quality budget applies when the dialog closes. Disabling
preparation lets existing borrowers return their clothes at the next eligible job change.

When the optional content providers are installed locally, also run:

```powershell
pwsh -File _tools/Check-Optional-Offerings.ps1
```

This checks eight combinations of the providers' actual 1.6 Defs and LoadFolders. Use
`-WorkshopDir` or `-SourcePaths` when their local paths differ. Missing packages are reported
as unverified prerequisites, not skipped successful tests.

Three more checkers live in the monorepo this mod was written in, and are not shipped here. They
still run when this folder sits beside it:

```
pwsh -File ../scripts/Check-DefRefs.ps1 -ModPath Mod -Brief
pwsh -File ../scripts/Check-XmlClasses.ps1 -ModPath . -TypeLists ../rw16_types.txt -Brief
pwsh -File ../scripts/Check-DefInjected.ps1 -TransMod Mod -Targets Mod -ExtraAssemblies Mod/Assemblies/ForTheOccasion.dll
```

## Licence

MIT. See `LICENSE` and `ATTRIBUTION.md`.
