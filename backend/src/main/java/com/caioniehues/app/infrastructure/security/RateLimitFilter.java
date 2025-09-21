package com.caioniehues.app.infrastructure.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.ConsumptionProbe;
import io.github.bucket4j.Refill;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimitFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(RateLimitFilter.class);

    private static final Set<String> RATE_LIMITED_ENDPOINTS = Set.of(
        "/api/v1/auth/login",
        "/api/v1/auth/register",
        "/api/v1/auth/forgot-password"
    );

    private final Map<String, Bucket> bucketCache;
    private final ObjectMapper objectMapper;

    public RateLimitFilter(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.bucketCache = new ConcurrentHashMap<>();
    }

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        String servletPath = request.getServletPath();

        if (!isRateLimitedEndpoint(servletPath)) {
            filterChain.doFilter(request, response);
            return;
        }

        String clientIp = getClientIpAddress(request);
        String bucketKey = createBucketKey(clientIp, servletPath);

        Bucket bucket = bucketCache.computeIfAbsent(bucketKey, key -> createBucket(servletPath));

        ConsumptionProbe probe = bucket.tryConsumeAndReturnRemaining(1);

        if (probe.isConsumed()) {
            logger.debug("Rate limit check passed for IP: {} on endpoint: {}", clientIp, servletPath);
            filterChain.doFilter(request, response);
        } else {
            logger.warn("Rate limit exceeded for IP: {} on endpoint: {}", clientIp, servletPath);
            handleRateLimitExceeded(request, response, probe);
        }
    }

    protected Bucket createBucket(String endpoint) {
        return Bucket.builder()
            .addLimit(getBandwidth(endpoint))
            .build();
    }

    private boolean isRateLimitedEndpoint(String servletPath) {
        return RATE_LIMITED_ENDPOINTS.stream()
            .anyMatch(endpoint -> servletPath.startsWith(endpoint));
    }

    private String createBucketKey(String clientIp, String endpoint) {
        return clientIp + ":" + endpoint;
    }

    private Bandwidth getBandwidth(String endpoint) {
        return switch (endpoint) {
            case "/api/v1/auth/login" ->
                Bandwidth.classic(5, Refill.intervally(5, Duration.ofMinutes(1)));
            case "/api/v1/auth/register" ->
                Bandwidth.classic(3, Refill.intervally(3, Duration.ofHours(1)));
            case "/api/v1/auth/forgot-password" ->
                Bandwidth.classic(2, Refill.intervally(2, Duration.ofHours(1)));
            default ->
                Bandwidth.classic(10, Refill.intervally(10, Duration.ofMinutes(1)));
        };
    }

    private void handleRateLimitExceeded(
            HttpServletRequest request,
            HttpServletResponse response,
            ConsumptionProbe probe) throws IOException {

        response.setStatus(429);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");

        long waitForRefillNanos = probe.getNanosToWaitForRefill();
        long retryAfterSeconds = Duration.ofNanos(waitForRefillNanos).getSeconds();

        response.setHeader("Retry-After", String.valueOf(retryAfterSeconds));

        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("type", "about:blank");
        errorResponse.put("title", "Too Many Requests");
        errorResponse.put("status", 429);
        errorResponse.put("detail", "Rate limit exceeded. Please try again later.");
        errorResponse.put("instance", request.getRequestURI());
        errorResponse.put("timestamp", Instant.now().toString());
        errorResponse.put("retryAfter", retryAfterSeconds);

        String jsonResponse = objectMapper.writeValueAsString(errorResponse);
        response.getWriter().write(jsonResponse);
        response.getWriter().flush();
    }

    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }

        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }

        String remoteAddr = request.getRemoteAddr();
        return remoteAddr != null ? remoteAddr : "unknown";
    }
}