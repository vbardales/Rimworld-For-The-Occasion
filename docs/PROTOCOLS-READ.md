# Workflow documents read, and at which revision

Kept by the For the Occasion session, as `WELCOME.md` (point 5) asks: what was read, in which version, and what was of
no use, so that a document is not reread until it changes. Updated 2026-10-02.

**Where versions come from.** The protocol documents (monorepo root) no longer have a git dir beside the monorepo
(`../rimworld-protocols.git` is gone), so they are identified by SHA-256 (first 12 hex digits) and modification time.
The tools' documents are in their own repositories (`git -C <repo> log -1 -- <file>`).

## Read in full on 2026-10-02

| Document | Version | Notes |
| --- | --- | --- |
| `AUDIT.md` | sha256 `7c00eb1f3b1b`, 2026-10-02 15:14 | Read whole. New since 2026-09-28: pass order (never played and red first, non-regression last), WSL clean-up at end of life, the fail-fast section, `FRENCH_REVIEW.md` is in TRANSLATIONS.md. |
| `TRANSLATIONS.md` | sha256 `e381086a5271`, 2026-10-02 09:51 | Only section 3, "Systematic French review by Virginie": `FRENCH_REVIEW.md` at the root via `scripts/Make-FrenchReview.ps1`. The rest was read on 2026-09-28 and 2026-09-30; not diffed. |
| `STATUS.md`, `TESTING.md`, `CHANGELOG.md`, `docs/runs/*`, `Tests/Pickle/Evidence/*/summary.*` | this repository | Read; STATUS.md and `docs/runs/` rewritten today. |

## Kept from earlier reads, not reread today; the file is newer than the read

| Document | Read | Now | Why it matters here |
| --- | --- | --- | --- |
| `AGENTS.md` | `3a1d2cb` 2026-09-24 | sha256 `7a236f03ca15`, 2026-09-29 | Evidence rules, publication by CI. |
| `PUBLISHING.md` | `95c6dfd` 2026-09-28 | sha256 `c765bb3c7bd1`, 2026-10-02 15:08 | New rules seen by grep only: gallery pawn captures dressed to show the mod (2026-10-01), typography and Preview line-art (`echo.png`) protocol. They matter for `prepublished` and for a future Preview; reread then. |
| `STYLE_RIMWORLD.md` | 2026-09-27 | sha256 `5a054cf3a04b`, 2026-10-02 15:08 | ModIcon control and the `.ico` convention only. |
| `MOD_SETTINGS.md` | `b83933b` 2026-09-23 | sha256 `404916bc99a7`, 2026-09-13 | Unchanged. |
| `PickleTools/Authoring/README.md` | `8d3ca6d` | `a47799f` 2026-09-29 | Reread when the suite is next edited. |
| `PickleTools/README.md` | `c771bef` | `ff20d89` 2026-09-29, modified, not committed | Reread when the suite is next edited. |
| `PickleTools/docs/steps.md` | `cba3ca1` | `da7c3b0` 2026-09-28 | Same. |
| `PickleTools/Headless/README.md` | `ed4e73a` | `ed4e73a` 2026-09-26 | Unchanged. |
| `Rimworld-Ticket-Dispatcher/docs/WELCOME.md` | `77ca9d7` 2026-09-27 | unchanged | Documents to read and note, evidence deletion past MAX_PATH (use `robocopy` `/MIR`, with `MSYS2_ARG_CONV_EXCL='*'` under Git Bash). |

## Read, and not useful for this mod now (do not reread unless it changes)

| Document | Version | Why not |
| --- | --- | --- |
| `scripts/SEARCHING.md` | sha256 `013075b06b89`, 2026-09-27 | Searching the Workshop corpus for a port; this mod is original. |
| `WORKSHOP_COMMENTS.md` | sha256 `3fb37586f04b`, 2026-09-29 | The thanks register. Nothing to post before `prepublished`; reread then (none of this mod's recipients is in it yet; RIMMSQOL is `posted`). |
| `Rimworld-Release-Admin/docs/OPERATIONS.md` | `3c03f51` 2026-09-26 | CI publishing runbook; matters at `prepublished` and at the `1.0.0` publish. |
| `Rimworld-Ticket-Dispatcher/docs/SUBMIT.md` | `d07b2b8` 2026-09-26 | Options of `Submit-PickleRun.ps1`; matters the day a pass is submitted. |

## In this repository

`README.md`, `ATTRIBUTION.md`, `LICENSE`, `CHANGELOG.md` (opens on `0.1.0`), `TESTING.md` and `Mod/About/About.xml` were
read on 2026-09-28 and are unchanged since, except `TESTING.md` (status row, 2026-10-02). `PUBLICATION.md`, `BACKLOG.md`,
`NOTES.md` and `BUGS.md` do not exist; `PUBLICATION.md` is required by `tested -> prepublished`. `FRENCH_REVIEW.md` and
`french-review-flags.json` are new (2026-10-02).
