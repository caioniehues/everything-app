package com.caioniehues.app.application.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

/**
 * Request to refresh authentication tokens.
 *
 * @param refreshToken The refresh token to exchange for new tokens
 */
@Schema(description = "Request to refresh authentication tokens")
public record RefreshRequest(
    @NotBlank(message = "Refresh token is required")
    @Schema(
        description = "The refresh token obtained during login",
        example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        requiredMode = Schema.RequiredMode.REQUIRED
    )
    String refreshToken
) {}