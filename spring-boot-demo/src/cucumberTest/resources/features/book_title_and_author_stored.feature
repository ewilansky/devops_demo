Feature: Users can save a book's title and author
    Users can save books to the database. A new book requires a title and an author to be specified.
Scenario: User saves a book with a title and an author specified
    Given The User creates a book 
    And The title is "Abaddon's Gate"
    And The author is "James S. A. Corey"
    When The user saves a book title and author
    Then The data the user stored is the same as the title and author specified