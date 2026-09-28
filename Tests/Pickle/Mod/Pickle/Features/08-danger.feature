# TESTING.md scenario 7, the danger gate in both directions. It sits ABOVE both dress paths and BELOW the
# return trip, and that asymmetry is the whole point: with the gate above both, a raid would freeze every
# borrower in evening dress with their armour parked in a wardrobe they were not allowed to walk to.
#
# So two things are asserted, opposite in kind: nobody STARTS dressing while the map is dangerous, and a
# colonist already dressed CAN still change back. The raid is a real RaidEnemy incident, and the step then
# lets ticks run, because the danger watcher only recalculates once the game has ticked past its last look.
#
# A raid can hurt the test colony. Each scenario ends before it matters and the next one reloads the save.
# The floor path is used because it needs no building, so no DLC: this feature runs in every pass.
Feature: the danger gate keeps its place between the return trip and the dress paths

  Background:
    Given the save "test-colony" is loaded
    And a colonist "Aurel" exists
    And For the Occasion: the anticipation window is 1200 ticks

  Scenario: nobody starts dressing up while the map is in danger
    Given For the Occasion: a raid arrives and the map is in danger
    And For the Occasion: a "Apparel_Robe" lies at (147, 155)
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 600 ticks
    Then For the Occasion: "Aurel" wears no ceremonial garment
    And For the Occasion: "Aurel" is not dressed for the occasion
    And For the Occasion: no hook has disabled the mod

  Scenario: a colonist already dressed can still change back under threat
    Given For the Occasion: a "Apparel_Robe" lies at (147, 155)
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 600 ticks
    Then For the Occasion: "Aurel" is dressed for the occasion
    When I wait 700 ticks
    And I wait 700 ticks
    And For the Occasion: a raid arrives and the map is in danger
    And For the Occasion: "Aurel" is made to choose a new job
    And I wait 300 ticks
    Then For the Occasion: "Aurel" is not dressed for the occasion
    And For the Occasion: no hook has disabled the mod
