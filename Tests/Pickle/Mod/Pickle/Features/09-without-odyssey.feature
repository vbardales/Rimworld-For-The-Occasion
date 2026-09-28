# The guard of the mod: Odyssey is OPTIONAL and only unlocks the outfit stand path. Without it the stand def
# does not exist, and the mod has to load without raising anything, with the no-building path as the only one.
#
# This feature asserts the ABSENCE of the DLL, so it can only pass in the pass sans-odyssey, and it is
# excluded from every other pass by name (`!09-without-odyssey`), never skipped by a tag: a requirement tag
# cannot say "when this is not there". The floor path itself is feature 06, played in the same pass.
Feature: the mod holds without Odyssey

  Scenario: Odyssey is out of the game and the outfit stand does not exist
    Then Nelim's Pickle Tools: the expansion "ludeon.rimworld.odyssey" is not active
    And no def "Building_OutfitStand" exists
    And mod "nelim.fortheoccasion" is loaded

  @requires:nelim.pickletools.loadaudit
  Scenario: the mod loads without a word about the missing DLC
    Then Nelim's Pickle Tools: the load of the mod "nelim.fortheoccasion" is clean
    And no errors were logged
