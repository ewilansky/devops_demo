package org.ahl.springbootdemo.web.exception;

public class BookIdMismatchException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public BookIdMismatchException() {
		// TODO Auto-generated constructor stub
	}

	public BookIdMismatchException(String message) {
		super(message);
		// TODO Auto-generated constructor stub
	}

	public BookIdMismatchException(Throwable cause) {
		super(cause);
		// TODO Auto-generated constructor stub
	}

	public BookIdMismatchException(String message, Throwable cause) {
		super(message, cause);
		// TODO Auto-generated constructor stub
	}

	public BookIdMismatchException(String message, Throwable cause, boolean enableSuppression,
			boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
		// TODO Auto-generated constructor stub
	}

}
