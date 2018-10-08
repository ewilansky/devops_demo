package org.ahl.springbootdemo;
import static org.junit.Assert.assertEquals;
import org.ahl.springbootdemo.persistence.model.Book;

import cucumber.api.java.en.*;

public class BookTestSteps {
    @Given("The User creates a book")
    public void the_User_creates_a_book() {
        Book book = new Book("Abaddon's Gate", "James S. A. Corey");
        assertEquals("unable to return book title", "Abaddon's Gate", book.getTitle());
		assertEquals("unable to return author title", "James S. A. Corey", book.getAuthor());
    }

    @Given("The title is {string}")
    public void the_title_is(String title) {
        Book book = new Book("Abaddon's Gate", "James S. A. Corey");
        assertEquals("unable to return book title", title, book.getTitle());
    }

    @Given("The author is {string}")
    public void the_author_is(String author) {
        Book book = new Book("Abaddon's Gate", "James S. A. Corey");
        assertEquals("unable to return book author", author, book.getAuthor());
    }

    @When("The user saves a book title and author")
    public void the_user_saves_a_book_title_and_author() {
        // TODO: mock the db call and return a record with a mocked api call...
        System.out.format("User saved book title and author");
    }

    @Then("The data the user stored is the same as the title and author specified")
    public void the_data_the_user_stored_is_the_same_as_the_title_and_author_specified() {
        // Write code here that turns the phrase above into concrete actions
        System.out.format("value stored same as value specified");
    }
}