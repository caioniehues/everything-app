package com.caioniehues.app.application.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Validator for password complexity requirements.
 * Implements the validation logic for @ValidPassword annotation.
 */
@Slf4j
public class PasswordValidator implements ConstraintValidator<ValidPassword, String> {

    private static final int MIN_LENGTH = 8;
    private static final int MAX_LENGTH = 128;

    private static final Pattern UPPERCASE_PATTERN = Pattern.compile(".*[A-Z].*");
    private static final Pattern LOWERCASE_PATTERN = Pattern.compile(".*[a-z].*");
    private static final Pattern DIGIT_PATTERN = Pattern.compile(".*\\d.*");
    private static final Pattern SPECIAL_CHAR_PATTERN = Pattern.compile(".*[!@#$%^&*()\\-_=+\\[\\]{};:'\",.<>/?\\\\|`~].*");

    // Common weak passwords to reject
    private static final Set<String> COMMON_WEAK_PASSWORDS = Set.of(
        "password", "Password", "Password1", "Password123", "Password123!",
        "12345678", "123456789", "1234567890", "qwerty123", "Qwerty123",
        "admin123", "Admin123", "welcome123", "Welcome123", "letmein123"
    );

    @Override
    public void initialize(ValidPassword constraintAnnotation) {
        // No initialization needed
    }

    @Override
    public boolean isValid(String password, ConstraintValidatorContext context) {
        if (password == null) {
            return false;
        }

        List<String> violations = new ArrayList<>();

        // Check length
        if (password.length() < MIN_LENGTH) {
            violations.add("Password must be at least " + MIN_LENGTH + " characters long");
        }
        if (password.length() > MAX_LENGTH) {
            violations.add("Password must not exceed " + MAX_LENGTH + " characters");
        }

        // Check for uppercase letter
        if (!UPPERCASE_PATTERN.matcher(password).matches()) {
            violations.add("Password must contain at least one uppercase letter");
        }

        // Check for lowercase letter
        if (!LOWERCASE_PATTERN.matcher(password).matches()) {
            violations.add("Password must contain at least one lowercase letter");
        }

        // Check for digit
        if (!DIGIT_PATTERN.matcher(password).matches()) {
            violations.add("Password must contain at least one number");
        }

        // Check for special character
        if (!SPECIAL_CHAR_PATTERN.matcher(password).matches()) {
            violations.add("Password must contain at least one special character");
        }

        // Check for common weak passwords
        if (COMMON_WEAK_PASSWORDS.contains(password)) {
            violations.add("Password is too common. Please choose a more secure password");
        }

        // Check for sequential characters (e.g., "abc", "123")
        if (hasSequentialCharacters(password)) {
            violations.add("Password should not contain sequential characters");
        }

        // Check for repeated characters (e.g., "aaa", "111")
        if (hasExcessiveRepeatedCharacters(password)) {
            violations.add("Password should not contain excessive repeated characters");
        }

        if (!violations.isEmpty()) {
            // Disable default constraint violation
            context.disableDefaultConstraintViolation();

            // Add all violation messages
            String combinedMessage = String.join(". ", violations);
            context.buildConstraintViolationWithTemplate(combinedMessage)
                   .addConstraintViolation();

            log.debug("Password validation failed: {}", combinedMessage);
            return false;
        }

        return true;
    }

    /**
     * Check if password contains sequential characters
     */
    private boolean hasSequentialCharacters(String password) {
        if (password.length() < 3) {
            return false;
        }

        for (int i = 0; i < password.length() - 2; i++) {
            char c1 = password.charAt(i);
            char c2 = password.charAt(i + 1);
            char c3 = password.charAt(i + 2);

            // Check for sequential characters (e.g., "abc", "123")
            if ((c2 == c1 + 1) && (c3 == c2 + 1)) {
                return true;
            }
            // Check for reverse sequential (e.g., "cba", "321")
            if ((c2 == c1 - 1) && (c3 == c2 - 1)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Check if password has excessive repeated characters
     */
    private boolean hasExcessiveRepeatedCharacters(String password) {
        if (password.length() < 3) {
            return false;
        }

        int maxRepeats = 2;  // Allow up to 2 consecutive identical characters
        int currentRepeats = 1;
        char previousChar = password.charAt(0);

        for (int i = 1; i < password.length(); i++) {
            char currentChar = password.charAt(i);
            if (currentChar == previousChar) {
                currentRepeats++;
                if (currentRepeats > maxRepeats) {
                    return true;
                }
            } else {
                currentRepeats = 1;
                previousChar = currentChar;
            }
        }
        return false;
    }
}