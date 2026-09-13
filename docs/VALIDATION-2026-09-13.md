# Correction validation — 2026-09-13

Baseline commit: `a5486e8b7418f06cd6fd677a609c44959669cd4b`, with uncommitted corrections
in this workspace. Final distributed assembly SHA256:
`9FF631359D7CCC108DAFEAD1918D7364874917D53DEA6CC79D982AF1E5E2F7DE`.
No commit, push, Workshop publication or game session was performed.

Preserved run output: [functional-tests.txt](validation-2026-09-13/functional-tests.txt).
Audited source/Mod/test-file hashes: [manifest.txt](validation-2026-09-13/manifest.txt).

## Changes

The settings switch previously returned before looking up an existing borrower. It now
blocks new dressing after both return paths; disabling also overrides retention during an
active ritual. The job finish action checks the switch again so a trip already underway
cannot dress a pawn after the option is turned off. Drafted/downed/forced-order protections
remain in effect: returns happen at an eligible job boundary, not during a forced action.

`FTO_Settings` uses a native MainButtonDef with buttonVisible=false, validWithoutMap=true
and a custom worker that opens RimWorld.Dialog_ModSettings on the LoadedModManager instance.
There is no custom visibility override or second settings store. The primary Mod options
page remains independent of RIMMSQOL. The native dialog saves through WriteSettings on close.

Eight settings remain global. Numeric fields normalize on load and before saving: budget
0-2, hours 1-48, distance 5-120. Nonfinite values fall back to documented defaults. The two
integer-valued sliders round loaded values consistently. WriteSettings also invalidates
the anticipation cache and applies the budget to both installed quality-component curves.
English and French scope/application guidance was added to the primary page.

The Preview's linking word was reduced using an image edit, then resized to the required
896 x 504. Final PNG: 831,737 bytes. It was directly viewed after installation. The original
banner and full edited result are preserved in Art/ alongside the original source artwork.
The title, summary and ceremonial scene remain readable; no camera defect identified.

About.xml now ends with the requested Steam-formatted repository link. French Keyed XML
comments are in English. Attribution is synchronized between the root and Mod/.

## Executed checks

| Check | Command / evidence | Result |
| --- | --- | --- |
| Build | `dotnet build Source/ForTheOccasion.csproj --no-restore -t:Rebuild` | Success, zero warnings/errors; updated Mod/Assemblies/ForTheOccasion.dll |
| Functional harness | `powershell -NoProfile -ExecutionPolicy Bypass -File _tools/Run-Functional-Tests.ps1` | 38 passed, 0 failed, 0 skipped |
| Numeric defaults/bounds | Harness 31-32 | All eight defaults; min/max, out-of-range, NaN/infinities, integer rounding |
| Serialization | Harness 33-34 | Real Scribe save and fresh-instance load of all eight values; missing/older fields recover valid defaults |
| Shortcut contract | Harness 35 | Shipped hidden Def, shared editable definition, native visibility getter IL, existing mod lookup, native dialog/save-on-close linkage |
| Disable regression | Harness 36 | Both return calls precede disable guard; retention and in-flight dressing guards checked in delivered IL |
| Settings application | Harness 37-38 | Cache invalidated; real WriteSettings applies budgets 0, 0.5, 1, 2 and back to 1 on both comp curves; zero participants has zero bonus |
| Optional content | `pwsh -File _tools/Check-Optional-Offerings.ps1` | 8 profiles pass; all 23 distinct optional references checked |
| XML references | `pwsh -File ../scripts/Check-DefRefs.ps1 -ModPath Mod -Brief` | Seven owned defs, valid XML, no missing/wrong-type references or unresolved parents in checker scope |
| XML classes | `pwsh -File ../scripts/Check-XmlClasses.ps1 -ModPath . -TypeLists ../rw16_types.txt -Brief` | All 11 referenced types resolve |
| DefInjected | `pwsh -File ../scripts/Check-DefInjected.ps1 -TransMod Mod -Targets Mod -ExtraAssemblies Mod/Assemblies/ForTheOccasion.dll` | 13 paths checked, zero errors; custom class included |
| Keyed resources | Actual DLL Translate-key extraction (test 28), source inventory, XML comparison | 26 nonempty unique EN/FR keys with matching parameter tokens; meanings reviewed |

Build uses cached Krafs.Rimworld.Ref 1.6.4871 and Lib.Harmony 2.4.2. The harness reads the
installed Steam game's actual managed assembly and Core/DLC XML. It copies the mod DLL to
a scratch directory before loading it. No test writes to the player's real configuration.

Tests 33-34 use real Scribe with the English numeric culture configured by RimWorld's Root.
Test 38 bypasses only the Mod constructor's user-file access and the Unity log sink; it
executes the delivered WriteSettings and actual SimpleCurves. Localization is checked
separately, so missing language initialization in this fixture is not treated as a rendered
UI test. Shortcut visibility is checked through its definition and native getter IL;
no running RIMMSQOL session or Unity GUI interaction is claimed.

The original 30 tests and their historical mutation notes retain their numbering. New
regression 36 was also run against the original DLL (`720D6B18...C682`) and failed with
"preparation switch bypasses an existing return path". The corrected DLL passes. The added
tests exposed fixture issues (PowerShell null/enumerable outputs and desktop numeric culture)
which were corrected before the final run. Historic 34 mutation outcomes were not rerun.

## Optional dependency evidence

Read-only Search-Workshop.sh metadata discovery covered 10,022 installed folders: 9,864
contained matching About.xml filenames; the other 158 had none. The target packages were
then verified directly against their own About.xml, 1.6 Defs and applicable LoadFolders.
Initial Bash PATH/sandbox failures were not treated as successful discovery.

| Provider | Local source | Checked references |
| --- | --- | --- |
| Perfumes | Workshop 3013711969, package Romyashi.Perfumes, 1.6/Defs | Four perfumes plus AromaflowerPetals; anima perfume additionally requires Anima Expansion |
| Anima Expansion | Workshop 3532147582, package Romyashi.AnimaExpansion, 1.6/Defs | No standalone anima perfume ThingDef; it enables the conditional definition in Perfumes |
| Vanilla Brewing Expanded | Workshop 2186560858, package VanillaExpanded.VBrewE, 1.6/Defs and conditional 1.6/Mods/VanillaPlantsExpanded/Defs | Nine unconditional referenced drinks; cider only when VPlantsE or VPlantsE_copy enables that folder |
| Incense Plus | Sibling RimScentExtendedIncensePlusExpansion/Mod | All six named incense ThingDefs |
| Rum and Shanties | Sibling RumAndShanties/Mod, root Defs selected by 1.6 LoadFolders | VFEP_Rum |

Profiles: none (0 references), brewing only (9), brewing+plants (10), brewing+plants-copy
(10), perfumes only (5), anima only (0), perfumes+anima (6), all (23). No package was activated.
The old XML fails the anima-only profile. A copy removing only the new cider gate fails
the brewing-only profile. These checks establish reference availability and conditional
loading, not the gameplay behavior of any third-party integration.

## Required final game validation

Current stage is **done**, ready for final game validation under the supplied workflow.
Execute docs/TESTING.md scenarios 0-12 in English and French, with a new colony and an
existing save. Check actual settings effects, force-worn flags and paint cleanup, changing
settings mid-trip, save/restart persistence, absence of a default visible/grey shortcut,
RIMMSQOL reveal/open/hide persistence, applicable companion mods and Player.log. Record
actual versions and observed results before advancing to tested.

The historical 2026-09-04 load observation remains historical and does not certify this
corrected build in game. No feature-level game success is inferred from green automated tests.
