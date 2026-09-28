# TESTING.md scenarios 3, 4 and 11: the outfit stand path, the one that hands a colonist's own clothes back
# EXACTLY as they were, force-worn flags included, which vanilla's own stand driver does not.
#
# The stand is Odyssey's, so every scenario carries @requires:ludeon.rimworld.odyssey: a pass that leaves the
# DLC out skips this feature, and a skip is not a pass. That pass is played for feature 09.
#
# Two things only a running game can settle, and that no offline test reaches: that the XML patch really
# leaves ONE ceremonial owner comp on each stand def once inheritance is resolved (the first version of the
# patch left two, seen only by running the game's own patch engine out of the game), and that a record made
# by a real dressing trip survives a save and a reload.
@requires:ludeon.rimworld.odyssey
Feature: an outfit stand as a ceremonial wardrobe

  Background:
    Given the save "test-colony" is loaded
    And a colonist "Aurel" exists
    And For the Occasion: the anticipation window is 1200 ticks

  Scenario: each stand def carries exactly one ceremonial owner comp
    Then For the Occasion: the stand def "Building_OutfitStand" carries exactly 1 ceremonial owner comp
    And For the Occasion: the stand def "Building_KidOutfitStand" carries exactly 1 ceremonial owner comp

  Scenario: the owner walks to the stand, dresses, and gets their own clothes back as they were
    Given For the Occasion: "Aurel" has nothing forced
    And For the Occasion: "Aurel" wears "Apparel_Pants" and it is forced
    And For the Occasion: an outfit stand stands at (150, 153) holding "Apparel_Robe" and owned by "Aurel"
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 700 ticks
    And I wait 700 ticks
    Then "Aurel" is wearing "Apparel_Robe"
    And For the Occasion: "Aurel" is dressed for the occasion
    And For the Occasion: the outfit stand does not hold "Apparel_Robe"
    When I wait 700 ticks
    And I wait 700 ticks
    Then For the Occasion: the anticipation window is closed
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 700 ticks
    And I wait 700 ticks
    Then For the Occasion: "Aurel" is not dressed for the occasion
    And For the Occasion: the outfit stand holds "Apparel_Robe"
    And For the Occasion: "Aurel" wears no ceremonial garment
    And For the Occasion: "Aurel" has "Apparel_Pants" forced
    And For the Occasion: no hook has disabled the mod
    And no errors were logged

  Scenario: switching preparation off with a borrower still dressed sends the outfit back
    Given For the Occasion: an outfit stand stands at (150, 153) holding "Apparel_Robe" and owned by "Aurel"
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 700 ticks
    And I wait 700 ticks
    Then "Aurel" is wearing "Apparel_Robe"
    When For the Occasion: setting "preparationEnabled" is set to "false"
    And For the Occasion: "Aurel" is made to choose a new job
    And I wait 700 ticks
    And I wait 700 ticks
    Then For the Occasion: "Aurel" is not dressed for the occasion
    And For the Occasion: the outfit stand holds "Apparel_Robe"
    And For the Occasion: no hook has disabled the mod

  Scenario: a dressed colonist and the stand's owner survive a save and a reload
    Given For the Occasion: an outfit stand stands at (150, 153) holding "Apparel_Robe" and owned by "Aurel"
    And For the Occasion: a ritual obligation is announced
    When For the Occasion: "Aurel" is made to choose a new job
    And I wait 700 ticks
    And I wait 700 ticks
    Then For the Occasion: "Aurel" is dressed for the occasion
    When I save and reload
    Then For the Occasion: "Aurel" is dressed for the occasion
    And For the Occasion: the outfit stand is owned by "Aurel"
    And For the Occasion: no hook has disabled the mod
