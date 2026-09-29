---
localization: complete
translation_en: complete
translation_fr: complete
mod:          For the Occasion
packageId:    nelim.fortheoccasion
repo:         Rimworld-For-The-Occasion
remote:       https://github.com/vbardales/Rimworld-For-The-Occasion.git
local_path:   C:\Users\nelim\Documents\rimworld\ForTheOccasion
visibility:   public
detached:     yes
stage:        done      # workflow state names are used literally, no codes; see the 2026-09-28 audit
licence:      open
licence_at:   written from scratch, MIT, sources shipped, and nothing is reused; the wardrobe path was shaped by Shift Change's design document, a named debt, and that mod is MIT
upstream_mod_remotes: N/A   # original work, nothing forked or based on; not `repo` (this mod's own repo) or `origin` (its git remote)
dependencies: declared
showcase:     complete
tested_on:
workshop:     3806761333, created private by the 0.1.0 pre-publication of 2026-09-23 (Steam creates every item private; its visibility was not checked by this audit). Mod/About/PublishedFileId.txt holds the id and is committed and pushed (0768d4d). The pre-publication is an act, not the prepublished state; the item is neither tested nor public.
settings_audit: complete
audit_date:   2026-09-28
audit_revision: 5053f5d when the checks ran; the plural fix is 8116a55 (it changed Source/, the two Keyed files and the DLL)
automated_tests: 39 passed, 0 failed, 0 skipped, 2026-09-28, on 8116a55 and the DLL DD89BD90 (rebuilt to the same bytes as the one distributed)
pickle_suite: written 2026-09-28; 14 features (01 loading, 02 settings, 03 shortcut, 04 RIMMSQOL, 05 offering table, 06 dressing without a building, 07 outfit stand, 08 danger, 09 without Odyssey, 10 optional providers, 11 Shift Change, 12 and 13 restart, 14 the ritual hook), five pass maps. Two runs so far, `sans-facultatifs`, docs/runs/2026-09-28.md has the detail: first run (b6cb) 12/3/1 of 16, all three failures in the test steps, fixed; second run (e3cf) 19/17/11 of 47, all seventeen failures again in the test steps (a ritual choice that could not build an obligation, a step's own CanUseTarget throwing, a raid arriving too far to be rated dangerous in time, this mod's own Workshop URL missing from the Pickle companion's About.xml, and one feature run under the wrong pass), fixed; not yet confirmed by a clean run
remaining:
  - "resolved 2026-09-28 (options -> l10n): FTO_OfferingsConsumed now has .One and .Many in both languages, chosen by the count (commit 8116a55), with harness test 39, seen red on three mutations. The three translation fields are complete again. The 0.1.0 upload carries the earlier DLL."
  - "resolved 2026-09-28 (preTest -> done, AUDIT.md step 8): the Pickle Gherkin suite is written in Tests/Pickle: 14 features, a steps assembly, five pass maps and a README that says what is covered and why what is left is not. Its step patterns compile with Pickle's own engine and every step line resolves without ambiguity (Tests/Pickle/Check-Steps.ps1). Scenario 9 (a birth) is justified as not applicable. Written, never run, and the first run is expected to need tuning."
  - "blocking (done -> tested), the gates set by the owner: (1) no scenario left in @wip: none exists, and none may be parked; (2) every conditional scenario has run, that is each @requires:<packageId> (Odyssey, RIMMSQOL, Shift Change, the optional offering providers) has had its own pass with a report read; (3) no manual test left to validate: the suite now exists and TESTING.md scenarios 0 to 12 map to its features (Tests/Pickle/README.md); every one must run green, scenario 9 is justified as not applicable, and one risk stays open: feature 14 (the hook that consumes at the end of a real ritual, begun from the game's own Begin ritual window) has never run, and if the test colony cannot begin such a ritual the gap reopens and must be closed or justified. Seven requests are needed, listed in TESTING.md."
  - "unverified (done -> tested): nothing has been observed in game on this build. Settings effects, persistence across restart, the disable-with-a-borrower regressions, the RIMMSQOL reveal, open and hide, English and French layout, Player.log, a new colony and an existing save, and Shift Change coexistence. Only the load (scenario 0) was ever seen, on 2026-09-04, on an older build."
  - "unverified: no customization mod has been tested in game, so no integration may be claimed. The shortcut is checked by its definition and by the native getter in the delivered code, not by a running RIMMSQOL."
  - "prepublished work still owed (tested -> prepublished): PUBLICATION.md does not exist; the description's THANKS credits only Ludeon, Harmony and Claude Code and does not thank the authors of the mods it names (Romyashi for Perfumes and Anima Expansion, Vanilla Brewing Expanded, Shift Change), nor link them; none of them is in WORKSHOP_COMMENTS.md yet. The page created by 0.1.0 carries the description as it stood on 2026-09-23."
  - "reserve, optional, not blocking: the Preview was engraved on 2026-09-13, before the overlay standard of 2026-09-25, so it has no version badge and there is no Art/preview-palette.json; the dependent settings are hidden when their parent is off instead of being greyed with a reason. Neither is a criterion of the chain."
session:      local_06821e6c-e45a-492a-99fd-d6a96d00f8af
updated:      2026-09-28, audit (options), plural fix (preTest), Pickle suite written (done)
---

# For the Occasion — status

## Update after the fix — 2026-09-28

**Stage: `preTest`, at that point.** The counted phrase was corrected the same day (commit `8116a55`): `FTO_OfferingsConsumed.One`
and `.Many` in both languages, picked by the count, and harness test 39 pins them. The rebuilt DLL matches the
distributed one (SHA256 `DD89BD90B58AEAD76455C8AF3B178F8127227EC7C0348C804D3D576A085C443F`), the harness passes
39 of 39, `Check-DefInjected` reports 13 keys and 0 errors. `options -> l10n` is therefore met, and
`l10n -> preTest` was already met, so the stage is `preTest`; `done` still needs the Pickle suite.
In the audit below, the `l10n` row and the first item of "Strictly necessary" describe the state before this fix.

**Stage: `done`, later the same day.** The Pickle Gherkin suite was written in `Tests/Pickle`: fourteen features,
a steps assembly of 60 steps, five pass maps and a README with the scope and the reasons. It has never been run.
`Tests/Pickle/Check-Steps.ps1` compiles every pattern with Pickle's own expression engine and matches all 347 step
lines against Pickle's vocabulary and the companions the maps stage: none is invalid, ambiguous or undefined (it
caught one undefined step while the suite was being written, `I save and reload`). The other criteria of
`preTest -> done` were already met: the scenarios are written, and the 39 automated tests and the XML tests are
green on the delivered DLL. What is left is the `done -> tested` gates, listed in `remaining`.

