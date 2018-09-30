package org.ahl.springbootdemo;

import static org.junit.jupiter.api.Assertions.*;

import org.ahl.springbootdemo.persistence.model.Book;
import org.junit.jupiter.api.Test;

public class BookTest {

	@Test
	void ShouldReturnBookTitleAndAuthor() {
		Book book = new Book("Abaddon's Gate", "James S. A. Corey");
		assertEquals("Abaddon's Gate", book.getTitle());
		assertEquals("James S. A. Corey", book.getAuthor());
	}
}
