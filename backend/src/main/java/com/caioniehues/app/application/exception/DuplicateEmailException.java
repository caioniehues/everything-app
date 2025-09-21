package com.caioniehues.app.application.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Exception thrown when attempting to register with an email that already exists.
 * Returns HTTP 409 Conflict status.
 */
@ResponseStatus(HttpStatus.CONFLICT)
public class DuplicateEmailException extends RuntimeException {

    public DuplicateEmailException(String message) {
        super(message);
    }

    public DuplicateEmailException(String message, Throwable cause) {
        super(message, cause);
    }

    /**
     * Create exception with standard message for the given email
     */
    public static DuplicateEmailException forEmail(String email) {
        // Don't expose the actual email in the error message for security
        return new DuplicateEmailException("An account with this email already exists");
    }
}