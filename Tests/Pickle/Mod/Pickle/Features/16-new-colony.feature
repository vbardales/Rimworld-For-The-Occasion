# AUDIT.md 8.i: a new colony starts with the mod active. Every other feature loads a fixture colony
# saved without the mod, so the game builds its GameComponents (PreparationTracker) for a colony that
# already exists. A new colony builds them from nothing, the way a player's first game does.
# A new colony costs minutes and is not reproducible: play it once, as one small ticket, with
# -Extra '-pickle-scenario-timeout=400' and the pass `nouvelle-colonie`. Nothing here depends on
# which colonists the draw gives.
@requires:nelim.pickletools.newcolony
@requires:nelim.pickletools.loadaudit
Feature: For the Occasion in a new colony

  Scenario: a new colony starts with the mod active and nothing is logged against it
    Given the main menu is open
    And Nelim's Pickle Tools: the new colony's seed is "fto-newcolony"
    When Nelim's Pickle Tools: a new colony is started
    And Nelim's Pickle Tools: any open message dialog is accepted
    And Nelim's Pickle Tools: the new colony's colonists have landed
    Then Nelim's Pickle Tools: the load of the mod "nelim.fortheoccasion" is clean
    And no errors were logged
