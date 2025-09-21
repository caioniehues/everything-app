package com.caioniehues.app.util;

import com.caioniehues.app.application.dto.request.LoginRequest;
import com.caioniehues.app.application.dto.request.RegisterRequest;
import com.caioniehues.app.application.dto.response.TokenResponse;
import com.caioniehues.app.domain.user.User;
import com.caioniehues.app.infrastructure.security.JwtService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@Component
public class AuthTestHelper {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private UserDetailsService userDetailsService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public TokenResponse registerAndLoginUser(RegisterRequest registerRequest) throws Exception {
        // Register the user
        registerUser(registerRequest);

        // Login and get tokens
        LoginRequest loginRequest = new LoginRequest(registerRequest.email(), registerRequest.password());
        return loginUser(loginRequest);
    }

    public TokenResponse registerAndLoginUser(String email, String fullName, String password) throws Exception {
        // Split full name into first and last for backward compatibility
        String[] parts = fullName.split(" ", 2);
        String firstName = parts[0];
        String lastName = parts.length > 1 ? parts[1] : "User";
        RegisterRequest registerRequest = new RegisterRequest(email, firstName, lastName, password, "+1234567890");
        return registerAndLoginUser(registerRequest);
    }

    public void registerUser(RegisterRequest registerRequest) throws Exception {
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
            .andExpect(status().isCreated());
    }

    public TokenResponse loginUser(LoginRequest loginRequest) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginRequest)))
            .andExpect(status().isOk())
            .andReturn();

        String responseContent = result.getResponse().getContentAsString();
        return objectMapper.readValue(responseContent, TokenResponse.class);
    }

    public TokenResponse loginUser(String email, String password) throws Exception {
        LoginRequest loginRequest = new LoginRequest(email, password);
        return loginUser(loginRequest);
    }

    public String generateValidJwtToken(User user) {
        return jwtService.generateAccessToken(user);
    }

    public String generateValidJwtToken(String email) {
        User user = (User) userDetailsService.loadUserByUsername(email);
        return generateValidJwtToken(user);
    }

    public String generateExpiredJwtToken(User user) {
        // Create a token that's already expired
        // This is a mock implementation - in real tests this should return an actually expired token
        return "expired.jwt.token";
    }

    public String generateInvalidJwtToken() {
        return "invalid.jwt.token";
    }

    public void authenticateUser(User user) {
        Authentication authentication = new UsernamePasswordAuthenticationToken(
            user, null, user.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

    public void authenticateUser(String email) {
        User user = (User) userDetailsService.loadUserByUsername(email);
        authenticateUser(user);
    }

    public void clearAuthentication() {
        SecurityContextHolder.clearContext();
    }

    public User createTestUser(String email, String fullName, String password) {
        return User.builder()
            .email(email)
            .username(email)
            .fullName(fullName)
            .passwordHash(passwordEncoder.encode(password))
            .enabled(true)
            .build();
    }

    public User createDefaultTestUser() {
        return createTestUser(
            TestDataBuilder.VALID_EMAIL,
            TestDataBuilder.VALID_FULL_NAME,
            TestDataBuilder.VALID_PASSWORD
        );
    }

    public String getAuthorizationHeader(String token) {
        return "Bearer " + token;
    }

    public String getAuthorizationHeaderForUser(User user) {
        String token = generateValidJwtToken(user);
        return getAuthorizationHeader(token);
    }

    public String getAuthorizationHeaderForUser(String email) {
        String token = generateValidJwtToken(email);
        return getAuthorizationHeader(token);
    }

    public void makeMultipleLoginAttempts(String email, String password, int attempts) throws Exception {
        LoginRequest loginRequest = new LoginRequest(email, password);
        String requestBody = objectMapper.writeValueAsString(loginRequest);

        for (int i = 0; i < attempts; i++) {
            mockMvc.perform(post("/api/v1/auth/login")
                .contentType(APPLICATION_JSON)
                .content(requestBody));
        }
    }

    public void makeMultipleRegistrationAttempts(String email, String fullName, String password, int attempts) throws Exception {
        // Split full name into first and last for backward compatibility
        String[] parts = fullName.split(" ", 2);
        String firstName = parts[0];
        String lastName = parts.length > 1 ? parts[1] : "User";
        RegisterRequest registerRequest = new RegisterRequest(email, firstName, lastName, password, "+1234567890");
        String requestBody = objectMapper.writeValueAsString(registerRequest);

        for (int i = 0; i < attempts; i++) {
            mockMvc.perform(post("/api/v1/auth/register")
                .contentType(APPLICATION_JSON)
                .content(requestBody));
        }
    }

    public boolean isTokenValid(String token, User user) {
        try {
            return jwtService.validateTokenForUser(token, user);
        } catch (Exception e) {
            return false;
        }
    }

    public String extractUsernameFromToken(String token) {
        try {
            return jwtService.extractUsername(token);
        } catch (Exception e) {
            return null;
        }
    }
}