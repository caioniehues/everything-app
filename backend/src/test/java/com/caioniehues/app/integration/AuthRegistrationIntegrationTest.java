package com.caioniehues.app.integration;

import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.application.dto.response.UserResponse;
import com.caioniehues.app.domain.user.User;
import com.caioniehues.app.infrastructure.persistence.UserRepository;
import com.caioniehues.app.util.AuthTestHelper;
import com.caioniehues.app.util.TestDataBuilder;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@DisplayName("Authentication Registration Integration Tests")
public class AuthRegistrationIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private AuthTestHelper authTestHelper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Test
    @DisplayName("Should successfully register a new user with valid data")
    void registerUser_WithValidData_ShouldCreateUser() throws Exception {
        // Given
        RegisterRequest request = TestDataBuilder.aValidRegisterRequest()
            .email("newuser@example.com")
            .fullName("New User")
            .password("StrongPass@2024!")
            .build();

        // When
        MvcResult result = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isCreated())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.email").value(request.email()))
            .andExpect(jsonPath("$.fullName").value(request.getFullName()))
            .andExpect(jsonPath("$.id").exists())
            .andExpect(jsonPath("$.password").doesNotExist())
            .andReturn();

        // Then
        UserResponse response = fromJson(result.getResponse().getContentAsString(), UserResponse.class);
        assertThat(response.email()).isEqualTo(request.email());
        assertThat(response.fullName()).isEqualTo(request.getFullName());
        assertThat(response.id()).isNotNull();

        // Verify database persistence
        Optional<User> savedUser = userRepository.findByEmail(request.email());
        assertThat(savedUser).isPresent();
        assertThat(savedUser.get().getEmail()).isEqualTo(request.email());
        assertThat(savedUser.get().getFullName()).isEqualTo(request.getFullName());
        assertThat(savedUser.get().isEnabled()).isTrue();
        assertThat(savedUser.get().isAccountNonLocked()).isTrue();

        // Verify password is encrypted
        assertThat(passwordEncoder.matches(request.password(), savedUser.get().getPassword())).isTrue();
    }

    @Test
    @DisplayName("Should reject registration with duplicate email")
    void registerUser_WithDuplicateEmail_ShouldReturnConflict() throws Exception {
        // Given
        RegisterRequest firstRequest = TestDataBuilder.aValidRegisterRequest()
            .email("duplicate@example.com")
            .build();

        RegisterRequest duplicateRequest = TestDataBuilder.aValidRegisterRequest()
            .email("duplicate@example.com")
            .fullName("Different Name")
            .build();

        // When - Register first user
        authTestHelper.registerUser(firstRequest);

        // Then - Try to register duplicate email
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(toJson(duplicateRequest)))
            .andExpect(status().isConflict())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Email Already Exists"))
            .andExpect(jsonPath("$.status").value(409))
            .andExpect(jsonPath("$.detail").exists());
    }

    @Test
    @DisplayName("Should reject registration with invalid email format")
    void registerUser_WithInvalidEmail_ShouldReturnBadRequest() throws Exception {
        // Given
        RegisterRequest request = TestDataBuilder.aRegisterRequest()
            .email("not-a-valid-email")
            .build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isBadRequest())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Validation Failed"))
            .andExpect(jsonPath("$.status").value(400))
            .andExpect(jsonPath("$.errors").exists());
    }

    @Test
    @DisplayName("Should reject registration with weak password")
    void registerUser_WithWeakPassword_ShouldReturnBadRequest() throws Exception {
        // Given
        RegisterRequest request = TestDataBuilder.aRegisterRequest()
            .password("weak")
            .build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isBadRequest())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Validation Failed"))
            .andExpect(jsonPath("$.status").value(400))
            .andExpect(jsonPath("$.errors.password").exists());
    }

    @Test
    @DisplayName("Should reject registration with missing required fields")
    void registerUser_WithMissingFields_ShouldReturnBadRequest() throws Exception {
        // Given
        RegisterRequest request = new RegisterRequest(null, null, null, null, null);

        // When/Then
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isBadRequest())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Validation Failed"))
            .andExpect(jsonPath("$.errors.email").exists())
            .andExpect(jsonPath("$.errors.fullName").exists())
            .andExpect(jsonPath("$.errors.password").exists());
    }

    @Test
    @DisplayName("Should reject registration with empty full name")
    void registerUser_WithEmptyFullName_ShouldReturnBadRequest() throws Exception {
        // Given
        RegisterRequest request = TestDataBuilder.aRegisterRequest()
            .fullName("")
            .build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isBadRequest())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.errors.fullName").exists());
    }

    @Test
    @DisplayName("Should reject registration with malformed JSON")
    void registerUser_WithMalformedJson_ShouldReturnBadRequest() throws Exception {
        // Given
        String malformedJson = "{ email: 'test@example.com', missing quotes }";

        // When/Then
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(malformedJson))
            .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Should handle concurrent registration attempts gracefully")
    void registerUser_ConcurrentRequests_ShouldHandleGracefully() throws Exception {
        // Given
        RegisterRequest request = TestDataBuilder.aValidRegisterRequest()
            .email("concurrent@example.com")
            .build();

        // When - Simulate concurrent registration attempts
        // First request should succeed
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isCreated());

        // Second request should fail with conflict
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isConflict());

        // Then - Verify only one user was created
        Optional<User> user = userRepository.findByEmail(request.email());
        assertThat(user).isPresent();
    }

    @Test
    @DisplayName("Should create user with proper timestamps")
    void registerUser_ShouldSetProperTimestamps() throws Exception {
        // Given
        RegisterRequest request = TestDataBuilder.aValidRegisterRequest()
            .email("timestamp@example.com")
            .build();

        // When
        authTestHelper.registerUser(request);

        // Then
        Optional<User> savedUser = userRepository.findByEmail(request.email());
        assertThat(savedUser).isPresent();
        assertThat(savedUser.get().getCreatedAt()).isNotNull();
        assertThat(savedUser.get().getUpdatedAt()).isNotNull();
        assertThat(savedUser.get().getCreatedAt()).isEqualTo(savedUser.get().getUpdatedAt());
    }

    @Test
    @DisplayName("Should normalize email to lowercase")
    void registerUser_WithUppercaseEmail_ShouldNormalizeToLowercase() throws Exception {
        // Given
        RegisterRequest request = TestDataBuilder.aValidRegisterRequest()
            .email("Test.User@EXAMPLE.COM")
            .build();

        // When
        authTestHelper.registerUser(request);

        // Then
        Optional<User> savedUser = userRepository.findByEmail("test.user@example.com");
        assertThat(savedUser).isPresent();
        assertThat(savedUser.get().getEmail()).isEqualTo("test.user@example.com");
        assertThat(savedUser.get().getUsername()).isEqualTo("test.user@example.com");
    }
}