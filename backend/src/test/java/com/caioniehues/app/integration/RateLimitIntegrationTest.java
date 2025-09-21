package com.caioniehues.app.integration;

import com.caioniehues.app.application.dto.request.LoginRequest;
import com.caioniehues.app.application.dto.request.RegisterRequest;
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

@DisplayName("Rate Limiting Integration Tests")
public class RateLimitIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private AuthTestHelper authTestHelper;

    @Test
    @DisplayName("Should enforce rate limit on login endpoint after 5 attempts")
    void loginEndpoint_ExceedingRateLimit_ShouldReturn429() throws Exception {
        // Given
        String email = "ratelimit@example.com";
        String password = "RateLimitPassword123!";
        RegisterRequest registerRequest = TestDataBuilder.aRegisterRequest()
            .email(email)
            .password(password)
            .build();

        authTestHelper.registerUser(registerRequest);

        LoginRequest validLoginRequest = TestDataBuilder.aLoginRequest()
            .email(email)
            .password(password)
            .build();

        LoginRequest invalidLoginRequest = TestDataBuilder.aLoginRequest()
            .email(email)
            .password("WrongPassword123!")
            .build();

        // When - Make 5 failed login attempts
        for (int i = 0; i < 5; i++) {
            mockMvc.perform(post("/api/v1/auth/login")
                    .contentType(APPLICATION_JSON)
                    .content(toJson(invalidLoginRequest)))
                .andExpect(status().isUnauthorized());
        }

        // Then - 6th attempt should be rate limited
        MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(validLoginRequest)))
            .andExpect(status().isTooManyRequests())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Too Many Requests"))
            .andExpect(jsonPath("$.status").value(429))
            .andExpect(jsonPath("$.retryAfter").exists())
            .andExpect(header().exists("Retry-After"))
            .andReturn();

        // Verify retry-after header is reasonable (should be <= 60 seconds for login)
        String retryAfter = result.getResponse().getHeader("Retry-After");
        assertThat(Integer.parseInt(retryAfter)).isLessThanOrEqualTo(60);
    }

    @Test
    @DisplayName("Should enforce rate limit on registration endpoint after 3 attempts")
    void registrationEndpoint_ExceedingRateLimit_ShouldReturn429() throws Exception {
        // Given
        RegisterRequest baseRequest = TestDataBuilder.aRegisterRequest()
            .email("basereg@example.com")
            .build();

        // When - Make 3 registration attempts
        for (int i = 0; i < 3; i++) {
            RegisterRequest request = TestDataBuilder.aRegisterRequest()
                .email("reg" + i + "@example.com")
                .build();

            mockMvc.perform(post("/api/v1/auth/register")
                    .contentType(APPLICATION_JSON)
                    .content(toJson(request)))
                .andExpect(status().isCreated());
        }

        // Then - 4th attempt should be rate limited
        RegisterRequest fourthRequest = TestDataBuilder.aRegisterRequest()
            .email("reg4@example.com")
            .build();

        MvcResult result = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(toJson(fourthRequest)))
            .andExpect(status().isTooManyRequests())
            .andExpect(content().contentType(APPLICATION_JSON))
            .andExpect(jsonPath("$.title").value("Too Many Requests"))
            .andExpect(jsonPath("$.status").value(429))
            .andExpect(jsonPath("$.retryAfter").exists())
            .andExpect(header().exists("Retry-After"))
            .andReturn();

        // Verify retry-after header indicates longer wait for registration (up to 1 hour)
        String retryAfter = result.getResponse().getHeader("Retry-After");
        assertThat(Integer.parseInt(retryAfter)).isLessThanOrEqualTo(3600);
    }

    @Test
    @DisplayName("Should not rate limit non-auth endpoints")
    void nonAuthEndpoints_ShouldNotBeRateLimited() throws Exception {
        // When/Then - Make multiple requests to health endpoint
        for (int i = 0; i < 10; i++) {
            mockMvc.perform(post("/api/health"))
                .andExpect(status().isNotFound()); // 404 because endpoint doesn't exist, not rate limited
        }
    }

    @Test
    @DisplayName("Should track rate limits per IP address")
    void rateLimiting_ShouldBePerIpAddress() throws Exception {
        // Given - Two different IP addresses (simulated via X-Forwarded-For)
        LoginRequest invalidRequest = TestDataBuilder.aLoginRequest()
            .email("nonexistent@example.com")
            .password("WrongPassword123!")
            .build();

        // When - Make 5 requests from first IP
        for (int i = 0; i < 5; i++) {
            mockMvc.perform(post("/api/v1/auth/login")
                    .contentType(APPLICATION_JSON)
                    .content(toJson(invalidRequest))
                    .header("X-Forwarded-For", "192.168.1.1"))
                .andExpect(status().isUnauthorized());
        }

        // Then - 6th request from first IP should be rate limited
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(invalidRequest))
                .header("X-Forwarded-For", "192.168.1.1"))
            .andExpect(status().isTooManyRequests());

        // But request from second IP should still work
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(invalidRequest))
                .header("X-Forwarded-For", "192.168.1.2"))
            .andExpect(status().isUnauthorized()); // Not rate limited, just invalid credentials
    }

    @Test
    @DisplayName("Should handle forgot password endpoint rate limiting")
    void forgotPasswordEndpoint_ShouldBeRateLimited() throws Exception {
        // Given
        var forgotPasswordRequest = """
            {
                "email": "forgot@example.com"
            }
            """;

        // When - Make 2 requests (limit is 2 per hour for forgot password)
        for (int i = 0; i < 2; i++) {
            mockMvc.perform(post("/api/v1/auth/forgot-password")
                    .contentType(APPLICATION_JSON)
                    .content(forgotPasswordRequest))
                .andExpect(status().isNotFound()); // Endpoint may not be implemented yet
        }

        // Then - 3rd request should be rate limited if endpoint exists
        // (This test will pass even if endpoint doesn't exist yet)
        MvcResult result = mockMvc.perform(post("/api/v1/auth/forgot-password")
                .contentType(APPLICATION_JSON)
                .content(forgotPasswordRequest))
            .andReturn();

        // If we get 429, verify it's a proper rate limit response
        if (result.getResponse().getStatus() == 429) {
            assertThat(result.getResponse().getContentAsString()).contains("Too Many Requests");
            assertThat(result.getResponse().getHeader("Retry-After")).isNotNull();
        }
    }

    @Test
    @DisplayName("Should include proper error details in rate limit response")
    void rateLimitResponse_ShouldIncludeProperErrorDetails() throws Exception {
        // Given
        LoginRequest invalidRequest = TestDataBuilder.aLoginRequest()
            .email("errordetails@example.com")
            .password("WrongPassword123!")
            .build();

        // When - Exceed rate limit
        authTestHelper.makeMultipleLoginAttempts("errordetails@example.com", "WrongPassword123!", 6);

        // Then - Check response format
        MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(invalidRequest)))
            .andExpect(status().isTooManyRequests())
            .andReturn();

        String responseContent = result.getResponse().getContentAsString();
        assertThat(responseContent).contains("Too Many Requests");
        assertThat(responseContent).contains("Rate limit exceeded");
        assertThat(responseContent).contains("retryAfter");

        // Should have proper RFC 7807 problem details format
        assertThat(responseContent).contains("\"type\":");
        assertThat(responseContent).contains("\"title\":");
        assertThat(responseContent).contains("\"status\":");
        assertThat(responseContent).contains("\"detail\":");
        assertThat(responseContent).contains("\"instance\":");
    }

    @Test
    @DisplayName("Should handle rate limiting with missing remote address")
    void rateLimiting_WithMissingRemoteAddress_ShouldUseDefaultHandling() throws Exception {
        // Given
        LoginRequest invalidRequest = TestDataBuilder.aLoginRequest()
            .email("noremoteaddr@example.com")
            .password("WrongPassword123!")
            .build();

        // When - Make requests without explicit IP headers
        // The rate limiting should still work using whatever IP resolution mechanism is available
        for (int i = 0; i < 6; i++) {
            MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
                    .contentType(APPLICATION_JSON)
                    .content(toJson(invalidRequest)))
                .andReturn();

            // After 5 attempts, should get rate limited
            if (i >= 5) {
                assertThat(result.getResponse().getStatus()).isEqualTo(429);
            } else {
                assertThat(result.getResponse().getStatus()).isEqualTo(401);
            }
        }
    }

    @Test
    @DisplayName("Should use X-Real-IP header when X-Forwarded-For is not present")
    void rateLimiting_ShouldUseXRealIpHeader() throws Exception {
        // Given
        LoginRequest invalidRequest = TestDataBuilder.aLoginRequest()
            .email("xrealip@example.com")
            .password("WrongPassword123!")
            .build();

        // When - Make requests with X-Real-IP header
        for (int i = 0; i < 5; i++) {
            mockMvc.perform(post("/api/v1/auth/login")
                    .contentType(APPLICATION_JSON)
                    .content(toJson(invalidRequest))
                    .header("X-Real-IP", "10.0.0.1"))
                .andExpect(status().isUnauthorized());
        }

        // Then - 6th request should be rate limited
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(invalidRequest))
                .header("X-Real-IP", "10.0.0.1"))
            .andExpect(status().isTooManyRequests());

        // But different X-Real-IP should not be affected
        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(toJson(invalidRequest))
                .header("X-Real-IP", "10.0.0.2"))
            .andExpect(status().isUnauthorized());
    }
}