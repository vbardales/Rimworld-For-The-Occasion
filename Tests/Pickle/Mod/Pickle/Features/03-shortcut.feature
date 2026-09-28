# TESTING.md scenario 12, minus RIMMSQOL, which feature 04 drives in its own pass.
#
# What this settles: the def is hidden on a clean configuration, and activating its worker (which is what a
# revealed button ends up calling) opens Dialog_ModSettings for THIS mod. That last check is the point:
# the question is whether the shortcut and the Options entry lead to the same place, and a dialog opened
# for another mod would look identical in a capture.
#
# Revealing moves buttonVisible directly, which is the same field a customization mod moves; the two
# captures are what a player would see. Nothing here is RIMMSQOL.
@review
Feature: the hidden MainButtons shortcut opens this mod's own settings

  Background:
    Given the save "test-colony" is loaded
    And I close all dialogs

  Scenario: hidden by default, and opens the same dialog when activated
    Then For the Occasion: the settings shortcut is hidden on a clean configuration
    And For the Occasion: the settings shortcut is not drawn
    When For the Occasion: the settings shortcut is activated
    Then For the Occasion: a settings dialog is open for this mod
    When I take a screenshot "settings opened by the shortcut"
    And I close all dialogs

  Scenario: a change made through the shortcut is there through Mod options
    When For the Occasion: the settings shortcut is activated
    Then For the Occasion: a settings dialog is open for this mod
    When For the Occasion: setting "qualityBudget" is set to "1.5"
    And I close all dialogs
    And For the Occasion: I open the settings dialog
    Then For the Occasion: setting "qualityBudget" reads "1.5"
    When I close all dialogs

  Scenario: revealed it is drawn and live, hidden it is gone again
    Then For the Occasion: the settings shortcut is not drawn
    When I take a screenshot "main button bar, shortcut hidden"
    And For the Occasion: the settings shortcut is revealed, as a customization mod would
    Then For the Occasion: the settings shortcut is drawn and enabled
    When I take a screenshot "main button bar, shortcut revealed"
    And For the Occasion: the settings shortcut is hidden again
    Then For the Occasion: the settings shortcut is not drawn

  # A launch that CHOOSES its language switches nothing: the def is injected at startup, so its description
  # is readable here. Run this feature once per language.
  Scenario: the description is the one for the language this pass runs in
    Then For the Occasion: the settings shortcut carries its description for the active language
