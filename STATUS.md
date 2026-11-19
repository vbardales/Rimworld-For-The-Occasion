---
localization: complete
translation_en: complete
translation_fr: complete   # reviewed by Virginie 2026-10-11 (reviewer, corrections applied verbatim in 685b646, see Translation audit below)
mod:          For the Occasion
packageId:    nelim.fortheoccasion
repo:         Rimworld-For-The-Occasion
remote:       https://github.com/vbardales/Rimworld-For-The-Occasion.git
local_path:   C:\Users\nelim\Documents\rimworld\ForTheOccasion
visibility:   public
detached:     yes
workflow_stage: playTests[1.0.0]
licence:      open
licence_at:   written from scratch, MIT, sources shipped, and nothing is reused; the wardrobe path was shaped by Shift Change's design document, a named debt, and that mod is MIT
upstream_mod_remotes: N/A   # original work, nothing forked or based on; not `repo` (this mod's own repo) or `origin` (its git remote)
dependencies: declared
ecosystem_line: 1.0   # PiI study of 2026-11-14 (Docs/inventory/ecosystem-steam/ForTheOccasion.md), links block 2026-11-19; the 1.0 line is done
workshop_required_items: n/a, not released yet   # 2026-11-19; the mod was never published (private item 3806761333, 0.1.0 pre-publication only); Harmony 2009463077 is the one mandatory Workshop dependency, to set as a Required item by hand at the end of writeReleaseDocs or at publish
showcase:     complete
social_preview_sha256: 930ef19bfe3eede353c76ae3fa97d35c1b10b1970f46bfb586b514c519a7ca3b   # uploaded 2026-10-12 to the GitHub social preview, og:image checked (same bytes); Preview.png redone 2026-11-03, upload owed (BACKLOG.md)
echo_review_sha: 145cbda5257b78d925577295800b758609e79c4d
code_review_sha: 4282f30985c7c9318d673941bd0cb3570aad22dc   # 2026-11-19, Opus sub-agent review of all Source/ and gameplay XML since the first commit; 3 findings in BACKLOG.md (two confirmed by reading)
tested_on:    2026-11-15, headless Pickle in the WSL, English and French, tree 8e4b9a3 plus STATUS commits; nothing seen by a person in the Windows game
workshop:     3806761333, created private by the 0.1.0 pre-publication of 2026-09-23 (Steam creates every item private; its visibility was not checked by this audit). Mod/About/PublishedFileId.txt holds the id and is committed and pushed (0768d4d). The pre-publication is an act, not the prepublished state; the item is neither tested nor public.
settings_audit: passed   # 2026-11-19: in game by Pickle in English (b4a3) and French (3363), the ten @review captures opened
tested_1_7:   no   # not played: the 1.7 pass follows the green 1.6 playTests (AUDIT.md, Passe 1.7)
audit_date:   2026-10-11
audit_revision: c42b53d
automated_tests: 37 passed, 0 failed, 0 skipped, 2026-11-19, Tests/Run-Functional-Tests.ps1, on the distributed DLL 23e4e3f4 (sha256 prefix; rebuilt identical)
pickle_suite: 15 features (01 to 14 plus 15 gallery, `@review`, shootGallery only), five pass maps. Green 2026-11-15 on 1.6: full suite English `sans-facultatifs` 34 passed, 11 skipped, 0 failed (b4a3); French (3363); the 11 skips played in their own sets (`avec-offrandes` 5 of 5, `avec-rimmsqol` 4 of 4, `avec-shiftchange` 2 of 2, `sans-odyssey` 2 of 2). One line per run in Docs/runs/pickle.md; kept proofs in Tests/Pickle/Evidence/
remaining:
  - "8.m done 2026-11-19: three findings recorded in BACKLOG.md (Known defects): D1 remote outfit swap when the stand is unreachable or on another map (CONFIRMED, Patch_JobInterception.cs:108-113 and CeremonialWardrobe.Undress), D2 return trip to a forbidden or out-of-area stand may loop (PLAUSIBLE), D3 tattoo restore also reverts the body tattoo (CONFIRMED, low). Fix after ticket 8b30 ends (tree frozen), replay features 06 and 07, review the diff. 8.i: ticket 8b30 queued 2026-11-19 (feature 16 new colony, English, pass nouvelle-colonie, tree 0131ac6, EvidenceDir Tests/Pickle/Inbox/new-colony-en): on RUN_DONE read summary.json and junit.xml, triage. 8.m: no code_review_sha, review since 0.1.0 not done. Then 1.7 pass"
  - see BACKLOG.md
session:      local_3985f501-9197-4120-a625-646747326435
updated:      2026-11-19, 8.i ticket 8b30 queued (feature 16 new colony); 8.m code review running
protocols_read_sha: c5366e853dd3a25a2e9c97cfed1c69ecb0357532
---
# For the Occasion: status

## State, 2026-11-19

`playTests[1.0.0]` after the replay of 2026-11-19 (Dependencies and Settings audit written; settings_audit passed). The suite is green in English and French on 1.6 (see `pickle_suite`). Open in the stage: 8.b, 8.i, 8.m (`remaining`), then the 1.7 pass (BACKLOG.md). The Inbox is empty and no run is queued.

