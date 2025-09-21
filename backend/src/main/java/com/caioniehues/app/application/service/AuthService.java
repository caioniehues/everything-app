package com.caioniehues.app.application.service;

import com.caioniehues.app.application.dto.request.LoginRequest;
import com.caioniehues.app.application.dto.request.RefreshRequest;
import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.application.dto.response.TokenResponse;
import com.caioniehues.app.application.dto.response.UserResponse;
import com.caioniehues.app.application.exception.AccountLockedException;
import com.caioniehues.app.application.exception.DuplicateEmailException;
import com.caioniehues.app.application.exception.InvalidCredentialsException;
import com.caioniehues.app.application.exception.InvalidRefreshTokenException;
import com.caioniehues.app.application.mapper.UserMapper;
import com.caioniehues.app.domain.user.RefreshToken;
import com.caioniehues.app.domain.user.Role;
import com.caioniehues.app.domain.user.TokenBlacklist;
import com.caioniehues.app.domain.user.User;
import com.caioniehues.app.infrastructure.persistence.RefreshTokenRepository;
import com.caioniehues.app.infrastructure.persistence.RoleRepository;
import com.caioniehues.app.infrastructure.persistence.TokenBlacklistRepository;
import com.caioniehues.app.infrastructure.persistence.UserRepository;
import com.caioniehues.app.infrastructure.security.JwtService;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashSet;
import java.util.List;

