# TESTING.md scenario 0. Everything here settles at the main menu, on Pickle's own vocabulary plus the
# LoadAudit companion, which reads the game log for what belongs to this mod and compares its keyed
# texts with the active language. Run it once per language: a key missing from French is invisible to
# the log (the game returns the key) and is exactly what that step reads from the data instead.
Feature: For the Occasion loads after its dependencies and defines its content

  Scenario: the mod loads after Harmony and Ideology
    Then mod "nelim.fortheoccasion" is loaded
    And mod "nelim.fortheoccasion" loads after "brrainz.harmony"
    And mod "nelim.fortheoccasion" loads after "ludeon.rimworld.ideology"

  Scenario: the defs the mod ships are all defined
    Then def "FTO_OfferingTable" of type "ThingDef" exists
    And def "FTO_PrepareForOccasion" of type "JobDef" exists
    And def "FTO_Settings" of type "MainButtonDef" exists

  @requires:nelim.pickletools.loadaudit
  Scenario: nothing in the log belongs to the mod and no key is missing from the active language
    Then Nelim's Pickle Tools: the load of the mod "nelim.fortheoccasion" is clean
    And no errors were logged
