package com.caioniehues.app.presentation.controller;

import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.net.URI;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ProblemDetail> handleValidationException(MethodArgumentNotValidException ex, WebRequest request) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(
            HttpStatus.BAD_REQUEST, "Validation failed");
        problemDetail.setTitle("Validation Error");
        problemDetail.setInstance(URI.create(request.getDescription(false).substring(4)));

        Map<String, Object> properties = new HashMap<>();
        Map<String, String> errors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .collect(Collectors.toMap(
                FieldError::getField,
                error -> error.getDefaultMessage() != null ? error.getDefaultMessage() : "Invalid value",
                (existing, replacement) -> existing
            ));
        properties.put("errors", errors);
        properties.put("timestamp", Instant.now());
        problemDetail.setProperties(properties);

        return ResponseEntity.badRequest().body(problemDetail);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ProblemDetail> handleConstraintViolation(ConstraintViolationException ex, WebRequest request) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(
            HttpStatus.BAD_REQUEST, "Constraint violation");
        problemDetail.setTitle("Validation Error");
        problemDetail.setInstance(URI.create(request.getDescription(false).substring(4)));

        Map<String, Object> properties = new HashMap<>();
        Map<String, String> errors = ex.getConstraintViolations()
            .stream()
            .collect(Collectors.toMap(
                violation -> violation.getPropertyPath().toString(),
                ConstraintViolation::getMessage,
                (existing, replacement) -> existing
            ));
        properties.put("errors", errors);
        properties.put("timestamp", Instant.now());
        problemDetail.setProperties(properties);

        return ResponseEntity.badRequest().body(problemDetail);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ProblemDetail> handleDataIntegrityViolation(DataIntegrityViolationException ex, WebRequest request) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(
            HttpStatus.CONFLICT, "Data integrity violation");
        problemDetail.setTitle("Conflict");
        problemDetail.setInstance(URI.create(request.getDescription(false).substring(4)));

        Map<String, Object> properties = new HashMap<>();
        properties.put("timestamp", Instant.now());

        String message = ex.getMostSpecificCause().getMessage();
        if (message != null) {
            if (message.contains("duplicate key") || message.contains("unique constraint")) {
                properties.put("error", "Duplicate value for unique field");
                if (message.contains("email")) {
                    properties.put("field", "email");
                    properties.put("message", "Email already exists");
                } else if (message.contains("username")) {
                    properties.put("field", "username");
                    properties.put("message", "Username already exists");
                }
            } else if (message.contains("foreign key")) {
                properties.put("error", "Referenced entity not found");
            }
        }
        problemDetail.setProperties(properties);

        log.error("Data integrity violation: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT).body(problemDetail);
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ProblemDetail> handleEntityNotFound(EntityNotFoundException ex, WebRequest request) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(
            HttpStatus.NOT_FOUND, ex.getMessage() != null ? ex.getMessage() : "Entity not found");
        problemDetail.setTitle("Not Found");
        problemDetail.setInstance(URI.create(request.getDescription(false).substring(4)));

        Map<String, Object> properties = new HashMap<>();
        properties.put("timestamp", Instant.now());
        problemDetail.setProperties(properties);

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(problemDetail);
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ProblemDetail> handleBadCredentials(BadCredentialsException ex, WebRequest request) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(
            HttpStatus.UNAUTHORIZED, "Invalid username or password");
        problemDetail.setTitle("Authentication Failed");
        problemDetail.setInstance(URI.create(request.getDescription(false).substring(4)));

        Map<String, Object> properties = new HashMap<>();
        properties.put("timestamp", Instant.now());
        problemDetail.setProperties(properties);

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(problemDetail);
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ProblemDetail> handleAuthenticationException(AuthenticationException ex, WebRequest request) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(
            HttpStatus.UNAUTHORIZED, "Authentication failed");
        problemDetail.setTitle("Unauthorized");
        problemDetail.setInstance(URI.create(request.getDescription(false).substring(4)));

        Map<String, Object> properties = new HashMap<>();
        properties.put("timestamp", Instant.now());
        problemDetail.setProperties(properties);

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(problemDetail);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ProblemDetail> handleAccessDenied(AccessDeniedException ex, WebRequest request) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(
            HttpStatus.FORBIDDEN, "Access denied");
        problemDetail.setTitle("Forbidden");
        problemDetail.setInstance(URI.create(request.getDescription(false).substring(4)));

        Map<String, Object> properties = new HashMap<>();
        properties.put("timestamp", Instant.now());
        problemDetail.setProperties(properties);

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(problemDetail);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ProblemDetail> handleIllegalArgument(IllegalArgumentException ex, WebRequest request) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(
            HttpStatus.BAD_REQUEST, ex.getMessage() != null ? ex.getMessage() : "Invalid argument");
        problemDetail.setTitle("Bad Request");
        problemDetail.setInstance(URI.create(request.getDescription(false).substring(4)));

        Map<String, Object> properties = new HashMap<>();
        properties.put("timestamp", Instant.now());
        problemDetail.setProperties(properties);

        return ResponseEntity.badRequest().body(problemDetail);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ProblemDetail> handleGenericException(Exception ex, WebRequest request) {
        ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(
            HttpStatus.INTERNAL_SERVER_ERROR, "An unexpected error occurred");
        problemDetail.setTitle("Internal Server Error");
        problemDetail.setInstance(URI.create(request.getDescription(false).substring(4)));

        Map<String, Object> properties = new HashMap<>();
        properties.put("timestamp", Instant.now());
        problemDetail.setProperties(properties);

        log.error("Unexpected error occurred", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(problemDetail);
    }
}