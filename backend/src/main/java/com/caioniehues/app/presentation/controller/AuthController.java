package com.caioniehues.app.presentation.controller;

import com.caioniehues.app.application.dto.request.LoginRequest;
import com.caioniehues.app.application.dto.request.RefreshRequest;
import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.application.dto.response.TokenResponse;
import com.caioniehues.app.application.dto.response.UserResponse;
import com.caioniehues.app.application.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * REST controller for authentication endpoints.
 * Handles user registration, login, logout, and token refresh.
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Authentication", description = "Authentication management endpoints")
public class AuthController {

    private final AuthService authService;

    /**
     * Register a new user account.
     *
     * @param request Registration details including email, name, and password
     * @return Created user information
     */
    @PostMapping("/register")
    @Operation(summary = "Register new user", description = "Create a new user account with the provided details")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "201",
            description = "User successfully registered",
            content = @Content(schema = @Schema(implementation = UserResponse.class))
        ),
        @ApiResponse(
            responseCode = "400",
            description = "Invalid input data",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "409",
            description = "Email already exists",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
        log.info("Registration request received for email: {}", request.getTrimmedEmail());

        UserResponse response = authService.register(request);

        log.info("User successfully registered with ID: {}", response.id());

        return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(response);
    }

    /**
     * Authenticate user and receive JWT tokens.
     *
     * @param request Login credentials
     * @return JWT tokens for authentication
     */
    @PostMapping("/login")
    @Operation(summary = "User login", description = "Authenticate user and receive JWT tokens")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Login successful",
            content = @Content(schema = @Schema(implementation = TokenResponse.class))
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Invalid credentials",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        ),
        @ApiResponse(
            responseCode = "403",
            description = "Account locked",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        log.info("Login request received for email: {}", request.getTrimmedEmail());

        TokenResponse response = authService.login(request);

        log.info("User successfully authenticated: {}", request.getTrimmedEmail());

        return ResponseEntity.ok(response);
    }

    /**
     * Refresh authentication tokens.
     *
     * @param request Refresh token request
     * @return New JWT tokens
     */
    @PostMapping("/refresh")
    @Operation(summary = "Refresh tokens", description = "Exchange refresh token for new token pair")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "Tokens refreshed successfully",
            content = @Content(schema = @Schema(implementation = TokenResponse.class))
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Invalid refresh token",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<TokenResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        log.info("Token refresh request received");

        TokenResponse response = authService.refreshToken(request);

        log.info("Tokens successfully refreshed");

        return ResponseEntity.ok(response);
    }

    /**
     * Logout user by invalidating tokens.
     *
     * @param authHeader Authorization header with bearer token
     * @return No content on successful logout
     */
    @PostMapping("/logout")
    @Operation(summary = "User logout", description = "Invalidate user tokens and end session")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "204",
            description = "Logout successful"
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Invalid token",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<Void> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        log.info("Logout request received");

        authService.logout(authHeader);

        log.info("User successfully logged out");

        return ResponseEntity.noContent().build();
    }

    /**
     * Get current authenticated user information.
     *
     * @param authHeader Authorization header with bearer token
     * @return Current user information
     */
    @GetMapping("/me")
    @Operation(summary = "Get current user", description = "Retrieve information about the authenticated user")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "User information retrieved",
            content = @Content(schema = @Schema(implementation = UserResponse.class))
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Unauthorized",
            content = @Content(schema = @Schema(implementation = ErrorResponse.class))
        )
    })
    public ResponseEntity<UserResponse> getCurrentUser(@RequestHeader("Authorization") String authHeader) {
        log.info("Get current user request received");

        var user = authService.getCurrentUser(authHeader);

        // Need UserMapper to convert User to UserResponse
        // For now, create a simple response
        UserResponse response = new UserResponse(
            user.getId(),
            user.getEmail(),
            user.getUsername(),
            user.getFullName(),
            null, // phoneNumber
            user.isEnabled(),
            null  // avatarUrl
        );

        return ResponseEntity.ok(response);
    }

    /**
     * Error response structure for API documentation
     */
    private record ErrorResponse(
        String message,
        String timestamp,
        String path,
        int status
    ) {}
}