# TESTING.md, "What cannot be tested here": cohabitation with Shift Change (3783456242). Both mods put a
# CompAssignableToPawn subclass on the same Building_OutfitStand def. CompAssignableToPawn scribes
# `assignedPawns` FLAT into the thing's node, so two subclasses would read each other's owners on load; this
# mod writes `FTO_`-prefixed keys. The offline harness proves the two sets of keys are disjoint by reading
# the code (test 15). Shift Change itself unifies owners: it copies its owners into every other assignable comp
# on the stand (read from its code, 2026-10-16), so a game shows ONE owner list, set by the comp edited last.
# This proves that in a game: an owner set through Shift Change is also ours, before and after a reload.
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

  Scenario: the owner set through Shift Change is the owner here too, through a save and a reload
    Given For the Occasion: an outfit stand stands at (150, 153) holding "Apparel_Robe" and owned by "Aurel"
    When For the Occasion: the other owner comp of the stand assigns "Belle"
    Then For the Occasion: both owner comps of the stand hold "Belle" alone
    When I save and reload
    Then For the Occasion: both owner comps of the stand hold "Belle" alone
    And For the Occasion: no hook has disabled the mod
    And no errors were logged
