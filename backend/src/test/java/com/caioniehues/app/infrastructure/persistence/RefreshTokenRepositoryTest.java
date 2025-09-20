package com.caioniehues.app.infrastructure.persistence;

import com.caioniehues.app.domain.user.RefreshToken;
import com.caioniehues.app.domain.user.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@Testcontainers
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class RefreshTokenRepositoryTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");

    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
    }

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private UserRepository userRepository;

    private User testUser;
    private RefreshToken validToken;
    private RefreshToken expiredToken;

    @BeforeEach
    void setUp() {
        // Clear repositories
        refreshTokenRepository.deleteAll();
        userRepository.deleteAll();
        entityManager.flush();

        // Create test user
        testUser = User.builder()
            .username("testuser")
            .email("test@example.com")
            .passwordHash("hashedPassword")
            .fullName("Test User")
            .enabled(true)
            .build();
        testUser = userRepository.save(testUser);

        // Create valid refresh token
        validToken = RefreshToken.builder()
            .token(UUID.randomUUID().toString())
            .user(testUser)
            .expiresAt(Instant.now().plus(7, ChronoUnit.DAYS))
            .build();

        // Create expired refresh token
        expiredToken = RefreshToken.builder()
            .token(UUID.randomUUID().toString())
            .user(testUser)
            .expiresAt(Instant.now().minus(1, ChronoUnit.DAYS))
            .build();
    }

    @Test
    @DisplayName("Should save and retrieve refresh token")
    void shouldSaveAndRetrieveRefreshToken() {
        RefreshToken saved = refreshTokenRepository.save(validToken);
        entityManager.flush();
        entityManager.clear();

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getCreatedAt()).isNotNull();

        RefreshToken found = refreshTokenRepository.findById(saved.getId()).orElse(null);
        assertThat(found).isNotNull();
        assertThat(found.getToken()).isEqualTo(validToken.getToken());
        assertThat(found.isRevoked()).isFalse();
    }

    @Test
    @DisplayName("Should find refresh token by token string")
    void shouldFindRefreshTokenByTokenString() {
        refreshTokenRepository.save(validToken);
        entityManager.flush();
        entityManager.clear();

        var found = refreshTokenRepository.findByToken(validToken.getToken());
        assertThat(found).isPresent();
        assertThat(found.get().getUser().getId()).isEqualTo(testUser.getId());

        var notFound = refreshTokenRepository.findByToken("nonexistent-token");
        assertThat(notFound).isEmpty();
    }

    @Test
    @DisplayName("Should find refresh token with user")
    void shouldFindRefreshTokenWithUser() {
        refreshTokenRepository.save(validToken);
        entityManager.flush();
        entityManager.clear();

        var found = refreshTokenRepository.findByTokenWithUser(validToken.getToken());
        assertThat(found).isPresent();
        assertThat(found.get().getUser()).isNotNull();
        assertThat(found.get().getUser().getUsername()).isEqualTo("testuser");
    }

    @Test
    @DisplayName("Should delete all tokens by user ID")
    void shouldDeleteAllTokensByUserId() {
        refreshTokenRepository.save(validToken);
        refreshTokenRepository.save(expiredToken);

        // Create another user with token
        User anotherUser = userRepository.save(User.builder()
            .username("another")
            .email("another@example.com")
            .passwordHash("password")
            .fullName("Another User")
            .build());

        RefreshToken anotherToken = refreshTokenRepository.save(RefreshToken.builder()
            .token(UUID.randomUUID().toString())
            .user(anotherUser)
            .expiresAt(Instant.now().plus(7, ChronoUnit.DAYS))
            .build());

        entityManager.flush();

        assertThat(refreshTokenRepository.count()).isEqualTo(3);

        refreshTokenRepository.deleteAllByUserId(testUser.getId());
        entityManager.flush();

        assertThat(refreshTokenRepository.count()).isEqualTo(1);
        assertThat(refreshTokenRepository.findById(anotherToken.getId())).isPresent();
    }

    @Test
    @DisplayName("Should delete expired tokens")
    void shouldDeleteExpiredTokens() {
        refreshTokenRepository.save(validToken);
        refreshTokenRepository.save(expiredToken);
        entityManager.flush();

        assertThat(refreshTokenRepository.count()).isEqualTo(2);

        refreshTokenRepository.deleteExpiredTokens(Instant.now());
        entityManager.flush();

        assertThat(refreshTokenRepository.count()).isEqualTo(1);
        assertThat(refreshTokenRepository.findByToken(validToken.getToken())).isPresent();
        assertThat(refreshTokenRepository.findByToken(expiredToken.getToken())).isEmpty();
    }

    @Test
    @DisplayName("Should revoke all valid tokens for user")
    void shouldRevokeAllValidTokensForUser() {
        RefreshToken token1 = refreshTokenRepository.save(validToken);
        RefreshToken token2 = refreshTokenRepository.save(RefreshToken.builder()
            .token(UUID.randomUUID().toString())
            .user(testUser)
            .expiresAt(Instant.now().plus(7, ChronoUnit.DAYS))
            .build());

        // Already revoked token
        RefreshToken revokedToken = refreshTokenRepository.save(RefreshToken.builder()
            .token(UUID.randomUUID().toString())
            .user(testUser)
            .expiresAt(Instant.now().plus(7, ChronoUnit.DAYS))
            .revoked(true)
            .revokedAt(Instant.now())
            .build());

        entityManager.flush();

        refreshTokenRepository.revokeAllValidTokensForUser(testUser.getId(), Instant.now());
        entityManager.flush();
        entityManager.clear();

        RefreshToken updatedToken1 = refreshTokenRepository.findById(token1.getId()).orElseThrow();
        RefreshToken updatedToken2 = refreshTokenRepository.findById(token2.getId()).orElseThrow();
        RefreshToken stillRevoked = refreshTokenRepository.findById(revokedToken.getId()).orElseThrow();

        assertThat(updatedToken1.isRevoked()).isTrue();
        assertThat(updatedToken1.getRevokedAt()).isNotNull();
        assertThat(updatedToken2.isRevoked()).isTrue();
        assertThat(updatedToken2.getRevokedAt()).isNotNull();
        assertThat(stillRevoked.isRevoked()).isTrue();
    }

    @Test
    @DisplayName("Should count valid tokens for user")
    void shouldCountValidTokensForUser() {
        refreshTokenRepository.save(validToken);
        refreshTokenRepository.save(RefreshToken.builder()
            .token(UUID.randomUUID().toString())
            .user(testUser)
            .expiresAt(Instant.now().plus(7, ChronoUnit.DAYS))
            .build());
        refreshTokenRepository.save(expiredToken);
        refreshTokenRepository.save(RefreshToken.builder()
            .token(UUID.randomUUID().toString())
            .user(testUser)
            .expiresAt(Instant.now().plus(7, ChronoUnit.DAYS))
            .revoked(true)
            .build());

        entityManager.flush();

        long count = refreshTokenRepository.countByUserIdAndRevokedFalseAndExpiresAtAfter(
            testUser.getId(),
            Instant.now()
        );

        assertThat(count).isEqualTo(2); // Only 2 valid, non-expired tokens
    }
}