Preview: `Art/Preview.config.json` and `Mod/About/Preview.png` redone 2026-11-03 after the `echo.width` and `echo.height` removal, validated by Virginie as rendered (echo robe hem touches the copy line, accepted). Echo `Art/echo-preview.png` validated by Virginie 2026-10-12 (`echo_review_sha`). ModIcon.png is 128 x 128 RGBA.

French title decided 2026-11-14: "Pour l'occasion" (`Docs/review-names.md`).

Decision 2026-10-16 (Virginie, go): Shift Change unifies stand owners with every other assignable comp (`ReconcileForeignOwners`, `SyncForeignOwners`) and hides our Set ceremonial owner button, so with both mods the owner is one list assigned through Shift Change; feature 11, TESTING.md and the Steam description follow it (no promise of two distinct owners or of our button).

Local scripts (2026-11-02): `Run-Functional-Tests.ps1` and `Check-Optional-Offerings.ps1` live in `Tests/`; harness 37 of 37. Rows await Audit validation (BACKLOG.md).

## Settings audit, 2026-11-19 (revision 69772df, DLL sha256 23e4e3f4)

Read in `Source/ForTheOccasionMod.cs` (`FtoSettings`, `DoSettingsWindowContents`, `WriteSettings`), `Mod/Defs/MainButtonDefs/MainButtons.xml` and `Source/MainButtonWorker_Settings.cs`. RimWorld 1.6, Harmony as declared. Scope: global (mod settings file), not per save.

**Inventory and rationale (eight options, all useful, none decorative):**

| Option | Default | Range | Why it exists | Applies |
| --- | --- | --- | --- | --- |
| `qualityBudget` | 1.0 (+0.25 total) | 0 to 2 | the one number that can compete with other ritual mods | at window close (`WriteSettings` rescales the curves of the comps attached at startup) |
| `offeringsEnabled` | on | on, off | switch the offering table bonus | next quality read |
| `preparationEnabled` | on | on, off | switch the dressing feature as a whole; off still lets borrowers return clothes | next job choice |
| `prepareOnObligation` | on | on, off | dress in the window after an announcement (free) | next job choice |
| `obligationWindowHours` | 12 | 1 to 48, rounded | length of that window | window cache invalidated at close (`ObligationWatch.Invalidate`) |
| `prepareOnLaunch` | on | on, off | dress at launch (costs ritual progress) | next job choice |
| `maxDetourDistance` | 40 | 5 to 120, rounded | keep the last-minute detour honest | next job choice |
| `tattooEnabled` | on | on, off | face paint for colonists with no tattoo | next dressing |

Dependent controls (window, detour, tattoo, launch) are hidden when their parent is off. No reset to defaults is offered. Owner decision 2026-11-19: both stay a reserve, optional, not blocking (BACKLOG.md).

**Access:** Mod options, then "For the Occasion", is primary. The MainButtons entry `FTO_Settings` is hidden by default (`buttonVisible` false: neither visible nor greyed), opens the same dialog, and RIMMSQOL reveals it. No customization mod is required.

**Commands and results (expected and observed):**

| Area | Run | Observed |
| --- | --- | --- |
| Harness (validation, persistence keys, bounds, no raw key) | `Tests/Run-Functional-Tests.ps1`, 2026-11-19, DLL 23e4e3f4 | 37 passed, 0 failed |
| Build | `dotnet build Source/ForTheOccasion.csproj -c Release` to a scratch folder, 2026-11-19 | 0 warnings, 0 errors, same sha256 as `Mod/Assemblies/ForTheOccasion.dll` |
| First use, primary access, effect, persistence (features 02, 12, 13), shortcut hidden by default (03) | Pickle `sans-facultatifs`, English and French, 2026-11-15, tree 8e4b9a3 (after the last `Source/` commit 66ab221) | 34 passed, 0 failed (b4a3 English, 3363 French); evidence `Tests/Pickle/Evidence/full-en-2`, `full-fr` |
| Shortcut integration (feature 04) | Pickle `avec-rimmsqol`, 2026-11-15 (999f) | 4 of 4 passed: listed hidden, revealed and drawn, hidden again, usable at 150 percent scale; `Tests/Pickle/Evidence/rimmsqol-04-en` |
| Optional dependencies | features 05 and 10 `avec-offrandes` (b27f), 11 `avec-shiftchange` (a9ee), 09 `sans-odyssey` (a255) | all green, `Tests/Pickle/Evidence/offerings-10-en`, `shiftchange-11-en`, `without-odyssey-09-en` |
| Runtime robustness | the same runs, log-clean step of each pass | no mod error in Player.log |

**Exclusions:** no reset to defaults exists, so the reset check does not apply. Opening the dialog from the RIMMSQOL button is RIMMSQOL's domain (owner, 2026-11-07). No person has watched the settings window in the Windows game on this build: Pickle captures only.

## Dependencies, 2026-11-19 (declareDependencies, revision 69772df)

