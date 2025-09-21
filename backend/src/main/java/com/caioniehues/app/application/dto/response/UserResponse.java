package com.caioniehues.app.application.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.Set;
import java.util.UUID;

/**
 * Data Transfer Object for user responses.
 * Represents user information sent to clients, excluding sensitive data like passwords.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record UserResponse(

    UUID id,

    String email,

    String username,

    String fullName,

    String phoneNumber,

    boolean enabled,

    Set<RoleResponse> roles,

    Instant createdAt,

    Instant lastLoginAt
) {
    /**
     * Constructor without timestamps (for simplified responses)
     */
    public UserResponse(UUID id, String email, String username, String fullName,
                       String phoneNumber, boolean enabled, Set<RoleResponse> roles) {
        this(id, email, username, fullName, phoneNumber, enabled, roles, null, null);
    }

    /**
     * Nested record for role information
     */
    public record RoleResponse(
        String name,
        String description
    ) {}
}