---
localization: complete
translation_en: complete
translation_fr: complete
settings_audit: complete
mod:          For the Occasion
packageId:    nelim.fortheoccasion
repo:         Rimworld-For-The-Occasion
visibility:   public
detached:     yes
stage:        done
licence:      open
licence_at:   written from scratch, MIT, sources shipped, and nothing is reused; the wardrobe path was shaped by Shift Change's design document, a named debt, and that mod is MIT
dependencies: declared
showcase:     complete
tested_on:
workshop:
remaining:
  - unverified: Execute docs/TESTING.md scenarios 0-12 in game, in English and French,
      on a new colony and an existing save; inspect Player.log and UI layout.
  - unverified: Confirm settings effects and restart persistence, borrower cleanup when disabled,
      and RIMMSQOL shortcut reveal/open/hide persistence; no customization integration tested in game.
  - unverified: Exercise Shift Change coexistence and relevant optional content in game.
session:      local_06821e6c-e45a-492a-99fd-d6a96d00f8af
updated:      2026-09-13
---

# For the Occasion — status

## Corrections and revalidation — 2026-09-13

**Current stage: `done` = ready for final functional validation in game.** This is
the supplied workflow's `done`, not `tested`. The previous audit below describes
the earlier revision and is retained as history; its defects are superseded here.

Baseline: `a5486e8b7418f06cd6fd677a609c44959669cd4b`, plus the current uncommitted
corrections. No commit or publication was performed. The pre-existing STATUS.md
changes and original art were preserved. Sources, distributed DLL, Preview,
settings shortcut Def and FR injection, Keyed scope text, optional-item gates,
About/attribution, tests and documentation changed. Detailed results and commands:
[docs/VALIDATION-2026-09-13.md](docs/VALIDATION-2026-09-13.md).

- Preview: `the` reduced to the linking-word size; final image actually inspected,
  896 x 504 PNG, 831,737 bytes. Prior banner archived in Art/; original source kept.
- Settings: native primary page retained; `FTO_Settings` is a normal MainButtonDef
  with `buttonVisible=false`. Its worker opens the native Dialog_ModSettings for
  the same loaded mod instance and leaves visibility to the game/customization tool.
- Disabling preparation no longer bypasses either return path, including during
  an active ritual, and no longer equips a new outfit at the end of an in-flight
  dressing trip. Existing pawn safety/forced-job gates still defer unsafe returns.
- Technical settings audit passes: eight defaults, finite numeric ranges, actual
  Scribe save/reload and missing/older values, native shortcut/dialog contract,
  disable control-flow regression, cache invalidation and actual rescaling through
  WriteSettings. Game UI and external customization integration are not certified.
- Localization finalized after settings: 26 nonempty unique Keyed entries per
  language with matching parameters; 13 FR DefInjected paths validated against
  the delivered assembly. Source English covers owned Def fields. No unresolved
  owned key or hardcoded player-facing sentence found. Runtime layout remains pending.
- Optional references checked against current 1.6 source packages/LoadFolders.
  Two further defects corrected: anima perfume requires Perfumes AND Anima Expansion;
  VBE cider requires brewing AND either supported Vanilla Plants Expanded package.
  Eight present/absent profiles resolve all 23 optional targets. Dependencies remain
  optional; no customization mod was added as a requirement.
- Build succeeds with zero warnings/errors. Delivered DLL SHA256:
  `9FF631359D7CCC108DAFEAD1918D7364874917D53DEA6CC79D982AF1E5E2F7DE`.
  The functional harness passes 38/38; XML reference/type/injection checks pass.
  Regression 36 fails on the original DLL and passes on the correction; old optional
  XML and a cider-gate mutation each fail the corresponding present/absent profile.
- Scenarios 10-12 now specify full settings, disabling and shortcut game checks,
  with new/existing saves and EN/FR coverage. Historical scenarios 0-9 are preserved.

**Next transition (`done` -> `tested`):** execute those game scenarios and review
logs, translated UI, persistence and integrations. No game test was executed here.
There is no remaining established defect from this audit. Source link and English
XML-comment follow-ups were also corrected; no additional camera reservation.

## Workflow audit — 2026-09-13

Audited revision: `a5486e8b7418f06cd6fd677a609c44959669cd4b`, also the live GitHub
HEAD. Repository: `C:/Users/nelim/Documents/rimworld/ForTheOccasion`; distributed
content: its `Mod/` directory. Initial local changes: only three `unchecked`
localization fields added to STATUS.md. Those fields were audited and updated;
historical results below are retained. No implementation, image or distributed
binary was changed. The verification build is under ignored `.build/audit/`.

