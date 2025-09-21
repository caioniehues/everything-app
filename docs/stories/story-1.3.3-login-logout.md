# Story 1.3.3: Login/Logout Endpoints & Session Management

## Story
As a family member,
I want to securely login and logout of the application,
so that I can access my financial data and protect it when done.

## Status
**Status**: Mostly Complete (90%)
**Epic**: Epic 1 - Foundation & Authentication System
**Parent Story**: 1.3 - Authentication API & Security Layer
**Started**: 21/09/2025
**Completed**: In Progress
**Developer**: Unassigned
**Priority**: HIGH - Core functionality
**Estimated Days**: 1 day
**Story Points**: 2

## Acceptance Criteria
- [ ] POST /api/v1/auth/login authenticates users and returns tokens
- [ ] Login validates email/password correctly
- [ ] Login returns access token (15min) and refresh token (7 days)
- [ ] POST /api/v1/auth/refresh exchanges valid refresh token for new pair
- [ ] POST /api/v1/auth/logout invalidates refresh token
- [ ] GET /api/v1/auth/me returns current user info
- [ ] Failed login attempts logged for security
- [ ] Token refresh implements rotation

## Dependencies
### Requires (Blocked By)
- [ ] Story 1.3.1 - JWT Service & Token Infrastructure
- [ ] Story 1.3.2 - Registration Endpoint (users to login)

### Enables (Blocks)
- [ ] Story 1.4 - Flutter Auth Screens
- [ ] All authenticated features

### Integration Points
- **Input**: Login credentials, refresh tokens
- **Output**: JWT token pairs, user session
- **Handoff**: Authenticated requests to all APIs

## Tasks

### TDD Test Tasks (2 hours)
- [ ] Write AuthServiceTest for login
  - [ ] Test successful login
  - [ ] Test invalid email
  - [ ] Test incorrect password
  - [ ] Test locked account
  - [ ] Test token generation
- [ ] Write AuthServiceTest for refresh
  - [ ] Test valid refresh token
  - [ ] Test expired refresh token
  - [ ] Test revoked refresh token
  - [ ] Test token rotation
- [ ] Write AuthServiceTest for logout
  - [ ] Test token blacklisting
  - [ ] Test logout audit logging

### DTOs Creation (1 hour)
- [ ] Create LoginRequest DTO
  - [ ] `/backend/src/main/java/com/caioniehues/app/application/dto/request/LoginRequest.java`
  - [ ] Email field with validation
  - [ ] Password field
  - [ ] Remember me flag (optional)
- [ ] Create TokenResponse DTO
  - [ ] `/backend/src/main/java/com/caioniehues/app/application/dto/response/TokenResponse.java`
  - [ ] Access token field
  - [ ] Refresh token field
  - [ ] Token type (Bearer)
  - [ ] Expires in (seconds)
- [ ] Create RefreshRequest DTO
  - [ ] Refresh token field
  - [ ] Device ID (optional)

### Login Service Implementation (2 hours)
- [ ] Implement AuthService.login()
  - [ ] Validate email exists
  - [ ] Verify password with BCrypt
  - [ ] Generate access token
  - [ ] Generate refresh token
  - [ ] Store refresh token in database
  - [ ] Log successful login
  - [ ] Track failed attempts
- [ ] Handle login exceptions
  - [ ] InvalidCredentialsException
  - [ ] AccountLockedException
  - [ ] AccountNotVerifiedException

### Refresh Token Implementation (1.5 hours)
- [ ] Implement AuthService.refreshToken()
  - [ ] Validate refresh token
  - [ ] Check token not blacklisted
  - [ ] Generate new token pair
  - [ ] Rotate refresh token
  - [ ] Invalidate old refresh token
  - [ ] Update database
- [ ] Implement token rotation
  - [ ] One-time use refresh tokens
  - [ ] Grace period for network issues

### Logout Implementation (1 hour)
- [ ] Implement AuthService.logout()
  - [ ] Extract token from request
  - [ ] Add to blacklist
  - [ ] Invalidate refresh token
  - [ ] Clear any sessions
  - [ ] Log logout event
- [ ] Implement token blacklist
  - [ ] Check blacklist on validation
  - [ ] TTL for blacklist entries

### Controller Implementation (1 hour)
- [ ] Implement AuthController endpoints
  - [ ] POST /api/v1/auth/login
  - [ ] POST /api/v1/auth/refresh
  - [ ] POST /api/v1/auth/logout
  - [ ] GET /api/v1/auth/me
- [ ] Handle responses
  - [ ] 200 OK for successful operations
  - [ ] 401 for invalid credentials
  - [ ] 403 for locked accounts

### Integration Testing (30 minutes)
- [ ] Test complete login flow
- [ ] Test refresh token rotation
- [ ] Test logout and re-login
- [ ] Test concurrent sessions

## Definition of Done
- [ ] Login endpoint authenticating users
- [ ] Token refresh working with rotation
- [ ] Logout invalidating tokens
- [ ] Current user endpoint working
- [ ] All tests passing (90%+ coverage)
- [ ] Security events logged
- [ ] API documented

## Dev Notes
- Implement token fingerprinting for added security
- Consider device tracking for sessions
- Add "remember me" functionality
- Log all authentication events
- Consider implementing SSO in future
- Rate limit login attempts (Story 1.3.4)

## Testing
- **Unit Tests**: Service methods
- **Controller Tests**: Endpoint behavior
- **Integration Tests**: Full auth flow
- **Security Tests**: Token manipulation
- **Test Command**: `./mvnw test -Dtest=*Login*,*Logout*,*Refresh*`
- **Coverage Target**: 90%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Brute force attacks | High | High | Rate limiting (1.3.4) |
| Token theft | Medium | High | Short expiry, rotation |
| Session hijacking | Low | High | Token fingerprinting |

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/application/dto/request/LoginRequest.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/request/RefreshRequest.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/response/TokenResponse.java`
- `/backend/src/main/java/com/caioniehues/app/application/exception/InvalidCredentialsException.java`
- `/backend/src/main/java/com/caioniehues/app/application/exception/InvalidRefreshTokenException.java`
- `/backend/src/test/java/com/caioniehues/app/application/service/AuthServiceLoginTest.java`

### Files to Modify
- `/backend/src/main/java/com/caioniehues/app/application/service/AuthService.java`
- `/backend/src/main/java/com/caioniehues/app/presentation/controller/AuthController.java`

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 1.3 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38