# Testing

What actually observed, what not, how observe rest.

## The one thing to understand first

**Mod designed fail open.** Prefix on `Pawn_JobTracker.StartJob` run when every
job of every pawn start, so unhandled exception there brick colony. Every hook
therefore catch, log once, disable mod for session, let vanilla proceed.

Consequence for testing = whole reason file exist: **failure show up as
silence, not error.** Clean `Player.log` not evidence mod work. Every
scenario below written to produce *positive* evidence, something you can see happen,
because "nothing went wrong" and "nothing happened at all" look identical in log.

Log live at:

```
%USERPROFILE%\AppData\LocalLow\Ludeon Studios\RimWorld by Ludeon Studios\Player.log
```

## Status

| | State |
|---|---|
| Loads without error | **observed**, 2026-09-04 |
| The out-of-game harness | **30 of 30 pass**, 2026-09-12 |
| Settings correction harness | **38 of 38 pass**, 2026-09-13 and again 2026-09-28 on `e9b1bc7`, same DLL; see docs/runs/2026-09-13-validation.md and docs/runs/2026-09-28.md |
| Workflow audit against `AUDIT.md` | 2026-09-28, stage `options`, then `preTest` after plural fix; see `STATUS.md` |
| The Pickle suite | **played in WSL, English only**, 2026-09-29/30, all seven passes once: offerings, RIMMSQOL, restart green; features 06, 07, 08, 14 and Shift Change reload red; see docs/runs/2026-09-30.md |
| Every scenario below | **not yet seen as whole**; no person watched game |

Load produced exactly three expected lines:

```
[For the Occasion] Harmony patches applied.
[For the Occasion] quality comps installed on 28 ritual outcome defs; 4 offering categories loaded.
[For the Occasion] offering table accepts 28 thing defs from 4 categories.
```

One real defect came from that single run, now fixed: six `Romy_*` offerings gated
on `reo.rimscent.perfumeexpansion`, which defines none, so absent def demanded and
cross-reference failed. Now name `Romyashi.Perfumes` and `Romyashi.AnimaExpansion`.

## The other half, which does not need a colony

