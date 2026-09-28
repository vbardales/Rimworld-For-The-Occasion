# The READER of the pair begun by 12-restart-write.feature, in a fresh process: the file the writer left is
# read back through the game's own reader, and then removed, so nothing leaks into the next run.
# Played alone it fails on purpose ("no settings file"): it has nothing to read.
Feature: settings written in another process (the reader)

  Scenario: the values the previous launch wrote are still there
    Given For the Occasion: the settings file the previous launch kept is discarded at the end
    Then For the Occasion: the settings file records "qualityBudget" as "0.5"
    When For the Occasion: settings are re-read from disk
    Then For the Occasion: setting "qualityBudget" reads "0.5"
    And For the Occasion: setting "obligationWindowHours" reads "30"
    And For the Occasion: setting "tattooEnabled" reads "false"
