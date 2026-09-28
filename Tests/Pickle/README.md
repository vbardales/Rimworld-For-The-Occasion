# In-game scenarios, run by Pickle

The scenarios of [TESTING.md](../../TESTING.md) that only a running game can settle, written in Gherkin for
[Pickle](https://github.com/RimWorks/Rimworld-Pickle) (`rimworks.pickle`, Workshop 3791648678).

**Written, never run.** Nothing here has been played. The suite compiles, every step line resolves against
Pickle's vocabulary and the companions its pass maps stage, and no expression is ambiguous
(`Check-Steps.ps1`, below). That says the scenarios can be loaded. It does not say a step does what its
sentence claims: only a run does, and the first one is expected to need tuning. The coordinates, the number of
ticks and the colony's colonists are guesses about the `test-colony` fixture until it has been played.

`Mod/` is a companion mod, **For the Occasion - Pickle tests**, never published. It holds the feature files
and the steps assembly built from `Source/`, so nothing test-related ships in the Workshop folder.

## Scope: what is here, and why it is not an offline test

`AUDIT.md` keeps in Gherkin only what a running game can show. Everything that a calculation, an XML contract,
a translation resource or a reading of the game's compiled code can settle is in
[`_tools/Run-Functional-Tests.ps1`](../../_tools/Run-Functional-Tests.ps1) (39 tests, no game). What is left:

| Scenario of TESTING.md | Feature | What only a running game shows |
| --- | --- | --- |
| 0, the load | `01-loading` | The mod loads after its dependencies, its defs exist, and nothing in the log belongs to it and no key is missing from the active language (LoadAudit reads the data, since the game logs no missing key). |
| 1, variety and not quantity | `05-offering-table` | The table really accepts the items, the stacks really fit (three a cell), and the offerings line the player is shown reads the counts and percentages he is told (the comp installed on the game's real ritual outcome defs, with its real curve). |
| 2, consumption | `05-offering-table` | The amounts taken from a real table are exactly 2, 4, 4 and 50, and nothing else moves. See "Not covered" for the hook. |
| 3, 4, the stand and the flags | `07-dressing-stand` | A colonist really walks to the stand, dresses, is undone at the end and gets their own clothes back with the force-worn flag they had. Also: one ceremonial owner comp per stand def once inheritance is resolved, and the record surviving a save and a reload. |
| 5, no building | `06-dressing-floor` | The prefix on `StartJob` really sends a free colonist to the finest ceremonial garment, and leaves an ordinary one alone. The tag reaches the game's garments, heirs of abstract bases included. |
| 6, face paint | `06-dressing-floor` | The face and the preparation record never disagree, and switching paint off paints nobody. |
| 7, the danger gate | `08-danger` | Under a real raid nobody starts dressing, and a colonist already dressed can still change back. |
| 8, anticipation | `06-dressing-floor` | The window opens on an announced obligation and closes after its length. |
| 10, settings | `02-settings`, `12-restart-write`, `13-restart-read` | The drawn window, a window that reaches the file, and a file that survives a real restart of the process. |
| 11, disabling with a borrower | `07-dressing-stand` | The outfit goes back when preparation is switched off mid-way. |
| 12, the shortcut | `03-shortcut`, `04-rimmsqol-shortcut` | Hidden by default, opens THIS mod's settings, drawn and not greyed when revealed; and RIMMSQOL itself lists, reveals, hides and forgets it. |
| Optional providers | `10-optional-offerings` | An item of each optional mod lands on the table and counts. |
| Shift Change | `11-shift-change` | Two owners on one stand stay apart through a save and a reload. |
| The DLC guard | `09-without-odyssey` | The mod loads without Odyssey, with no stand def. |

### Not covered here, with the reason

- **Scenario 9, a birth.** The rule that spares the doctor and the mother reads two booleans of the ritual role.
  Their census over the game's own definitions is an offline test (harness 26: 33 roles, 29 required, 29 not
  counting as participants, and the two roles of childbirth), and so is the wiring of the hook that reads them
  (harness 18). A birth would need a pregnant colonist in labour, a doctor, and a real launch of the childbirth
  ritual, none of which a Pickle step stages; a scenario that faked them would test the fake.
- **The hook that consumes at the end of a ritual.** `LordJob_Ritual.ApplyOutcome`'s postfix is checked by the
  harness where it can be (its target, its parameter names, the `ended` flag it reads in a prefix, the duel's
  unconditional call to the base). No step starts a real ritual, so `05` calls the consumption directly and the
  message it raises is not asserted. This is a **known gap**, not a justified absence: a step that launches a
  ritual through `RitualBehaviorWorker.TryExecuteOn` would close it.
- **The Begin ritual window itself.** The offerings line is asked of the comp, not read off a drawn window, and
  the preparation line is not asked at all (it needs role assignments).
- **A new colony.** Every scenario loads the supplied `test-colony`. The mod adds nothing to a colony at
  creation, and what it does save (the preparation records, the owner lists) is exercised by a save and a reload.
  The NewColony companion is played once in a final pass, and is not part of this suite.
- **Whether a colonist gets paint at all.** It is a draw from their ideoligion's style and can come out empty. The
  scenario asserts that the face and the record agree, which cannot be flaky.

## Passes

A mod is not validated by one run. Each pass is one request to the launcher (`Submit-PickleRun.ps1`), and the
language of a pass is fixed at launch, so each language is its own request.

| Pass | Map | Plays | Notes |
| --- | --- | --- | --- |
| Without the optional mods, English and French | `wsl-deps.sans-facultatifs.map` | everything except `04`, `09`, `10`, `11` | Filter `'For the Occasion - Pickle tests,!09-without-odyssey,!12-restart-write,!13-restart-read'`. `04`, `10` and `11` skip by their `@requires`. |
| Without Odyssey | `wsl-deps.sans-odyssey.map` | `01`, `06`, `08`, `09` | Filter `'01-loading,06-dressing-floor,08-danger,09-without-odyssey'`. `07` skips by its `@requires`. |
| With RIMMSQOL | `wsl-deps.avec-rimmsqol.map` | `04` | Filter `'04-rimmsqol-shortcut'`. |
| With Shift Change | `wsl-deps.avec-shiftchange.map` | `11` | Filter `'11-shift-change'`. |
| With the optional providers | `wsl-deps.avec-offrandes.map` | `10` | Filter `'10-optional-offerings'`. Vanilla Plants Expanded is not staged, on purpose: it only opens the cider gate, which the XML profiles cover. |
| Restart | `wsl-deps.sans-facultatifs.map` | `12` then `13` | `-Filter '12-restart-write' -Then '13-restart-read'`, one request, one lock. Never play the writer alone. |

The passes with optional mods are a first draft of their maps: the prerequisites of Incense Plus (RimScent and
its incense framework) and of Anima Expansion (its bunny framework) are named from their `About.xml`, and none
of the maps has been staged. The staging script reads a map with `read`, so **every map ends with a newline**.

No mod declares an incompatibility (`About.xml` has no `incompatibleWith`), so there is no pass for one.

`@review` features attach captures that a person has to open. A green says the path was walked, not that the
window is laid out well or that a colonist is wearing the robe in the picture.

## Checking the suite without a game

```powershell
powershell.exe -ExecutionPolicy Bypass -File Tests/Pickle/Check-Steps.ps1
```

It compiles every step pattern with Pickle's own expression engine, and matches every step line of every
feature against this suite's expressions, Pickle's vocabulary and the companions the pass maps stage. An invalid
pattern makes a run play zero scenarios, an ambiguous line fails a healthy scenario, and an undefined step
cannot run; the check has already caught the last one, `I save and reload`, which Pickle registers as a string
literal and no extraction of its attributes sees. Rebuild the steps before a run, since Pickle loads the
assembly when the game starts:

```powershell
dotnet build Tests/Pickle/Source/ForTheOccasion.PickleSteps.csproj -c Release
```

## Hazards written down before the first run

- **The settings file is kept on disk between scenarios** unless a sandbox restores it. `SettingsSteps`
  backs the file up before each scenario, puts the defaults back in memory, and restores both after, closing any
  settings window and hiding the shortcut again. The restart pair stands the sandbox down on purpose.
- **A modal settings window pauses the game**, so no feature waits ticks while one is open.
- **A step waits at most five seconds** unless it says otherwise, and the headless install runs about 500 to 700
  ticks a second, so every wait is cut into chunks of about 700 ticks.
- **The mod fails open.** A hook that throws disables the mod for the session, which looks exactly like a mod
  that is idle. Every behavioural scenario ends by asking whether it happened, and by looking at the log.
- **A raid can hurt the test colony.** `08-danger` ends before it matters, and the next scenario reloads the save.

## What a reviewer has to do

Run each pass through the shared launcher, then read `exitReason` before the counts, compare the scenarios
played with the features discovered, and open every `@review` capture: the settings window in each language
(`settings window on its defaults`), the shortcut on the bar hidden and revealed, and RIMMSQOL's list and
edit page. What to keep afterwards, and what to delete, is in [docs/runs/README.md](../../docs/runs/README.md).
