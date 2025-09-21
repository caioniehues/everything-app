package com.caioniehues.app.application.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * Login request containing user credentials.
 *
 * @param email User's email address
 * @param password User's password
 */
@Schema(description = "Login request with user credentials")
public record LoginRequest(
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be a valid email address")
    @Schema(description = "User's email address", example = "john.doe@example.com", requiredMode = Schema.RequiredMode.REQUIRED)
    String email,

    @NotBlank(message = "Password is required")
    @Schema(description = "User's password", example = "SecureP@ssw0rd!42", requiredMode = Schema.RequiredMode.REQUIRED)
    String password
) {
    /**
     * Get trimmed email for consistency.
     *
     * @return Trimmed email address
     */
    public String getTrimmedEmail() {
        return email != null ? email.trim().toLowerCase() : null;
    }
}