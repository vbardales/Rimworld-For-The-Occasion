# Testing

What has actually been observed, what has not, and how to observe the rest.

## The one thing to understand first

**This mod is designed to fail open.** The prefix on `Pawn_JobTracker.StartJob` runs when every
job of every pawn starts, so an unhandled exception there would brick the colony. Every hook
therefore catches, logs once, disables the mod for the session, and lets vanilla proceed.

The consequence for testing is the whole reason this file exists: **a failure shows up as
silence, not as an error.** A clean `Player.log` is not evidence that the mod works. Every
scenario below is written to produce *positive* evidence — something you can see happen — because
"nothing went wrong" and "nothing happened at all" look identical from the log.

The log lives at:

```
%USERPROFILE%\AppData\LocalLow\Ludeon Studios\RimWorld by Ludeon Studios\Player.log
```

## Status

| | State |
|---|---|
| Loads without error | **observed**, 2026-09-04 |
| The out-of-game harness | **30 of 30 pass**, 2026-09-12 |
| Settings correction harness | **38 of 38 pass**, 2026-09-13; see docs/runs/2026-09-13-validation.md |
| Every scenario below | **never observed** |

The load produced exactly the three expected lines:

```
[For the Occasion] Harmony patches applied.
[For the Occasion] quality comps installed on 28 ritual outcome defs; 4 offering categories loaded.
[For the Occasion] offering table accepts 28 thing defs from 4 categories.
```

One real defect came out of that single run and is fixed: the six `Romy_*` offerings were gated
on `reo.rimscent.perfumeexpansion`, which defines none of them, so an absent def was demanded and
the cross-reference failed. They now name `Romyashi.Perfumes` and `Romyashi.AnimaExpansion`.

## The other half, which does not need a colony

`_tools/Run-Functional-Tests.ps1` runs thirty-eight tests without starting the
game. Run it before playing any of the scenarios below, and again before a release:

```powershell
powershell -ExecutionPolicy Bypass -File _tools\Run-Functional-Tests.ps1
```

It asks a different question from the one this file asks. The scenarios below ask whether the mod
does what it says. That file asks whether the game still does what the mod expects of it: whether
removing a garment still destroys its force-worn flag, whether a duel still ends by calling the
outcome this mod patches, whether the save key it writes is still one nobody else writes. It also
runs the mod's own patch operations against the game's real defs, which is how the stand patch was
caught giving every outfit stand the ceremonial owner comp twice.

Neither half replaces the other. Nothing there sees a colonist walk to a wardrobe.

## Scenario 0 — it loaded

**Do:** start a game with the mod active.

**Expect:** the three lines above, in that order. The counts depend on your modlist: the number of
ritual outcome defs is every def whose worker derives from `RitualOutcomeEffectWorker_FromQuality`,
and the thing-def count is the union of the four offering categories, so both grow with the mods
you run.

**Then filter the log for the classics:**

```
Select-String -Path "$env:USERPROFILE\AppData\LocalLow\Ludeon Studios\RimWorld by Ludeon Studios\Player.log" -Pattern '^(XML error|Config error|Could not resolve|Could not find)'
```

**Fails if:** any of the three lines is missing, or one names zero defs. Zero ritual outcome defs
means the comps were never attached and every quality scenario below is moot.

## Scenario 1 — the offering table counts variety, not quantity

**Setup:** build an offering table beside an altar. Put **four beers and nothing else** on it.

**Do:** open *Begin ritual* on any ritual held at that altar.

**Expect:** an **Offerings 1 / 4** line, worth about +4 %. Hovering it lists the four categories
with a tick against *drink* and a cross against the other three.

**Then:** add incense, a fine meal and 50 gold, so all four categories are satisfied.

**Expect:** the line becomes **Offerings 4 / 4**, worth about +12 %.

**Fails if:** three hundred beers ever read as more than 1 / 4. That is the entire mechanic — the
bonus is read off the number of distinct satisfied categories, never off the amount.

**Gotcha:** an item counts towards at most one category, so a stack of chocolate cannot fill both
*fine food* and *treasure*. And the table is 1x2 with three stacks per cell: six stacks, enough
for all four categories on one table. If you only ever see two, check `maxItemsInCell`.

## Scenario 2 — the offerings are consumed

**Setup:** scenario 1, with all four categories satisfied. Note the stack counts.

**Do:** let the ritual run to completion.

**Expect:** a message naming how many offerings were consumed, and the stacks reduced by exactly
each category's `countRequired` — 2 scent, 4 food, 4 drink, 50 treasure. Nothing else on the table
is touched.

