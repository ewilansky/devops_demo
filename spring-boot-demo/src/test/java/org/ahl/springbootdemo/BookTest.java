package org.ahl.springbootdemo;

import static org.junit.jupiter.api.Assertions.*;

import org.ahl.springbootdemo.persistence.model.Book;
import org.junit.jupiter.api.Test;

public class BookTest {

	@Test
	void ShouldReturnBookTitleAndAuthor() {
		Book book = new Book("Abaddon's Gate", "James S. A. Corey");
		assertEquals("Abaddon's Gate", book.getTitle(), "unable to return book title");
		assertEquals("James S. A. Corey", book.getAuthor(), "unable to return author title");
	}
	
	@Test
	void ShouldSetAndGetIdBookTitleAndAuthor() {
		Book book = new Book();
		book.setAuthor("James S. A. Corey");
		book.setTitle("Abaddon's Gate");
		book.setId(12345);
		assertEquals("Abaddon's Gate", book.getTitle(), "unable to return book title");
		assertEquals("James S. A. Corey", book.getAuthor(), "unable to return author title");
		assertEquals(12345, book.getId(), "unable to return book id");
	}
}
