# Pictures for the Workshop gallery, not a test: "The feast day", one day at Nelim's Sanctuary (the owner's save "Nelims-tribe",
# SanctuaryBacklot docs/GALERIE.md, SANCTUAIRE-LIEUX.md, SANCTUAIRE-CASES.md), without the interface. The story, the looks and the
# subtitle of each scene are in PUBLICATION.md ("Gallery: the story", "Gallery subtitles"); the plan there comes first and this file
# follows it, one Scenario = one picture. Images 5 and 8 are interface captures (the quality tooltip, the settings window) and
# image 6 (the offerings spent) waits for feature 14: none of them is here yet. Never played: the cells come from SANCTUAIRE-CASES.md
# (ritual-hall row 122 and 121 are free from x 204 to 209, hearth-hall row 116 from x 172 to 183), the garment colours are dyed
# after the colonist has put them on (the stand holds undyed robes), and the colours and expressions are to be read on the capture.
#
# Nelim is the protagonist and keeps the look of the fixture (her own face, brown eyes); Tomas and Maelys are her guests, with the
# hairstyles of Vanilla Hair Expanded (VHE_Buzzcut, VHE_SideBraid). Each picture leaves the bottom of the frame empty: the English
# subtitle is burnt there afterwards, it is not part of the scenario. The dog faces the camera (South) in picture 3.
@review @en-only @requires:nelim.pickletools.screenshotstudio @requires:nelim.pickletools.stagedecor @requires:nelim.pickletools.colonistrace @requires:ludeon.rimworld.odyssey
Feature: Gallery pictures of the feast day

  Scenario: 1 - Dawn: the feast day is announced and nobody has changed yet (ritual-hall, 07:00)
    Given the save "Nelims-tribe" is loaded
    And game speed is paused
    And I set the hour to 7
    And For the Occasion: an outfit stand stands at (209, 121) holding "Apparel_Robe" and owned by "Nelim"
    And Nelim's Pickle Tools: an adult animal of kind "Labrador" named "Shogun" is spawned at (205, 116)
    When Nelim's Pickle Tools: studio presentation mode is enabled
    And Nelim's Sanctuary: I am at the sanctuary "ritual-hall"
    And Nelim's Pickle Tools: "Nelim" stands at (206, 121) facing East
    And Nelim's Sanctuary: Nelim has her own face
    And Nelim's Pickle Tools: the animal "Shogun" stands at (205, 116) facing South
    And I wait 60 ticks
    And I take a screenshot "gallery 1 dawn"
    Then no errors were logged

  Scenario: 2 - The stand: Nelim trades her work clothes for the robe (ritual-hall, 08:00)
    Given the save "Nelims-tribe" is loaded
    And game speed is paused
    And I set the hour to 7
    And For the Occasion: an outfit stand stands at (209, 121) holding "Apparel_Robe" and owned by "Nelim"
    And For the Occasion: the anticipation window is 1200 ticks
    And For the Occasion: a ritual obligation is announced
    When Nelim's Pickle Tools: I let 2400 ticks pass
    Then For the Occasion: "Nelim" is dressed for the occasion
    When Nelim's Pickle Tools: the "Apparel_Robe" worn by "Nelim" is dyed rgb (52, 60, 140)
    And Nelim's Pickle Tools: studio presentation mode is enabled
    And Nelim's Sanctuary: I am at the sanctuary "ritual-hall"
    And Nelim's Pickle Tools: "Nelim" stands at (208, 121) facing East
    And Nelim's Sanctuary: Nelim has her own face
    And I wait 60 ticks
    And I take a screenshot "gallery 2 the stand"
    Then no errors were logged

  Scenario: 3 - The table: four kinds of offering (ritual-hall, 11:00)
    Given the save "Nelims-tribe" is loaded
    And game speed is paused
    And I set the hour to 11
    And For the Occasion: an offering table stands at (206, 122)
    When For the Occasion: 6 "SmokeleafLeaves" are laid on the offering table
    And For the Occasion: 6 "MealFine" are laid on the offering table
    And For the Occasion: 6 "Beer" are laid on the offering table
    And For the Occasion: 60 "Gold" are laid on the offering table
    And Nelim's Pickle Tools: an adult animal of kind "Labrador" named "Shogun" is spawned at (207, 120)
    And Nelim's Pickle Tools: studio presentation mode is enabled
    And Nelim's Sanctuary: I am at the sanctuary "ritual-hall"
    And Nelim's Pickle Tools: the animal "Shogun" stands at (207, 120) facing South
    And Nelim's Pickle Tools: I frame the rectangle from (204, 119) to (209, 123)
    And I wait 60 ticks
    And I take a screenshot "gallery 3 the table"
    Then no errors were logged

  Scenario: 4 - The hearth: everyone dressed for the same rite (hearth-hall, 17:00)
    Given the save "Nelims-tribe" is loaded
    And game speed is paused
    And I set the hour to 17
    And a colonist "Tomas" exists
    And Nelim's Pickle Tools: "Tomas" hairstyle is "VHE_Buzzcut"
    And Nelim's Pickle Tools: "Tomas" hair colour is rgb (35, 28, 24)
    And Nelim's Pickle Tools: "Tomas" brows are "BrowThick"
    And Nelim's Pickle Tools: "Tomas" mouth is "MouthNormal"
    And a colonist "Maelys" exists
    And Nelim's Pickle Tools: "Maelys" hairstyle is "VHE_SideBraid"
    And Nelim's Pickle Tools: "Maelys" hair colour is rgb (225, 225, 230)
    And Nelim's Pickle Tools: "Maelys" brows are "BrowNormal"
    And For the Occasion: an outfit stand stands at (172, 116) holding "Apparel_Robe" and owned by "Nelim"
    And For the Occasion: "Tomas" has no tattoo
    And For the Occasion: "Maelys" has no tattoo
    And For the Occasion: a "Apparel_Robe" lies at (176, 116)
    And For the Occasion: a "Apparel_Cape" lies at (178, 116)
    And For the Occasion: the anticipation window is 1200 ticks
    And For the Occasion: a ritual obligation is announced
    When Nelim's Pickle Tools: I let 2400 ticks pass
    Then For the Occasion: "Nelim" is dressed for the occasion
    And For the Occasion: "Tomas" is dressed for the occasion
    And For the Occasion: "Maelys" is dressed for the occasion
    When Nelim's Pickle Tools: studio presentation mode is enabled
    And Nelim's Sanctuary: I am at the sanctuary "hearth-hall"
    And Nelim's Pickle Tools: "Nelim" stands at (179, 116) facing East
    And Nelim's Pickle Tools: "Tomas" stands at (181, 114) facing North
    And Nelim's Pickle Tools: "Maelys" stands at (183, 116) facing West
    And Nelim's Sanctuary: Nelim has her own face
    And I wait 60 ticks
    And I take a screenshot "gallery 4 the hearth"
    Then no errors were logged

  Scenario: 7 - Next morning: the robes are back on the stand and the paint is gone (ritual-hall, 07:00)
    Given the save "Nelims-tribe" is loaded
    And game speed is paused
    And I set the hour to 7
    And For the Occasion: an outfit stand stands at (209, 121) holding "Apparel_Robe" and owned by "Nelim"
    And For the Occasion: the anticipation window is 1200 ticks
    And For the Occasion: a ritual obligation is announced
    When Nelim's Pickle Tools: I let 2400 ticks pass
    Then For the Occasion: "Nelim" is dressed for the occasion
    When Nelim's Pickle Tools: I let 3600 ticks pass
    Then For the Occasion: the anticipation window is closed
    When For the Occasion: "Nelim" is made to choose a new job
    And Nelim's Pickle Tools: I let 2400 ticks pass
    Then For the Occasion: "Nelim" is not dressed for the occasion
    And For the Occasion: the outfit stand holds "Apparel_Robe"
    When Nelim's Pickle Tools: studio presentation mode is enabled
    And Nelim's Sanctuary: I am at the sanctuary "ritual-hall"
    And Nelim's Pickle Tools: "Nelim" stands at (208, 121) facing East
    And Nelim's Sanctuary: Nelim has her own face
    And I wait 60 ticks
    And I take a screenshot "gallery 7 next morning"
    Then no errors were logged