/**
 * Service responsible for authentication operations.
 * Handles user registration, login, logout, and token management.
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final TokenBlacklistRepository tokenBlacklistRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;

    private static final String DEFAULT_ROLE_NAME = "USER";

    /**
     * Register a new user with the provided details.
     *
     * @param request Registration request containing user details
     * @return UserResponse with created user information
     * @throws DuplicateEmailException if email already exists
     */
    public UserResponse register(RegisterRequest request) {
        log.info("Processing registration request for email: {}", request.getTrimmedEmail());

        // Validate email uniqueness
        validateEmailUniqueness(request.getTrimmedEmail());

        // Build the new user entity
        User newUser = buildUserFromRequest(request);

        // Save the user
        User savedUser = userRepository.save(newUser);
        log.info("Successfully registered user with ID: {} and email: {}",
                savedUser.getId(), savedUser.getEmail());

        // Log registration event for audit
        logRegistrationEvent(savedUser);

        // Return the response DTO
        return userMapper.toResponse(savedUser);
    }

    /**
     * Validate that the email is not already in use
     */
    private void validateEmailUniqueness(String email) {
        if (userRepository.existsByEmail(email)) {
            log.warn("Registration attempt with duplicate email: {}", email);
            throw DuplicateEmailException.forEmail(email);
        }

        // Also check username since we use email as username
        if (userRepository.existsByUsername(email)) {
            log.warn("Registration attempt with email matching existing username: {}", email);
            throw DuplicateEmailException.forEmail(email);
        }
    }

    /**
     * Build a User entity from the registration request
     */
    private User buildUserFromRequest(RegisterRequest request) {
        // Hash the password with BCrypt
        String hashedPassword = passwordEncoder.encode(request.password());

        // Build the user
        User user = User.builder()
            .username(request.getTrimmedEmail())  // Use email as username
            .email(request.getTrimmedEmail())
            .passwordHash(hashedPassword)
            .fullName(request.getFullName())
            .enabled(true)  // Enable account immediately
            .roles(new HashSet<>())
            .build();

        // Assign default role
        assignDefaultRole(user);

        return user;
    }

    /**
     * Assign the default USER role to the new user
     */
    private void assignDefaultRole(User user) {
        roleRepository.findByName(DEFAULT_ROLE_NAME)
            .ifPresentOrElse(
                role -> {
                    user.addRole(role);
                    log.debug("Assigned default role '{}' to user", DEFAULT_ROLE_NAME);
                },
                () -> log.warn("Default role '{}' not found. User created without role.", DEFAULT_ROLE_NAME)
            );
    }

    /**
     * Log registration event for audit purposes
     */
    private void logRegistrationEvent(User user) {
        // In a real application, this would write to an audit log table or service
        log.info("AUDIT: New user registration - ID: {}, Email: {}, Username: {}, Timestamp: {}",
                user.getId(),
                user.getEmail(),
                user.getUsername(),
                user.getCreatedAt());
    }

    /**
     * Authenticate user and generate JWT tokens.
     *
     * @param request Login request with credentials
     * @return TokenResponse containing access and refresh tokens
     * @throws InvalidCredentialsException if credentials are invalid
     * @throws AccountLockedException if account is locked
     */
    public TokenResponse login(LoginRequest request) {
        log.info("Processing login request for email: {}", request.getTrimmedEmail());

        try {
            // Authenticate using Spring Security
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                    request.getTrimmedEmail(),
                    request.password()
                )
            );

            User user = (User) authentication.getPrincipal();

            // Invalidate any existing refresh tokens for this user
            invalidateExistingRefreshTokens(user);

            // Generate new tokens
            String accessToken = jwtService.generateAccessToken(user);
            String refreshToken = jwtService.generateRefreshToken(user);

            // Save refresh token to database
            saveRefreshToken(refreshToken, user);

            log.info("Successful login for user: {}", user.getEmail());
            logLoginEvent(user, true);

            return TokenResponse.of(accessToken, refreshToken);

        } catch (BadCredentialsException ex) {
            log.warn("Failed login attempt for email: {}", request.getTrimmedEmail());
            logLoginEvent(request.getTrimmedEmail(), false);
            throw InvalidCredentialsException.defaultMessage();
        } catch (LockedException ex) {
            log.warn("Login attempt for locked account: {}", request.getTrimmedEmail());
            throw new AccountLockedException("Account is locked", ex);
        }
    }

    /**
     * Refresh authentication tokens using a valid refresh token.
     *
     * @param request Refresh token request
     * @return New TokenResponse with rotated tokens
     * @throws InvalidRefreshTokenException if refresh token is invalid
     */
    public TokenResponse refreshToken(RefreshRequest request) {
        String refreshTokenString = request.refreshToken();

        // Extract username from token
        String username = jwtService.extractUsername(refreshTokenString);
        User user = userRepository.findByEmail(username)
            .orElseThrow(InvalidRefreshTokenException::invalid);

        // Validate refresh token
        RefreshToken refreshToken = refreshTokenRepository.findByToken(refreshTokenString)
            .orElseThrow(InvalidRefreshTokenException::invalid);

        if (refreshToken.isRevoked()) {
            log.warn("Attempt to use revoked refresh token for user: {}", username);
            throw InvalidRefreshTokenException.revoked();
        }

        if (refreshToken.getExpiresAt().isBefore(Instant.now())) {
            log.warn("Attempt to use expired refresh token for user: {}", username);
            throw InvalidRefreshTokenException.expired();
        }

        // Additional JWT validation
        if (!jwtService.validateTokenForUser(refreshTokenString, user)) {
            log.warn("Invalid refresh token signature for user: {}", username);
            throw InvalidRefreshTokenException.invalid();
        }

        // Implement token rotation - revoke old token
        refreshToken.setRevoked(true);
        refreshTokenRepository.save(refreshToken);

        // Generate new token pair
        String newAccessToken = jwtService.generateAccessToken(user);
        String newRefreshToken = jwtService.generateRefreshToken(user);

        // Save new refresh token
        saveRefreshToken(newRefreshToken, user);

        log.info("Successfully refreshed tokens for user: {}", user.getEmail());

        return TokenResponse.of(newAccessToken, newRefreshToken);
    }

    /**
     * Logout user by invalidating their tokens.
     *
     * @param authHeader Authorization header containing the access token
     */
    public void logout(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.warn("Invalid authorization header for logout");
            return;
        }

        String token = authHeader.substring(7);

        try {
            // Extract user from token
            String username = jwtService.extractUsername(token);
            User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

            // Add access token to blacklist (extract JTI first)
            String jti = jwtService.extractClaim(token, claims -> claims.getId());
            if (jti != null) {
                TokenBlacklist blacklistEntry = TokenBlacklist.builder()
                    .jti(jti)
                    .expiresAt(jwtService.extractClaim(token, Claims::getExpiration).toInstant())
                    .build();
                tokenBlacklistRepository.save(blacklistEntry);
            }

            // Revoke all refresh tokens for this user
            refreshTokenRepository.revokeAllValidTokensForUser(user.getId(), Instant.now());

            log.info("Successfully logged out user: {}", user.getEmail());
            logLogoutEvent(user);

        } catch (Exception ex) {
            log.error("Error during logout: {}", ex.getMessage());
        }
    }

    /**
     * Get current authenticated user from token.
     *
     * @param authHeader Authorization header with Bearer token
     * @return Current authenticated user
     * @throws InvalidCredentialsException if token is invalid
     */
    public User getCurrentUser(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw InvalidCredentialsException.defaultMessage();
        }

        String token = authHeader.substring(7);

        // Check if token is blacklisted by JTI
        String jti = jwtService.extractClaim(token, claims -> claims.getId());
        if (jti != null && tokenBlacklistRepository.existsByJti(jti)) {
            throw InvalidCredentialsException.defaultMessage();
        }

        String username = jwtService.extractUsername(token);
        User user = userRepository.findByEmail(username)
            .orElseThrow(InvalidCredentialsException::defaultMessage);

        if (!jwtService.validateTokenForUser(token, user)) {
            throw InvalidCredentialsException.defaultMessage();
        }

        return user;
    }

    /**
     * Invalidate all existing refresh tokens for a user.
     */
    private void invalidateExistingRefreshTokens(User user) {
        refreshTokenRepository.revokeAllValidTokensForUser(user.getId(), Instant.now());
    }

    /**
     * Save a new refresh token to the database.
     */
    private void saveRefreshToken(String tokenString, User user) {
        RefreshToken refreshToken = RefreshToken.builder()
            .token(tokenString)
            .user(user)
            .expiresAt(Instant.now().plus(7, ChronoUnit.DAYS))
            .revoked(false)
            .build();
        refreshTokenRepository.save(refreshToken);
    }

    /**
     * Log login event for audit.
     */
    private void logLoginEvent(User user, boolean success) {
        log.info("AUDIT: Login {} - User: {}, Email: {}, Timestamp: {}",
            success ? "SUCCESS" : "FAILED",
            user.getId(),
            user.getEmail(),
            Instant.now());
    }

    /**
     * Log login event with email only (for failed attempts).
     */
    private void logLoginEvent(String email, boolean success) {
        log.info("AUDIT: Login {} - Email: {}, Timestamp: {}",
            success ? "SUCCESS" : "FAILED",
            email,
            Instant.now());
    }

    /**
     * Log logout event for audit.
     */
    private void logLogoutEvent(User user) {
        log.info("AUDIT: Logout - User: {}, Email: {}, Timestamp: {}",
            user.getId(),
            user.getEmail(),
            Instant.now());
    }
}