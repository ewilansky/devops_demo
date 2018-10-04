Feature: A book's title and author can be stored
    Users can save books to the database. A new book requires a title and an author to be specified.
Scenario: User saves a book with a title and an author specified
    Given The User creates a book 
    When The user saves a book title and author
    Then The user is told the book information was saved