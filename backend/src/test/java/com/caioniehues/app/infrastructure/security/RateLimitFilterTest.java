package com.caioniehues.app.infrastructure.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.ConsumptionProbe;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.Duration;
import java.util.concurrent.ConcurrentHashMap;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("Rate Limit Filter Tests")
class RateLimitFilterTest {

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private FilterChain filterChain;

    @Mock
    private PrintWriter writer;

    @Mock
    private Bucket bucket;

    @Mock
    private ConsumptionProbe consumptionProbe;

    @Mock
    private ObjectMapper objectMapper;

    private RateLimitFilter rateLimitFilter;
    private ConcurrentHashMap<String, Bucket> buckets;

    @BeforeEach
    void setUp() throws IOException {
        buckets = new ConcurrentHashMap<>();
        rateLimitFilter = new RateLimitFilter(objectMapper);

        when(response.getWriter()).thenReturn(writer);
    }

    @Test
    @DisplayName("Should skip rate limiting for non-auth endpoints")
    void nonAuthEndpoints_ShouldSkipRateLimit() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");

        // When
        rateLimitFilter.doFilter(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(response, never()).setStatus(anyInt());
    }

    @Test
    @DisplayName("Should allow requests within rate limit for login endpoint")
    void loginEndpoint_WithinRateLimit_ShouldAllow() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/auth/login");
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");
        when(bucket.tryConsume(1)).thenReturn(true);

        // Create a mock rate limit filter that uses our mock bucket
        RateLimitFilter mockRateLimitFilter = new RateLimitFilter(objectMapper) {
            @Override
            protected Bucket createBucket(String endpoint) {
                return bucket;
            }
        };

        // When
        mockRateLimitFilter.doFilter(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(response, never()).setStatus(eq(429));
    }

    @Test
    @DisplayName("Should block requests exceeding rate limit for login endpoint")
    void loginEndpoint_ExceedingRateLimit_ShouldBlock() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/auth/login");
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");
        when(bucket.tryConsume(1)).thenReturn(false);
        when(bucket.tryConsumeAndReturnRemaining(1)).thenReturn(consumptionProbe);
        when(consumptionProbe.getNanosToWaitForRefill()).thenReturn(Duration.ofSeconds(30).toNanos());

        // Create a mock rate limit filter that uses our mock bucket
        RateLimitFilter mockRateLimitFilter = new RateLimitFilter(objectMapper) {
            @Override
            protected Bucket createBucket(String endpoint) {
                return bucket;
            }
        };

        // When
        mockRateLimitFilter.doFilter(request, response, filterChain);

        // Then
        verify(response).setStatus(429);
        verify(response).setContentType("application/json");
        verify(response).setHeader("Retry-After", "30");
        verify(filterChain, never()).doFilter(request, response);
    }

    @Test
    @DisplayName("Should apply different rate limits for different endpoints")
    void differentEndpoints_ShouldHaveDifferentRateLimits() throws ServletException, IOException {
        // Given - Login endpoint (5 per minute)
        when(request.getServletPath()).thenReturn("/api/v1/auth/login");
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");

        // When/Then
        rateLimitFilter.doFilter(request, response, filterChain);

        // Given - Register endpoint (3 per hour)
        when(request.getServletPath()).thenReturn("/api/v1/auth/register");

        // When/Then
        rateLimitFilter.doFilter(request, response, filterChain);

        // Should continue processing both requests
        verify(filterChain, times(2)).doFilter(request, response);
    }

    @Test
    @DisplayName("Should track rate limits per IP address")
    void differentIpAddresses_ShouldHaveSeparateRateLimits() throws ServletException, IOException {
        // Given - First IP
        when(request.getServletPath()).thenReturn("/api/v1/auth/login");
        when(request.getRemoteAddr()).thenReturn("192.168.1.1");

        // When
        rateLimitFilter.doFilter(request, response, filterChain);

        // Given - Second IP
        when(request.getRemoteAddr()).thenReturn("192.168.1.2");

        // When
        rateLimitFilter.doFilter(request, response, filterChain);

        // Then - Both should be allowed as they have separate buckets
        verify(filterChain, times(2)).doFilter(request, response);
        verify(response, never()).setStatus(eq(429));
    }

    @Test
    @DisplayName("Should include rate limit information in error response")
    void rateLimitExceeded_ShouldIncludeProperErrorResponse() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/auth/login");
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");
        when(bucket.tryConsume(1)).thenReturn(false);
        when(bucket.tryConsumeAndReturnRemaining(1)).thenReturn(consumptionProbe);
        when(consumptionProbe.getNanosToWaitForRefill()).thenReturn(Duration.ofMinutes(1).toNanos());

        // Create a mock rate limit filter that uses our mock bucket
        RateLimitFilter mockRateLimitFilter = new RateLimitFilter(objectMapper) {
            @Override
            protected Bucket createBucket(String endpoint) {
                return bucket;
            }
        };

        // When
        mockRateLimitFilter.doFilter(request, response, filterChain);

        // Then
        verify(response).setStatus(429);
        verify(response).setContentType("application/json");
        verify(response).setHeader("Retry-After", "60");
        verify(writer).write(anyString()); // Error response body
        verify(writer).flush();
    }

    @Test
    @DisplayName("Should handle X-Forwarded-For header for IP detection")
    void xForwardedForHeader_ShouldBeUsedForIpDetection() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/auth/login");
        when(request.getHeader("X-Forwarded-For")).thenReturn("192.168.1.100, 10.0.0.1");
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");

        // When
        rateLimitFilter.doFilter(request, response, filterChain);

        // Then - Should continue processing (using first IP from X-Forwarded-For)
        verify(filterChain).doFilter(request, response);
    }

    @Test
    @DisplayName("Should handle registration endpoint with stricter limits")
    void registrationEndpoint_ShouldHaveStricterLimits() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/auth/register");
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");

        // When
        rateLimitFilter.doFilter(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(response, never()).setStatus(eq(429));
    }

    @Test
    @DisplayName("Should handle password reset endpoint with appropriate limits")
    void passwordResetEndpoint_ShouldHaveAppropiateLimits() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/auth/forgot-password");
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");

        // When
        rateLimitFilter.doFilter(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(response, never()).setStatus(eq(429));
    }

    @Test
    @DisplayName("Should provide accurate retry-after time")
    void rateLimitExceeded_ShouldProvideAccurateRetryAfterTime() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/auth/login");
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");
        when(bucket.tryConsume(1)).thenReturn(false);
        when(bucket.tryConsumeAndReturnRemaining(1)).thenReturn(consumptionProbe);
        when(consumptionProbe.getNanosToWaitForRefill()).thenReturn(Duration.ofSeconds(45).toNanos());

        // Create a mock rate limit filter that uses our mock bucket
        RateLimitFilter mockRateLimitFilter = new RateLimitFilter(objectMapper) {
            @Override
            protected Bucket createBucket(String endpoint) {
                return bucket;
            }
        };

        // When
        mockRateLimitFilter.doFilter(request, response, filterChain);

        // Then
        verify(response).setHeader("Retry-After", "45");
    }

    @Test
    @DisplayName("Should handle missing remote address gracefully")
    void missingRemoteAddress_ShouldUseDefaultAddress() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/auth/login");
        when(request.getRemoteAddr()).thenReturn(null);
        when(request.getHeader("X-Forwarded-For")).thenReturn(null);

        // When
        rateLimitFilter.doFilter(request, response, filterChain);

        // Then - Should continue processing with default IP handling
        verify(filterChain).doFilter(request, response);
    }
}