## Workflow audit — 2026-09-28

**Previous stage: `done` (2026-09-13). Retained stage: `options`.** The stage names are the workflow's own,
used literally: `dansMonoRepo`, `horsMonoRepo`, ModIcon generated, Preview generated, `preOptions`, `options`,
`l10n`, `preTest`, `done`, `tested`, `prepublished`, `published`. Later independent checks are kept where they
were established, but no state is claimed past a transition whose mandatory criteria are not all met.

Audited revision: `5053f5d` on `main`, equal to `origin/main` and to GitHub HEAD when the checks ran, then the audit's own commits up to `018d573`. Local
changes when the audit started: `Mod/About/PublishedFileId.txt` and `Art/ModIcon.ico`, `Art/Preview.ico`, all
untracked, and `Mod/desktop.ini`, ignored. No file of `Mod/` other than `ATTRIBUTION.md` changed during the
audit, and `Source/` and the DLL did not change at all. Protocol documents and their versions:
[docs/PROTOCOLS-READ.md](docs/PROTOCOLS-READ.md). No game was started and none was needed.

| Transition | Result |
| --- | --- |
| `dansMonoRepo` -> `horsMonoRepo` | **Validated.** Standalone repository at `C:\Users\nelim\Documents\rimworld\ForTheOccasion`, remote `origin` to the existing GitHub repository, PUBLIC (`gh repo view`), local HEAD equal to `origin/main`. STATUS.md initialised. `licence: open`, justified by an explicit MIT licence, sources shipped and no third-party file. Names agree: For the Occasion, `nelim.fortheoccasion`, `Rimworld-For-The-Occasion`, `ForTheOccasion`; no `renew`, since it is original. README, ATTRIBUTION, LICENSE and CHANGELOG are in English, and `ATTRIBUTION.md` and `LICENSE` are byte-identical to their copies in `Mod/`. **Origin repository: none.** This is an original work (nothing to fork, base on, or send a pull request to); the nearest prior art, Shift Change (MrBeverage, MIT, `github.com/beverage/shift-change`), was read for design only and nothing of it is reused. Written in ATTRIBUTION.md. |
| -> ModIcon generated | **Validated.** Release build, zero warnings and zero errors, rebuilt DLL identical to the distributed one (SHA256 `9FF631359D7CCC108DAFEAD1918D7364874917D53DEA6CC79D982AF1E5E2F7DE`). `ModIcon.png`: 128 x 128 PNG, 22,376 bytes, and legible at 32 px: the head, its party hat and the horn stay readable, the confetti reduces to specks. Nothing was generated, modified or requested. |
| -> Preview generated | **Validated.** `Preview.png`: 896 x 504 PNG, 831,737 bytes, under 1 MB. Opened at full size and at 268 px: the title, the summary and the ceremony scene (offering table, brazier, three colonists seen from above) are legible. No concrete camera defect. |
| -> `preOptions` | **Validated.** Description in English. The gold rule is one accent against a warm ambient and no secondary ink is in use, so there is nothing to confuse. `the` is set at the reduced linking-word size. No prefix or suffix is owed. The description ends on `[url=https://github.com/vbardales/Rimworld-For-The-Occasion]Source code on GitHub[/url]`, and its target agrees with the remote and with `<url>`. |
| -> `options` | **Validated, by source analysis and automated tests; not in game.** Eight global settings, each with a consumer; primary access is Mod options -> For the Occasion; the `FTO_Settings` MainButtonDef ships `buttonVisible=false` and opens the same native dialog. Harness tests 31 to 38 (defaults, bounds, a real Scribe round trip, older values, the shortcut contract, the disable regression, cache invalidation, real WriteSettings rescaling) pass on the delivered DLL. No customization mod was tested, so none is claimed. |
| -> `l10n` | **Defect, so not established.** One counted phrase breaks the counts-and-plurals rule of TRANSLATIONS.md (2026-09-25), see `remaining`. Everything else passes: 26 Keyed keys per language, nonempty, unique, with the same parameters; harness test 28 takes the requested keys out of the delivered code's `Translate` calls and finds all of them in both languages; `Check-DefInjected` 13 keys, 0 errors; no hardcoded player-facing sentence found. The three translation fields go from `complete` to `partial` for that reason alone. |
| -> `preTest` | **Validated independently; retained but not reachable yet.** Ideology and Harmony are declared and used; Odyssey is optional and its patches carry `MayRequire`; `loadAfter` names the optional providers; no `LoadFolders` is needed for a single root. `Check-Optional-Offerings`: 8 profiles pass, 23 optional references resolve. That is XML availability, not an in-game integration test. |
| -> `done` | **Not met.** Scenarios 0 to 12 are written with preconditions, actions and results; automated tests are written, run and green (38 of 38); the XML tests are part of them. **No Pickle Gherkin suite is written** (`Tests/Pickle/` does not exist) and its scope is not justified. |
| -> `tested` | **Not verified.** Nothing was played, and nothing may be until a suite exists and a pass is filed. The three gates are listed in `remaining` and in TESTING.md. |
| -> `prepublished` | **Not evaluated.** Independent findings are in `remaining`. |
| -> `published` | **No.** The Workshop item 3806761333 exists, private, from the `0.1.0` pre-publication (CHANGELOG.md, commit `0768d4d`); it is not the `1.0.0`. |

