# TESTING.md scenario 2, through a REAL ritual: the game's own Begin ritual window, the ritual begun from it
# as a lord job, and then ended (or cancelled) by asking that lord job to apply its outcome. That is the method
# the mod patches, so the hook that consumes the offerings is reached the way it is in play.
#
# Feature 05 calls the consumption directly and proves the amounts. This proves the wiring, which the offline
# harness can only read from the game's code: the hook fires at the end of a rite, takes nothing from a
# cancelled one, and never takes twice when the game calls the outcome twice (the `ended` guard).
#
# The ritual is the first of the player's ideoligion that takes a ritual spot and needs no role: a rite that
# cannot start from a bare test colony would say nothing about this mod. If the fixture's ideoligion has none,
# the first step fails and lists what it tried. The ending is forced instead of waited for: a real rite lasts
# game hours.
Feature: the rite consumes what counted, once, and takes nothing from a cancelled one

  Background:
    Given the save "test-colony" is loaded
    And For the Occasion: an offering table stands at (144, 152)
    And For the Occasion: a ritual spot stands at (148, 152)

  @review
  Scenario: the Begin ritual window shows the offerings, and the ended rite takes exactly what counted
    When For the Occasion: 10 "SmokeleafLeaves" are laid on the offering table
    And For the Occasion: 10 "MealFine" are laid on the offering table
    And For the Occasion: 10 "Beer" are laid on the offering table
    And For the Occasion: 80 "Gold" are laid on the offering table
    And For the Occasion: the Begin ritual window is opened at the ritual spot
    Then For the Occasion: the Begin ritual window shows the offerings line "4 / 4" worth 12 percent
    When I take a screenshot "begin ritual window, four offerings laid out"
    And For the Occasion: the ritual is begun from that window
    And For the Occasion: the running ritual ends
    Then For the Occasion: 8 "SmokeleafLeaves" remain on the offering table
    And For the Occasion: 6 "MealFine" remain on the offering table
    And For the Occasion: 6 "Beer" remain on the offering table
    And For the Occasion: 30 "Gold" remain on the offering table
    And For the Occasion: no hook has disabled the mod
    And no errors were logged

  Scenario: a cancelled rite takes nothing
    When For the Occasion: 4 "Beer" are laid on the offering table
    And For the Occasion: 2 "SmokeleafLeaves" are laid on the offering table
    And For the Occasion: the Begin ritual window is opened at the ritual spot
    And For the Occasion: the ritual is begun from that window
    And For the Occasion: the running ritual is cancelled
    Then For the Occasion: 4 "Beer" remain on the offering table
    And For the Occasion: 2 "SmokeleafLeaves" remain on the offering table
    And For the Occasion: no hook has disabled the mod

  Scenario: the game reporting the outcome twice takes the offerings once
    When For the Occasion: 6 "Beer" are laid on the offering table
    And For the Occasion: 4 "SmokeleafLeaves" are laid on the offering table
    And For the Occasion: the Begin ritual window is opened at the ritual spot
    And For the Occasion: the ritual is begun from that window
    And For the Occasion: the running ritual ends
    And For the Occasion: the running ritual reports its outcome a second time
    Then For the Occasion: 2 "Beer" remain on the offering table
    And For the Occasion: 2 "SmokeleafLeaves" remain on the offering table
    And For the Occasion: no hook has disabled the mod
