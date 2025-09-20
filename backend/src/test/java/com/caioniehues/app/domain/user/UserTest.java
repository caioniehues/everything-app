package com.caioniehues.app.domain.user;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.GrantedAuthority;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class UserTest {

    private User user;
    private Role adminRole;
    private Role userRole;

    @BeforeEach
    void setUp() {
        user = User.builder()
            .username("testuser")
            .email("test@example.com")
            .passwordHash("hashedPassword")
            .fullName("Test User")
            .enabled(true)
            .build();

        adminRole = Role.builder()
            .name("ADMIN")
            .description("Administrator role")
            .build();

        userRole = Role.builder()
            .name("USER")
            .description("Regular user role")
            .build();
    }

    @Test
    @DisplayName("Should create user with default values")
    void shouldCreateUserWithDefaultValues() {
        assertThat(user.getUsername()).isEqualTo("testuser");
        assertThat(user.getEmail()).isEqualTo("test@example.com");
        assertThat(user.getFullName()).isEqualTo("Test User");
        assertThat(user.isEnabled()).isTrue();
        assertThat(user.getRoles()).isEmpty();
        assertThat(user.getRefreshTokens()).isEmpty();
        assertThat(user.getLastLoginAt()).isNull();
    }

    @Test
    @DisplayName("Should implement UserDetails interface correctly")
    void shouldImplementUserDetailsCorrectly() {
        assertThat(user.getPassword()).isEqualTo("hashedPassword");
        assertThat(user.isAccountNonExpired()).isTrue();
        assertThat(user.isAccountNonLocked()).isTrue();
        assertThat(user.isCredentialsNonExpired()).isTrue();
        assertThat(user.isEnabled()).isTrue();
    }

    @Test
    @DisplayName("Should convert roles to authorities")
    void shouldConvertRolesToAuthorities() {
        user.addRole(adminRole);
        user.addRole(userRole);

        var authorities = user.getAuthorities();

        assertThat(authorities).hasSize(2);
        assertThat(authorities.stream().map(GrantedAuthority::getAuthority))
            .containsExactlyInAnyOrder("ROLE_ADMIN", "ROLE_USER");
    }

    @Test
    @DisplayName("Should add and remove roles")
    void shouldAddAndRemoveRoles() {
        assertThat(user.getRoles()).isEmpty();

        user.addRole(adminRole);
        assertThat(user.getRoles()).containsExactly(adminRole);

        user.addRole(userRole);
        assertThat(user.getRoles()).containsExactlyInAnyOrder(adminRole, userRole);

        user.removeRole(adminRole);
        assertThat(user.getRoles()).containsExactly(userRole);
    }

    @Test
    @DisplayName("Should update last login timestamp")
    void shouldUpdateLastLoginTimestamp() {
        assertThat(user.getLastLoginAt()).isNull();

        Instant beforeLogin = Instant.now();
        user.updateLastLogin();
        Instant afterLogin = Instant.now();

        assertThat(user.getLastLoginAt())
            .isNotNull()
            .isAfterOrEqualTo(beforeLogin)
            .isBeforeOrEqualTo(afterLogin);
    }

    @Test
    @DisplayName("Should handle equality based on ID")
    void shouldHandleEqualityBasedOnId() {
        User user1 = User.builder().username("user1").build();
        User user2 = User.builder().username("user2").build();

        // Both without IDs - not equal
        assertThat(user1).isNotEqualTo(user2);

        // Set same ID
        UUID id = UUID.randomUUID();
        user1.setId(id);
        user2.setId(id);

        assertThat(user1).isEqualTo(user2);

        // Different IDs
        user2.setId(UUID.randomUUID());
        assertThat(user1).isNotEqualTo(user2);
    }

    @Test
    @DisplayName("Should exclude sensitive data from toString")
    void shouldExcludeSensitiveDataFromToString() {
        user.addRole(adminRole);
        RefreshToken token = RefreshToken.builder()
            .token("secret-token")
            .user(user)
            .expiresAt(Instant.now().plusSeconds(3600))
            .build();
        user.getRefreshTokens().add(token);

        String toString = user.toString();

        assertThat(toString).doesNotContain("hashedPassword");
        assertThat(toString).doesNotContain("secret-token");
        assertThat(toString).contains("testuser");
        assertThat(toString).contains("test@example.com");
    }
}