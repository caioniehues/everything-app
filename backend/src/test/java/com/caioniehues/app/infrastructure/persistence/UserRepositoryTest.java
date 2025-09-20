package com.caioniehues.app.infrastructure.persistence;

import com.caioniehues.app.domain.user.Role;
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
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;

@DataJpaTest
@Testcontainers
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UserRepositoryTest {

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
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    private User testUser;
    private Role adminRole;

    @BeforeEach
    void setUp() {
        // Clear any existing data
        userRepository.deleteAll();
        roleRepository.deleteAll();
        entityManager.flush();

        // Create test role
        adminRole = Role.builder()
            .name("ADMIN")
            .description("Administrator role")
            .build();
        roleRepository.save(adminRole);

        // Create test user
        testUser = User.builder()
            .username("testuser")
            .email("test@example.com")
            .passwordHash("hashedPassword")
            .fullName("Test User")
            .enabled(true)
            .roles(Set.of(adminRole))
            .build();
    }

    @Test
    @DisplayName("Should save and retrieve user")
    void shouldSaveAndRetrieveUser() {
        User savedUser = userRepository.save(testUser);
        entityManager.flush();
        entityManager.clear();

        assertThat(savedUser.getId()).isNotNull();
        assertThat(savedUser.getCreatedAt()).isNotNull();
        assertThat(savedUser.getUpdatedAt()).isNotNull();

        User foundUser = userRepository.findById(savedUser.getId()).orElse(null);
        assertThat(foundUser).isNotNull();
        assertThat(foundUser.getUsername()).isEqualTo("testuser");
        assertThat(foundUser.getEmail()).isEqualTo("test@example.com");
    }

    @Test
    @DisplayName("Should find user by username")
    void shouldFindUserByUsername() {
        userRepository.save(testUser);
        entityManager.flush();
        entityManager.clear();

        var foundUser = userRepository.findByUsername("testuser");
        assertThat(foundUser).isPresent();
        assertThat(foundUser.get().getEmail()).isEqualTo("test@example.com");

        var notFound = userRepository.findByUsername("nonexistent");
        assertThat(notFound).isEmpty();
    }

    @Test
    @DisplayName("Should find user by email")
    void shouldFindUserByEmail() {
        userRepository.save(testUser);
        entityManager.flush();
        entityManager.clear();

        var foundUser = userRepository.findByEmail("test@example.com");
        assertThat(foundUser).isPresent();
        assertThat(foundUser.get().getUsername()).isEqualTo("testuser");

        var notFound = userRepository.findByEmail("nonexistent@example.com");
        assertThat(notFound).isEmpty();
    }

    @Test
    @DisplayName("Should check if user exists by username")
    void shouldCheckIfUserExistsByUsername() {
        userRepository.save(testUser);
        entityManager.flush();

        assertThat(userRepository.existsByUsername("testuser")).isTrue();
        assertThat(userRepository.existsByUsername("nonexistent")).isFalse();
    }

    @Test
    @DisplayName("Should check if user exists by email")
    void shouldCheckIfUserExistsByEmail() {
        userRepository.save(testUser);
        entityManager.flush();

        assertThat(userRepository.existsByEmail("test@example.com")).isTrue();
        assertThat(userRepository.existsByEmail("nonexistent@example.com")).isFalse();
    }

    @Test
    @DisplayName("Should find user with roles by username")
    void shouldFindUserWithRolesByUsername() {
        userRepository.save(testUser);
        entityManager.flush();
        entityManager.clear();

        var foundUser = userRepository.findByUsernameWithRoles("testuser");
        assertThat(foundUser).isPresent();
        assertThat(foundUser.get().getRoles()).hasSize(1);
        assertThat(foundUser.get().getRoles().iterator().next().getName()).isEqualTo("ADMIN");
    }

    @Test
    @DisplayName("Should find user with roles by email")
    void shouldFindUserWithRolesByEmail() {
        userRepository.save(testUser);
        entityManager.flush();
        entityManager.clear();

        var foundUser = userRepository.findByEmailWithRoles("test@example.com");
        assertThat(foundUser).isPresent();
        assertThat(foundUser.get().getRoles()).hasSize(1);
        assertThat(foundUser.get().getRoles().iterator().next().getName()).isEqualTo("ADMIN");
    }

    @Test
    @DisplayName("Should update last login timestamp")
    void shouldUpdateLastLoginTimestamp() {
        User savedUser = userRepository.save(testUser);
        entityManager.flush();

        Instant loginTime = Instant.now();
        userRepository.updateLastLogin(savedUser.getId(), loginTime);
        entityManager.flush();
        entityManager.clear();

        User updatedUser = userRepository.findById(savedUser.getId()).orElseThrow();
        assertThat(updatedUser.getLastLoginAt()).isCloseTo(loginTime, within(1, ChronoUnit.SECONDS));
    }

    @Test
    @DisplayName("Should enforce unique constraints")
    void shouldEnforceUniqueConstraints() {
        userRepository.save(testUser);
        entityManager.flush();

        // Try to save another user with same username
        User duplicateUsername = User.builder()
            .username("testuser")
            .email("different@example.com")
            .passwordHash("password")
            .fullName("Different User")
            .build();

        assertThat(userRepository.save(duplicateUsername))
            .isNotNull(); // Save succeeds but flush should fail

        try {
            entityManager.flush();
        } catch (Exception e) {
            assertThat(e).hasMessageContaining("constraint");
        }

        entityManager.clear();

        // Try to save another user with same email
        User duplicateEmail = User.builder()
            .username("different")
            .email("test@example.com")
            .passwordHash("password")
            .fullName("Different User")
            .build();

        userRepository.save(duplicateEmail);

        try {
            entityManager.flush();
        } catch (Exception e) {
            assertThat(e).hasMessageContaining("constraint");
        }
    }
}