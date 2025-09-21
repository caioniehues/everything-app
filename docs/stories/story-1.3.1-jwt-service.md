# Story 1.3.1: JWT Service & Token Infrastructure

## Story
As a developer,
I want to implement JWT token generation and validation services,
so that the authentication system can securely manage user sessions.

## Status
**Status**: Complete ✅
**Epic**: Epic 1 - Foundation & Authentication System
**Parent Story**: 1.3 - Authentication API & Security Layer
**Started**: 21/09/2025
**Completed**: 21/09/2025
**Developer**: Unassigned
**Priority**: CRITICAL - Foundation for all auth
**Estimated Days**: 1 day
**Story Points**: 2

## Acceptance Criteria
- [ ] JWT service generates access tokens with 15-minute expiry
- [ ] JWT service generates refresh tokens with 7-day expiry
- [ ] Token validation correctly verifies signatures
- [ ] Token claims extraction working properly
- [ ] Token expiry checked during validation
- [ ] Refresh token storage implemented in database
- [ ] Token blacklisting mechanism ready
- [ ] All token operations have unit tests

## Dependencies
### Requires (Blocked By)
- [ ] Story 1.1 - Backend Infrastructure (Complete ✅)
- [ ] Story 1.2.1 - Backend security dependencies configured

### Enables (Blocks)
- [ ] Story 1.3.2 - Registration Endpoint
- [ ] Story 1.3.3 - Login/Logout Endpoints
- [ ] Story 1.3.4 - Security & Rate Limiting
- [ ] All authenticated API endpoints

### Integration Points
- **Input**: User credentials and roles from database
- **Output**: JWT tokens for authentication
- **Handoff**: JwtService available for AuthService

## Tasks

### TDD Test Tasks (2 hours)
- [ ] Write JwtServiceTest
  - [ ] Test access token generation
  - [ ] Test refresh token generation
  - [ ] Test token validation (valid tokens)
  - [ ] Test token validation (expired tokens)
  - [ ] Test token validation (invalid signature)
  - [ ] Test claims extraction
  - [ ] Test token blacklisting
- [ ] Write CustomUserDetailsTest
  - [ ] Test user details mapping
  - [ ] Test authorities mapping
  - [ ] Test serialization

### JWT Service Implementation (3 hours)
- [ ] Create JwtService class
  - [ ] `/backend/src/main/java/com/caioniehues/app/infrastructure/security/JwtService.java`
  - [ ] Configure secret key from environment
  - [ ] Implement generateAccessToken(UserDetails)
  - [ ] Implement generateRefreshToken(UserDetails)
  - [ ] Implement validateToken(String token)
  - [ ] Implement extractUsername(String token)
  - [ ] Implement extractClaims(String token)
  - [ ] Implement isTokenExpired(String token)
- [ ] Create token entities
  - [ ] RefreshToken entity with expiry
  - [ ] RefreshTokenRepository
  - [ ] Token blacklist entity
  - [ ] BlacklistRepository

### User Details Implementation (2 hours)
- [ ] Create CustomUserDetails
  - [ ] `/backend/src/main/java/com/caioniehues/app/infrastructure/security/CustomUserDetails.java`
  - [ ] Implement UserDetails interface
  - [ ] Map User entity to UserDetails
  - [ ] Include roles and permissions
- [ ] Create CustomUserDetailsService
  - [ ] `/backend/src/main/java/com/caioniehues/app/infrastructure/security/CustomUserDetailsService.java`
  - [ ] Load user by username
  - [ ] Map roles to authorities
  - [ ] Handle user not found

### Configuration (1 hour)
- [ ] Configure JWT properties
  - [ ] Secret key in application.yml
  - [ ] Access token expiry
  - [ ] Refresh token expiry
  - [ ] Issuer information
- [ ] Add JWT dependencies to pom.xml
  - [ ] io.jsonwebtoken:jjwt-api
  - [ ] io.jsonwebtoken:jjwt-impl
  - [ ] io.jsonwebtoken:jjwt-jackson

### Documentation (30 minutes)
- [ ] Document JWT token structure
- [ ] Document refresh token flow
- [ ] Document token storage approach
- [ ] Add examples to README

## Definition of Done
- [ ] JWT service generating valid tokens
- [ ] Token validation working correctly
- [ ] Refresh tokens stored in database
- [ ] All tests passing (90%+ coverage)
- [ ] No security vulnerabilities
- [ ] Code reviewed and approved
- [ ] Documentation complete

## Dev Notes
- Use HS256 algorithm for JWT signing
- Store JWT secret as environment variable
- Implement token rotation for refresh tokens
- Consider implementing JWT fingerprinting
- Add jti claim for token uniqueness
- Log all token generation/validation events

## Testing
- **Unit Tests**: JwtService methods, UserDetails
- **Integration Tests**: Token flow with database
- **Security Tests**: Token tampering, expiry
- **Test Command**: `./mvnw test -Dtest=*JwtService*,*UserDetails*`
- **Coverage Target**: 90%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Secret key exposure | Low | Critical | Environment variables, key rotation |
| Token theft | Medium | High | Short expiry, refresh rotation |
| Algorithm confusion | Low | High | Hardcode algorithm choice |

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/JwtService.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/CustomUserDetails.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/CustomUserDetailsService.java`
- `/backend/src/main/java/com/caioniehues/app/domain/entity/RefreshToken.java`
- `/backend/src/main/java/com/caioniehues/app/domain/repository/RefreshTokenRepository.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/security/JwtServiceTest.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/security/CustomUserDetailsTest.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/security/CustomUserDetailsServiceTest.java`

### Files to Modify
- `/backend/pom.xml` - Add JWT dependencies
- `/backend/src/main/resources/application.yml` - JWT configuration

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 1.3 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38