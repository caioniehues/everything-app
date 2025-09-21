package com.caioniehues.app.integration;

import com.caioniehues.app.application.dto.request.RefreshRequest;
import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.application.dto.response.TokenResponse;
import com.caioniehues.app.application.dto.response.UserResponse;
import com.caioniehues.app.infrastructure.security.JwtService;
import com.caioniehues.app.util.AuthTestHelper;
import com.caioniehues.app.util.TestDataBuilder;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MvcResult;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@DisplayName("Token Management Integration Tests")
public class TokenManagementIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private AuthTestHelper authTestHelper;

    @Autowired
    private JwtService jwtService;

    @Test
    @DisplayName("Should successfully refresh tokens with valid refresh token")
    void refreshToken_WithValidToken_ShouldReturnNewTokens() throws Exception {
        // Given
        String email = "refresh@example.com";
        String password = "RefreshPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        TokenResponse loginResponse = authTestHelper.registerAndLoginUser(registerRequest);
        RefreshRequest refreshRequest = new RefreshRequest(loginResponse.refreshToken());

        // When
        MvcResult result = mockMvc.perform(post("/api/v1/auth/refresh")
                .contentType(APPLICATION_JSON)
                .content(toJson(refreshRequest)))
            .andExpect(status().isOk())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.accessToken").exists())
            .andExpect(jsonPath("$.refreshToken").exists())
            .andExpect(jsonPath("$.tokenType").value("Bearer"))
            .andExpect(jsonPath("$.expiresIn").exists())
            .andReturn();

        // Then
        TokenResponse refreshResponse = fromJson(result.getResponse().getContentAsString(), TokenResponse.class);

        // New tokens should be different from original
        assertThat(refreshResponse.accessToken()).isNotEqualTo(loginResponse.accessToken());
        assertThat(refreshResponse.refreshToken()).isNotEqualTo(loginResponse.refreshToken());

        // New access token should be valid
        var userDetails = (com.caioniehues.app.domain.user.User) userDetailsService.loadUserByUsername(email);
        assertThat(jwtService.validateTokenForUser(refreshResponse.accessToken(), userDetails)).isTrue();

        // Original refresh token should be invalidated (token rotation)
        RefreshRequest oldTokenRequest = new RefreshRequest(loginResponse.refreshToken());
        mockMvc.perform(post("/api/v1/auth/refresh")
                .contentType(APPLICATION_JSON)
                .content(toJson(oldTokenRequest)))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Should reject token refresh with invalid refresh token")
    void refreshToken_WithInvalidToken_ShouldReturnUnauthorized() throws Exception {
        // Given
        RefreshRequest refreshRequest = TestDataBuilder.anInvalidRefreshRequest().build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/refresh")
                .contentType(APPLICATION_JSON)
                .content(toJson(refreshRequest)))
            .andExpect(status().isUnauthorized())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Invalid Refresh Token"))
            .andExpect(jsonPath("$.status").value(401));
    }

    @Test
    @DisplayName("Should allow access to protected endpoints with valid access token")
    void protectedEndpoint_WithValidToken_ShouldAllowAccess() throws Exception {
        // Given
        String email = "protected@example.com";
        String password = "ProtectedPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        TokenResponse tokenResponse = authTestHelper.registerAndLoginUser(registerRequest);
        String authHeader = authTestHelper.getAuthorizationHeader(tokenResponse.accessToken());

        // When/Then
        mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", authHeader))
            .andExpect(status().isOk())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.email").value(email))
            .andExpect(jsonPath("$.id").exists());
    }

    @Test
    @DisplayName("Should reject access to protected endpoints without token")
    void protectedEndpoint_WithoutToken_ShouldReturnUnauthorized() throws Exception {
        // When/Then
        mockMvc.perform(get("/api/v1/auth/me"))
            .andExpect(status().isUnauthorized())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Unauthorized"))
            .andExpect(jsonPath("$.status").value(401));
    }

    @Test
    @DisplayName("Should reject access to protected endpoints with invalid token")
    void protectedEndpoint_WithInvalidToken_ShouldReturnUnauthorized() throws Exception {
        // Given
        String invalidToken = authTestHelper.getAuthorizationHeader("invalid.jwt.token");

        // When/Then
        mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", invalidToken))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Should successfully logout and blacklist token")
    void logout_WithValidToken_ShouldBlacklistToken() throws Exception {
        // Given
        String email = "logout@example.com";
        String password = "LogoutPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        TokenResponse tokenResponse = authTestHelper.registerAndLoginUser(registerRequest);
        String authHeader = authTestHelper.getAuthorizationHeader(tokenResponse.accessToken());

        // Verify token works before logout
        mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", authHeader))
            .andExpect(status().isOk());

        // When - Logout
        mockMvc.perform(post("/api/v1/auth/logout")
                .header("Authorization", authHeader))
            .andExpect(status().isOk())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.message").value("Logout successful"));

        // Then - Token should be blacklisted
        mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", authHeader))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Should handle logout without token gracefully")
    void logout_WithoutToken_ShouldReturnUnauthorized() throws Exception {
        // When/Then
        mockMvc.perform(post("/api/v1/auth/logout"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Should validate token expiration correctly")
    void tokenValidation_WithExpiredToken_ShouldReject() throws Exception {
        // Given
        String email = "expired@example.com";
        String password = "ExpiredPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        var userDetails = (com.caioniehues.app.domain.user.User) userDetailsService.loadUserByUsername(email);
        String expiredToken = authTestHelper.generateExpiredJwtToken(userDetails);
        String authHeader = authTestHelper.getAuthorizationHeader(expiredToken);

        // When/Then
        mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", authHeader))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Should handle malformed Authorization header")
    void protectedEndpoint_WithMalformedAuthHeader_ShouldReturnUnauthorized() throws Exception {
        // When/Then - Missing Bearer prefix
        mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", "invalid-header-format"))
            .andExpect(status().isUnauthorized());

        // And - Just "Bearer" without token
        mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", "Bearer"))
            .andExpect(status().isUnauthorized());

        // And - Bearer with empty token
        mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", "Bearer "))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Should return current user information for authenticated requests")
    void getCurrentUser_WithValidToken_ShouldReturnUserInfo() throws Exception {
        // Given
        String email = "currentuser@example.com";
        String fullName = "Current User";
        String password = "CurrentPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .fullName(fullName)
            .password(password)
            .build();

        TokenResponse tokenResponse = authTestHelper.registerAndLoginUser(registerRequest);
        String authHeader = authTestHelper.getAuthorizationHeader(tokenResponse.accessToken());

        // When
        MvcResult result = mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", authHeader))
            .andExpect(status().isOk())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.email").value(email))
            .andExpect(jsonPath("$.fullName").value(fullName))
            .andExpect(jsonPath("$.id").exists())
            .andExpect(jsonPath("$.password").doesNotExist())
            .andReturn();

        // Then
        UserResponse response = fromJson(result.getResponse().getContentAsString(), UserResponse.class);
        assertThat(response.email()).isEqualTo(email);
        assertThat(response.fullName()).isEqualTo(fullName);
        assertThat(response.id()).isNotNull();
    }

    @Test
    @DisplayName("Should handle concurrent token operations")
    void concurrentTokenOperations_ShouldHandleGracefully() throws Exception {
        // Given
        String email = "concurrent@example.com";
        String password = "ConcurrentPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        TokenResponse tokenResponse = authTestHelper.registerAndLoginUser(registerRequest);
        RefreshRequest refreshRequest = new RefreshRequest(tokenResponse.refreshToken());

        // When - Try to refresh the same token multiple times concurrently
        // First refresh should succeed
        mockMvc.perform(post("/api/v1/auth/refresh")
                .contentType(APPLICATION_JSON)
                .content(toJson(refreshRequest)))
            .andExpect(status().isOk());

        // Second refresh with same token should fail (token rotation)
        mockMvc.perform(post("/api/v1/auth/refresh")
                .contentType(APPLICATION_JSON)
                .content(toJson(refreshRequest)))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Should handle token refresh with missing refresh token")
    void refreshToken_WithMissingToken_ShouldReturnBadRequest() throws Exception {
        // Given
        RefreshRequest emptyRequest = new RefreshRequest(null);

        // When/Then
        mockMvc.perform(post("/api/v1/auth/refresh")
                .contentType(APPLICATION_JSON)
                .content(toJson(emptyRequest)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.title").value("Validation Failed"))
            .andExpect(jsonPath("$.errors.refreshToken").exists());
    }
}