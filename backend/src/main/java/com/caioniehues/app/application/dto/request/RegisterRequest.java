package com.caioniehues.app.application.dto.request;

import com.caioniehues.app.application.validation.ValidPassword;
import jakarta.validation.constraints.*;

/**
 * Data Transfer Object for user registration requests.
 * Contains all necessary information to create a new user account.
 */
public record RegisterRequest(

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    @Size(max = 100, message = "Email must not exceed 100 characters")
    String email,

    @NotBlank(message = "First name is required")
    @Size(min = 1, max = 50, message = "First name must be between 1 and 50 characters")
    @Pattern(regexp = "^[a-zA-Z\\s'-]+$", message = "First name can only contain letters, spaces, hyphens and apostrophes")
    String firstName,

    @NotBlank(message = "Last name is required")
    @Size(min = 1, max = 50, message = "Last name must be between 1 and 50 characters")
    @Pattern(regexp = "^[a-zA-Z\\s'-]+$", message = "Last name can only contain letters, spaces, hyphens and apostrophes")
    String lastName,

    @NotBlank(message = "Password is required")
    @ValidPassword  // Custom validation for password complexity
    String password,

    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Phone number must be in E.164 format")
    String phoneNumber
) {
    /**
     * Get the full name by combining first and last names
     */
    public String getFullName() {
        return String.format("%s %s", firstName.trim(), lastName.trim()).trim();
    }

    /**
     * Get trimmed email for consistency
     */
    public String getTrimmedEmail() {
        return email != null ? email.trim().toLowerCase() : null;
    }
}