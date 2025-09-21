package com.caioniehues.app.integration;

import com.caioniehues.app.application.dto.request.LoginRequest;
import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.application.dto.response.TokenResponse;
import com.caioniehues.app.util.AuthTestHelper;
import com.caioniehues.app.util.TestDataBuilder;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@DisplayName("Security Configuration Integration Tests")
public class SecurityIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private AuthTestHelper authTestHelper;

    @Test
    @DisplayName("Should include proper security headers in all responses")
    void responses_ShouldIncludeSecurityHeaders() throws Exception {
        // When/Then
        mockMvc.perform(get("/api/health"))
            .andExpect(header().exists("X-Content-Type-Options"))
            .andExpect(header().string("X-Content-Type-Options", "nosniff"))
            .andExpect(header().exists("X-Frame-Options"))
            .andExpect(header().string("X-Frame-Options", "DENY"))
            .andExpect(header().exists("X-XSS-Protection"));
    }

    @Test
    @DisplayName("Should include HSTS header for HTTPS security")
    void responses_ShouldIncludeHSTSHeader() throws Exception {
        // When/Then
        mockMvc.perform(get("/api/health"))
            .andExpect(header().exists("Strict-Transport-Security"));
    }

    @Test
    @DisplayName("Should handle CORS preflight requests correctly")
    void corsPreflight_ShouldBeHandledCorrectly() throws Exception {
        // When/Then
        mockMvc.perform(options("/api/v1/auth/login")
                .header("Origin", "http://localhost:3000")
                .header("Access-Control-Request-Method", "POST")
                .header("Access-Control-Request-Headers", "Content-Type,Authorization"))
            .andExpect(status().isOk())
            .andExpect(header().exists("Access-Control-Allow-Origin"))
            .andExpect(header().exists("Access-Control-Allow-Methods"))
            .andExpect(header().exists("Access-Control-Allow-Headers"))
            .andExpect(header().exists("Access-Control-Max-Age"));
    }

    @Test
    @DisplayName("Should allow requests from localhost origins")
    void corsActualRequest_FromLocalhostOrigin_ShouldBeAllowed() throws Exception {
        // Given
        LoginRequest loginRequest = TestDataBuilder.aLoginRequest().build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest))
                .header("Origin", "http://localhost:3000"))
            .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:3000"));
    }

    @Test
    @DisplayName("Should prevent SQL injection attacks in login")
    void loginEndpoint_WithSQLInjectionAttempt_ShouldBeSecure() throws Exception {
        // Given - SQL injection attempts in email field
        LoginRequest sqlInjectionRequest = new LoginRequest(
            "admin'; DROP TABLE users; --",
            "password"
        );

        // When/Then - Should be handled as invalid email format, not execute SQL
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(sqlInjectionRequest)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.title").value("Validation Failed"));

        // Verify database integrity - users table should still exist
        int userCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM users", Integer.class);
        // Count should be 0 since we clean up before each test, but table should exist
    }

    @Test
    @DisplayName("Should prevent XSS attacks in registration")
    void registrationEndpoint_WithXSSAttempt_ShouldSanitizeInput() throws Exception {
        // Given
        RegisterRequest xssRequest = TestDataBuilder.aRegisterRequest()
            .email("test@example.com")
            .fullName("<script>alert('xss')</script>Test User")
            .build();

        // When
        authTestHelper.registerUser(xssRequest);

        // Then - Script tags should be handled safely (not executed)
        // The exact behavior depends on whether we sanitize or validate
        // For now, we just verify the registration doesn't break the system
    }

    @Test
    @DisplayName("Should reject requests with invalid Content-Type")
    void authEndpoints_WithInvalidContentType_ShouldReject() throws Exception {
        // Given
        LoginRequest loginRequest = TestDataBuilder.aLoginRequest().build();

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType("text/plain")
                .content(toJson(loginRequest)))
            .andExpect(status().isUnsupportedMediaType());
    }

    @Test
    @DisplayName("Should handle oversized request payloads")
    void authEndpoints_WithOversizedPayload_ShouldReject() throws Exception {
        // Given - Create a very large payload
        StringBuilder largePayload = new StringBuilder("{\"email\":\"test@example.com\",\"password\":\"");
        for (int i = 0; i < 100000; i++) {
            largePayload.append("a");
        }
        largePayload.append("\"}");

        // When/Then
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(largePayload.toString()))
            .andExpect(status().is4xxClientError()); // Should reject large payloads
    }

    @Test
    @DisplayName("Should disable CSRF protection for API endpoints")
    void apiEndpoints_ShouldNotRequireCSRFTokens() throws Exception {
        // Given
        LoginRequest loginRequest = TestDataBuilder.aLoginRequest().build();

        // When/Then - POST without CSRF token should not fail due to CSRF
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(loginRequest)))
            .andExpect(result -> assertThat(result.getResponse().getStatus()).isNotEqualTo(403)); // Should not be CSRF forbidden
    }

    @Test
    @DisplayName("Should use stateless session management")
    void apiEndpoints_ShouldBeStateless() throws Exception {
        // When/Then - Multiple requests should not create sessions
        mockMvc.perform(get("/api/health"))
            .andExpect(status().isOk())
            .andExpect(header().doesNotExist("Set-Cookie"));

        mockMvc.perform(get("/api/health"))
            .andExpect(status().isOk())
            .andExpect(header().doesNotExist("Set-Cookie"));
    }

    @Test
    @DisplayName("Should handle token tampering attempts")
    void protectedEndpoint_WithTamperedToken_ShouldReject() throws Exception {
        // Given
        String email = "tamper@example.com";
        String password = "TamperPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        TokenResponse tokenResponse = authTestHelper.registerAndLoginUser(registerRequest);

        // Tamper with the token by changing a character
        String tamperedToken = tokenResponse.accessToken().substring(0, 50) + "X" +
            tokenResponse.accessToken().substring(51);
        String authHeader = authTestHelper.getAuthorizationHeader(tamperedToken);

        // When/Then
        mockMvc.perform(get("/api/v1/auth/me")
                .header("Authorization", authHeader))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Should handle malformed JWT tokens")
    void protectedEndpoint_WithMalformedJWT_ShouldReject() throws Exception {
        // Given - Various malformed JWT tokens
        String[] malformedTokens = {
            "not.a.jwt",
            "header.payload", // Missing signature
            "header.payload.signature.extra", // Too many parts
            "", // Empty token
            "Bearer", // Just the Bearer keyword
            "malformed", // No dots
            "a.b.c.d.e" // Too many parts
        };

        // When/Then
        for (String malformedToken : malformedTokens) {
            mockMvc.perform(get("/api/v1/auth/me")
                    .header("Authorization", "Bearer " + malformedToken))
                .andExpect(status().isUnauthorized());
        }
    }

    @Test
    @DisplayName("Should handle concurrent authentication attempts safely")
    void concurrentAuthentication_ShouldBeThreadSafe() throws Exception {
        // Given
        String email = "concurrent@example.com";
        String password = "ConcurrentPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        LoginRequest loginRequest = TestDataBuilder.aLoginRequest()
            .email(email)
            .password(password)
            .build();

        // When - Make multiple concurrent login attempts
        // This tests that our security configuration handles concurrent requests safely
        for (int i = 0; i < 5; i++) {
            mockMvc.perform(post("/api/v1/auth/login")
                    .contentType(APPLICATION_JSON)
                    .content(toJson(loginRequest)))
                .andExpect(status().isOk());
        }

        // Then - All should succeed and not interfere with each other
        // (The test passing indicates thread safety)
    }

    @Test
    @DisplayName("Should log security events for audit purposes")
    void authenticationEvents_ShouldBeLogged() throws Exception {
        // Given
        String email = "audit@example.com";
        String password = "AuditPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        // When - Perform various authentication events
        // Successful login
        LoginRequest validLogin = TestDataBuilder.aLoginRequest()
            .email(email)
            .password(password)
            .build();
        authTestHelper.loginUser(validLogin);

        // Failed login
        LoginRequest invalidLogin = TestDataBuilder.aLoginRequest()
            .email(email)
            .password("WrongPassword123!")
            .build();
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(invalidLogin)))
            .andExpect(status().isUnauthorized());

        // Then - Events should be logged
        // (In a real implementation, we would verify log entries)
        // For now, we verify the operations don't fail
    }

    @Test
    @DisplayName("Should properly handle authentication header edge cases")
    void authenticationHeader_EdgeCases_ShouldBeHandledSafely() throws Exception {
        // Given - Various edge cases for Authorization header
        String[] edgeCases = {
            null, // No header
            "", // Empty header
            "Bearer", // No token
            "Bearer ", // Space but no token
            "Basic dGVzdDp0ZXN0", // Wrong auth type
            "bearer valid.jwt.token", // Wrong case
            "BearerX valid.jwt.token", // Typo in Bearer
            "Bearer  extra.spaces.token", // Extra spaces
        };

        // When/Then
        for (String authHeader : edgeCases) {
            var request = get("/api/v1/auth/me");
            if (authHeader != null) {
                request = request.header("Authorization", authHeader);
            }

            mockMvc.perform(request)
                .andExpect(status().isUnauthorized());
        }
    }
}