`scripts/Run-Functional-Tests.ps1` run thirty-nine tests without starting
game. Run before playing any scenario below, and again before release:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Run-Functional-Tests.ps1
```

Ask different question from this file. Scenarios below ask whether mod
does what it says. That file ask whether game still does what mod expects: whether
removing garment still destroys force-worn flag, whether duel still ends by calling
outcome this mod patches, whether save key it writes still one nobody else writes. Also
run mod's own patch operations against game's real defs, which how stand patch was
caught giving every outfit stand ceremonial owner comp twice.

Neither half replace other. Nothing there sees colonist walk to wardrobe.

## Scenario 0: it loaded

**Do:** start game with mod active.

**Expect:** three lines above, in order. Counts depend on modlist: number of
ritual outcome defs = every def whose worker derives from `RitualOutcomeEffectWorker_FromQuality`,
thing-def count = union of four offering categories, so both grow with
mods you run.

**Then filter log for classics:**

```
Select-String -Path "$env:USERPROFILE\AppData\LocalLow\Ludeon Studios\RimWorld by Ludeon Studios\Player.log" -Pattern '^(XML error|Config error|Could not resolve|Could not find)'
```

**Fails if:** any of three lines missing, or one names zero defs. Zero ritual outcome defs
mean comps never attached, every quality scenario below moot.

## Scenario 1: the offering table counts variety, not quantity

**Setup:** build offering table beside altar. Put **four beers and nothing else** on it.

**Do:** open *Begin ritual* on any ritual held at that altar.

**Expect:** **Offerings 1 / 4** line, worth about +4 %. Hover list
four categories with tick against *drink* and cross against other three.

**Then:** add incense, fine meal, 50 gold, so all four categories satisfied.

**Expect:** line become **Offerings 4 / 4**, worth about +12 %.

**Fails if:** three hundred beers ever read more than 1 / 4. That entire mechanic,
bonus read off number of distinct satisfied categories, never amount.

**Gotcha:** item counts toward at most one category, so stack of chocolate cannot fill both
*fine food* and *treasure*. Table is 1x2 with three stacks per cell: six stacks, enough
for all four categories on one table. If only ever see two, check `maxItemsInCell`.

## Scenario 2: the offerings are consumed

**Setup:** scenario 1, all four categories satisfied. Note stack counts.

**Do:** let ritual run to completion.

**Expect:** message naming how many offerings consumed, stacks reduced by exactly
each category's `countRequired`, 2 scent, 4 food, 4 drink, 50 treasure. Nothing else on table
touched.

**Fails if:** nothing consumed. Without this step you build table once and every
ritual in game better forever, not mechanic, permanent stat.

**Then, negative half:** start another ritual and **cancel** it.

**Expect:** nothing consumed, no message. `ApplyOutcome` postfixed with `cancelled` read
straight from parameter, and `ended` captured in prefix so second call cannot consume
twice.

## Scenario 3: a colonist actually changes clothes, with an outfit stand

Core of mod and riskiest code in it: job inserted ahead of one that was
starting, deferred job's targets reserved with `curJob` temporarily swapped, static
re-entrancy guard. None ever seen run.

**Setup:** Odyssey required. Build outfit stand, put robe or cape in it, select it and use
**Set ceremonial owner** to assign colonist. Make sure map calm.

**Do:** start ritual that colonist takes part in.

**Expect:** they walk to stand, spend moment there, and **arrive at ceremony wearing
robe**. Their own clothes now inside stand.

**Fails if:** they walk straight to ritual in work clothes. Means prefix declined or
threw. Check log for single `[For the Occasion] disabled for this session` line, if it is
there, mod off, not merely idle.

## Scenario 4: and gets them back, force-worn flags included

Half vanilla's own stand driver never does: `JobDriver_UseOutfitStand` force-flags
everything it hands back, street clothes included.

**Setup:** before scenario 3, **force-wear one garment** on colonist (right-click it in
gear tab) and leave another under normal policy.

**Do:** run scenario 3 through end of ritual, then let colonist take another job.

**Expect:** they return to stand, put own clothes back on, and garment that was
force-worn **is force-worn again**, other not.

**Why delicate:** every apparel removal destroys that flag:
`Pawn_ApparelTracker.Notify_ApparelRemoved` calls `SetForced(ap, false)` unconditionally. Mod
records forced-ness at check-in, last moment fact exists anywhere in game, and
restores it after `Wear`.

**Fails if:** everything comes back force-worn, or nothing does.

## Scenario 5: the no-building path

**Setup:** colonist with **no** stand assigned. Leave robe, cape or any royal garment lying
on floor within reach.

**Do:** start ritual they take part in.

**Expect:** they put garment on; displaced clothes fall on floor, exactly as when apparel
policy changed by hand. After ritual mod simply drops force-worn flag and
**vanilla's own `JobGiver_OptimizeApparel` re-dresses them**, no return trip on this
path, deliberate.

**Fails if:** they never change, or stay in robe forever. Second case mean flag
not dropped.

**Gotcha:** garment must carry `FTO_Ceremonial` tag, applied by criterion to
apparel already tagged `Royal`, `RoyalRobe`, `Robe`, `Cape`, `BestowerHood` or
`HoraxianCeremonial`. Without Royalty, vanilla has very few. If nothing happens, verify you hold
one of those, not ordinary duster.

## Scenario 6: face paint

**Setup:** colonist with **no tattoo at all**, in ideoligion that has tattoo styles.

**Do:** run any dressing scenario.

**Expect:** face tattoo drawn from own ideoligion's style appears with outfit, gone
when they change back.

**Expect also, on colonist who already has tattoo:** nothing changes. You do not erase
somebody else's mark for evening, so mod only paints bare face.

**Costs nothing to check:** `TattooDef` has no permanence in engine. Setting and clearing
one instant and free, why this ships no art.

## Scenario 7: the danger gate, in both directions

Gate sits **above both dress paths and below return trip**, asymmetry whole
point. Shift Change learned this in play: with gate above both arms, raid froze every
borrower in evening dress with armour parked in wardrobe they not allowed to walk to.

**Setup:** colonist already in ceremonial dress, ritual over.

**Do:** trigger raid.

**Expect two different things:**

- nobody **starts** dressing up while map dangerous;
- colonist already dressed **can still walk back** and change out of it.

**Fails if:** dressed colonist stuck in robe for whole raid. Exact bug
placement exists to avoid, would mean gate drifted above return trip.

## Scenario 8: anticipation, the free path

**Setup:** in settings, confirm *Get ready when a ritual is announced* on and note
window, 12 hours default.

**Do:** cause ritual obligation, colonist dying gives funeral obligation.

**Expect:** over following hours, free colonists dress themselves with no ritual running.
*Begin ritual* window then already shows **Dressed for the occasion n / 6** before you start
anything, starting it costs no progress.

**Expect after window closes:** they change back on own.

**Why matters:** intended way to play. Last-minute detour genuinely costs
quality, `RitualStage.ProgressPerTick` is 1 and `LordJob_Ritual.LordJobTick` advances
unconditionally, so clock does not stop for latecomers.

## Scenario 9: nobody is diverted away from a birth

**Setup:** Biotech. Colonist in labour, another standing by.

**Do:** let childbirth ritual start.

**Expect:** **no attendant walks off to change clothes.** Mother excluded by
lying-down gate, attendant excluded because mod refuses to mark anyone
assignment holds as required for rite.

**Fails if:** attendant leaves for wardrobe. Emergency gate cannot catch this alone:
their job comes from lord duty, so `job.workGiverDef` null and emergency test never
fires.

**Same rule covers more than births.** Anyone ritual cannot proceed without,
bestower at bestowing ceremony, executioner, accused at trial, stays put for same
reason. Spectators, point of mod, free to go and dress.

## What cannot be tested here

**Cohabitation with Shift Change** ([3783456242](https://steamcommunity.com/sharedfiles/filedetails/?id=3783456242)).
Both mods put `CompAssignableToPawn` subclass on same `Building_OutfitStand` def. This mod
scribes `FTO_`-prefixed keys so two never read each other's owners, and drops base comp's
hardcoded `Misc4` hotkey, which on storage building collides with settings clipboard. None
of that can be exercised without Shift Change installed, inert without it.

Shift Change unifies owners of stand with every other assignable comp beside it, ours included
(`ReconcileForeignOwners`, `SyncForeignOwners`, `CopyOwnersInto` in its code): ONE owner list,
set by whichever comp edited last. Shift Change also hides this mod's "Set ceremonial owner" button on any stand it
manages (`Patch_ForeignOwnerGizmos`), so with both installed owner assigned through Shift Change only. To test: install both, assign colonist through Shift Change,
check same colonist is ceremonial owner here, save, reload, check still is.

## Scenario 10: settings, defaults and persistence (English and French)

**Setup:** back up existing settings file, use clean test configuration; Harmony,
Ideology and this mod, initially without MainButtons customization mod. Use new colony,
then repeat relevant checks with existing save. Repeat UI steps in English and French.

**Do:** open Mod options -> For the Occasion (Pour l'occasion in French).
Check defaults: budget x1 (+25% total), offerings/preparation/announcement/launch/paint enabled,
12 hours, 40 cells. Exercise budget x0/x2, window 1/48 hours, distance 5/120 cells, switch
dependencies. Close/reopen, restart, load other save.

**Expect:** values stay within limits and persist globally. All labels/tooltips
translated, readable, unclipped. Budget applies on close; at x0 behavior remains
but both quality bonuses zero, at x2 combined ceiling +50%. Restore x1 and confirm
+25%. Disabling offerings stops both bonus and consumption while keeping table usable.
Disable each preparation trigger separately and verify only that trigger stops; disable paint
before new dressing and verify no temporary tattoo added. Restore all switches afterward.

**Check:** no repeated errors, raw keys or settings exceptions in Player.log. Sliders give
no free-text input; missing/older serialized defaults and numeric normalization additionally
covered by automated tests. No runtime result recorded until these steps performed.

## Scenario 11: disable preparation with a borrower and an in-flight trip

**Setup:** scenario 3/4, one borrower dressed from stand (one original garment forced,
one not), temporary face paint active; another colonist walking to stand to get dressed.

**Do:** disable preparation while ritual active, close settings, then allow first
borrower eligible non-forced job change and allow second pawn finish trip.

**Expect:** borrower returns ceremonial outfit, recovers original clothes and
original forced flags, loses only temporary paint. Second pawn does not dress on
arrival. Nobody starts new dressing trip. Reenable preparation and repeat ceremony:
normal preparation works again. Repeat without stand, and with save/reload while disabled.
Drafted/downed/forced-job gates may defer return; release those constraints before judging.

## Scenario 12: optional hidden shortcut

**Setup:** clean configuration with mod active. No customization mod at first.

**Do/expect:** no visible or greyed-out For the Occasion MainButton. Primary settings
route works. Install RIMMSQOL, record actual version, reveal `FTO_Settings`, open it and
change value. Close, reopen via Mod options, confirm same value; change it there
and verify through shortcut. Hide button again, restart, confirm visibility
persists as chosen. Repeat in French and English, check logs. Run same sequence for
any other customization mod before claiming integration tested.

## What `tested` requires

Scenarios above what has to be watched. This section what has to be true before
`STATUS.md` may say `tested`. Restates step `done -> tested` of `AUDIT.md` for this mod, with
what each rule comes to here. Today not met: Pickle suite in `Tests/Pickle/` played once per pass (docs/runs/2026-09-30.md)
and several features red, so those scenarios still to be replayed green.

- **No scenario left in `@wip`.** Scenario set aside either repaired and replayed, or deleted with
  reason. One left standing is scenario waiting, not passed.
- **Every conditional scenario has run.** Each `@requires:<packageId>` scenario, whether needs optional
  mod, DLC or companion tool, gets own pass on map that mounts it, and that report
  read: `setName`, suite and scenario names checked before cited, because report
  folder shared by whole machine. Scenario skipped for want of condition not passed
  scenario. Conditions of this mod: Odyssey (outfit stand path), RIMMSQOL (hidden
  shortcut), Shift Change (shared stand) and five providers of optional offerings named under
  "Passes this mod needs".
- **No manual test left to validate.** Each of scenarios 0 to 12 either written in Gherkin
  and green, or listed not applicable with reason. Nothing left to tick by hand. `@review`
  captures still have to be opened and looked at, but that reading of image scenario
  already proved in intended state, not one more manual test. Suite written and
  [Tests/Pickle/README.md](Tests/Pickle/README.md) has table of which feature plays which scenario.
  Scenario 9 (birth) listed there as not applicable, with reason. Hook that consumes at
  end of real ritual now feature of own (`14-ritual-hook`), least certain of
  suite because it drives game's Begin ritual window by reflection: if first run cannot
  begin ritual from test colony, gap reopens and has to be closed or justified before
  `tested`.
- **A green run is not the proof.** Read `exitReason` before numbers, compare scenarios played
  with features discovered, open every `@review` capture. Green says path walked,
  not that image shows colonist in robe or ritual window with its two quality lines.
- Logs read; interface checked in French and English, in game in developer mode: accented
  gibberish is key missing from active language, clean English line in French game is
  string that never went through `Translate`.
- Every scenario that failed replayed green on build containing its fix.

## Passes this mod needs

Mod whose `TESTING.md` not say how many passes it needs is tried, not tested. Pass maps
live in `Tests/Pickle/` (one `wsl-deps.<name>.map` each, each run once) and filter of each pass in
[Tests/Pickle/README.md](Tests/Pickle/README.md). One `-DepMap` per request, and language of pass
fixed at launch, so each language is request of own: seven requests in all: first
pass in English and French, then one each for pass without Odyssey, with RIMMSQOL, with Shift
Change, with optional providers, and for restart pair.

1. **Without the optional mods**, English and French: Core, DLC, Harmony, Pickle, Ideology (hard
   dependency, with Harmony) and this mod. Proves mod stands alone, only pass where
   capture clean. All four offering categories can be filled from vanilla items (smokeleaf leaves,
   fine meals, beer, gold), so every offering scenario can run here.
2. **Without Odyssey** (`!ludeon.rimworld.odyssey` in pass map): outfit stand does not exist,
   so no-building path only one, and mod must load without raising error.
3. **With the optional mods**, one pass per combination that cannot coexist: RIMMSQOL (1084452457) for
   shortcut, Shift Change (3783456242) for shared stand, RimScent Extended - Incense Plus and
   Rum and Shanties (both of this collection), Perfumes (3013711969) with Anima Expansion (3532147582),
   and Vanilla Brewing Expanded (2186560858) with Vanilla Plants Expanded. Vanilla Plants Expanded and
   its `_copy` package two separate ways of opening cider gate (two profiles of
   `scripts/Check-Optional-Offerings.ps1`). Whether can be loaded together not established
   here, so each gets own pass until it is.
4. **A pass per declared incompatibility:** none. `About.xml` declares no `incompatibleWith`.

## Evidence to keep

Full rules, with reasons, in [docs/runs/README.md](docs/runs/README.md). In short, for
Pickle run and harness:

- **Keep**, for revision now in repository and per pass: `summary.json`, `summary.md`,
  `junit.xml` and `Player.log` of latest run; one capture per asserted state; film only for
  dressing trip, where assertion in motion; older report only when sole
  proof of check latest run did not repeat (RIMMSQOL pass, Shift Change pass).
- **Delete** `report.html`, `messages.ndjson`, earlier runs of same set, failed attempts once
  cause written down, anything about superseded build.
- **Minify** what stays: captures as JPEG at `-q:v 3`, looked at in full size first.
- **Where:** on disk under `evidence/` and `Tests/Pickle/Evidence/`, both ignored by git. What goes to
  git is one text line per run in `docs/runs/`, carrying revision, set, `exitReason`,
  counts and what person opened.

## Reporting a failure

Include three `[For the Occasion]` load lines, any other line mentioning mod, and which
scenario number failed. `disabled for this session` line, if present, single most
useful thing in file: names hook that threw.