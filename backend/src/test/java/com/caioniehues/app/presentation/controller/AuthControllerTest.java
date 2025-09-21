package com.caioniehues.app.presentation.controller;

import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.application.dto.response.UserResponse;
import com.caioniehues.app.application.exception.DuplicateEmailException;
import com.caioniehues.app.application.service.AuthService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import java.util.UUID;

import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(controllers = AuthController.class, excludeAutoConfiguration = {
    org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration.class,
    org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration.class
})
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("Auth Controller Registration Tests")
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthService authService;

    private RegisterRequest validRequest;
    private UserResponse userResponse;

    @BeforeEach
    void setUp() {
        validRequest = new RegisterRequest(
            "john.doe@example.com",
            "John",
            "Doe",
            "SecureP@ssw0rd!42",
            "+1234567890"
        );

        userResponse = new UserResponse(
            UUID.randomUUID(),
            "john.doe@example.com",
            "john.doe@example.com",
            "John Doe",
            "+1234567890",
            true,
            null
        );
    }

    @Test
    @DisplayName("Should register user successfully with valid data")
    void register_WithValidData_ShouldReturn201Created() throws Exception {
        // Given
        when(authService.register(any(RegisterRequest.class))).thenReturn(userResponse);

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(validRequest)));

        // Then
        result.andExpect(status().isCreated())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.email", is(userResponse.email())))
            .andExpect(jsonPath("$.username", is(userResponse.username())))
            .andExpect(jsonPath("$.fullName", is(userResponse.fullName())))
            .andExpect(jsonPath("$.enabled", is(true)));

        verify(authService).register(any(RegisterRequest.class));
    }

    @Test
    @DisplayName("Should return 400 for invalid email format")
    void register_WithInvalidEmail_ShouldReturn400() throws Exception {
        // Given
        RegisterRequest invalidEmailRequest = new RegisterRequest(
            "invalid-email",
            "John",
            "Doe",
            "SecureP@ssw0rd!42",
            null
        );

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invalidEmailRequest))
);

        // Then
        result.andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errors.email").exists());

        verify(authService, never()).register(any());
    }

    @Test
    @DisplayName("Should return 400 for weak password")
    void register_WithWeakPassword_ShouldReturn400() throws Exception {
        // Given
        RegisterRequest weakPasswordRequest = new RegisterRequest(
            "john@example.com",
            "John",
            "Doe",
            "weak",  // Too short, no uppercase, no number, no special char
            null
        );

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(weakPasswordRequest))
);

        // Then
        result.andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errors.password").exists());

        verify(authService, never()).register(any());
    }

    @Test
    @DisplayName("Should return 400 for missing required fields")
    void register_WithMissingFields_ShouldReturn400() throws Exception {
        // Given
        String incompleteRequest = """
            {
                "email": "test@example.com"
            }
            """;

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(incompleteRequest)
);

        // Then
        result.andExpect(status().isBadRequest());

        verify(authService, never()).register(any());
    }

    @Test
    @DisplayName("Should return 409 for duplicate email")
    void register_WithDuplicateEmail_ShouldReturn409() throws Exception {
        // Given
        when(authService.register(any(RegisterRequest.class)))
            .thenThrow(new DuplicateEmailException("Email already exists"));

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(validRequest)));

        // Then
        result.andExpect(status().isConflict())
            .andExpect(jsonPath("$.message").value("Email already exists"));

        verify(authService).register(any(RegisterRequest.class));
    }

    @Test
    @DisplayName("Should validate email is not blank")
    void register_WithBlankEmail_ShouldReturn400() throws Exception {
        // Given
        RegisterRequest blankEmailRequest = new RegisterRequest(
            "",
            "John",
            "Doe",
            "SecureP@ssw0rd!42",
            null
        );

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(blankEmailRequest))
);

        // Then
        result.andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errors.email").exists());

        verify(authService, never()).register(any());
    }

    @Test
    @DisplayName("Should validate first name is not blank")
    void register_WithBlankFirstName_ShouldReturn400() throws Exception {
        // Given
        RegisterRequest blankNameRequest = new RegisterRequest(
            "test@example.com",
            "",
            "Doe",
            "SecureP@ssw0rd!42",
            null
        );

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(blankNameRequest))
);

        // Then
        result.andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errors.firstName").exists());

        verify(authService, never()).register(any());
    }

    @Test
    @DisplayName("Should validate last name is not blank")
    void register_WithBlankLastName_ShouldReturn400() throws Exception {
        // Given
        RegisterRequest blankNameRequest = new RegisterRequest(
            "test@example.com",
            "John",
            "",
            "SecureP@ssw0rd!42",
            null
        );

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(blankNameRequest))
);

        // Then
        result.andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errors.lastName").exists());

        verify(authService, never()).register(any());
    }

    @Test
    @DisplayName("Should accept registration without phone number")
    void register_WithoutPhoneNumber_ShouldSucceed() throws Exception {
        // Given
        RegisterRequest requestWithoutPhone = new RegisterRequest(
            "test@example.com",
            "John",
            "Doe",
            "SecureP@ssw0rd!42",
            null
        );

        when(authService.register(any(RegisterRequest.class))).thenReturn(userResponse);

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(requestWithoutPhone))
);

        // Then
        result.andExpect(status().isCreated());

        verify(authService).register(any(RegisterRequest.class));
    }

    @Test
    @DisplayName("Should handle registration with all valid fields including phone")
    void register_WithAllFields_ShouldSucceed() throws Exception {
        // Given
        when(authService.register(any(RegisterRequest.class))).thenReturn(userResponse);

        // When
        ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(validRequest)));

        // Then
        result.andExpect(status().isCreated())
            .andExpect(jsonPath("$.phoneNumber", is(userResponse.phoneNumber())));

        verify(authService).register(any(RegisterRequest.class));
    }

    @Test
    @DisplayName("Should validate password meets complexity requirements")
    void register_PasswordComplexityValidation() throws Exception {
        // Test various invalid passwords
        String[][] invalidPasswords = {
            {"short", "Password must be at least 8 characters"},
            {"alllowercase123!", "Password must contain uppercase letter"},
            {"ALLUPPERCASE123!", "Password must contain lowercase letter"},
            {"NoNumbers!@#", "Password must contain a number"},
            {"NoSpecialChar123", "Password must contain special character"}
        };

        for (String[] testCase : invalidPasswords) {
            RegisterRequest request = new RegisterRequest(
                "test@example.com",
                "John",
                "Doe",
                testCase[0],
                null
            );

            ResultActions result = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
    );

            result.andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.password").exists());
        }

        verify(authService, never()).register(any());
    }
}