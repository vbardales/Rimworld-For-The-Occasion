# TESTING.md scenarios 5, 6 and 8: a colonist really changing clothes with no building, when an obligation is
# announced. This is the prefix on Pawn_JobTracker.StartJob, which runs for every job of every pawn and fails
# open, so a failure looks like nothing happening. Each scenario therefore asserts something that has to be
# SEEN (a garment worn, a record dropped) and ends by asking whether a hook disabled the mod.
#
# The window is a few hundred ticks instead of twelve hours, so a scenario takes seconds: the rule is the
# same, the obligation is just that many ticks old when it stops counting. Waits are cut into chunks under
# the five-second step limit (about 500 to 700 ticks a second in the headless install).
#
# Not asserted, on purpose: that the colonist's own clothes come back on their own after the free change.
# That is vanilla's JobGiver_OptimizeApparel, which this mod relies on and does not own.
Feature: colonists put on ceremonial clothes when a ritual is announced, and take them off afterwards

  Background:
    Given the save "test-colony" is loaded
    And a colonist "Aurel" exists
    And For the Occasion: the anticipation window is 1200 ticks

  Scenario: the game's ceremonial garments carry the tag, and an ordinary one does not
    Then For the Occasion: the garment "Apparel_Robe" carries the ceremonial tag
    And For the Occasion: the garment "Apparel_Cape" carries the ceremonial tag
    And For the Occasion: the garment "Apparel_HatTop" carries the ceremonial tag
    And For the Occasion: the garment "Apparel_Corset" carries the ceremonial tag
    And For the Occasion: the garment "Apparel_Duster" does not carry the ceremonial tag

  Scenario: an announced ritual sends a free colonist to the finest ceremonial garment
    Given For the Occasion: a "Apparel_Robe" lies at (147, 155)
    And For the Occasion: a ritual obligation is announced
    Then For the Occasion: the anticipation window is open
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 600 ticks
    Then "Aurel" is wearing "Apparel_Robe"
    And For the Occasion: "Aurel" wears a ceremonial garment
    And For the Occasion: "Aurel" is dressed for the occasion
    And For the Occasion: no hook has disabled the mod
    And no errors were logged

  Scenario: an ordinary garment lying about is left alone
    Given For the Occasion: a "Apparel_Duster" lies at (147, 155)
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 600 ticks
    Then For the Occasion: "Aurel" wears no ceremonial garment
    And For the Occasion: "Aurel" is not dressed for the occasion
    And For the Occasion: no hook has disabled the mod

  Scenario: nothing happens when preparation is switched off
    Given For the Occasion: setting "preparationEnabled" is set to "false"
    And For the Occasion: a "Apparel_Robe" lies at (147, 155)
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 600 ticks
    Then For the Occasion: "Aurel" is not dressed for the occasion
    And For the Occasion: "Aurel" wears no ceremonial garment

  Scenario: when the window closes the colonist gives the preparation up
    Given For the Occasion: a "Apparel_Robe" lies at (147, 155)
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 600 ticks
    Then For the Occasion: "Aurel" is dressed for the occasion
    When I wait 700 ticks
    And I wait 700 ticks
    Then For the Occasion: the anticipation window is closed
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 300 ticks
    Then For the Occasion: "Aurel" is not dressed for the occasion
    And For the Occasion: no hook has disabled the mod

  Scenario: face paint follows the record, and goes with it
    Given For the Occasion: "Aurel" has no tattoo
    And For the Occasion: a "Apparel_Robe" lies at (147, 155)
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 600 ticks
    Then For the Occasion: "Aurel" is dressed for the occasion
    And For the Occasion: "Aurel" has face paint exactly when the preparation record says so
    When I wait 700 ticks
    And I wait 700 ticks
    And For the Occasion: "Aurel" is made to choose a new job
    And I wait 300 ticks
    Then For the Occasion: "Aurel" has no face tattoo

  Scenario: with the paint switched off nobody is painted
    Given For the Occasion: setting "tattooEnabled" is set to "false"
    And For the Occasion: "Aurel" has no tattoo
    And For the Occasion: a "Apparel_Robe" lies at (147, 155)
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 600 ticks
    Then For the Occasion: "Aurel" is dressed for the occasion
    And For the Occasion: "Aurel" has no face tattoo
