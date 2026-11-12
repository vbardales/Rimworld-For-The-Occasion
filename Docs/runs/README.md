# Runs

One text file per day of testing, written by hand from the run reports. It is the only record of a
run that lives in git: one line per run, never a folder.

The evidence itself stays **on disk**, under `evidence/` (harness output, hash manifests) and
`Tests/Pickle/Evidence/` (Pickle reports, captures, films, `Player.log`), and both are ignored by git.
Screenshots and films never diff, and a whole-run `report.html` can add tens of megabytes on its own.
The disk is shared by every mod, so the rules of `AGENTS.md` ("Test evidence") apply: keep only what
still proves something, and cut a run's evidence down as soon as a newer one replaces it.

What a line here must carry, since the media are not beside it:

- the revision tested (`git rev-parse --short HEAD`, and whether the tree was clean) and, for a run of
  the game, the set (`setName`), `exitReason`, and discovered / passed / failed / skipped
- for a failure, the cause as read from the report, not the assumed one
- what a person actually opened and saw in the captures and films, and what they did not show
- where the evidence is on disk, so the next reader can find it

A line without those is a claim, not a record. The evidence directories are not backed up: if the
machine is lost, these files and the history are what remain.

## What to keep, and how, for this mod

**The out-of-game harness** (`_tools/Run-Functional-Tests.ps1`, 38 tests): keep the raw output of
the **latest** run on the revision now in the repository, as `evidence/<date>-<sha>-harness.txt`, and
delete the one it replaces. A harness run on a superseded build proves nothing about the current one.
The distributed DLL's SHA256 goes in the line, since it is what ties a green result to the shipped file.

**A Pickle run, once the suite exists.** For the revision now in the repository, keep per set:

- the four text files of the latest run: `summary.json`, `summary.md`, `junit.xml` and `Player.log`.
  Read `exitReason` before the numbers, and compare the scenarios played with the features discovered
- one capture per asserted state, not one per step. A capture that shows no assertion (a dialog in the
  way, a loading screen) goes. `@review` captures are kept only once opened and looked at
- a film only where the assertion depends on time, motion or a transition, and only the last one.
  Here that is the dressing trip: a colonist walking to the outfit stand, changing, walking back
- an older report only when it is the sole proof of a check the latest run did not repeat. Typical
  cases for this mod: the reports of the passes that stage an optional mod (RIMMSQOL for the hidden
  shortcut, Shift Change for the shared outfit stand), and the second language of a settings capture

**Delete:** the whole-run `report.html` and `messages.ndjson` (they are stale the moment the build
changes, and `summary.json` with `junit.xml` say the same), contact sheets derived from a film, earlier
runs of the same set, failed attempts once their cause is written in the daily line, and anything about
a revision that the latest run replaced.

**Minify what stays.** Captures are kept as JPEG at `-q:v 3`, not PNG: about a tenth of the size, and
small text is still legible. Look at a capture at full size **before** converting it:

```bash
ffmpeg -i capture.png -q:v 3 capture.jpg && rm capture.png
```

A capture is evidence of what was seen, not of pixels, so lossy is fine. It is not fine for anything
that will be measured or diffed later.

**Before deleting a report, check that no `STATUS.md` field points at it**, and repoint the field
first. Then add its line to the daily file in this folder; that text is the history. List what goes and
what stays before deleting anything.

`Remove-Item` stalls on capture names longer than MAX_PATH. Empty the folder with
`robocopy <empty folder> <target> /MIR`, then remove the shell that is left.
