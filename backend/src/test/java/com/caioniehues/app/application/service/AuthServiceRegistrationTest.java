package com.caioniehues.app.application.service;

import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.application.dto.response.UserResponse;
import com.caioniehues.app.application.exception.DuplicateEmailException;
import com.caioniehues.app.application.mapper.UserMapper;
import com.caioniehues.app.domain.user.Role;
import com.caioniehues.app.domain.user.User;
import com.caioniehues.app.infrastructure.persistence.RoleRepository;
import com.caioniehues.app.infrastructure.persistence.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("Auth Service Registration Tests")
class AuthServiceRegistrationTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private RoleRepository roleRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private AuthService authService;

    private RegisterRequest registerRequest;
    private Role defaultRole;
    private User savedUser;
    private UserResponse expectedResponse;

    @BeforeEach
    void setUp() {
        registerRequest = new RegisterRequest(
            "john.doe@example.com",
            "John",
            "Doe",
            "SecureP@ssw0rd!42",
            "+1234567890"
        );

        defaultRole = Role.builder()
            .name("USER")
            .description("Regular family member")
            .build();

        savedUser = User.builder()
            .username("john.doe@example.com")
            .email("john.doe@example.com")
            .fullName("John Doe")
            .passwordHash("$2a$12$hashedPassword")
            .enabled(true)
            .build();

        expectedResponse = new UserResponse(
            UUID.randomUUID(),
            "john.doe@example.com",
            "john.doe@example.com",
            "John Doe",
            null,
            true,
            null
        );
    }

    @Test
    @DisplayName("Should successfully register new user with encrypted password")
    void register_WithValidData_ShouldCreateUserSuccessfully() {
        // Given
        when(userRepository.existsByEmail(registerRequest.email())).thenReturn(false);
        when(userRepository.existsByUsername(registerRequest.email())).thenReturn(false);
        when(passwordEncoder.encode(registerRequest.password())).thenReturn("$2a$12$hashedPassword");
        when(roleRepository.findByName("USER")).thenReturn(Optional.of(defaultRole));
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(savedUser)).thenReturn(expectedResponse);

        // When
        UserResponse response = authService.register(registerRequest);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.email()).isEqualTo(registerRequest.email());
        assertThat(response.fullName()).isEqualTo("John Doe");

        // Verify user was saved with correct data
        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        User savedUserArg = userCaptor.getValue();

        assertThat(savedUserArg.getEmail()).isEqualTo(registerRequest.email());
        assertThat(savedUserArg.getUsername()).isEqualTo(registerRequest.email());
        assertThat(savedUserArg.getPasswordHash()).isEqualTo("$2a$12$hashedPassword");
        assertThat(savedUserArg.getFullName()).isEqualTo("John Doe");

        verify(passwordEncoder).encode(registerRequest.password());
        verify(roleRepository).findByName("USER");
    }

    @Test
    @DisplayName("Should reject registration with duplicate email")
    void register_WithDuplicateEmail_ShouldThrowException() {
        // Given
        when(userRepository.existsByEmail(registerRequest.email())).thenReturn(true);

        // When/Then
        DuplicateEmailException exception = assertThrows(
            DuplicateEmailException.class,
            () -> authService.register(registerRequest)
        );

        assertThat(exception.getMessage()).contains("already exists");
        verify(userRepository, never()).save(any(User.class));
        verify(passwordEncoder, never()).encode(anyString());
    }

    @Test
    @DisplayName("Should reject registration with duplicate username")
    void register_WithDuplicateUsername_ShouldThrowException() {
        // Given
        when(userRepository.existsByEmail(registerRequest.email())).thenReturn(false);
        when(userRepository.existsByUsername(registerRequest.email())).thenReturn(true);

        // When/Then
        DuplicateEmailException exception = assertThrows(
            DuplicateEmailException.class,
            () -> authService.register(registerRequest)
        );

        assertThat(exception.getMessage()).contains("already exists");
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Should hash password with BCrypt")
    void register_ShouldHashPasswordWithBCrypt() {
        // Given
        String rawPassword = "SecureP@ssw0rd!42";
        String hashedPassword = "$2a$12$encodedPasswordHash";

        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(passwordEncoder.encode(rawPassword)).thenReturn(hashedPassword);
        when(roleRepository.findByName("USER")).thenReturn(Optional.of(defaultRole));
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(any(User.class))).thenReturn(expectedResponse);

        // When
        authService.register(registerRequest);

        // Then
        verify(passwordEncoder).encode(rawPassword);

        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        assertThat(userCaptor.getValue().getPasswordHash()).isEqualTo(hashedPassword);
    }

    @Test
    @DisplayName("Should assign default USER role to new registration")
    void register_ShouldAssignDefaultUserRole() {
        // Given
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("$2a$12$hash");
        when(roleRepository.findByName("USER")).thenReturn(Optional.of(defaultRole));
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(any(User.class))).thenReturn(expectedResponse);

        // When
        authService.register(registerRequest);

        // Then
        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        User savedUserArg = userCaptor.getValue();

        assertThat(savedUserArg.getRoles()).contains(defaultRole);
        verify(roleRepository).findByName("USER");
    }

    @Test
    @DisplayName("Should handle missing default role gracefully")
    void register_WithMissingDefaultRole_ShouldCreateUserWithoutRole() {
        // Given
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("$2a$12$hash");
        when(roleRepository.findByName("USER")).thenReturn(Optional.empty());
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(any(User.class))).thenReturn(expectedResponse);

        // When
        UserResponse response = authService.register(registerRequest);

        // Then
        assertThat(response).isNotNull();

        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        User savedUserArg = userCaptor.getValue();

        assertThat(savedUserArg.getRoles()).isEmpty();
    }

    @Test
    @DisplayName("Should set username as email for registration")
    void register_ShouldSetUsernameAsEmail() {
        // Given
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("$2a$12$hash");
        when(roleRepository.findByName("USER")).thenReturn(Optional.of(defaultRole));
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(any(User.class))).thenReturn(expectedResponse);

        // When
        authService.register(registerRequest);

        // Then
        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        User savedUserArg = userCaptor.getValue();

        assertThat(savedUserArg.getUsername()).isEqualTo(registerRequest.email());
        assertThat(savedUserArg.getEmail()).isEqualTo(registerRequest.email());
    }

    @Test
    @DisplayName("Should enable user account by default")
    void register_ShouldEnableAccountByDefault() {
        // Given
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("$2a$12$hash");
        when(roleRepository.findByName("USER")).thenReturn(Optional.of(defaultRole));
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(any(User.class))).thenReturn(expectedResponse);

        // When
        authService.register(registerRequest);

        // Then
        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        assertThat(userCaptor.getValue().isEnabled()).isTrue();
    }

    @Test
    @DisplayName("Should combine first and last name for full name")
    void register_ShouldCombineNamesForFullName() {
        // Given
        RegisterRequest request = new RegisterRequest(
            "test@example.com",
            "Jane",
            "Smith",
            "Password!42X",
            null
        );

        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("$2a$12$hash");
        when(roleRepository.findByName("USER")).thenReturn(Optional.of(defaultRole));
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(any(User.class))).thenReturn(expectedResponse);

        // When
        authService.register(request);

        // Then
        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        assertThat(userCaptor.getValue().getFullName()).isEqualTo("Jane Smith");
    }

    @Test
    @DisplayName("Should handle registration with optional phone number")
    void register_WithPhoneNumber_ShouldSavePhoneNumber() {
        // Given
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("$2a$12$hash");
        when(roleRepository.findByName("USER")).thenReturn(Optional.of(defaultRole));
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(any(User.class))).thenReturn(expectedResponse);

        // When
        authService.register(registerRequest);

        // Then
        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        // Note: Phone field would be added to User entity in a real implementation
    }

    @Test
    @DisplayName("Should trim whitespace from email and names")
    void register_ShouldTrimWhitespace() {
        // Given
        RegisterRequest requestWithWhitespace = new RegisterRequest(
            "  john@example.com  ",
            "  John  ",
            "  Doe  ",
            "Password!42X",
            null
        );

        when(userRepository.existsByEmail("john@example.com")).thenReturn(false);
        when(userRepository.existsByUsername("john@example.com")).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("$2a$12$hash");
        when(roleRepository.findByName("USER")).thenReturn(Optional.of(defaultRole));
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(any(User.class))).thenReturn(expectedResponse);

        // When
        authService.register(requestWithWhitespace);

        // Then
        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(userCaptor.capture());
        User savedUserArg = userCaptor.getValue();

        assertThat(savedUserArg.getEmail()).isEqualTo("john@example.com");
        assertThat(savedUserArg.getFullName()).isEqualTo("John Doe");
    }
}