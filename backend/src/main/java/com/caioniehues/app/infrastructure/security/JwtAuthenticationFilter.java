package com.caioniehues.app.infrastructure.security;

import com.caioniehues.app.infrastructure.persistence.TokenBlacklistRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Set;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String BEARER_PREFIX = "Bearer ";

    private static final Set<String> PUBLIC_ENDPOINTS = Set.of(
        "/api/v1/auth/login",
        "/api/v1/auth/register",
        "/api/v1/auth/forgot-password",
        "/api/v1/auth/reset-password",
        "/api/v1/auth/verify-email",
        "/api/health",
        "/actuator",
        "/v3/api-docs",
        "/swagger-ui",
        "/swagger-resources",
        "/webjars"
    );

    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;
    private final TokenBlacklistRepository tokenBlacklistRepository;

    public JwtAuthenticationFilter(
            JwtService jwtService,
            UserDetailsService userDetailsService,
            TokenBlacklistRepository tokenBlacklistRepository) {
        this.jwtService = jwtService;
        this.userDetailsService = userDetailsService;
        this.tokenBlacklistRepository = tokenBlacklistRepository;
    }

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        try {
            String servletPath = request.getServletPath();

            if (isPublicEndpoint(servletPath)) {
                logger.debug("Skipping authentication for public endpoint: {}", servletPath);
                filterChain.doFilter(request, response);
                return;
            }

            if (SecurityContextHolder.getContext().getAuthentication() != null &&
                SecurityContextHolder.getContext().getAuthentication().isAuthenticated()) {
                logger.debug("User already authenticated, skipping JWT processing");
                filterChain.doFilter(request, response);
                return;
            }

            String authHeader = request.getHeader(AUTHORIZATION_HEADER);
            if (authHeader == null || !authHeader.startsWith(BEARER_PREFIX)) {
                logger.debug("No valid Authorization header found, continuing without authentication");
                filterChain.doFilter(request, response);
                return;
            }

            String jwt = authHeader.substring(BEARER_PREFIX.length());
            String username = jwtService.extractUsername(jwt);

            if (username != null) {
                String jti = jwtService.extractClaim(jwt, claims -> claims.getId());

                if (tokenBlacklistRepository.existsByJti(jti)) {
                    logger.warn("Attempt to use blacklisted token with JTI: {}", jti);
                    filterChain.doFilter(request, response);
                    return;
                }

                var userDetails = userDetailsService.loadUserByUsername(username);

                if (jwtService.validateTokenForUser(jwt, userDetails)) {
                    UsernamePasswordAuthenticationToken authToken =
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                    logger.debug("Successfully authenticated user: {}", username);
                } else {
                    logger.debug("Token validation failed for user: {}", username);
                }
            }
        } catch (Exception e) {
            logger.error("Authentication error: {}", e.getMessage(), e);
        }

        filterChain.doFilter(request, response);
    }

    private boolean isPublicEndpoint(String servletPath) {
        return PUBLIC_ENDPOINTS.stream()
            .anyMatch(endpoint -> servletPath.startsWith(endpoint));
    }
}