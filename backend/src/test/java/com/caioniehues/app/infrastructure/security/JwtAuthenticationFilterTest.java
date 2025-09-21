package com.caioniehues.app.infrastructure.security;

import com.caioniehues.app.domain.user.User;
import com.caioniehues.app.infrastructure.persistence.TokenBlacklistRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;

import java.io.IOException;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("JWT Authentication Filter Tests")
class JwtAuthenticationFilterTest {

    @Mock
    private JwtService jwtService;

    @Mock
    private UserDetailsService userDetailsService;

    @Mock
    private TokenBlacklistRepository tokenBlacklistRepository;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private FilterChain filterChain;

    @InjectMocks
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    private User testUser;
    private String validToken;
    private String validJti;

    @BeforeEach
    void setUp() {
        testUser = User.builder()
            .username("test@example.com")
            .email("test@example.com")
            .fullName("Test User")
            .enabled(true)
            .build();

        validToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.valid.token";
        validJti = "test-jti-123";

        // Clear security context before each test
        SecurityContextHolder.clearContext();
    }

    @Test
    @DisplayName("Should skip authentication for public endpoints")
    void publicEndpoints_ShouldSkipAuthentication() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/auth/login");

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(jwtService, never()).extractUsername(anyString());
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    @DisplayName("Should skip authentication for health endpoints")
    void healthEndpoints_ShouldSkipAuthentication() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/health");

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(jwtService, never()).extractUsername(anyString());
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    @DisplayName("Should skip authentication for Swagger endpoints")
    void swaggerEndpoints_ShouldSkipAuthentication() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/v3/api-docs");

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(jwtService, never()).extractUsername(anyString());
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    @DisplayName("Should continue without authentication when no Authorization header")
    void noAuthorizationHeader_ShouldContinueWithoutAuth() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getHeader("Authorization")).thenReturn(null);

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(jwtService, never()).extractUsername(anyString());
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    @DisplayName("Should continue without authentication when Authorization header doesn't start with Bearer")
    void invalidAuthorizationHeader_ShouldContinueWithoutAuth() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getHeader("Authorization")).thenReturn("Basic dGVzdDp0ZXN0");

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(jwtService, never()).extractUsername(anyString());
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    @DisplayName("Should authenticate user with valid JWT token")
    void validJwtToken_ShouldAuthenticateUser() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getHeader("Authorization")).thenReturn("Bearer " + validToken);
        when(jwtService.extractUsername(validToken)).thenReturn("test@example.com");
        when(jwtService.extractClaim(eq(validToken), any())).thenReturn(validJti);
        when(tokenBlacklistRepository.existsByJti(validJti)).thenReturn(false);
        when(userDetailsService.loadUserByUsername("test@example.com")).thenReturn(testUser);
        when(jwtService.validateTokenForUser(validToken, testUser)).thenReturn(true);

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        assertThat(auth).isNotNull();
        assertThat(auth.getPrincipal()).isEqualTo(testUser);
        assertThat(auth.isAuthenticated()).isTrue();
    }

    @Test
    @DisplayName("Should not authenticate with blacklisted token")
    void blacklistedToken_ShouldNotAuthenticate() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getHeader("Authorization")).thenReturn("Bearer " + validToken);
        when(jwtService.extractUsername(validToken)).thenReturn("test@example.com");
        when(jwtService.extractClaim(eq(validToken), any())).thenReturn(validJti);
        when(tokenBlacklistRepository.existsByJti(validJti)).thenReturn(true);

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(userDetailsService, never()).loadUserByUsername(anyString());
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    @DisplayName("Should not authenticate with invalid token")
    void invalidToken_ShouldNotAuthenticate() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getHeader("Authorization")).thenReturn("Bearer " + validToken);
        when(jwtService.extractUsername(validToken)).thenReturn("test@example.com");
        when(jwtService.extractClaim(eq(validToken), any())).thenReturn(validJti);
        when(tokenBlacklistRepository.existsByJti(validJti)).thenReturn(false);
        when(userDetailsService.loadUserByUsername("test@example.com")).thenReturn(testUser);
        when(jwtService.validateTokenForUser(validToken, testUser)).thenReturn(false);

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    @DisplayName("Should handle JWT service exceptions gracefully")
    void jwtServiceException_ShouldContinueWithoutAuth() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getHeader("Authorization")).thenReturn("Bearer " + validToken);
        when(jwtService.extractUsername(validToken)).thenThrow(new RuntimeException("Invalid JWT"));

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    @DisplayName("Should handle user not found gracefully")
    void userNotFound_ShouldContinueWithoutAuth() throws ServletException, IOException {
        // Given
        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getHeader("Authorization")).thenReturn("Bearer " + validToken);
        when(jwtService.extractUsername(validToken)).thenReturn("nonexistent@example.com");
        when(jwtService.extractClaim(eq(validToken), any())).thenReturn(validJti);
        when(tokenBlacklistRepository.existsByJti(validJti)).thenReturn(false);
        when(userDetailsService.loadUserByUsername("nonexistent@example.com"))
            .thenThrow(new RuntimeException("User not found"));

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    @DisplayName("Should not set authentication if user already authenticated")
    void alreadyAuthenticated_ShouldSkipAuthentication() throws ServletException, IOException {
        // Given
        SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
        Authentication existingAuth = mock(Authentication.class);
        when(existingAuth.isAuthenticated()).thenReturn(true);
        securityContext.setAuthentication(existingAuth);
        SecurityContextHolder.setContext(securityContext);

        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getHeader("Authorization")).thenReturn("Bearer " + validToken);

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(request, response);
        verify(jwtService, never()).extractUsername(anyString());
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isEqualTo(existingAuth);
    }

    @Test
    @DisplayName("Should extract token correctly from Authorization header")
    void authorizationHeader_ShouldExtractTokenCorrectly() throws ServletException, IOException {
        // Given
        String fullHeader = "Bearer " + validToken;
        when(request.getServletPath()).thenReturn("/api/v1/users/profile");
        when(request.getHeader("Authorization")).thenReturn(fullHeader);
        when(jwtService.extractUsername(validToken)).thenReturn("test@example.com");
        when(jwtService.extractClaim(eq(validToken), any())).thenReturn(validJti);
        when(tokenBlacklistRepository.existsByJti(validJti)).thenReturn(false);
        when(userDetailsService.loadUserByUsername("test@example.com")).thenReturn(testUser);
        when(jwtService.validateTokenForUser(validToken, testUser)).thenReturn(true);

        // When
        jwtAuthenticationFilter.doFilterInternal(request, response, filterChain);

        // Then
        ArgumentCaptor<String> tokenCaptor = ArgumentCaptor.forClass(String.class);
        verify(jwtService).extractUsername(tokenCaptor.capture());
        assertThat(tokenCaptor.getValue()).isEqualTo(validToken);

        verify(filterChain).doFilter(request, response);
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNotNull();
    }
}