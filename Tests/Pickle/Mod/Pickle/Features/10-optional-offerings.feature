# The optional providers of offerings, each listed in the categories with its own MayRequire. The XML profiles
# of _tools/Check-Optional-Offerings.ps1 prove the references RESOLVE; only a game with the provider loaded
# says that its item really lands on the table and counts. Played only by the pass avec-offrandes, which
# stages every provider named below; a scenario whose provider is missing is skipped, and a skip is not a pass.
#
# Vanilla Plants Expanded is not staged: it only opens the cider gate, which the XML profiles cover.
Feature: items from optional mods count as offerings

  Background:
    Given the save "test-colony" is loaded
    And For the Occasion: an offering table stands at (144, 152)

  @requires:nelim.rimscent.extended.incenseplus
  Scenario: incense from RimScent Extended - Incense Plus counts as scent
    Then For the Occasion: the offering table accepts "RimScentExtended_Incense_Frankincense"
    When For the Occasion: 2 "RimScentExtended_Incense_Frankincense" are laid on the offering table
    Then For the Occasion: the offering table counts 1 of 4 categories

  @requires:Romyashi.Perfumes
  Scenario: a perfume from Perfumes counts as scent
    Then For the Occasion: the offering table accepts "Romy_FlowerPerfume"
    When For the Occasion: 2 "Romy_FlowerPerfume" are laid on the offering table
    Then For the Occasion: the offering table counts 1 of 4 categories

  @requires:Romyashi.Perfumes @requires:Romyashi.AnimaExpansion
  Scenario: the anima perfume needs Perfumes AND Anima Expansion
    Then For the Occasion: the offering table accepts "Romy_AnimaPerfume"
    When For the Occasion: 2 "Romy_AnimaPerfume" are laid on the offering table
    Then For the Occasion: the offering table counts 1 of 4 categories

  @requires:VanillaExpanded.VBrewE
  Scenario: a drink from Vanilla Brewing Expanded counts as drink
    Then For the Occasion: the offering table accepts "VBE_Whiskey"
    When For the Occasion: 4 "VBE_Whiskey" are laid on the offering table
    Then For the Occasion: the offering table counts 1 of 4 categories

  @requires:nelim.rumandshanties
  Scenario: rum from Rum and Shanties counts as drink
    Then For the Occasion: the offering table accepts "VFEP_Rum"
    When For the Occasion: 4 "VFEP_Rum" are laid on the offering table
    Then For the Occasion: the offering table counts 1 of 4 categories
