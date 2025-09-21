# Story 1.3: Authentication API & Security Layer

## Story
As a system administrator,
I want to implement secure authentication endpoints with JWT tokens,
so that family members can safely access their financial data.

## Status
**Status**: Draft
**Epic**: Epic 1 - Foundation & Authentication System
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Next story to implement

## Acceptance Criteria
- [ ] POST /api/v1/auth/register creates new family member with hashed password (BCrypt)
- [ ] POST /api/v1/auth/login returns JWT access token (15min) and refresh token (7 days)
- [ ] POST /api/v1/auth/refresh exchanges valid refresh token for new token pair
- [ ] POST /api/v1/auth/logout invalidates refresh token
- [ ] Spring Security configured to validate JWT on protected endpoints
- [ ] Role-based access control implemented (ADMIN, FAMILY_MEMBER roles)
- [ ] Password requirements enforced (min 8 chars, complexity rules)
- [ ] Rate limiting on auth endpoints (5 attempts per minute)

## Tasks

### TDD Test Tasks (Do First!)
- [ ] Write tests for UserDetailsService implementation
- [ ] Write tests for JwtService token generation
- [ ] Write tests for JwtService token validation
- [ ] Write tests for AuthService registration logic
- [ ] Write tests for AuthService login logic
- [ ] Write tests for refresh token rotation
- [ ] Write tests for password validation rules
- [ ] Write integration tests for auth endpoints

### Implementation Tasks
- [ ] Implement UserDetailsService
  - [ ] Create CustomUserDetails class
  - [ ] Load user from database
  - [ ] Map roles to authorities
- [ ] Create JwtService
  - [ ] Generate access tokens
  - [ ] Generate refresh tokens
  - [ ] Validate tokens
  - [ ] Extract claims from tokens
- [ ] Implement SecurityConfig
  - [ ] Configure JWT filter
  - [ ] Set up authentication entry point
  - [ ] Configure access denied handler
  - [ ] Define public/protected endpoints
- [ ] Create AuthenticationController
  - [ ] Implement /register endpoint
  - [ ] Implement /login endpoint
  - [ ] Implement /refresh endpoint
  - [ ] Implement /logout endpoint
  - [ ] Implement /me endpoint
- [ ] Implement AuthService
  - [ ] Registration with validation
  - [ ] Login with password verification
  - [ ] Refresh token rotation
  - [ ] Token blacklisting for logout
- [ ] Create DTOs
  - [ ] LoginRequest DTO
  - [ ] RegisterRequest DTO
  - [ ] TokenResponse DTO
  - [ ] UserResponse DTO
- [ ] Implement rate limiting
  - [ ] Configure Bucket4j
  - [ ] Apply to auth endpoints
  - [ ] Return 429 on limit exceeded
- [ ] Add password validation
  - [ ] Minimum length check
  - [ ] Complexity requirements
  - [ ] Common password check

### Security Tasks
- [ ] Configure CORS properly
- [ ] Add security headers
- [ ] Implement CSRF protection (if needed)
- [ ] Add audit logging for auth events
- [ ] Test for common vulnerabilities

### Validation Tasks
- [ ] Test registration with valid/invalid data
- [ ] Test login with correct/incorrect credentials
- [ ] Test token refresh flow
- [ ] Test token expiration
- [ ] Test rate limiting
- [ ] Test role-based access
- [ ] Verify password hashing
- [ ] Test logout functionality

## Dev Notes
- **IMPORTANT**: Follow TDD - Write tests FIRST, then implementation
- Use BCrypt with strength 12 for password hashing
- Implement token rotation for enhanced security
- Store refresh tokens in database for revocation
- Add correlation IDs to auth logs
- Consider implementing "remember me" functionality
- Ensure all auth events are audited

## Testing
- **Unit Tests**: All service methods
- **Integration Tests**: All endpoints with TestContainers
- **Security Tests**: Token validation, rate limiting
- **Test Command**: `./mvnw test`
- **Coverage Target**: 90% for security-critical code

## Dev Agent Record

### Agent Model Used
- To be assigned

### Debug Log References
- To be created

### Completion Notes
- Not started

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/application/dto/request/LoginRequest.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/request/RegisterRequest.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/response/TokenResponse.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/response/UserResponse.java`
- `/backend/src/main/java/com/caioniehues/app/application/service/AuthService.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/JwtService.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/CustomUserDetails.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/CustomUserDetailsService.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/JwtAuthenticationFilter.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/JwtAuthenticationEntryPoint.java`
- `/backend/src/main/java/com/caioniehues/app/config/SecurityConfig.java`
- `/backend/src/main/java/com/caioniehues/app/config/RateLimitConfig.java`
- `/backend/src/main/java/com/caioniehues/app/presentation/controller/AuthController.java`

### Test Files to Create
- `/backend/src/test/java/com/caioniehues/app/application/service/AuthServiceTest.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/security/JwtServiceTest.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/security/CustomUserDetailsServiceTest.java`
- `/backend/src/test/java/com/caioniehues/app/presentation/controller/AuthControllerTest.java`
- `/backend/src/test/java/com/caioniehues/app/integration/AuthenticationIntegrationTest.java`

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 00:21:09 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 00:21:09