Feature: Launch and search
  Background:
    Given the app is running in the integration environment

  Scenario: Search for Avengers and Spider-Man, open details, return to the popular list
    Then the exact text "Movie viewer" is visible
    And the widget keyed "search_button" is visible
    And the widget keyed "movie0" is visible
    And the widget keyed "movie1" is visible
    When I tap the widget keyed "search_button"
    And I enter "avengers" into the focused field
    Then the exact text "Avengers: Endgame" is visible
    And the exact text "Avengers: Doomsday" is visible
    When I tap the exact text "Avengers: Endgame"
    Then the widget keyed "movie_detail_title" is visible
    And the exact text "Avengers: Endgame" is visible
    And the widget keyed "movie_detail_rating" is visible
    And the widget keyed "movie_detail_overview" is visible
    When I tap the widget keyed "movie_detail_back_button"
    And I tap the widget keyed "search_clear_button"
    And I enter "spider man" into the focused field
    Then the exact text "Spider-Man: No Way Home" is visible
    And the exact text "Avengers: Endgame" is absent
    When I tap the exact text "Spider-Man: No Way Home"
    Then the widget keyed "movie_detail_title" is visible
    And the exact text "Spider-Man: No Way Home" is visible
    And the widget keyed "movie_detail_rating" is visible
    And the widget keyed "movie_detail_overview" is visible
    When I tap the widget keyed "movie_detail_back_button"
    And I tap the widget keyed "search_back_button"
    Then the exact text "Movie viewer" is visible
    And the widget keyed "search_button" is visible
    And the widget keyed "movie0" is visible
    And the widget keyed "movie1" is visible
    And the exact text "Spider-Man: No Way Home" is absent
    And the widget keyed "search_back_button" is absent
