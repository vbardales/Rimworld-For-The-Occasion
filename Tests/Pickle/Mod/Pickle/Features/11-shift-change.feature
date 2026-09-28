# TESTING.md, "What cannot be tested here": cohabitation with Shift Change (3783456242). Both mods put a
# CompAssignableToPawn subclass on the same Building_OutfitStand def. CompAssignableToPawn scribes
# `assignedPawns` FLAT into the thing's node, so two subclasses would read each other's owners on load; this
# mod writes `FTO_`-prefixed keys. The offline harness proves the two sets of keys are disjoint by reading
# the code (test 15). This proves what it means in a game: two owners on one stand, a save, a reload, and
# each list still holds its own pawn.
#
# Written against the class hierarchy, not against Shift Change's names: any assignable comp that is not
# ours. Played only by the pass avec-shiftchange.
@requires:MrBeverage.ShiftChange @requires:ludeon.rimworld.odyssey
Feature: this mod and Shift Change share one outfit stand

  Background:
    Given the save "test-colony" is loaded
    And a colonist "Aurel" exists
    And a colonist "Belle" exists

  Scenario: the stand def carries both owner comps, ours exactly once
    Then For the Occasion: the outfit stand def carries another mod's owner comp beside ours
    And For the Occasion: the stand def "Building_OutfitStand" carries exactly 1 ceremonial owner comp

  Scenario: two owners on one stand stay apart through a save and a reload
    Given For the Occasion: an outfit stand stands at (150, 153) holding "Apparel_Robe" and owned by "Aurel"
    When For the Occasion: the other owner comp of the stand assigns "Belle"
    Then For the Occasion: the stand's ceremonial owner is "Aurel" and the other owner is "Belle"
    When I save and reload
    Then For the Occasion: the stand's ceremonial owner is "Aurel" and the other owner is "Belle"
    And For the Occasion: no hook has disabled the mod
    And no errors were logged
