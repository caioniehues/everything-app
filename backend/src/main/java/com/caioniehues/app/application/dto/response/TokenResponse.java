package com.caioniehues.app.application.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

/**
 * Response containing authentication tokens.
 *
 * @param accessToken JWT access token for API authentication
 * @param refreshToken JWT refresh token for obtaining new access tokens
 * @param tokenType Type of token (always "Bearer")
 * @param expiresIn Access token expiration time in seconds
 */
@Schema(description = "Authentication token response")
public record TokenResponse(
    @JsonProperty("access_token")
    @Schema(
        description = "JWT access token for API authentication",
        example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    )
    String accessToken,

    @JsonProperty("refresh_token")
    @Schema(
        description = "JWT refresh token for obtaining new access tokens",
        example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    )
    String refreshToken,

    @JsonProperty("token_type")
    @Schema(
        description = "Type of token",
        example = "Bearer"
    )
    String tokenType,

    @JsonProperty("expires_in")
    @Schema(
        description = "Access token expiration time in seconds",
        example = "900"
    )
    Integer expiresIn
) {
    /**
     * Create a standard token response with default values.
     *
     * @param accessToken The access token
     * @param refreshToken The refresh token
     * @return TokenResponse with Bearer type and 900 seconds expiry
     */
    public static TokenResponse of(String accessToken, String refreshToken) {
        return new TokenResponse(accessToken, refreshToken, "Bearer", 900);
    }
}