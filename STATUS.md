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
showcase:     complete
social_preview_sha256: 930ef19bfe3eede353c76ae3fa97d35c1b10b1970f46bfb586b514c519a7ca3b   # uploaded 2026-10-12 to the GitHub social preview, og:image checked (same bytes)
echo_review_sha: 145cbda5257b78d925577295800b758609e79c4d
tested_on:    2026-09-30, headless Pickle in the WSL, English only, partial and red (see pickle_suite); no French pass, nothing seen by a person in the Windows game
workshop:     3806761333, created private by the 0.1.0 pre-publication of 2026-09-23 (Steam creates every item private; its visibility was not checked by this audit). Mod/About/PublishedFileId.txt holds the id and is committed and pushed (0768d4d). The pre-publication is an act, not the prepublished state; the item is neither tested nor public.
settings_audit: complete
tested_1_7:   no   # not played: the 1.7 pass follows the green 1.6 playTests (AUDIT.md, Passe 1.7)
audit_date:   2026-10-11
audit_revision: c42b53d, tree dirty (Art migration, STATUS.md, documents); no file of Source/, Mod/Languages or Mod/Assemblies changed since 8116a55
automated_tests: 39 passed, 0 failed, 0 skipped, 2026-10-02, replayed on 84a70dc with the DLL DD89BD90 (not rebuilt this time; the distributed file)
pickle_suite: written 2026-09-28; 14 features (01 loading, 02 settings, 03 shortcut, 04 RIMMSQOL, 05 offering table, 06 dressing without a building, 07 outfit stand, 08 danger, 09 without Odyssey, 10 optional providers, 11 Shift Change, 12 and 13 restart, 14 the ritual hook), five pass maps. Three runs so far, `sans-facultatifs`; docs/runs/2026-09-28.md (runs 1-2) and docs/runs/2026-09-29.md (run 3) have the detail. Run 3 (c9be), 2026-09-29: 102 passed, 14 failed, 13 skipped of 129; settings/offerings/log/Odyssey-pass all confirmed fixed; two more test-side bugs fixed (a double AddObligation call, a raid strategy that could land no pawn on the map); feature 14 (the ritual hook) now fails cleanly on a fixture limitation flagged to the owner (the test-colony ideoligion has no ritual that both skips a required role and accepts a bare RitualSpot), not yet resolved, so `tested` is not reached. Since then (docs/runs/2026-09-30.md): fourth run 2026-09-29, 104 passed, 12 failed, 13 skipped of 129, the same features red (06 dressing, 07 stand, 08 danger, 14 ritual hook); `avec-offrandes` 5/5 green, `avec-rimmsqol` 4/4 green, restart pair green; `sans-odyssey` watchdog-timeout, feature 06 times out; `avec-shiftchange` 1 of 2, the reload loses the owner. All passes have now run once in English, none is fully green
remaining:
  - "unverified (writeTests, 3.b): a rebuild on 2026-10-11 gives a DLL (SHA256 7B0ABAB2...) that differs from the committed one (DD89BD90...) with the same sources: Source/ForTheOccasion.csproj floats Lib.Harmony 2.* and Krafs.Rimworld.Ref 1.6.*-*, and newer packages are now in the NuGet cache. The committed DLL was kept; not pinned (no code change made). Decide with the owner whether to pin."
  - "unverified (writeTests, 7.b): LOCAL_SCRIPTS.md rows for scripts/*.ps1 and Tests/Pickle/Check-Steps.ps1 await the Audit workflow session validation. 2026-10-11: _tools/ moved to scripts/, _tools/cutout-icon.cjs and compose-preview-icon.cjs deleted (obsolete), .build/ removed (the two Directory.Build.props deleted: intermediates now in Source/obj, gitignored)."
  - "defect (done -> tested): scenarios red on the fourth run and the Shift Change pass: features 06, 07, 08 (no preparation record after Announce; the outfit stays unchanged; the raid step times out), feature 14 (the fixture ideoligion offers no ritual that takes a bare RitualSpot without a role), and the Shift Change reload ('ceremonial owners are [Belle], not Aurel'). Whether each is a mod defect or a test defect is not yet established from the reports. None has a green replay on a build that contains a fix."
  - "unverified (done -> tested): a French pass of the suite (every pass so far ran in English), the @review captures (only the hidden-shortcut capture was opened), and the pass `sans-odyssey` played to its end (it hit the watchdog)."
  - "resolved 2026-09-28 (options -> l10n): FTO_OfferingsConsumed now has .One and .Many in both languages, chosen by the count (commit 8116a55), with harness test 39, seen red on three mutations. The three translation fields are complete again. The 0.1.0 upload carries the earlier DLL."
  - "resolved 2026-09-28 (preTest -> done, AUDIT.md step 8): the Pickle Gherkin suite is written in Tests/Pickle: 14 features, a steps assembly, five pass maps and a README that says what is covered and why what is left is not. Its step patterns compile with Pickle's own engine and every step line resolves without ambiguity (Tests/Pickle/Check-Steps.ps1). Scenario 9 (a birth) is justified as not applicable. Written, never run, and the first run is expected to need tuning."
  - "blocking (done -> tested), the gates set by the owner: (1) no scenario left in @wip: none exists, and none may be parked; (2) every conditional scenario has run, that is each @requires:<packageId> (Odyssey, RIMMSQOL, Shift Change, the optional offering providers) has had its own pass with a report read (RIMMSQOL and the providers: played and green; Odyssey-absent and Shift Change: played, red); (3) no manual test left to validate: the suite now exists and TESTING.md scenarios 0 to 12 map to its features (Tests/Pickle/README.md); every one must run green, scenario 9 is justified as not applicable, and one risk stays open: feature 14 (the hook that consumes at the end of a real ritual, begun from the game's own Begin ritual window) has never run, and if the test colony cannot begin such a ritual the gap reopens and must be closed or justified. Seven requests are needed, listed in TESTING.md."
  - "unverified (done -> tested): nothing has been observed in game on this build. Settings effects, persistence across restart, the disable-with-a-borrower regressions, the RIMMSQOL reveal, open and hide, English and French layout, Player.log, a new colony and an existing save, and Shift Change coexistence. Only the load (scenario 0) was ever seen, on 2026-09-04, on an older build."
  - "unverified: no customization mod has been tested in game, so no integration may be claimed. The shortcut is checked by its definition and by the native getter in the delivered code, not by a running RIMMSQOL."
  - "prepublished work still owed (tested -> prepublished): PUBLICATION.md does not exist; the description's THANKS credits only Ludeon, Harmony and Claude Code and does not thank the authors of the mods it names (Romyashi for Perfumes and Anima Expansion, Vanilla Brewing Expanded, Shift Change), nor link them; none of them is in WORKSHOP_COMMENTS.md yet. The page created by 0.1.0 carries the description as it stood on 2026-09-23."
  - "open tickets 2026-10-16 (owner of all: session FtO local_3985f501, registered with TM): 0b26 feature 06 (diagnostic step dropped), 7c89 feature 14 (substitutable roles accepted, steps rebuilt), ba7b feature 11 avec-shiftchange (owners unified, asserts Belle alone on both comps). Next: if 0b26 is green apply the same removal of the made-to-choose-a-new-job step to features 07 and 08, if red find a job boundary that does not interrupt by force; sans-odyssey watchdog only after 06 is green."
  - "decision 2026-10-16 (Virginie, go): Shift Change unifies stand owners with every other assignable comp and hides our Set ceremonial owner button, so with both mods the owner is one list assigned through Shift Change; feature 11, TESTING.md and the Steam description follow it (no promise of two distinct owners or of our button)."
  - "gallery 2026-10-16: PUBLICATION.md plan, looks (Vanilla Hair Expanded: VHE_Buzzcut, VHE_SideBraid), expressions and six subtitles are written; Tests/Pickle/Mod/Pickle/Features/15-gallery.feature (images 1 2 3 4 7) and wsl-deps.galerie.map are written, never run, no ticket (shootGallery work after green playTests). Images 5, 6, 8 not written; 6 waits for feature 14."
  - "reserve, optional, not blocking: the Preview was engraved on 2026-09-13, before the overlay standard of 2026-09-25, so it has no version badge and there is no Art/preview-palette.json; the dependent settings are hidden when their parent is off instead of being greyed with a reason. Neither is a criterion of the chain."
