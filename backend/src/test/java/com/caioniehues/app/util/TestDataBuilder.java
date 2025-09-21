package com.caioniehues.app.util;

import com.caioniehues.app.application.dto.request.LoginRequest;
import com.caioniehues.app.application.dto.request.RefreshRequest;
import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.domain.user.User;

import java.time.LocalDateTime;
import java.util.UUID;

public class TestDataBuilder {

    public static class UserBuilder {
        private String email = "test@example.com";
        private String username = "test@example.com";
        private String fullName = "Test User";
        private String passwordHash = "SecurePassword123!";
        private boolean enabled = true;
        private boolean accountNonExpired = true;
        private boolean accountNonLocked = true;
        private boolean credentialsNonExpired = true;
        private LocalDateTime createdAt = LocalDateTime.now();
        private LocalDateTime updatedAt = LocalDateTime.now();

        public UserBuilder email(String email) {
            this.email = email;
            this.username = email; // Keep username and email in sync
            return this;
        }

        public UserBuilder fullName(String fullName) {
            this.fullName = fullName;
            return this;
        }

        public UserBuilder passwordHash(String passwordHash) {
            this.passwordHash = passwordHash;
            return this;
        }

        public UserBuilder enabled(boolean enabled) {
            this.enabled = enabled;
            return this;
        }

        public UserBuilder accountLocked() {
            this.accountNonLocked = false;
            return this;
        }

        public UserBuilder credentialsExpired() {
            this.credentialsNonExpired = false;
            return this;
        }

        public User build() {
            return User.builder()
                .email(email)
                .username(username)
                .fullName(fullName)
                .passwordHash(passwordHash)
                .enabled(enabled)
                .build();
        }
    }

    public static class RegisterRequestBuilder {
        private String email = "test@example.com";
        private String firstName = "Test";
        private String lastName = "User";
        private String password = "SecurePass@2024!";
        private String phoneNumber = "+1234567890";

        public RegisterRequestBuilder email(String email) {
            this.email = email;
            return this;
        }

        public RegisterRequestBuilder firstName(String firstName) {
            this.firstName = firstName;
            return this;
        }

        public RegisterRequestBuilder lastName(String lastName) {
            this.lastName = lastName;
            return this;
        }

        public RegisterRequestBuilder fullName(String fullName) {
            // Split full name into first and last for backward compatibility
            String[] parts = fullName.split(" ", 2);
            this.firstName = parts[0];
            this.lastName = parts.length > 1 ? parts[1] : "";
            return this;
        }

        public RegisterRequestBuilder password(String password) {
            this.password = password;
            return this;
        }

        public RegisterRequestBuilder phoneNumber(String phoneNumber) {
            this.phoneNumber = phoneNumber;
            return this;
        }

        public RegisterRequestBuilder weakPassword() {
            this.password = "weak";
            return this;
        }

        public RegisterRequestBuilder invalidEmail() {
            this.email = "not-an-email";
            return this;
        }

        public RegisterRequest build() {
            return new RegisterRequest(email, firstName, lastName, password, phoneNumber);
        }
    }

    public static class LoginRequestBuilder {
        private String email = "test@example.com";
        private String password = "SecurePass@2024!";

        public LoginRequestBuilder email(String email) {
            this.email = email;
            return this;
        }

        public LoginRequestBuilder password(String password) {
            this.password = password;
            return this;
        }

        public LoginRequestBuilder wrongPassword() {
            this.password = "WrongPassword123!";
            return this;
        }

        public LoginRequestBuilder invalidEmail() {
            this.email = "nonexistent@example.com";
            return this;
        }

        public LoginRequest build() {
            return new LoginRequest(email, password);
        }
    }

    public static class RefreshRequestBuilder {
        private String refreshToken = "sample-refresh-token-" + UUID.randomUUID();

        public RefreshRequestBuilder refreshToken(String refreshToken) {
            this.refreshToken = refreshToken;
            return this;
        }

        public RefreshRequestBuilder expiredToken() {
            this.refreshToken = "expired-token-" + UUID.randomUUID();
            return this;
        }

        public RefreshRequestBuilder invalidToken() {
            this.refreshToken = "invalid-token";
            return this;
        }

        public RefreshRequest build() {
            return new RefreshRequest(refreshToken);
        }
    }

    // Factory methods for common test cases
    public static UserBuilder aUser() {
        return new UserBuilder();
    }

    public static UserBuilder aValidUser() {
        return new UserBuilder();
    }

    public static UserBuilder aDisabledUser() {
        return new UserBuilder().enabled(false);
    }

    public static UserBuilder aLockedUser() {
        return new UserBuilder().accountLocked();
    }

    public static RegisterRequestBuilder aRegisterRequest() {
        return new RegisterRequestBuilder();
    }

    public static RegisterRequestBuilder aValidRegisterRequest() {
        return new RegisterRequestBuilder();
    }

    public static RegisterRequestBuilder anInvalidRegisterRequest() {
        return new RegisterRequestBuilder().invalidEmail().weakPassword();
    }

    public static LoginRequestBuilder aLoginRequest() {
        return new LoginRequestBuilder();
    }

    public static LoginRequestBuilder aValidLoginRequest() {
        return new LoginRequestBuilder();
    }

    public static LoginRequestBuilder anInvalidLoginRequest() {
        return new LoginRequestBuilder().wrongPassword();
    }

    public static RefreshRequestBuilder aRefreshRequest() {
        return new RefreshRequestBuilder();
    }

    public static RefreshRequestBuilder aValidRefreshRequest() {
        return new RefreshRequestBuilder();
    }

    public static RefreshRequestBuilder anInvalidRefreshRequest() {
        return new RefreshRequestBuilder().invalidToken();
    }

    // Common test data values
    public static final String VALID_EMAIL = "test@example.com";
    public static final String VALID_PASSWORD = "SecurePass@2024!";
    public static final String VALID_FULL_NAME = "Test User";
    public static final String INVALID_EMAIL = "not-an-email";
    public static final String WEAK_PASSWORD = "weak";
    public static final String WRONG_PASSWORD = "WrongPass@2024!";
}