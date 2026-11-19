# Pickle runs

One line per run (AUDIT.md 8.l). All runs English unless stated, played in the WSL by the dispatcher worker, `sans-facultatifs` unless stated. Evidence on disk, ignored by git: kept proofs are in `Tests/Pickle/Evidence/` (each with a `RELEASE.md`).

| Date | Ticket | Set and scope | Result | Cause read from the report |
| --- | --- | --- | --- | --- |
| 2026-09-28 | b6cb | whole suite, no dep map | 12 of 16 passed, 3 failed, 1 skipped | test steps (`Driver.Settings` stale, `Driver.Ritual` null obligation list, `AssertQualityLine`); fixed, evidence deleted |
| 2026-09-28 | e3cf | whole suite | 19 of 47 passed, 17 failed, 11 skipped | test side: obligation choice, `CanUseTarget` throw, raid arrival, missing Workshop URL in the Pickle mod; fixed, evidence deleted |
| 2026-09-29 | c9be | whole suite, without 09 | 102 of 129 passed, 14 failed, 13 skipped | double `AddObligation` call, raid with no hostile pawn, feature 14 fixture ideoligion has no ritual that takes a bare spot; evidence deleted |
| 2026-09-29 | fourth run | whole suite | 104 of 129 passed, 12 failed, 13 skipped | features 06, 07, 08, 14 red, no preparation record after `Announce`; deleted |
| 2026-09-30 | | `avec-offrandes`, `avec-rimmsqol`, restart pair | 5 of 5, 4 of 4, 2 of 2 passed | green; offerings and rimmsqol folders superseded 2026-10-19 |
| 2026-09-30 | | `sans-odyssey`, `avec-shiftchange` | 3 of 9 (watchdog-timeout), 1 of 2 | 175 s waits in feature 06; Shift Change unifies owners (mod design, see STATUS decision); deleted |
| 2026-10-19 | 365c, 9108, a749 | features 04 `avec-rimmsqol`, 05 `avec-offrandes`, 14 | 4 of 4, 6 of 6, 2 of 3 passed | feature 14 `outcome twice`: the step looked the ritual lord up again after the first end (test defect) |
| 2026-11-04 | be36 | feature 14 | 3 of 3 passed | green after the `EndAgain` fix (9556c77); kept in `Evidence/full-en-2` |
| 2026-11-14 | a0a9, 1ede, ca32, 6225, 1bf3, ed47 | feature 06 scenario alone | red then found | mod defect fixed in `Divert` (4e7ead7); trip cut by a scenario step, not the mod (b0ee929) |
| 2026-11-14 | 5a67, 08f0 | feature 06 | give-up scenario green, whole file 7 of 7 | kept in `Evidence/dressing-06-whole-en` |
| 2026-11-14 | 7797, 4cdb | features 07, 08 | 4 of 4, 2 of 2 passed | after scenario placement fixes (96dc1dc, f288136, 8e4b9a3); 08 kept in `Evidence/danger-08-en-1` |
| 2026-11-15 | b4a3 | whole suite, without 09 and 15, English | 34 passed, 11 skipped, 0 failed | kept in `Evidence/full-en-2` |
| 2026-11-15 | 3363 | whole suite, French | green | kept in `Evidence/full-fr` |
| 2026-11-15 | b27f, 999f, a9ee, a255 | feature 10 `avec-offrandes`, 04 `avec-rimmsqol`, 11 `avec-shiftchange`, 09 `sans-odyssey` | 5 of 5, 4 of 4, 2 of 2, 2 of 2 passed | the 11 skips of b4a3 played in their own sets; kept in `Evidence/` |
| 2026-11-19 | b2d9 (refile of 8b30 red: landing blocked by an open dialog) | feature 16 `nouvelle-colonie`, English, tree c12aadb | 1 of 1 passed | new colony starts with the mod, no error logged; kept in `Evidence/new-colony-en/` |

Not covered: feature 15 (gallery, `@review`, `shootGallery`), the 1.7 pass, the floor path in a game really without Odyssey (no save without Odyssey).

Harness: 37 passed, 0 failed, 2026-11-02, on the distributed DLL `DD89BD90` (`Tests/Run-Functional-Tests.ps1`).