The user-supplied workflow overrides conflicting protocol advice, particularly:
settings technical checks precede localization, but interactive game checks belong
to `tested`, and direct image inspection does not require a historical generation log.
Read protocols: parent PUBLISHING.md, STYLE_RIMWORLD.md, MOD_SETTINGS.md and TRANSLATIONS.md.

**Previous stage: `preTest`. Retained stage: `preview` = "Preview generated"
("Preview generee" in the supplied workflow).** Stage codes for this audit are
`dansMonoRepo`, `horsMonoRepo`, `modIcon`, `preview`, `preOptions`, `options`,
`l10n`, `preTest`, `done`, `tested`, in that order. `modIcon` means "ModIcon generated".
Later independent checks do not bypass an earlier mandatory gate.

| Transition | Finding |
| --- | --- |
| dansMonoRepo -> horsMonoRepo | Validated: standalone .git root, configured GitHub origin, PUBLIC repository and pushed HEAD confirmed with `gh repo view` and `git ls-remote origin HEAD`. Names consistently identify For the Occasion / nelim.fortheoccasion / Rimworld-For-The-Occasion / ForTheOccasion. English initial documentation exists. MIT and attribution copies in Mod are byte-identical to the root copies. `open` is justified by the explicit MIT licence and documented original implementation with acknowledged design influences; no third-party assembly or texture is shipped. |
| horsMonoRepo -> ModIcon generated | Validated for the delivered implementation: rebuild succeeded, zero warnings/errors, and its DLL exactly matches the distributed DLL. Icon directly inspected: PNG, 128 x 128, 22,376 bytes, outlined winking mascot with celebration objects. Later settings-contract defects are recorded at their dedicated gate. |
| ModIcon generated -> Preview generated | Validated by direct inspection: PNG, 896 x 504, 612,870 bytes, below 1 MB. Ceremony, wardrobe and offering table are visible; title and English summary are legible. No concrete camera defect identified. Original artwork exists under Art/. |
| Preview generated -> preOptions | Defect: `the` in the title is rendered at full size; STYLE_RIMWORLD.md requires linking words at 65 percent unless essential as a strong word. Here it is the ordinary article before Occasion. No prefix/suffix is required for this original implementation; `For` is retained as the meaningful opening of the phrase. Warm gold and secondary blue in the scene are distinguishable; there is no status tag requiring secondary ink. |
| preOptions -> options | Partial: useful primary settings page exists; mandatory hidden shortcut is absent, and a disabling interaction has a code defect (below). The existing tests do not cover the complete settings contract. No game or RIMMSQOL test is claimed. |
| options -> l10n | Resource checks pass independently (below); formal localization fields remain partial until the settings gate passes and affected texts are rechecked. No missing owned translation was found. |
| l10n -> preTest | Required Ideology and Harmony are declared and used. RimWorld 1.6 is targeted. Odyssey is optional and its stand operations have MayRequire; optional offering references have per-item gates and loadAfter entries. No LoadFolders is needed for this single-root distribution. Current third-party item availability in every optional package has not been independently checked; retain this as an integration verification, not a known missing dependency. |
| preTest -> done | Existing scenarios 0-9 specify setup/actions/expected outcomes. Existing automated suite rerun: 30 passed, 0 failed, 0 skipped, including five XML tests against installed game definitions. These independent results do not cover the outstanding settings work or bypass earlier gates. |
| done -> tested | Non-verified: no functional game session executed during this audit. Historic load-only observation on 2026-09-04 is not final functional validation. FR/EN interface, settings persistence and shortcut, new game/existing save and relevant integrations remain to exercise. |

### Settings audit

Eight global options in Source/ForTheOccasionMod.cs: quality budget 1 (slider 0-2),
offerings true, preparation true, anticipation true, launch preparation true,
anticipation window 12 hours (1-48), maximum detour 40 cells (5-120), tattoos true.
All have meaningful consumers in preparation, wardrobe or offering code. Scribe
declares all eight defaults. Sliders constrain UI input; no free-text number entry
is exposed. Child controls depend on preparation and trigger toggles. Budget curves
are rescaled by WriteSettings; other switches are read during relevant actions,
with the anticipation cache refreshed at most every 250 ticks. These are source
observations, not successful persistence or full behavioral tests.

Primary access uses SettingsCategory/DoSettingsWindowContents. Inventory of Source/
and Mod/ found no MainButtonDef or MainTabWindow for a discoverable hidden shortcut.
RIMMSQOL and other customization integrations tested: **none**.

