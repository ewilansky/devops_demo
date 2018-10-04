package org.ahl.springbootdemo;

// import static org.junit.jupiter.api.Assertions.*;
import static org.junit.Assert.*;
import org.junit.Test;


import org.ahl.springbootdemo.persistence.model.Book;
// import org.junit.jupiter.api.Test;

public class BookTest {

	@Test
	public void ShouldReturnBookTitleAndAuthor() {
		Book book = new Book("Abaddon's Gate", "James S. A. Corey");
		assertEquals("unable to return book title", "Abaddon's Gate", book.getTitle());
		assertEquals("unable to return author title", "James S. A. Corey", book.getAuthor());
	}
	
	@Test
	public void ShouldSetAndGetIdBookTitleAndAuthor() {
		Book book = new Book();
		book.setAuthor("James S. A. Corey");
		book.setTitle("Abaddon's Gate");
		book.setId(12345);
		assertEquals("unable to return book title", "Abaddon's Gate", book.getTitle());
		assertEquals("unable to return author title", "James S. A. Corey", book.getAuthor());
		// assertEquals(12345, book.getId(), "unable to return book id");
		assertEquals(12345, book.getId());
	}
	
	@Test
	public void ShouldReturnAHashCode() {
		Book book = new Book("test", "test");
		Integer code = book.hashCode();
		
		assertTrue(code.intValue() != 0);
	}
}
