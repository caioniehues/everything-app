package com.caioniehues.app.integration;

import com.caioniehues.app.application.dto.request.LoginRequest;
import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.application.dto.response.TokenResponse;
import com.caioniehues.app.infrastructure.security.JwtService;
import com.caioniehues.app.util.AuthTestHelper;
import com.caioniehues.app.util.TestDataBuilder;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MvcResult;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@DisplayName("Authentication Login Integration Tests")
public class AuthLoginIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private AuthTestHelper authTestHelper;

    @Autowired
    private JwtService jwtService;

    @Test
    @DisplayName("Should successfully login with valid credentials")
    void loginUser_WithValidCredentials_ShouldReturnTokens() throws Exception {
        // Given
        String email = "login@example.com";
        String password = "LoginPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email(email)
            .password(password)
            .build();

        // When
        MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest)))
            .andExpect(status().isOk())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.accessToken").exists())
            .andExpect(jsonPath("$.refreshToken").exists())
            .andExpect(jsonPath("$.tokenType").value("Bearer"))
            .andExpect(jsonPath("$.expiresIn").exists())
            .andReturn();

        // Then
        TokenResponse response = fromJson(result.getResponse().getContentAsString(), TokenResponse.class);
        assertThat(response.accessToken()).isNotNull();
        assertThat(response.refreshToken()).isNotNull();
        assertThat(response.tokenType()).isEqualTo("Bearer");
        assertThat(response.expiresIn()).isPositive();

        // Verify token claims
        String extractedUsername = jwtService.extractUsername(response.accessToken());
        assertThat(extractedUsername).isEqualTo(email);

        // Verify token is valid
        var userDetails = (com.caioniehues.app.domain.user.User)
            userDetailsService.loadUserByUsername(email);
        assertThat(jwtService.validateTokenForUser(response.accessToken(), userDetails)).isTrue();
    }

    @Test
    @DisplayName("Should reject login with invalid email")
    void loginUser_WithInvalidEmail_ShouldReturnUnauthorized() throws Exception {
        // Given
        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email("nonexistent@example.com")
            .password("SomePassword123!")
            .build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest)))
            .andExpect(status().isUnauthorized())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Authentication Failed"))
            .andExpect(jsonPath("$.status").value(401))
            .andExpect(jsonPath("$.detail").exists());
    }

    @Test
    @DisplayName("Should reject login with wrong password")
    void loginUser_WithWrongPassword_ShouldReturnUnauthorized() throws Exception {
        // Given
        String email = "wrongpass@example.com";
        String correctPassword = "CorrectPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(correctPassword)
            .build();

        authTestHelper.registerUser(registerRequest);

        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email(email)
            .password("WrongPassword123!")
            .build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest)))
            .andExpect(status().isUnauthorized())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Authentication Failed"))
            .andExpect(jsonPath("$.status").value(401));
    }

    @Test
    @DisplayName("Should reject login with invalid email format")
    void loginUser_WithInvalidEmailFormat_ShouldReturnBadRequest() throws Exception {
        // Given
        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email("not-an-email")
            .build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest)))
            .andExpect(status().isBadRequest())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Validation Failed"))
            .andExpect(jsonPath("$.errors.email").exists());
    }

    @Test
    @DisplayName("Should reject login with missing credentials")
    void loginUser_WithMissingCredentials_ShouldReturnBadRequest() throws Exception {
        // Given
        LoginRequest loginRequest = new LoginRequest(null, null);

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest)))
            .andExpect(status().isBadRequest())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Validation Failed"))
            .andExpect(jsonPath("$.errors.email").exists())
            .andExpect(jsonPath("$.errors.password").exists());
    }

    @Test
    @DisplayName("Should handle multiple successful logins for same user")
    void loginUser_MultipleLogins_ShouldGenerateDifferentTokens() throws Exception {
        // Given
        String email = "multilogin@example.com";
        String password = "LoginPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email(email)
            .password(password)
            .build();

        // When - First login
        TokenResponse firstLogin = authTestHelper.loginUser(loginRequest);

        // Wait a moment to ensure different timestamps
        Thread.sleep(1000);

        // Second login
        TokenResponse secondLogin = authTestHelper.loginUser(loginRequest);

        // Then
        assertThat(firstLogin.accessToken()).isNotEqualTo(secondLogin.accessToken());
        assertThat(firstLogin.refreshToken()).isNotEqualTo(secondLogin.refreshToken());

        // Both tokens should be valid
        var userDetails = (com.caioniehues.app.domain.user.User)
            userDetailsService.loadUserByUsername(email);
        assertThat(jwtService.validateTokenForUser(firstLogin.accessToken(), userDetails)).isTrue();
        assertThat(jwtService.validateTokenForUser(secondLogin.accessToken(), userDetails)).isTrue();
    }

    @Test
    @DisplayName("Should return correct token expiration time")
    void loginUser_ShouldReturnCorrectExpirationTime() throws Exception {
        // Given
        String email = "expiry@example.com";
        String password = "ExpiryPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email(email)
            .password(password)
            .build();

        // When
        TokenResponse response = authTestHelper.loginUser(loginRequest);

        // Then
        // expiresIn should be approximately 15 minutes (900 seconds)
        assertThat(response.expiresIn()).isBetween(890, 900);
    }

    @Test
    @DisplayName("Should trim whitespace from email during login")
    void loginUser_WithWhitespaceInEmail_ShouldTrimAndSucceed() throws Exception {
        // Given
        String email = "trimtest@example.com";
        String password = "TrimPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email("  " + email + "  ") // Email with whitespace
            .password(password)
            .build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.accessToken").exists());
    }

    @Test
    @DisplayName("Should handle case-insensitive email login")
    void loginUser_WithDifferentEmailCase_ShouldSucceed() throws Exception {
        // Given
        String email = "casetest@example.com";
        String password = "CasePassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email.toLowerCase())
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email(email.toUpperCase()) // Different case
            .password(password)
            .build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.accessToken").exists());
    }

    @Test
    @DisplayName("Should reject login with malformed JSON")
    void loginUser_WithMalformedJson_ShouldReturnBadRequest() throws Exception {
        // Given
        String malformedJson = "{ email: 'test@example.com', missing quotes }";

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(malformedJson))
            .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("Should include proper CORS headers in login response")
    void loginUser_ShouldIncludeCorsHeaders() throws Exception {
        // Given
        String email = "cors@example.com";
        String password = "CorsPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email(email)
            .password(password)
            .build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest))
                .header("Origin", "http://localhost:3000"))
            .andExpect(status().isOk())
            .andExpect(header().exists("Access-Control-Allow-Origin"));
    }
}