Concrete disabling defect: Patch_JobInterception.Decide returns immediately at
`if (!ForTheOccasionMod.Settings.preparationEnabled) return true;` before looking
up an existing PreparationRecord or executing the return path. Disabling the option
after a pawn dressed therefore disables this mod's cleanup as well; its stand
clothes and temporary tattoo cannot be restored through that path until reenabled.
PreparationTracker's periodic cleanup only removes stale/dead records, and
WriteSettings only rescales curves. This control-flow defect is established from
code; its visible game reproduction remains unexecuted.

Harness test 4 executes the two quality-component switches, and test 7 checks the
quality budget curves. They do not establish all eight defaults/boundaries,
settings serialization round trips, WriteSettings rescaling, trigger/tattoo effects
and the disabling interaction. Complete the applicable technical checks and fix
the established defects before marking settings complete. Interactive checks are
reserved for the final game gate, as explicitly required by the audit prompt.

### Translation audit

Inventory: settings labels/tooltips and title, ritual quality labels/tooltips and
consumption message, ceremonial owner gizmo and inspect string; one table's label
and description, four category labels/descriptions, one job report. Code uses
owned FTO_ keys, native translated Def labels and pawn names. Counts, checkmarks,
punctuation, internal save identifiers and English technical logs are not prose
requiring independent translation keys. No player-facing hardcoded sentence found.

Both Keyed files have 25 nonempty unique entries with matching parameter tokens;
reviewed English/French meanings. Harness test 28 extracts requested keys from the
delivered DLL's Translate calls and passes for both languages. All 11 owned
DefInjected fields have French values and English source Def values; redundant
English DefInjected files are unnecessary. Initial Check-DefInjected run could
not resolve the custom class (eight UNKNOWN TYPE warnings); rerun with
`-ExtraAssemblies .build/audit/ForTheOccasion.dll` checks all 11 with zero errors
and no unknown-type warning. OfferingCategoryDef inherits native translatable
label/description from Verse.Def. In-game formatting and language switching remain
unverified. Formal finalization waits for the settings gate, not missing resources.

### Executed checks and boundaries

- `gh repo view vbardales/Rimworld-For-The-Occasion --json name,visibility,defaultBranchRef`
  and `git ls-remote origin HEAD`: PUBLIC, main, audited SHA. Initial sandbox access
  failures were resolved by approved read-only execution.
- `dotnet build Source/ForTheOccasion.csproj --no-restore -t:Rebuild -p:OutputPath=../.build/audit/`:
  passed after approved SDK access; initial MSB4184 access denial was environmental.
  Cached reference packages: Krafs.Rimworld.Ref 1.6.4871, Lib.Harmony 2.4.2.
- Rebuilt and distributed DLL SHA256:
  `720D6B18D593827683A8283BB569E75ED0B162113EA0FA9910B6220D4985C682`.
- `powershell -ExecutionPolicy Bypass -File _tools/Run-Functional-Tests.ps1`:
  30 passed, zero failed/skipped, 132 seconds; installed Steam RimWorld assemblies
  and real Core/DLC XML, without starting the game. Historical mutation results
  were preserved but not rerun or recertified.
- `pwsh -File ../scripts/Check-DefRefs.ps1 -ModPath Mod -Brief`: six mod defs,
  XML well formed, no unresolved references, wrong target types or missing parents
  within this checker's scope; conditional third-party branches are not an exhaustive
  installed-integration validation.
- `pwsh -File ../scripts/Check-DefInjected.ps1 -TransMod Mod -Targets Mod -ExtraAssemblies .build/audit/ForTheOccasion.dll`:
  11 keys checked, zero errors. Keyed uniqueness/nonempty/token comparison also passed.
- `pwsh -File ../scripts/Check-XmlClasses.ps1 -ModPath . -TypeLists ../rw16_types.txt -Brief`:
  all 10 XML-referenced types resolved against the supplied game type list and mod sources.
  The delivered DLL was independently exercised by the functional harness.
- PNG format/dimensions/size read with System.Drawing; both images actually viewed.
  No historical generation report or comparison screenshot is required to retain
  these observations. No image generation/editing was performed.

### Next transition and separate publication notes

Strict next step: reduce the ordinary linking word `the` to 65 percent in the
Preview title, keeping the exact name and main ink, then inspect the resulting
image and confirm dimensions/size/legibility. No game test is required to cross
this next transition. The later settings defects remain independent blockers.

Publication follow-up outside this immediate transition: About.xml has the correct
repository url, but its description lacks the final Steam-formatted "Source code
on GitHub" link requested by PUBLISHING.md. French XML comments also remain in
the French Keyed file despite the English-comment convention. These do not imply
missing player-facing translations. No additional camera reservation is raised.

## Historical record (retained)

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
