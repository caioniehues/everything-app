package com.caioniehues.app.application.exception;

/**
 * Exception thrown when a refresh token is invalid, expired, or revoked.
 */
public class InvalidRefreshTokenException extends RuntimeException {

    public InvalidRefreshTokenException(String message) {
        super(message);
    }

    public InvalidRefreshTokenException(String message, Throwable cause) {
        super(message, cause);
    }

    /**
     * Create exception for expired token.
     *
     * @return InvalidRefreshTokenException for expired token
     */
    public static InvalidRefreshTokenException expired() {
        return new InvalidRefreshTokenException("Refresh token has expired");
    }

    /**
     * Create exception for revoked token.
     *
     * @return InvalidRefreshTokenException for revoked token
     */
    public static InvalidRefreshTokenException revoked() {
        return new InvalidRefreshTokenException("Refresh token has been revoked");
    }

    /**
     * Create exception for invalid/not found token.
     *
     * @return InvalidRefreshTokenException for invalid token
     */
    public static InvalidRefreshTokenException invalid() {
        return new InvalidRefreshTokenException("Invalid refresh token");
    }
}