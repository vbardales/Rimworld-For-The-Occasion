# TESTING.md scenario 10, the real restart: this is the WRITER, run in one process; feature 13 is the READER,
# run in a second one. They are a pair and are only meaningful together, in one lock:
#
#   -Filter '12-restart-write' -Then '13-restart-read'
#
# The writer keeps its settings file on purpose (it stands the sandbox down, in its own steps, where whoever
# reads the feature can see it), and only the reader puts things back. So it must never be played alone:
# it would leave non-default settings on disk for the next run. Excluding the reader excludes the writer.
Feature: settings written in one process (the writer)

  Scenario: values are written and left for the next launch
    Given For the Occasion: the settings file is kept for the next launch
    When For the Occasion: setting "qualityBudget" is set to "0.5"
    And For the Occasion: setting "obligationWindowHours" is set to "30"
    And For the Occasion: setting "tattooEnabled" is set to "false"
    And For the Occasion: settings are written to disk
    Then For the Occasion: the settings file records "qualityBudget" as "0.5"
