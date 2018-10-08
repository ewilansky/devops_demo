package org.ahl.springbootdemo;

import cucumber.api.java.en.*;

public class BookTestSteps {
    @Given("The User creates a book")
    public void the_User_creates_a_book() {
        // Write code here that turns the phrase above into concrete actions
        System.out.format("A book was created");
    }

    @Given("The title is {string}")
    public void the_title_is(String string) {
        // Write code here that turns the phrase above into concrete actions
        System.out.format("A title is set");
    }

    @Given("The author is {string}")
    public void the_author_is(String string) {
        // Write code here that turns the phrase above into concrete actions
        System.out.format("An author is set");
    }

    @When("The user saves a book title and author")
    public void the_user_saves_a_book_title_and_author() {
        // Write code here that turns the phrase above into concrete actions
        System.out.format("User saved book title and author");
    }

    @Then("The data the user stored is the same as the title and author specified")
    public void the_data_the_user_stored_is_the_same_as_the_title_and_author_specified() {
        // Write code here that turns the phrase above into concrete actions
        System.out.format("value stored same as value specified");
    }
}