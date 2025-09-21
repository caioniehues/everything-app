package com.caioniehues.app.infrastructure.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.Map;

@Component
public class SecurityAuditLogger {

    private static final Logger securityLogger = LoggerFactory.getLogger("SECURITY_AUDIT");
    private static final Logger logger = LoggerFactory.getLogger(SecurityAuditLogger.class);

    public void logSuccessfulLogin(String username, String ipAddress, String userAgent) {
        logSecurityEvent("LOGIN_SUCCESS", username, ipAddress, userAgent, Map.of(
            "event", "successful_login",
            "username", username,
            "ip_address", ipAddress,
            "user_agent", userAgent != null ? userAgent : "unknown"
        ));
    }

    public void logFailedLogin(String username, String ipAddress, String userAgent, String reason) {
        logSecurityEvent("LOGIN_FAILURE", username, ipAddress, userAgent, Map.of(
            "event", "failed_login",
            "username", username != null ? username : "unknown",
            "ip_address", ipAddress,
            "user_agent", userAgent != null ? userAgent : "unknown",
            "failure_reason", reason
        ));
    }

    public void logTokenRefresh(String username, String ipAddress, String userAgent) {
        logSecurityEvent("TOKEN_REFRESH", username, ipAddress, userAgent, Map.of(
            "event", "token_refresh",
            "username", username,
            "ip_address", ipAddress,
            "user_agent", userAgent != null ? userAgent : "unknown"
        ));
    }

    public void logLogout(String username, String ipAddress, String userAgent) {
        logSecurityEvent("LOGOUT", username, ipAddress, userAgent, Map.of(
            "event", "logout",
            "username", username,
            "ip_address", ipAddress,
            "user_agent", userAgent != null ? userAgent : "unknown"
        ));
    }

    public void logUnauthorizedAccess(String ipAddress, String requestUri, String userAgent) {
        logSecurityEvent("UNAUTHORIZED_ACCESS", null, ipAddress, userAgent, Map.of(
            "event", "unauthorized_access",
            "ip_address", ipAddress,
            "request_uri", requestUri,
            "user_agent", userAgent != null ? userAgent : "unknown"
        ));
    }

    public void logAccessDenied(String username, String ipAddress, String requestUri, String userAgent) {
        logSecurityEvent("ACCESS_DENIED", username, ipAddress, userAgent, Map.of(
            "event", "access_denied",
            "username", username != null ? username : "unknown",
            "ip_address", ipAddress,
            "request_uri", requestUri,
            "user_agent", userAgent != null ? userAgent : "unknown"
        ));
    }

    public void logRateLimitExceeded(String ipAddress, String endpoint, String userAgent) {
        logSecurityEvent("RATE_LIMIT_EXCEEDED", null, ipAddress, userAgent, Map.of(
            "event", "rate_limit_exceeded",
            "ip_address", ipAddress,
            "endpoint", endpoint,
            "user_agent", userAgent != null ? userAgent : "unknown"
        ));
    }

    public void logSuspiciousActivity(String username, String ipAddress, String activity, String details) {
        logSecurityEvent("SUSPICIOUS_ACTIVITY", username, ipAddress, null, Map.of(
            "event", "suspicious_activity",
            "username", username != null ? username : "unknown",
            "ip_address", ipAddress,
            "activity", activity,
            "details", details
        ));
    }

    public void logPasswordReset(String username, String ipAddress, String userAgent) {
        logSecurityEvent("PASSWORD_RESET", username, ipAddress, userAgent, Map.of(
            "event", "password_reset",
            "username", username,
            "ip_address", ipAddress,
            "user_agent", userAgent != null ? userAgent : "unknown"
        ));
    }

    public void logAccountLocked(String username, String ipAddress, String reason) {
        logSecurityEvent("ACCOUNT_LOCKED", username, ipAddress, null, Map.of(
            "event", "account_locked",
            "username", username,
            "ip_address", ipAddress,
            "reason", reason
        ));
    }

    public void logRegistration(String username, String ipAddress, String userAgent) {
        logSecurityEvent("USER_REGISTRATION", username, ipAddress, userAgent, Map.of(
            "event", "user_registration",
            "username", username,
            "ip_address", ipAddress,
            "user_agent", userAgent != null ? userAgent : "unknown"
        ));
    }

    public void logEmailVerification(String username, String ipAddress) {
        logSecurityEvent("EMAIL_VERIFICATION", username, ipAddress, null, Map.of(
            "event", "email_verification",
            "username", username,
            "ip_address", ipAddress
        ));
    }

    private void logSecurityEvent(String eventType, String username, String ipAddress, String userAgent, Map<String, String> details) {
        try {
            // Set MDC context for structured logging
            MDC.put("event_type", eventType);
            MDC.put("timestamp", Instant.now().toString());
            MDC.put("ip_address", ipAddress != null ? ipAddress : "unknown");

            if (username != null) {
                MDC.put("username", username);
            }

            if (userAgent != null) {
                MDC.put("user_agent", userAgent);
            }

            // Add all details to MDC
            details.forEach(MDC::put);

            // Log the security event
            securityLogger.info("Security Event: {} - IP: {} - User: {} - Details: {}",
                eventType,
                ipAddress != null ? ipAddress : "unknown",
                username != null ? username : "anonymous",
                details.toString());

        } catch (Exception e) {
            logger.error("Failed to log security event: {}", eventType, e);
        } finally {
            // Always clear MDC to prevent context leakage
            MDC.clear();
        }
    }
}