session:      local_3985f501-9197-4120-a625-646747326435
updated:      2026-10-11, French review by Virginie applied; writeTests exit criteria met; stage playTests[1.0.0]
protocols_read_sha: 2f60f605ba8f292dec63672a8b562473b846d6a7
---
# For the Occasion: status

## Workflow audit, 2026-10-11

**Previous: `done` (old vocabulary). Retained: `writeTests[1.0.0]`.** Revision `c42b53d` on `main`; local changes: Art migration (Preview.config.json, echo, Gallery, ModIcon sources), STATUS.md, documents. `Source/`, `Mod/Languages`, DLL untouched since `8116a55`. No game started.
Earlier dated sections moved to [docs/runs/2026-10-11-status-history.md](docs/runs/2026-10-11-status-history.md).

| Transition | Result |
| --- | --- |
| setupRepo to localize | Held, as audited 2026-09-28 and 2026-10-02; no key, text, dependency changed. |
| writeTests 7.b | Harness replayed today: 39 passed, 0 failed, 0 skipped, 8 s, on distributed DLL. |
| writeTests 7.d | Pickle suite written (14 features, five pass maps), run in English; not criterion of this state. |
| writeTests 7.g | **Not met.** `translation_fr` is `partial`: Virginie's French review not recorded. |
| playTests | Not reached; red scenarios and unverified items listed in `remaining`. |