Read in `Mod/About/About.xml`, `Mod/Patches`, `Mod/Defs` and `Source`; `Check-ModBasics` PASS, `Check-OptionalCompat` OK (0 target to declare, 7 already ordered by `loadAfter` or `modDependencies`).

- **Mandatory (`modDependencies`):** Ideology (`Ludeon.RimWorld.Ideology`, DLC, rituals and ideoligions) and Harmony (`brrainz.harmony`, Workshop 2009463077, `steamWorkshopUrl` and `downloadUrl` set; the job-start prefix needs it). Nothing else is required.
- **DLC:** Ideology required. Odyssey is optional: `Patches/OutfitStand_CeremonialOwner.xml` adds the owner comp to its outfit stands with `MayRequire`, and without it the no-building path runs. Royalty, Biotech and Anomaly are in `loadAfter` only (their robes and ceremonial garb are found by vanilla apparel tags, no reference). `supportedVersions`: 1.6. No `LoadFolders.xml`.
- **Optional integrations (offering providers, `MayRequire` on list items in `OfferingCategories.xml`, all in `loadAfter`):** Vanilla Brewing Expanded (`VanillaExpanded.VBrewE`), Vanilla Plants Expanded (`VanillaExpanded.VPlantsE` and `_copy`), Perfumes (`romyashi.perfumes`), Anima Expansion (`romyashi.animaexpansion`), RimScent Extended incense (`nelim.rimscent.extended.incenseplus`), Rum and Shanties (`nelim.rumandshanties`). None is required.
- **`OptionalCompat.xml`:** none shipped. Every guarded target is in `loadAfter`, so the file would be empty (`Check-OptionalCompat` 0 to declare).
- **Interactions with no declaration:** Shift Change (3783456242) and RIMMSQOL (the hidden MainButtons shortcut) are not referenced by code or patch (only comments name Shift Change); they are played in Pickle (features 11 and 04) and need no `loadAfter`, `MayRequire` or `OptionalCompat` entry.
- **Animals:** the mod adds none, so the four animal integrations of `ANIMALS.md` do not apply.
- **Required items on the Workshop page:** `workshop_required_items: n/a, not released yet` (front matter).

## Translation audit, 2026-10-11: Virginie's review

Reviewer: Virginie, 2026-10-11, revision 6f09caf plus working tree before commit 685b646. English and French read in full. Corrections (applied verbatim, 685b646): FTO_Offering_Food, FTO_Offering_Drink, FTO_OfferingsDesc, FTO_PreparationDesc, FTO_TattooDesc last sentence, FTO_PreparedFactor, FTO_PreparedTooltip, FTO_SetCeremonialOwnerDesc (gender-free wording), FTO_OfferingTable.description, English FTO_SetCeremonialOwnerDesc opening, two CHANGELOG fixes, em dashes removed from French sources and docs. Later ChatGPT reviews (2026-10-17, 2026-11-14, 2026-11-15) applied small changes at the owner's "applique ce qui est pertinent"; `TRANSLATION_REVIEW.md` is regenerated by `scripts/Make-TranslationReview.ps1 -ModRoot . -RepoType original` (the licence field `open` would otherwise read as `renew`).

Re-read 2026-11-19 (8.b): Virginie validated the texts as changed by the ChatGPT rounds of 2026-11-14 and 15 (revision c62dea6; round 11, page 1 of 1, came back with nothing to apply). Nothing changed.

## Ecosystem

Study by PiI, 2026-11-14 (22 searches), full file `Docs/inventory/ecosystem-steam/ForTheOccasion.md` in the rimworld root, PiI commit e09e95b. No original: own work.

- Duplicates and replacements: none. No mod makes colonists dress for an Ideology ritual, none adds an offering building that raises ritual quality.
- Patches and retextures of the original: not applicable.
- Translations of the original: not applicable.
- Links: Shift Change 3783456242 (MIT, Odyssey and Harmony, 1.6 and 1.7, v1.5.5 on 2026-11-06) swaps outfits per job, room or area at an outfit stand. No ritual mention in 131 comments. Our named design debt.
- Overlaps to play in Pickle: (1) Shift Change and FtO both move pawns into outfits, decide who wins at a ritual (Odyssey on); (2) Night Change (sibling mod) overlaps Shift Change's sleepwear stand, plus Pajama Shift 3694943331 and Automatic Swap Outfit 3547991604; (3) the +0.25 quality cap with Ritual Size Attenuation, More Ritual Rewards, New Ritual Reward (all touch `RitualOutcomeEffectDef`).
- Links block (PiI 0ef2ef1, 2026-11-19): 8 linked rows, no parent: Shift Change 3783456242 and its zh 3792236957, Automatic Swap Outfit 3547991604, Pajama Shift 3694943331, Outfit Stands Plus 3545172389 and Forked 3724311713, Do The Rituals Yourselves 3511385838, Ritual Size Attenuation 3262033797.
- Verdict: no rival. Overlaps are compatibility checks, not reasons to change the mod. If any Shift Change logic is taken, record it in ATTRIBUTION.md.