### Checks run, and what they showed

- `dotnet build Source/ForTheOccasion.csproj -c Release -t:Rebuild -p:OutputPath=<scratch>`: passed; the rebuilt
  DLL and `Mod/Assemblies/ForTheOccasion.dll` share the SHA256 above.
- `powershell -NoProfile -ExecutionPolicy Bypass -File _tools/Run-Functional-Tests.ps1`: 38 passed, 0 failed,
  0 skipped, 24 s, on `e9b1bc7`. It reads the installed game's assembly and Core and DLC Defs, and starts no game.
  Raw output on disk, ignored: `evidence/2026-09-28-e9b1bc7-harness.txt`.
- `pwsh -File _tools/Check-Optional-Offerings.ps1`: 8 profiles passed, 23 targets. From the monorepo root:
  `Check-DefRefs` (7 owned defs, no missing or wrong-type reference), `Check-XmlClasses` (11 types resolve),
  `Check-DefInjected -ExtraAssemblies Mod/Assemblies/ForTheOccasion.dll` (13 keys, 0 errors).
- Images read directly; the 32 px and 268 px renditions were made in a scratch folder and deleted.
- The `TESTING.md` move was checked by mutation on a scratch copy: harness test 29 goes red when the sentence it
  looks for disappears and when the file is missing.