### Necessary to leave `writeTests`

1. Virginie reviews `FRENCH_REVIEW.md`, answers; then `translation_fr: complete` with review recorded.
2. Audit workflow session validates local scripts (`scripts/LOCAL_SCRIPTS.md`).

### Then in `playTests`

Fix and replay red features 06, 07, 08, 14, Shift Change reload, `sans-odyssey`; French pass; open `@review` captures.
### Full replay of the chain, 2026-10-11 (current protocols)

- **setupRepo, makeSources:** repo PUBLIC, `main` equal `origin/main`; `ATTRIBUTION.md` and `LICENSE` identical to `Mod/` copies; ModIcon.png 128 x 128 PNG, 21.8 KB; Preview.png 896 x 504 PNG; icon and Preview derivatives newer than neither source change of 2026-10-02/03 (Art migration uncommitted, owned by another change). `Art/` still holds files outside minimal set (`ModIcon-original.png`, `ModIcon-signature-candidate.png`, `echo-source.svg`): closing-pass step 1, clear at commit.
- **code:** CHANGELOG heading renamed `## [Unreleased]` (was `## [1.0.0] - unreleased`, 3.c). Build: 0 warnings, 0 errors; DLL not reproducible byte for byte (see `remaining`).
- **declareDependencies, auditSettings, localize:** `Check-ModBasics` PASS (13 XML, 7 defs), `Check-Translations` PASS (25 Keyed calls, French injections), `Check-DefRefs` clean (7 defs). About.xml: Ideology and Harmony hard, optional providers in `loadAfter`.
- **writeTests:** harness 39 passed; Pickle suite written. `TESTING.md` is scenario file (AUDIT.md 7.a names `TEST_SCENARIOS.md`, other protocol lines say `TESTING.md`: not renamed). `PUBLICATION.md` not exist yet (writeDocs). Exit blocked by 7.g only.

### Translation audit, 2026-10-11: Virginie's review

