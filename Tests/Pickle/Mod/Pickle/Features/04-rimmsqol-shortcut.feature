# MOD_SETTINGS.md, "Shortcut integration": in RIMMSQOL, reveal the shortcut, open the same settings, hide it
# again. Feature 03 tests THIS mod's side of that contract by moving buttonVisible by hand. This drives
# RIMMSQOL itself through the shared steps of PickleTools/RimmsqolSteps, so the answer to "can RIMMSQOL
# list and reveal the shortcut" no longer rests on reading its source.
#
# What it does not do: click RIMMSQOL's checkbox. The steps call what the checkbox calls. That RIMMSQOL keeps
# its choice across a restart is RIMMSQOL's behaviour and is not repeated here.
#
# Played only by the pass avec-rimmsqol. The requirement tags make a missing tool a skip rather than a
# false validation; a skipped feature is not a passed one.
@review @rimmsqol @requires:MalteSchulze.RIMMSqol @requires:nelim.pickletools.rimmsqol @requires:nelim.pickletools.interfacescale
Feature: RIMMSQOL reveals and hides the settings shortcut

  Background:
    Given the save "test-colony" is loaded
    And I close all dialogs
    Then mod "MalteSchulze.RIMMSqol" is loaded
    And RIMMSQOL is ready to be driven

  Scenario: RIMMSQOL's own list offers the shortcut, hidden, and the bar does not draw it
    Then RIMMSQOL's own list of main buttons offers "FTO_Settings"
    And RIMMSQOL shows the main button "FTO_Settings" as hidden
    And RIMMSQOL holds no choice for the main button "FTO_Settings"
    And the main bar does not draw the button "FTO_Settings"
    When RIMMSQOL's own window is opened on its list of main buttons
    Then RIMMSQOL's own window is open
    When I take a screenshot "rimmsqol, its list of main buttons, with the shortcut"
    And I close all dialogs

  Scenario: revealed in RIMMSQOL the shortcut is drawn, and it opens the same settings as Mod options
    When RIMMSQOL reveals the main button "FTO_Settings"
    Then RIMMSQOL shows the main button "FTO_Settings" as visible
    And RIMMSQOL's settings file records the main button "FTO_Settings" as visible
    And the main bar draws the button "FTO_Settings"
    When I close all dialogs
    And the main bar's button "FTO_Settings" is activated
    Then For the Occasion: a settings dialog is open for this mod
    When I take a screenshot "settings opened by the shortcut RIMMSQOL revealed"
    And I close all dialogs

  Scenario: hidden again in RIMMSQOL the shortcut leaves the bar, and forgetting the choice leaves nothing behind
    Given RIMMSQOL reveals the main button "FTO_Settings"
    And the main bar draws the button "FTO_Settings"
    When RIMMSQOL hides the main button "FTO_Settings"
    Then RIMMSQOL shows the main button "FTO_Settings" as hidden
    And the main bar does not draw the button "FTO_Settings"
    And RIMMSQOL's settings file records the main button "FTO_Settings" as hidden
    When RIMMSQOL forgets its choice for the main button "FTO_Settings"
    Then RIMMSQOL holds no choice for the main button "FTO_Settings"
    And RIMMSQOL's settings file records no choice for the main button "FTO_Settings"

  Scenario: the revealed shortcut remains usable at 150 percent interface scale
    Given Nelim's Pickle Tools: the interface scale is 150 percent
    When RIMMSQOL reveals the main button "FTO_Settings"
    Then the main bar draws the button "FTO_Settings"
    When the main bar's button "FTO_Settings" is activated
    Then For the Occasion: a settings dialog is open for this mod
    When I take a screenshot "settings opened from RIMMSQOL at 150 percent scale"
    And I close all dialogs
