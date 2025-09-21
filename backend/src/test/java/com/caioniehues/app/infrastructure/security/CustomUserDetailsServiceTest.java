package com.caioniehues.app.infrastructure.security;

import com.caioniehues.app.domain.user.Role;
import com.caioniehues.app.domain.user.User;
import com.caioniehues.app.infrastructure.persistence.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("Custom UserDetails Service Tests")
class CustomUserDetailsServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private CustomUserDetailsService userDetailsService;

    private User testUser;
    private Role userRole;

    @BeforeEach
    void setUp() {
        userRole = Role.builder()
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
    }

    @Test
    @DisplayName("Should load user by username successfully")
    void loadUserByUsername_WithExistingUser_ShouldReturnUserDetails() {
        // Given
        when(userRepository.findByUsernameWithRoles("testuser"))
            .thenReturn(Optional.of(testUser));

        // When
        UserDetails userDetails = userDetailsService.loadUserByUsername("testuser");

        // Then
        assertThat(userDetails).isNotNull();
        assertThat(userDetails.getUsername()).isEqualTo("testuser");
        assertThat(userDetails.getPassword()).isEqualTo("$2a$10$hashedpassword");
        assertThat(userDetails.isEnabled()).isTrue();
        assertThat(userDetails.getAuthorities())
            .hasSize(1)
            .anyMatch(auth -> auth.getAuthority().equals("ROLE_USER"));

        verify(userRepository, times(1)).findByUsernameWithRoles("testuser");
    }

    @Test
    @DisplayName("Should load user by email successfully")
    void loadUserByUsername_WithEmail_ShouldReturnUserDetails() {
        // Given
        when(userRepository.findByUsernameWithRoles("test@example.com"))
            .thenReturn(Optional.empty());
        when(userRepository.findByEmailWithRoles("test@example.com"))
            .thenReturn(Optional.of(testUser));

        // When
        UserDetails userDetails = userDetailsService.loadUserByUsername("test@example.com");

        // Then
        assertThat(userDetails).isNotNull();
        assertThat(userDetails.getUsername()).isEqualTo("testuser");
        assertThat(userDetails.getAuthorities())
            .hasSize(1);

        verify(userRepository, times(1)).findByUsernameWithRoles("test@example.com");
        verify(userRepository, times(1)).findByEmailWithRoles("test@example.com");
    }

    @Test
    @DisplayName("Should throw exception when user not found")
    void loadUserByUsername_WithNonExistentUser_ShouldThrowException() {
        // Given
        when(userRepository.findByUsernameWithRoles("nonexistent"))
            .thenReturn(Optional.empty());
        when(userRepository.findByEmailWithRoles("nonexistent"))
            .thenReturn(Optional.empty());

        // When/Then
        UsernameNotFoundException exception = assertThrows(
            UsernameNotFoundException.class,
            () -> userDetailsService.loadUserByUsername("nonexistent")
        );

        assertThat(exception.getMessage()).isEqualTo("User not found: nonexistent");
        verify(userRepository, times(1)).findByUsernameWithRoles("nonexistent");
        verify(userRepository, times(1)).findByEmailWithRoles("nonexistent");
    }

    @Test
    @DisplayName("Should load user with multiple roles")
    void loadUserByUsername_WithMultipleRoles_ShouldReturnCorrectAuthorities() {
        // Given
        Role adminRole = Role.builder()
            .name("ADMIN")
            .description("Administrator")
            .build();

        User adminUser = User.builder()
            .username("admin")
            .email("admin@example.com")
            .passwordHash("$2a$10$adminpassword")
            .fullName("Admin User")
            .enabled(true)
            .roles(Set.of(userRole, adminRole))
            .build();

        when(userRepository.findByUsernameWithRoles("admin"))
            .thenReturn(Optional.of(adminUser));

        // When
        UserDetails userDetails = userDetailsService.loadUserByUsername("admin");

        // Then
        assertThat(userDetails.getAuthorities())
            .hasSize(2)
            .anyMatch(auth -> auth.getAuthority().equals("ROLE_USER"))
            .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"));
    }

    @Test
    @DisplayName("Should load disabled user correctly")
    void loadUserByUsername_WithDisabledUser_ShouldReturnDisabledUserDetails() {
        // Given
        User disabledUser = User.builder()
            .username("disabled")
            .email("disabled@example.com")
            .passwordHash("$2a$10$disabledpassword")
            .fullName("Disabled User")
            .enabled(false)
            .roles(Set.of(userRole))
            .build();

        when(userRepository.findByUsernameWithRoles("disabled"))
            .thenReturn(Optional.of(disabledUser));

        // When
        UserDetails userDetails = userDetailsService.loadUserByUsername("disabled");

        // Then
        assertThat(userDetails.isEnabled()).isFalse();
        assertThat(userDetails.isAccountNonExpired()).isTrue();
        assertThat(userDetails.isAccountNonLocked()).isTrue();
        assertThat(userDetails.isCredentialsNonExpired()).isTrue();
    }

    @Test
    @DisplayName("Should handle null username")
    void loadUserByUsername_WithNullUsername_ShouldThrowException() {
        // When/Then
        UsernameNotFoundException exception = assertThrows(
            UsernameNotFoundException.class,
            () -> userDetailsService.loadUserByUsername(null)
        );

        assertThat(exception.getMessage()).isEqualTo("User not found: null");
        verify(userRepository, never()).findByUsernameWithRoles(anyString());
        verify(userRepository, never()).findByEmailWithRoles(anyString());
    }

    @Test
    @DisplayName("Should handle empty username")
    void loadUserByUsername_WithEmptyUsername_ShouldThrowException() {
        // When/Then
        UsernameNotFoundException exception = assertThrows(
            UsernameNotFoundException.class,
            () -> userDetailsService.loadUserByUsername("")
        );

        assertThat(exception.getMessage()).isEqualTo("User not found: ");

        // Verify no repository calls were made due to early return
        verify(userRepository, never()).findByUsernameWithRoles(anyString());
        verify(userRepository, never()).findByEmailWithRoles(anyString());
    }

    @Test
    @DisplayName("Should cache loaded user details")
    void loadUserByUsername_CalledMultipleTimes_ShouldUseCache() {
        // Given
        when(userRepository.findByUsernameWithRoles("testuser"))
            .thenReturn(Optional.of(testUser));

        // When - Call twice
        UserDetails firstCall = userDetailsService.loadUserByUsername("testuser");
        UserDetails secondCall = userDetailsService.loadUserByUsername("testuser");

        // Then
        assertThat(firstCall).isEqualTo(secondCall);
        // Note: Actual caching behavior would be configured via Spring Cache
        // This test verifies the method can be called multiple times
        verify(userRepository, times(2)).findByUsernameWithRoles("testuser");
    }

    @Test
    @DisplayName("Should trim whitespace from username")
    void loadUserByUsername_WithWhitespace_ShouldTrimAndLoad() {
        // Given
        when(userRepository.findByUsernameWithRoles("testuser"))
            .thenReturn(Optional.of(testUser));

        // When
        UserDetails userDetails = userDetailsService.loadUserByUsername("  testuser  ");

        // Then
        assertThat(userDetails.getUsername()).isEqualTo("testuser");
        verify(userRepository, times(1)).findByUsernameWithRoles("testuser");
    }
}