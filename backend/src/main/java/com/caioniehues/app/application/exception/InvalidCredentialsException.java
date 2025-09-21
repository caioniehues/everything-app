package com.caioniehues.app.application.exception;

/**
 * Exception thrown when login credentials are invalid.
 */
public class InvalidCredentialsException extends RuntimeException {

    public InvalidCredentialsException(String message) {
        super(message);
    }

    public InvalidCredentialsException(String message, Throwable cause) {
        super(message, cause);
    }

    /**
     * Create exception with default message.
     *
     * @return InvalidCredentialsException with standard message
     */
    public static InvalidCredentialsException defaultMessage() {
        return new InvalidCredentialsException("Invalid email or password");
    }
}