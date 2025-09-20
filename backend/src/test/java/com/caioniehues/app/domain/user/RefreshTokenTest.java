package com.caioniehues.app.domain.user;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

import static org.assertj.core.api.Assertions.assertThat;

class RefreshTokenTest {

    private RefreshToken refreshToken;
    private User user;

    @BeforeEach
    void setUp() {
        user = User.builder()
            .username("testuser")
            .email("test@example.com")
            .passwordHash("hashedPassword")
            .fullName("Test User")
            .build();

        refreshToken = RefreshToken.builder()
            .token("test-token-value")
            .user(user)
            .expiresAt(Instant.now().plus(7, ChronoUnit.DAYS))
            .build();
    }

    @Test
    @DisplayName("Should create refresh token with default values")
    void shouldCreateRefreshTokenWithDefaultValues() {
        assertThat(refreshToken.getToken()).isEqualTo("test-token-value");
        assertThat(refreshToken.getUser()).isEqualTo(user);
        assertThat(refreshToken.isRevoked()).isFalse();
        assertThat(refreshToken.getRevokedAt()).isNull();
        assertThat(refreshToken.getExpiresAt()).isAfter(Instant.now());
    }

    @Test
    @DisplayName("Should detect expired token")
    void shouldDetectExpiredToken() {
        RefreshToken expiredToken = RefreshToken.builder()
            .token("expired-token")
            .user(user)
            .expiresAt(Instant.now().minus(1, ChronoUnit.HOURS))
            .build();

        assertThat(expiredToken.isExpired()).isTrue();
        assertThat(refreshToken.isExpired()).isFalse();
    }

    @Test
    @DisplayName("Should validate token correctly")
    void shouldValidateTokenCorrectly() {
        // Valid token
        assertThat(refreshToken.isValid()).isTrue();

        // Revoked token
        refreshToken.revoke();
        assertThat(refreshToken.isValid()).isFalse();

        // Expired token
        RefreshToken expiredToken = RefreshToken.builder()
            .token("expired-token")
            .user(user)
            .expiresAt(Instant.now().minus(1, ChronoUnit.HOURS))
            .build();
        assertThat(expiredToken.isValid()).isFalse();

        // Revoked and expired
        expiredToken.revoke();
        assertThat(expiredToken.isValid()).isFalse();
    }

    @Test
    @DisplayName("Should revoke token correctly")
    void shouldRevokeTokenCorrectly() {
        assertThat(refreshToken.isRevoked()).isFalse();
        assertThat(refreshToken.getRevokedAt()).isNull();

        Instant beforeRevoke = Instant.now();
        refreshToken.revoke();
        Instant afterRevoke = Instant.now();

        assertThat(refreshToken.isRevoked()).isTrue();
        assertThat(refreshToken.getRevokedAt())
            .isNotNull()
            .isAfterOrEqualTo(beforeRevoke)
            .isBeforeOrEqualTo(afterRevoke);
    }

    @Test
    @DisplayName("Should exclude sensitive data from toString")
    void shouldExcludeSensitiveDataFromToString() {
        String toString = refreshToken.toString();

        assertThat(toString).doesNotContain("test-token-value");
        assertThat(toString).doesNotContain(user.toString());
    }
}