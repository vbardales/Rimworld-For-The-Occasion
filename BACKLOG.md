# Backlog

Work not done and known defects of For the Occasion.

## Open

- Close the `playTests` exit (8.i new colony scenario, 8.m code review), then file the 1.7 ticket (`tested_1_7: no`; `<li>1.7</li>` only after a green 1.7 run).
- `Tests/Pickle/Mod/Pickle/Features/09-without-odyssey.feature` uses steps of ExpansionSteps without `@requires:nelim.pickletools.expansions` (`Check-Steps` REQUIRES line); the feature played green (a255), add the tag.
- Local scripts: convert to the generated `Tests/Test-Mod.ps1` plus one `Tests/Rule-OwnValues.ps1` shape (`AGENTS.md`, "Local scripts and tests"); needs the `0.1.0` prepublication state (done: Workshop 3806761333, `PublishedFileId.txt` committed) and CI/CD. Rows of `Tests/Run-Functional-Tests.ps1` and `Tests/Check-Optional-Offerings.ps1` await Audit validation.
- Not covered by any run: feature 15 (gallery, `@review`, `shootGallery`), the 1.7 pass, the floor path in a game really without Odyssey (needs a save without Odyssey or NewColony).
- Never seen by a person in the Windows game on this build: settings effects, restart persistence, RIMMSQOL reveal, layout in both languages, a new colony and an existing save, Shift Change coexistence. Only the load was seen (2026-09-04, older build).
- Build: a rebuild on 2026-11-19 gives the same DLL as `Mod/Assemblies` (SHA256 `23e4e3f4...`), but `Source/ForTheOccasion.csproj` still floats `Lib.Harmony 2.*` and `Krafs.Rimworld.Ref 1.6.*-*`, so a later package update can change it. Decide with the owner whether to pin.
- Gallery (`shootGallery`, after green `playTests`): `PUBLICATION.md` holds the plan; `Tests/Pickle/Mod/Pickle/Features/15-gallery.feature` and `wsl-deps.galerie.map` are written, never run. Images 5, 6, 8 not written.
- Publication, owed before `prepublished`: the Steam description THANKS credits only Ludeon, Harmony and Claude Code; it must thank and link the authors of the mods it names (Romyashi for Perfumes and Anima Expansion, Vanilla Brewing Expanded, Shift Change) and each gets a draft in `WORKSHOP_COMMENTS.md`.
- Owed: `social_preview_sha256` of `STATUS.md` differs from `Mod/About/Preview.png` (redone 2026-11-03 after the upload of 2026-10-12): upload again, record the new sha256. `echo_review_sha` is stale (gallery 0-preview).
- Optional, not blocking: the Preview has no version badge and there is no `Art/preview-palette.json`; dependent settings are hidden when their parent is off instead of greyed with a reason.

## Known defects

Found by the code review of 2026-11-19 (Opus sub-agent, all of `Source/` and the gameplay XML), fix owed after ticket 8b30 (the tree stays frozen while it waits), then replay features 06 and 07 and review the diff:

- **D1, confirmed:** `Patch_JobInterception.cs:108-113` calls `CeremonialWardrobe.Undress` when `CanReserveAndReach(stand)` fails. `Undress` swaps the apparel with the stand whenever it is spawned, without checking the pawn is on the same map or can reach it. A colonist who leaves by caravan or pod still in costume gets the street clothes from the stand on the other map; a stand walled in or reserved by a haul does the same on the spot. Fix: in that branch use the no-building path (drop the force-worn flag, keep the record or retry) unless the pawn is at the stand.
- **D2, plausible:** the return-trip gate (`Patch_JobInterception.cs:102-119`) does not test `IsForbidden`, but the job toils use `FailOnDespawnedNullOrForbidden`: a stand forbidden or taken out of the area after dressing may fail the return trip every 300 ticks. Check `Thing.IsForbidden(pawn)` in the gate.
- **D3, confirmed, low:** `CeremonialWardrobe.cs:265-276` saves the body tattoo with the face one and `RestoreTattoo` writes both back, so a body tattoo the player changed in between is lost. Fix: restore the face tattoo only.

Fixed earlier: Divert reservation conflict (4e7ead7), test-side timing and raid steps (features 06, 07, 08).