**Fails if:** nothing is consumed. Without this step you would build the table once and every
ritual in the game would be better forever, which is not a mechanic, it is a permanent stat.

**Then, the negative half:** start another ritual and **cancel** it.

**Expect:** nothing consumed, no message. `ApplyOutcome` is postfixed with `cancelled` read
straight from the parameter, and `ended` captured in a prefix so a second call cannot consume
twice.

## Scenario 3 — a colonist actually changes clothes, with an outfit stand

This is the core of the mod and the riskiest code in it: a job inserted ahead of the one that was
starting, the deferred job's targets reserved with `curJob` temporarily swapped, a static
re-entrancy guard. None of it has ever been seen to run.

**Setup:** Odyssey required. Build an outfit stand, put a robe or a cape in it, select it and use
**Set ceremonial owner** to assign a colonist. Make sure the map is calm.

**Do:** start a ritual that colonist takes part in.

**Expect:** they walk to the stand, spend a moment there, and **arrive at the ceremony wearing the
robe**. Their own clothes are now inside the stand.

**Fails if:** they walk straight to the ritual in work clothes. That means the prefix declined or
threw. Check the log for a single `[For the Occasion] disabled for this session` line — if it is
there, the mod is off, not merely idle.

## Scenario 4 — and gets them back, force-worn flags included

This is the half vanilla's own stand driver never does: `JobDriver_UseOutfitStand` force-flags
everything it hands back, street clothes included.

**Setup:** before scenario 3, **force-wear one garment** on the colonist (right-click it in the
gear tab) and leave another under normal policy.

**Do:** run scenario 3 through to the end of the ritual, then let the colonist take another job.

**Expect:** they return to the stand, put their own clothes back on, and the garment that was
force-worn **is force-worn again**, while the other is not.

**Why it is delicate:** every apparel removal destroys that flag —
`Pawn_ApparelTracker.Notify_ApparelRemoved` calls `SetForced(ap, false)` unconditionally. The mod
records forced-ness at check-in, the last moment the fact exists anywhere in the game, and
restores it after `Wear`.

**Fails if:** everything comes back force-worn, or nothing does.

## Scenario 5 — the no-building path

**Setup:** a colonist with **no** stand assigned. Leave a robe, a cape or any royal garment lying
on the floor within reach.

**Do:** start a ritual they take part in.

**Expect:** they put the garment on; their displaced clothes fall on the floor, exactly as when an
apparel policy is changed by hand. After the ritual the mod simply drops the force-worn flag and
**vanilla's own `JobGiver_OptimizeApparel` re-dresses them** — there is no return trip on this
path, and that is deliberate.

**Fails if:** they never change, or they stay in the robe forever. The second case means the flag
was not dropped.

**Gotcha:** the garment must carry the `FTO_Ceremonial` tag, which is applied by criterion to
apparel already tagged `Royal`, `RoyalRobe`, `Robe`, `Cape`, `BestowerHood` or
`HoraxianCeremonial`. Without Royalty, vanilla has very few. If nothing happens, verify you are
holding one of those and not an ordinary duster.

## Scenario 6 — face paint

**Setup:** a colonist with **no tattoo at all**, in an ideoligion that has tattoo styles.

**Do:** run any dressing scenario.

**Expect:** a face tattoo drawn from their own ideoligion's style appears with the outfit, and is
gone when they change back.

**Expect also, on a colonist who already has a tattoo:** nothing changes. You do not erase
somebody else's mark for an evening, so the mod only paints a bare face.

**Costs nothing to check:** a `TattooDef` has no permanence in the engine. Setting and clearing
one is instant and free, which is why this ships no art.

## Scenario 7 — the danger gate, in both directions

The gate sits **above both dress paths and below the return trip**, and the asymmetry is the whole
point. Shift Change learned this in play: with the gate above both arms, a raid froze every
borrower in evening dress with their armour parked in a wardrobe they were not allowed to walk to.

**Setup:** a colonist already in ceremonial dress, ritual over.

**Do:** trigger a raid.

**Expect two different things:**

- nobody **starts** dressing up while the map is dangerous;
- the colonist already dressed **can still walk back** and change out of it.

**Fails if:** the dressed colonist is stuck in the robe for the whole raid. That is the exact bug
the placement exists to avoid, and it would mean the gate has drifted above the return trip.

## Scenario 8 — anticipation, the free path

**Setup:** in the settings, confirm *Get ready when a ritual is announced* is on and note the
window, 12 hours by default.

**Do:** cause a ritual obligation — a colonist dying gives you a funeral obligation.

**Expect:** over the following hours, free colonists dress themselves with no ritual running. The
*Begin ritual* window then already shows **Dressed for the occasion n / 6** before you start
anything, and starting it costs no progress.

