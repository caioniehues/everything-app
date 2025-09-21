package com.caioniehues.app.infrastructure.security;

import com.caioniehues.app.domain.user.Role;
import com.caioniehues.app.domain.user.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.security.SignatureException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.Instant;
import java.util.Date;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertThrows;

@ExtendWith(MockitoExtension.class)
@DisplayName("JWT Service Tests")
class JwtServiceTest {

    private JwtService jwtService;
    private User testUser;
    private static final String TEST_SECRET = "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "secretKey", TEST_SECRET);
        ReflectionTestUtils.setField(jwtService, "accessTokenExpiration", 900000L); // 15 minutes
        ReflectionTestUtils.setField(jwtService, "refreshTokenExpiration", 604800000L); // 7 days
        ReflectionTestUtils.setField(jwtService, "issuer", "everything-app");

        Role userRole = Role.builder()
            .name("USER")
            .description("Regular user")
            .build();

        testUser = User.builder()
            .username("testuser")
            .email("test@example.com")
            .passwordHash("$2a$10$hashedpassword")
            .fullName("Test User")
            .enabled(true)
            .roles(Set.of(userRole))
            .build();

        // Set ID using reflection for testing
        ReflectionTestUtils.setField(testUser, "id", UUID.randomUUID());
    }

    @Test
    @DisplayName("Should generate valid access token with correct claims")
    void generateAccessToken_WithValidUser_ShouldReturnTokenWithCorrectClaims() {
        // When
        String token = jwtService.generateAccessToken(testUser);

        // Then
        assertThat(token).isNotNull().isNotEmpty();

        Claims claims = jwtService.extractAllClaims(token);
        assertThat(claims.getSubject()).isEqualTo(testUser.getUsername());
        assertThat(claims.get("userId", String.class)).isEqualTo(testUser.getId().toString());
        assertThat(claims.get("email", String.class)).isEqualTo(testUser.getEmail());
        assertThat(claims.get("fullName", String.class)).isEqualTo(testUser.getFullName());
        assertThat(claims.get("tokenType", String.class)).isEqualTo("ACCESS");
        assertThat(claims.getIssuer()).isEqualTo("everything-app");
    }

    @Test
    @DisplayName("Should generate access token with 15-minute expiry")
    void generateAccessToken_ShouldHave15MinuteExpiry() {
        // When
        String token = jwtService.generateAccessToken(testUser);

        // Then
        Claims claims = jwtService.extractAllClaims(token);
        Date expiration = claims.getExpiration();
        Date issuedAt = claims.getIssuedAt();

        long differenceInMillis = expiration.getTime() - issuedAt.getTime();
        long fifteenMinutesInMillis = 15 * 60 * 1000;

        assertThat(differenceInMillis).isEqualTo(fifteenMinutesInMillis);
    }

    @Test
    @DisplayName("Should generate valid refresh token with correct claims")
    void generateRefreshToken_WithValidUser_ShouldReturnTokenWithCorrectClaims() {
        // When
        String token = jwtService.generateRefreshToken(testUser);

        // Then
        assertThat(token).isNotNull().isNotEmpty();

        Claims claims = jwtService.extractAllClaims(token);
        assertThat(claims.getSubject()).isEqualTo(testUser.getUsername());
        assertThat(claims.get("userId", String.class)).isEqualTo(testUser.getId().toString());
        assertThat(claims.get("tokenType", String.class)).isEqualTo("REFRESH");
    }

    @Test
    @DisplayName("Should generate refresh token with 7-day expiry")
    void generateRefreshToken_ShouldHave7DayExpiry() {
        // When
        String token = jwtService.generateRefreshToken(testUser);

        // Then
        Claims claims = jwtService.extractAllClaims(token);
        Date expiration = claims.getExpiration();
        Date issuedAt = claims.getIssuedAt();

        long differenceInMillis = expiration.getTime() - issuedAt.getTime();
        long sevenDaysInMillis = 7L * 24 * 60 * 60 * 1000;

        assertThat(differenceInMillis).isEqualTo(sevenDaysInMillis);
    }

    @Test
    @DisplayName("Should validate token with correct signature")
    void validateToken_WithValidToken_ShouldReturnTrue() {
        // Given
        String token = jwtService.generateAccessToken(testUser);

        // When
        boolean isValid = jwtService.validateToken(token);

        // Then
        assertThat(isValid).isTrue();
    }

    @Test
    @DisplayName("Should reject token with invalid signature")
    void validateToken_WithInvalidSignature_ShouldThrowException() {
        // Given
        String validToken = jwtService.generateAccessToken(testUser);
        String tamperedToken = validToken.substring(0, validToken.length() - 10) + "TAMPERED";

        // When/Then
        assertThrows(SignatureException.class, () -> jwtService.validateToken(tamperedToken));
    }

    @Test
    @DisplayName("Should reject expired token")
    void validateToken_WithExpiredToken_ShouldThrowException() {
        // Given - Create service with 1ms expiry for testing
        JwtService shortExpiryService = new JwtService();
        ReflectionTestUtils.setField(shortExpiryService, "secretKey", TEST_SECRET);
        ReflectionTestUtils.setField(shortExpiryService, "accessTokenExpiration", 1L);
        ReflectionTestUtils.setField(shortExpiryService, "issuer", "everything-app");

        String token = shortExpiryService.generateAccessToken(testUser);

        // Wait for token to expire
        try {
            Thread.sleep(10);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // When/Then
        assertThrows(ExpiredJwtException.class, () -> jwtService.validateToken(token));
    }

    @Test
    @DisplayName("Should reject malformed token")
    void validateToken_WithMalformedToken_ShouldThrowException() {
        // Given
        String malformedToken = "not.a.valid.jwt.token";

        // When/Then
        assertThrows(MalformedJwtException.class, () -> jwtService.validateToken(malformedToken));
    }

    @Test
    @DisplayName("Should extract username from valid token")
    void extractUsername_WithValidToken_ShouldReturnCorrectUsername() {
        // Given
        String token = jwtService.generateAccessToken(testUser);

        // When
        String username = jwtService.extractUsername(token);

        // Then
        assertThat(username).isEqualTo(testUser.getUsername());
    }

    @Test
    @DisplayName("Should extract all claims from valid token")
    void extractAllClaims_WithValidToken_ShouldReturnAllClaims() {
        // Given
        String token = jwtService.generateAccessToken(testUser);

        // When
        Claims claims = jwtService.extractAllClaims(token);

        // Then
        assertThat(claims).isNotNull();
        assertThat(claims.getSubject()).isEqualTo(testUser.getUsername());
        assertThat(claims.get("userId")).isNotNull();
        assertThat(claims.get("email")).isNotNull();
        assertThat(claims.getIssuer()).isEqualTo("everything-app");
    }

    @Test
    @DisplayName("Should correctly identify expired token")
    void isTokenExpired_WithExpiredToken_ShouldReturnTrue() {
        // Given - Create service with 1ms expiry
        JwtService shortExpiryService = new JwtService();
        ReflectionTestUtils.setField(shortExpiryService, "secretKey", TEST_SECRET);
        ReflectionTestUtils.setField(shortExpiryService, "accessTokenExpiration", 1L);
        ReflectionTestUtils.setField(shortExpiryService, "issuer", "everything-app");

        String token = shortExpiryService.generateAccessToken(testUser);

        // Wait for expiry
        try {
            Thread.sleep(10);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        // When
        boolean isExpired = jwtService.isTokenExpired(token);

        // Then
        assertThat(isExpired).isTrue();
    }

    @Test
    @DisplayName("Should correctly identify non-expired token")
    void isTokenExpired_WithValidToken_ShouldReturnFalse() {
        // Given
        String token = jwtService.generateAccessToken(testUser);

        // When
        boolean isExpired = jwtService.isTokenExpired(token);

        // Then
        assertThat(isExpired).isFalse();
    }

    @Test
    @DisplayName("Should validate token matches user")
    void validateTokenForUser_WithMatchingUser_ShouldReturnTrue() {
        // Given
        String token = jwtService.generateAccessToken(testUser);

        // When
        boolean isValid = jwtService.validateTokenForUser(token, testUser);

        // Then
        assertThat(isValid).isTrue();
    }

    @Test
    @DisplayName("Should reject token for different user")
    void validateTokenForUser_WithDifferentUser_ShouldReturnFalse() {
        // Given
        String token = jwtService.generateAccessToken(testUser);

        User differentUser = User.builder()
            .username("differentuser")
            .build();

        // When
        boolean isValid = jwtService.validateTokenForUser(token, differentUser);

        // Then
        assertThat(isValid).isFalse();
    }

    @Test
    @DisplayName("Should extract user ID from token")
    void extractUserId_WithValidToken_ShouldReturnCorrectUserId() {
        // Given
        String token = jwtService.generateAccessToken(testUser);

        // When
        UUID userId = jwtService.extractUserId(token);

        // Then
        assertThat(userId).isEqualTo(testUser.getId());
    }

    @Test
    @DisplayName("Should extract token type from access token")
    void extractTokenType_WithAccessToken_ShouldReturnACCESS() {
        // Given
        String token = jwtService.generateAccessToken(testUser);

        // When
        String tokenType = jwtService.extractTokenType(token);

        // Then
        assertThat(tokenType).isEqualTo("ACCESS");
    }

    @Test
    @DisplayName("Should extract token type from refresh token")
    void extractTokenType_WithRefreshToken_ShouldReturnREFRESH() {
        // Given
        String token = jwtService.generateRefreshToken(testUser);

        // When
        String tokenType = jwtService.extractTokenType(token);

        // Then
        assertThat(tokenType).isEqualTo("REFRESH");
    }

    @Test
    @DisplayName("Should generate unique JTI for each token")
    void generateToken_ShouldHaveUniqueJti() {
        // When
        String token1 = jwtService.generateAccessToken(testUser);
        String token2 = jwtService.generateAccessToken(testUser);

        // Then
        Claims claims1 = jwtService.extractAllClaims(token1);
        Claims claims2 = jwtService.extractAllClaims(token2);

        assertThat(claims1.getId()).isNotNull();
        assertThat(claims2.getId()).isNotNull();
        assertThat(claims1.getId()).isNotEqualTo(claims2.getId());
    }
}