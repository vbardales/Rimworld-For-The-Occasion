# Workflow documents read, and at which revision

Written by the For the Occasion session on 2026-09-28, as `WELCOME.md` (point 5) asks: for each document, the
last commit that touched it, and whether it was modified and not committed. When a document has moved since,
this is the line that says which rule the session leaned on. Documents that were of no use are marked, so that
they are not read again until they change.

**Where the versions come from.** The protocol documents are no longer in the monorepo: they belong to
`vbardales/Rimworld-protocols`, whose git dir is `../rimworld-protocols.git` and whose work tree is the monorepo
root (HEAD `dea856b` when this was written). From the root, `git log -1 -- AUDIT.md` answers with the commit that
*removed* it, so the versions below were read with:

```
git --git-dir=../rimworld-protocols.git --work-tree=. log -1 --format='%h %ad' --date=short -- <file>
git --git-dir=../rimworld-protocols.git --work-tree=. status --short -- <file>
```

The tools' documents are read in the repository that carries them (`git -C PickleTools log -1 -- <file>`, and the
same for `Rimworld-Release-Admin` and `Rimworld-Ticket-Dispatcher`). A document that git shows as modified has no
commit for what was read, so its SHA-256 (first 12 hexadecimal digits) and modification time are given instead.

## Read, and useful

| Document | Repository | Version read | Why it matters here |
| --- | --- | --- | --- |
| `AGENTS.md` | protocols | `3a1d2cb` 2026-09-24 | The ordered gates (settings, then translations, then `preTest`), the evidence rules (latest report per scenario, one text line per run in `docs/runs/`, list before deleting) and the CI publishing rules. |
| `AUDIT.md` | protocols | `c5ca0c0` 2026-09-26, **modified, not committed**: sha256 `e85f1285099d`, mtime 2026-09-27 21:24 | The chain and every transition, the rule that no session ever launches RimWorld, that an audit generates no image and creates no feature, the `done -> tested` gates (no `@wip`, every `@requires` played, no manual test left), the `0.1.0` pre-publication rule, and the session title `<mod> / <stage>`. |
| `PUBLISHING.md` | protocols | `95c6dfd` 2026-09-28 | The origin-repository rule, the description ending on `Source code on GitHub`, the two `ATTRIBUTION.md` copies compared, the `PublishedFileId.txt` commit, the pathspec on `git commit`, the thanks and `PUBLICATION.md` that `prepublished` will need. |
| `TRANSLATIONS.md` | protocols | `f5c2d9d` 2026-09-25 | The gate for `l10n`, including the counts-and-plurals rule of 2026-09-25, which is what a counted `{0} offerings` message breaks. |
| `MOD_SETTINGS.md` | protocols | `b83933b` 2026-09-23 (file dated 2026-09-13) | The settings gate and the `settings_audit` field: what `complete` needs, the hidden MainButtons shortcut, and that a source reading is not an in-game result. |
| `STYLE_RIMWORLD.md` | protocols | `7311308` 2026-09-25, **modified, not committed**: sha256 `2c6db32396ae`, mtime 2026-09-27 21:24 | Only two parts: how the delivered ModIcon is controlled (128 px, 32 px legibility, owner-only generation) and the `.ico` and `desktop.ini` folder-icon convention. |
| `Rimworld-Ticket-Dispatcher/docs/WELCOME.md` | Ticket-Dispatcher | `77ca9d7` 2026-09-27 | The list of documents to read and to note, `desktop.ini` and `.ico` kept out of git and out of `Mod/`, how to delete evidence past MAX_PATH, and that a `report.html` of a stale build proves nothing. |

## Read, and not useful for this mod now (do not reread unless it changes)

