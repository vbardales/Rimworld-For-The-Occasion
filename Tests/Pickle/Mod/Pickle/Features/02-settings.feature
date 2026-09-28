# TESTING.md scenario 10, as far as one process takes it: the real Dialog_ModSettings on its defaults, and
# the round trip object -> file -> object. The defaults themselves, the numeric bounds and the Scribe
# round trip are proved out of the game by the harness (tests 31 to 38); what only a running game shows is
# the drawn window and a window that really reaches the file. The real restart is the pair 12 and 13.
#
# No tick wait in this feature: Dialog_ModSettings force-pauses the game, so "I wait N ticks" can never be
# satisfied while it is open. The open step waits for frames itself.
@review
Feature: the settings page and the file behind it

  Background:
    Given the save "test-colony" is loaded
    And I close all dialogs

  @watch
  Scenario: the window on a clean configuration
    Given For the Occasion: settings are at their documented defaults
    When For the Occasion: I open the settings dialog
    Then For the Occasion: a settings dialog is open for this mod
    When I take a screenshot "settings window on its defaults"
    And I close all dialogs
    Then no errors were logged

  Scenario: changed values reach the file and come back from it
    When For the Occasion: setting "qualityBudget" is set to "0.5"
    And For the Occasion: setting "obligationWindowHours" is set to "30"
    And For the Occasion: setting "maxDetourDistance" is set to "80"
    And For the Occasion: setting "preparationEnabled" is set to "false"
    And For the Occasion: settings are written to disk
    Then For the Occasion: the settings file records "qualityBudget" as "0.5"
    And For the Occasion: the settings file records "obligationWindowHours" as "30"
    And For the Occasion: the settings file records "maxDetourDistance" as "80"
    And For the Occasion: the settings file records "preparationEnabled" as "false"
    When For the Occasion: settings are re-read from disk
    Then For the Occasion: setting "qualityBudget" reads "0.5"
    And For the Occasion: setting "obligationWindowHours" reads "30"
    And For the Occasion: setting "preparationEnabled" reads "false"

  Scenario: closing the window through the game writes the file
    Given For the Occasion: setting "offeringsEnabled" is set to "false"
    When For the Occasion: I open the settings dialog
    And I close all dialogs
    Then For the Occasion: the settings file records "offeringsEnabled" as "false"
