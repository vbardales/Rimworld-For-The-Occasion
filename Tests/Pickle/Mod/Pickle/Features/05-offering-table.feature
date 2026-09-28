# TESTING.md scenarios 1 and 2, on a real map. The harness proves the categories' XML and the shape of the
# counting code out of the game; only a running game says that the table really accepts what it should,
# that its stacks really fit (three per cell, two cells), and that consuming really takes the amounts the
# player is told about: 2 scent, 4 food, 4 drink, 50 treasure.
#
# The hook that calls the consumption at the end of a ritual is a postfix on LordJob_Ritual.ApplyOutcome.
# No scenario here starts a real ritual: its target, parameter names and `ended` guard are read from the
# game's code by the harness (tests 10 and 13), and the consumption is called directly. See README.md.
#
# The table is placed by the step; the coordinates are a stretch of free ground of the test colony, and
# whatever stands there is moved aside.
Feature: the offering table counts variety, and the rite consumes what counted

  Background:
    Given the save "test-colony" is loaded
    And For the Occasion: an offering table stands at (144, 152)

  Scenario: the table accepts every kind of offering and nothing else
    Then For the Occasion: the offering table accepts "Beer"
    And For the Occasion: the offering table accepts "MealFine"
    And For the Occasion: the offering table accepts "Gold"
    And For the Occasion: the offering table accepts "SmokeleafLeaves"
    And For the Occasion: the offering table refuses "Steel"
    And For the Occasion: the offering table refuses "WoodLog"

  Scenario: four beers and nothing else are one category of four
    When For the Occasion: 4 "Beer" are laid on the offering table
    Then For the Occasion: the offering table counts 1 of 4 categories
    And For the Occasion: the Begin ritual window shows the offerings line "1 / 4" worth 4 percent

  Scenario: a hundred and fifty beers are still one category of four
    When For the Occasion: 150 "Beer" are laid on the offering table
    Then For the Occasion: the offering table counts 1 of 4 categories

  Scenario: one of each kind fills the four categories on one table
    When For the Occasion: 2 "SmokeleafLeaves" are laid on the offering table
    And For the Occasion: 4 "MealFine" are laid on the offering table
    And For the Occasion: 4 "Beer" are laid on the offering table
    And For the Occasion: 50 "Gold" are laid on the offering table
    Then For the Occasion: the offering table counts 4 of 4 categories
    And For the Occasion: the Begin ritual window shows the offerings line "4 / 4" worth 12 percent

  Scenario: too little of a kind does not count, and is not taken
    When For the Occasion: 3 "Beer" are laid on the offering table
    Then For the Occasion: the offering table counts 0 of 4 categories
    When For the Occasion: the offerings are consumed
    Then For the Occasion: 0 offerings were consumed
    And For the Occasion: 3 "Beer" remain on the offering table

  Scenario: the rite takes exactly the amount each category asks for, and nothing else
    When For the Occasion: 10 "SmokeleafLeaves" are laid on the offering table
    And For the Occasion: 10 "MealFine" are laid on the offering table
    And For the Occasion: 10 "Beer" are laid on the offering table
    And For the Occasion: 80 "Gold" are laid on the offering table
    Then For the Occasion: the offering table counts 4 of 4 categories
    When For the Occasion: the offerings are consumed
    Then For the Occasion: 60 offerings were consumed
    And For the Occasion: 8 "SmokeleafLeaves" remain on the offering table
    And For the Occasion: 6 "MealFine" remain on the offering table
    And For the Occasion: 6 "Beer" remain on the offering table
    And For the Occasion: 30 "Gold" remain on the offering table
    And no errors were logged
