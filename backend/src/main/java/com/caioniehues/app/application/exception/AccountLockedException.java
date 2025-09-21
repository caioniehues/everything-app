package com.caioniehues.app.application.exception;

/**
 * Exception thrown when attempting to login with a locked account.
 */
public class AccountLockedException extends RuntimeException {

    public AccountLockedException(String message) {
        super(message);
    }

    public AccountLockedException(String message, Throwable cause) {
        super(message, cause);
    }

    /**
     * Create exception with default message.
     *
     * @return AccountLockedException with standard message
     */
    public static AccountLockedException defaultMessage() {
        return new AccountLockedException("Account is locked due to multiple failed login attempts");
    }

    /**
     * Create exception for temporarily locked account.
     *
     * @param minutes Minutes until unlock
     * @return AccountLockedException with time information
     */
    public static AccountLockedException temporaryLock(int minutes) {
        return new AccountLockedException(
            String.format("Account is temporarily locked. Please try again in %d minutes", minutes)
        );
    }
}