**Expect after the window closes:** they change back on their own.

**Why it matters:** this is the intended way to play. The last-minute detour genuinely costs
quality — `RitualStage.ProgressPerTick` is 1 and `LordJob_Ritual.LordJobTick` advances
unconditionally, so the clock does not stop for latecomers.

## Scenario 9 — nobody is diverted away from a birth

**Setup:** Biotech. A colonist in labour, with another standing by.

**Do:** let the childbirth ritual start.

**Expect:** **no attendant walks off to change clothes.** The mother is excluded by the
lying-down gate, and the attendant is excluded because the mod refuses to mark anyone the
assignment holds as required for the rite.

**Fails if:** an attendant leaves for a wardrobe. The emergency gate cannot catch this on its own:
their job comes from a lord duty, so `job.workGiverDef` is null and the emergency test never
fires.

**The same rule covers more than births.** Anyone the ritual cannot proceed without — the
bestower at a bestowing ceremony, the executioner, the accused at a trial — stays put for the same
reason. Spectators, who are the point of the mod, are free to go and dress.

## What cannot be tested here

**Cohabitation with Shift Change** ([3783456242](https://steamcommunity.com/sharedfiles/filedetails/?id=3783456242)).
Both mods put a `CompAssignableToPawn` subclass on the same `Building_OutfitStand` def. This mod
scribes `FTO_`-prefixed keys so the two never read each other's owners, and drops the base comp's
hardcoded `Misc4` hotkey, which on a storage building collides with the settings clipboard. None
of that can be exercised without Shift Change installed, and it is inert without it.

To test it: install both, assign the same stand a work owner in Shift Change and a ceremonial
owner here, save, reload, and check both assignments survived and are still distinct.

## Scenario 10 — settings, defaults and persistence (English and French)

**Setup:** back up the existing settings file and use a clean test configuration; Harmony,
Ideology and this mod, initially without a MainButtons customization mod. Use a new colony,
then repeat the relevant checks with an existing save. Repeat the UI steps in English and French.

**Do:** open Mod options -> For the Occasion (Pour l'occasion in French).
Check defaults: budget x1 (+25% total), offerings/preparation/announcement/launch/paint enabled,
12 hours, 40 cells. Exercise budget x0/x2, window 1/48 hours, distance 5/120 cells and switch
dependencies. Close/reopen, restart, and load the other save.

**Expect:** values stay within those limits and persist globally. All labels/tooltips are
translated, readable and unclipped. The budget applies on close; at x0 the behavior remains
but both quality bonuses are zero, at x2 their combined ceiling is +50%. Restore x1 and confirm
+25%. Disabling offerings stops both their bonus and consumption while keeping the table usable.
Disable each preparation trigger separately and verify only that trigger stops; disable paint
before a new dressing and verify no temporary tattoo is added. Restore all switches afterward.

**Check:** no repeated errors, raw keys or settings exceptions in Player.log. Sliders provide
no free-text input; missing/older serialized defaults and numeric normalization are additionally
covered by the automated tests. No runtime result is recorded until these steps are performed.

## Scenario 11 — disable preparation with a borrower and an in-flight trip

**Setup:** scenario 3/4, one borrower dressed from a stand (one original garment forced,
one not), temporary face paint active; another colonist walking to a stand to get dressed.

**Do:** disable preparation while the ritual is active, close settings, then allow the first
borrower an eligible non-forced job change and allow the second pawn to finish the trip.

**Expect:** the borrower returns the ceremonial outfit, recovers original clothes and their
original forced flags, and loses only temporary paint. The second pawn does not dress on
arrival. Nobody starts a new dressing trip. Reenable preparation and repeat a ceremony:
normal preparation works again. Repeat without a stand, and with a save/reload while disabled.
Drafted/downed/forced-job gates may defer return; release those constraints before judging it.

## Scenario 12 — optional hidden shortcut

**Setup:** a clean configuration with the mod active. No customization mod at first.

**Do/expect:** no visible or greyed-out For the Occasion MainButton. The primary settings
route works. Install RIMMSQOL, record its actual version, reveal `FTO_Settings`, open it and
change a value. Close, reopen via Mod options and confirm the same value; change it there
and verify through the shortcut. Hide the button again, restart and confirm visibility
persists as chosen. Repeat in French and English and check logs. Run the same sequence for
any other customization mod before claiming that integration tested.

## Reporting a failure

Include the three `[For the Occasion]` load lines, any other line mentioning the mod, and which
scenario number failed. The `disabled for this session` line, if present, is the single most
useful thing in the file: it names the hook that threw.