Reviewer: Virginie, 2026-10-11, revision 6f09caf plus working tree before commit 685b646. English and French read in full. Corrections (applied verbatim, 685b646): FTO_Offering_Food, FTO_Offering_Drink, FTO_OfferingsDesc (old Désactivé, la table... incorrect), FTO_PreparationDesc, FTO_TattooDesc last sentence, FTO_PreparedFactor, FTO_PreparedTooltip, FTO_SetCeremonialOwnerDesc (gender-free wording), FTO_OfferingTable.description (marquent l'occasion), English FTO_SetCeremonialOwnerDesc opening, two CHANGELOG fixes, em dashes removed from French sources and docs. FTO_TattooDesc and FTO_PreparedTooltip participles agree with tattoo, not colonist: correct. Harness 39 of 39 and Check-Translations PASS after edit. French and English texts changed: Pickle scenarios displaying them replayed in playTests (French pass included).

### playTests, 2026-10-11: first fix and ticket

Cause of fourth run's common signal, read from `junit.xml`: feature 06 first fails at `the anticipation window is closed although an obligation was announced`. `ObligationWatch.WindowOpen()` caches answer 250 ticks; Background's own `StartJob` calls cached "closed" before `Announce` ran, so test read stale answer. Judged test defect (in play lag at most 250 ticks, about 4 s normal speed; mod unchanged). Fix: `Announce` calls `ObligationWatch.Invalidate()` (commit `78abc09`, steps DLL rebuilt; `Check-Steps.ps1` cannot run here: `CucumberExpressions.dll` missing under Pickle's Workshop folder). Ticket `20261011-222852-943-f2ea`, `-Filter '::an announced ritual sends a free colonist'`, `sans-facultatifs`, evidence `Tests/Pickle/Evidence/2026-10-11-announce-en`. Features 07 and 08 share signal, replayed after this one green; feature 14 and Shift Change reload separate questions.

Ticket `20261011-222852-943-f2ea` (2026-10-11, exit 1, `Tests/Pickle/Evidence/2026-10-11-announce-en`): stale-cache fix worked, window assert now passes; scenario then fails at `pawn 'Aurel' should be wearing 'Apparel_Robe'; wearing Apparel_Pants, Apparel_BasicShirt` (all four colonists hauling, 600 ticks later). Which gate of `Patch_JobInterception.Decide` closed not visible: prefix fails open, logs nothing. Commit `c4185cf` adds step `For the Occasion: {string} is ready to be sent to dress` (asserts gates one by one) after window assert of feature 06. Ticket `20261012-041650-538-a959`, same filter. Duplicate ticket `20261012-041516-624-74d3` submitted by mistake, cancelled before run.

### Preview refresh, 2026-10-12

Art committed (`d021321`: ModIcon source and derivatives, Preview config, `echo-preview.png`, gallery; superseded cutout and old previews dropped). `Art/Preview.config.json` now takes `echo.file: echo-preview.png`; `node ../scripts/Render-Preview.cjs` regenerated `Mod/About/Preview.png` (896 x 504, 635,825 bytes) and `Art/Gallery/0-preview.png` (byte-identical, checked with `cmp`) (`d42a085`). Image opened: title, rule, summary, echo, 1.6 badge legible, nothing overlapping. GitHub social preview uploaded from that file; repository `og:image` serves same bytes (sha256 above, recorded in `social_preview_sha256`). Not done: `echo_review_sha` (echo decision is owner's; linter asks before `prepareRelease`). `Art/ModIcon-original.png` untracked, outside minimal set: committed (kept in history), then removed.

2026-10-12: ModIcon badge moved to bottom-right corner (`Art/Preview.config.json`: `corner`, `translate`, `veilRight`); Preview and `Art/Gallery/0-preview.png` regenerated (`145cbda`, identical bytes, 631,499), image opened, legible; social preview re-uploaded, `og:image` serves same bytes, `social_preview_sha256` updated.

Echo validated by Virginie, 2026-10-12: `Art/echo-preview.png` kept (colonist and brazier line-art, top-left panel); `echo_review_sha` = `145cbda`, commit of gallery and echo state she saw.

### Audit replay, 2026-10-15 (protocols at e733386f)

Re-read protocol changes since `71363b2e`: state `auditSettings` now `settings`; session names carry no marker (Workflow Board colours them); `Art/Gallery-clean/` and gallery subtitles (shootGallery, later); full Pickle pass only for diagnostic and non-regression, red scenario replayed alone; no RimWorld version in reader-facing descriptions (`PUBLICATION.md` not written yet); `tested_1_7` field (set `no`, not played); echo path `echo-source.png` with interim `echo-preview.png` invalidated by first gallery capture (mountPreview). Replayed on current tree: `Check-Status -Strict` 0 errors 0 warnings, `Check-ModBasics` PASS, `Check-Translations` PASS, harness 39 of 39. Stage unchanged, `playTests[1.0.0]`: scenarios of feature 06, 07, 08, 14, Shift Change reload still red or unplayed on current steps; ticket `20261014-111325-739-d83a` abandoned by queue (nothing played), no ticket of this mod queued.

### Gallery plan, 2026-10-15

No gallery capture or scenario existed: `Art/Gallery/` holds only `0-preview.png`, no story written. `PUBLICATION.md` now carries story ("The feast day", one day at Sanctuary, Nelim protagonist), wardrobe and faces of three pawns, eight-image plan mapped to `TESTING.md` scenarios, subtitle table (six scenes, interface captures 5 and 8 none). Image 6 (offerings spent) blocked until Pickle feature 14 has run; image 4 needs three dressed pawns, never played. Nothing played or captured; gallery scenarios are `shootGallery` work, after green `playTests`.

Ticket `20261015-222535-292-52aa` (2026-10-15): feature 06, one scenario, steps of `4c0a14f` (steps DLL is one built 2026-10-13); evidence `Tests/Pickle/Evidence/2026-10-15-announce-en`. Replaces abandoned `20261014-111325-739-d83a`.

### Audit replay, 2026-10-16 (protocols at 005d9b27)

Protocols re-read since e733386f: titles now `<pastille> <code> <short name>/<stage>` (code `FtO`), `dormant[x.y.z]`, local scripts table (nothing for this mod); `protocols_read_sha` updated. Replayed on current tree: `Check-Status -Strict` 0 errors 0 warnings, `Check-ModBasics` PASS, `Check-Translations` PASS, `Check-DefRefs` clean, harness 39 of 39. Stage unchanged, `playTests[1.0.0]`. Ticket `20261015-222535-292-52aa` failed on test defect: diagnostic step re-called `Decide` after real divert, which 300-tick cooldown then let through; step removed from feature 06, ticket `20261016-114205-285-0b26` replays it. PUBLICATION.md gallery plan read against TESTING.md (stand holds robe in image 1, expressions by image, Odyssey).

### Shift Change reload, read from its code, 2026-10-16

Red step of `avec-shiftchange` (`the ceremonial owners are [Belle], not Aurel`) fails BEFORE reload, so not save-key leak. ShiftChange.dll (3783456242), `CompAssignableToPawn_ShiftStand`, deliberately unifies owners with every other `CompAssignableToPawn` on same stand (`ReconcileForeignOwners`, `SyncForeignOwners`, `CopyOwnersInto`): assigning Belle in its comp copies Belle into ours, removes Aurel. Two mods therefore do not keep two owners apart; stand has one owner list, set by whichever comp edited last. Not defect of FTO save keys, not test defect: feature 11 and TESTING.md cohabitation text assume behaviour Shift Change lacks. Owner decision needed: accept unified owner and rewrite feature 11 to assert it, or find way to keep lists apart.

Shift Change, second reading (2026-10-16): `Patch_ForeignOwnerGizmos` returns no gizmo for every other `CompAssignableToPawn` on stand with `CompShiftStand`, so our "Set ceremonial owner" button hidden there; owner set through Shift Change, mirrored into our comp by `SyncForeignOwners` (flag `ownersUnified`, set in `PostSpawnSetup`, saved under `shiftChangeOwnersUnified`). Unproven: what other comp holds after `TryAssignPawn(Belle)` when Aurel there first (feature 11, ticket `ba7b`, asserts both comps hold Belle alone).