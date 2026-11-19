# Backlog

Work not done and known defects of For the Occasion.

## Open

- Pass the `playTests` exit check (`AUDIT.md`), then file the 1.7 ticket (`tested_1_7: no`; `<li>1.7</li>` only after a green 1.7 run).
- Local scripts: convert to the generated `Tests/Test-Mod.ps1` plus one `Tests/Rule-OwnValues.ps1` shape (`AGENTS.md`, "Local scripts and tests"); needs the `0.1.0` prepublication state (done: Workshop 3806761333, `PublishedFileId.txt` committed) and CI/CD. Rows of `Tests/Run-Functional-Tests.ps1` and `Tests/Check-Optional-Offerings.ps1` await Audit validation.
- Not covered by any run: feature 15 (gallery, `@review`, `shootGallery`), the 1.7 pass, the floor path in a game really without Odyssey (needs a save without Odyssey or NewColony).
- Never seen by a person in the Windows game on this build: settings effects, restart persistence, RIMMSQOL reveal, layout in both languages, a new colony and an existing save, Shift Change coexistence. Only the load was seen (2026-09-04, older build).
- Build is not reproducible byte for byte: `Source/ForTheOccasion.csproj` floats `Lib.Harmony 2.*` and `Krafs.Rimworld.Ref 1.6.*-*`. The committed DLL (SHA256 `DD89BD90...`) is kept. Decide with the owner whether to pin.
- Gallery (`shootGallery`, after green `playTests`): `PUBLICATION.md` holds the plan; `Tests/Pickle/Mod/Pickle/Features/15-gallery.feature` and `wsl-deps.galerie.map` are written, never run. Images 5, 6, 8 not written.
- Publication, owed before `prepublished`: the Steam description THANKS credits only Ludeon, Harmony and Claude Code; it must thank and link the authors of the mods it names (Romyashi for Perfumes and Anima Expansion, Vanilla Brewing Expanded, Shift Change) and each gets a draft in `WORKSHOP_COMMENTS.md`.
- Owed: `social_preview_sha256` of `STATUS.md` differs from `Mod/About/Preview.png` (redone 2026-11-03 after the upload of 2026-10-12): upload again, record the new sha256. `echo_review_sha` is stale (gallery 0-preview).
- Optional, not blocking: the Preview has no version badge and there is no `Art/preview-palette.json`; dependent settings are hidden when their parent is off instead of greyed with a reason.

## Known defects

None open. Fixed this stretch: Divert reservation conflict (4e7ead7), test-side timing and raid steps (features 06, 07, 08).