| Document | Repository | Version read | Why not, and when it matters |
| --- | --- | --- | --- |
| `scripts/SEARCHING.md` | protocols | `372c447` 2026-09-23, **modified, not committed**: sha256 `013075b06b89`, mtime 2026-09-27 21:14 | Searching the whole Workshop corpus. This mod is original: there is no port to check against ten thousand folders. |
| `WORKSHOP_COMMENTS.md` | protocols | `dea856b` 2026-09-28 | The thanks register. Nothing to post before `prepublished`. **Read it again then**: none of this mod's recipients is in the register yet (Shift Change 3783456242, Perfumes 3013711969, Anima Expansion 3532147582, Vanilla Brewing Expanded 2186560858), and RIMMSQOL 1084452457 is already `posted`, so it only gets a line in `Covers`. |
| `Rimworld-Release-Admin/docs/OPERATIONS.md` | Release-Admin | `3c03f51` 2026-09-26 | The CI publishing runbook. It matters at `prepublished` and at the `1.0.0` publish: the dry-run, the full SHA, `Steam change notes` in `PUBLICATION.md`, the generated workflow. |
| `Rimworld-Ticket-Dispatcher/docs/SUBMIT.md` | Ticket-Dispatcher | `d07b2b8` 2026-09-26 | Every option of `Submit-PickleRun.ps1`. No request has been filed: the suite is written and has never been played. It matters the day a pass is submitted. |

## Read, and useful once the Pickle suite was written (2026-09-28)

| Document | Repository | Version read | Why it mattered |
| --- | --- | --- | --- |
| `PickleTools/Authoring/README.md` | PickleTools | `8d3ca6d` 2026-09-26 | The layout of a suite, the pass matrix, that a step waits five seconds by default, that a modal window pauses ticks, the hooks, and that `AUDIT.md` sends a suite author here first. |
| `PickleTools/README.md` | PickleTools | `c771bef` 2026-09-25 | Which shared companions fit: `LoadAudit`, `ExpansionSteps`, `RimmsqolSteps` and `InterfaceScale` are staged by the pass maps. |
| `PickleTools/Headless/README.md` | PickleTools | `ed4e73a` 2026-09-26 | Filters and their exclusions, `-DepMap`, `-Then` for the restart pair, `!ludeon.rimworld.odyssey`, that a map ends with a newline. |
| `PickleTools/docs/steps.md` | PickleTools | `cba3ca1` 2026-09-25; **changed since**: `96eda0f` 2026-09-28, not reread | The shared steps. The suite was checked against Pickle's own step attributes and the companions' sources by `Tests/Pickle/Check-Steps.ps1`, which does not depend on this file. Reread it when the suite is next edited. |

Also read for the steps, not as protocol: the features and step code of `SkillIcons/Tests/Pickle` (the settings sandbox, the hidden shortcut, the RIMMSQOL feature) and the `AncientChineseBeastAndGeneExpandedRenew` note in `PickleTools/Elsewhere/`, which is where it says `I save and reload` is registered as a string literal.

## In this repository

| File | State when read |
| --- | --- |
| `STATUS.md` | Rewritten by this audit; `stage: options`, `settings_audit: complete`, and the three translation fields `partial`. The older audits stay below it as history. |
| `README.md` | Read. It says thirty-nine tests after the fix and points at `TESTING.md`, which moved from `docs/` to the root today. |
| `CHANGELOG.md` | Read. `0.1.0` (creation of the `PublishedFileId.txt` file) added today under the unreleased `1.0.0`. |
| `ATTRIBUTION.md`, `LICENSE` | Read. Each is byte-identical to its copy in `Mod/`. `ATTRIBUTION.md` now says there is no origin repository and names Shift Change's author and repository. |
| `TESTING.md` | Moved to the root; gained "What `tested` requires", "Passes this mod needs" and "Evidence to keep". Scenarios 0 to 12 are all manual; only the load (scenario 0) was ever observed, on 2026-09-04 and on an older build. |
| `docs/runs/` | `README.md` (what evidence to keep), `2026-09-13-validation.md` and `2026-09-28.md`. |
| `Mod/About/About.xml` | Read. The description ends on `Source code on GitHub` with the repository as its target, and `<url>` agrees. `THANKS` does not yet credit Romyashi, Vanilla Brewing Expanded or Shift Change: that is `prepublished` work. |
| `Tests/Pickle/` | Written 2026-09-28: 13 features, the steps assembly and five pass maps; `README.md` there says what is covered and what is not. Never run. |
| `PUBLICATION.md`, `BACKLOG.md`, `NOTES.md`, `BUGS.md` | **Do not exist.** `PUBLICATION.md` is required by `tested -> prepublished`. |