### Kept, moved and removed today

- `0.1.0` added to CHANGELOG.md (`## [0.1.0]`, "creation of the `PublishedFileId.txt` file"), with the id file,
  committed and pushed as `0768d4d`.
- `.gitignore` gained `*.dds`, `*.ico`, `evidence/` and `Tests/Pickle/Evidence/`. **No `.dds` has ever been tracked**
  in this repository, in the tree or in any commit, and there was no Pickle evidence or capture anywhere, so nothing
  had to leave git for those reasons.
- `docs/validation-2026-09-13/` (raw output of a 38-test run and a hash manifest, both in git) removed: superseded by
  today's run on the identical DLL. Its narrative is `docs/runs/2026-09-13-validation.md`, and today's line is
  `docs/runs/2026-09-28.md`. What evidence to keep for the tests is written in `docs/runs/README.md` and
  `TESTING.md`.
- `TESTING.md` moved from `docs/` to the root, like every other mod; the harness, README and validation record follow.

### Strictly necessary to cross the next transition

1. **`options` -> `l10n`:** fix the one counted phrase (two keys per language, chosen by the count), add a harness
   test for it, rebuild so the distributed DLL matches the sources, and set the three translation fields back to
   `complete`.
2. **`preTest` -> `done`:** write the Pickle Gherkin suite for what only a running game can show, and state its
   scope. Read `PickleTools/Authoring/README.md` first; it was not read in this audit.

Not needed and not done: running any test in game, generating any image, publishing.

> The sections below are earlier audits, kept as history. Their statement that the stage is `done` is superseded by
> this one.

## Corrections and revalidation — 2026-09-13

**Current stage: `done` = ready for final functional validation in game (superseded on 2026-09-28: see the audit above).** This is
the supplied workflow's `done`, not `tested`. The previous audit below describes
the earlier revision and is retained as history; its defects are superseded here.

Baseline: `a5486e8b7418f06cd6fd677a609c44959669cd4b`, plus the current uncommitted
corrections. No commit or publication was performed. The pre-existing STATUS.md
changes and original art were preserved. Sources, distributed DLL, Preview,
settings shortcut Def and FR injection, Keyed scope text, optional-item gates,
About/attribution, tests and documentation changed. Detailed results and commands:
[docs/runs/2026-09-13-validation.md](docs/runs/2026-09-13-validation.md).

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

**Nothing has been observed in game.** `TESTING.md` holds ten scenarios, none of them run.
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
