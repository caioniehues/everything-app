# Story 1.3.4: Security Configuration & Rate Limiting

## Story
As a system administrator,
I want comprehensive security configuration with rate limiting,
so that the application is protected against common attacks and abuse.

## Status
**Status**: Mostly Complete (90%)
**Epic**: Epic 1 - Foundation & Authentication System
**Parent Story**: 1.3 - Authentication API & Security Layer
**Started**: 21/09/2025
**Completed**: In Progress
**Developer**: Unassigned
**Priority**: CRITICAL - Security foundation
**Estimated Days**: 1 day
**Story Points**: 2

## Acceptance Criteria
- [ ] Spring Security configured with JWT authentication filter
- [ ] Public and protected endpoints properly defined
- [ ] Rate limiting active on auth endpoints (5 attempts/minute)
- [ ] Security headers configured (HSTS, CSP, X-Frame-Options)
- [ ] CORS configured for Flutter app
- [ ] Authentication entry point returns proper 401
- [ ] Access denied handler returns proper 403
- [ ] Audit logging captures security events

## Dependencies
### Requires (Blocked By)
- [ ] Story 1.3.1 - JWT Service & Token Infrastructure
- [ ] Story 1.3.2 - Registration Endpoint
- [ ] Story 1.3.3 - Login/Logout Endpoints

### Enables (Blocks)
- [ ] Story 1.3.5 - Integration Testing
- [ ] All protected API endpoints

### Integration Points
- **Input**: HTTP requests to all endpoints
- **Output**: Filtered, authenticated requests
- **Handoff**: Security context for all APIs

## Tasks

### TDD Test Tasks (2 hours)
- [ ] Write SecurityConfigTest
  - [ ] Test public endpoint access
  - [ ] Test protected endpoint blocking
  - [ ] Test valid JWT acceptance
  - [ ] Test invalid JWT rejection
  - [ ] Test CORS configuration
- [ ] Write RateLimitingTest
  - [ ] Test rate limit enforcement
  - [ ] Test rate limit reset
  - [ ] Test per-IP limiting
  - [ ] Test 429 response

### Security Configuration (3 hours)
- [ ] Create SecurityConfig
  - [ ] `/backend/src/main/java/com/caioniehues/app/config/SecurityConfig.java`
  - [ ] Configure SecurityFilterChain
  - [ ] Add JWT authentication filter
  - [ ] Define public endpoints (/api/v1/auth/*)
  - [ ] Protect all other endpoints
  - [ ] Configure session management (stateless)
  - [ ] Disable CSRF for API
- [ ] Create JWT filter
  - [ ] `/backend/src/main/java/com/caioniehues/app/infrastructure/security/JwtAuthenticationFilter.java`
  - [ ] Extract token from Authorization header
  - [ ] Validate token with JwtService
  - [ ] Set SecurityContext
  - [ ] Handle filter exceptions
- [ ] Configure authentication handlers
  - [ ] `/backend/src/main/java/com/caioniehues/app/infrastructure/security/JwtAuthenticationEntryPoint.java`
  - [ ] Return 401 with proper message
  - [ ] `/backend/src/main/java/com/caioniehues/app/infrastructure/security/CustomAccessDeniedHandler.java`
  - [ ] Return 403 with proper message

### Rate Limiting Implementation (2 hours)
- [ ] Configure Bucket4j
  - [ ] `/backend/src/main/java/com/caioniehues/app/config/RateLimitConfig.java`
  - [ ] Add Bucket4j dependency
  - [ ] Configure rate limit buckets
  - [ ] 5 requests per minute for auth
  - [ ] 100 requests per minute for API
- [ ] Create rate limit filter
  - [ ] `/backend/src/main/java/com/caioniehues/app/infrastructure/security/RateLimitFilter.java`
  - [ ] Track requests by IP
  - [ ] Apply to auth endpoints
  - [ ] Return 429 when exceeded
  - [ ] Add retry-after header
- [ ] Configure different limits
  - [ ] Login: 5 per minute
  - [ ] Registration: 3 per hour
  - [ ] Password reset: 3 per hour

### Security Headers (1 hour)
- [ ] Configure security headers
  - [ ] Strict-Transport-Security
  - [ ] Content-Security-Policy
  - [ ] X-Frame-Options: DENY
  - [ ] X-Content-Type-Options: nosniff
  - [ ] X-XSS-Protection
  - [ ] Referrer-Policy
- [ ] Configure CORS
  - [ ] Allow Flutter app origins
  - [ ] Configure allowed methods
  - [ ] Configure allowed headers
  - [ ] Handle preflight requests

### Audit Logging (1 hour)
- [ ] Create security event logger
  - [ ] `/backend/src/main/java/com/caioniehues/app/infrastructure/security/SecurityAuditLogger.java`
  - [ ] Log authentication success
  - [ ] Log authentication failure
  - [ ] Log authorization failures
  - [ ] Log rate limit violations
- [ ] Configure structured logging
  - [ ] Include correlation IDs
  - [ ] Include user context
  - [ ] Include IP addresses
  - [ ] Include user agents

### Documentation (30 minutes)
- [ ] Document security configuration
- [ ] Document rate limits
- [ ] Document CORS setup
- [ ] Create security guidelines

## Definition of Done
- [ ] JWT filter authenticating requests
- [ ] Rate limiting preventing abuse
- [ ] Security headers configured
- [ ] CORS working for Flutter
- [ ] Audit logging all events
- [ ] All tests passing
- [ ] No security vulnerabilities
- [ ] Documentation complete

## Dev Notes
- Use OncePerRequestFilter for JWT
- Consider implementing CAPTCHA for repeated failures
- Add IP-based blocking for severe violations
- Monitor rate limit metrics
- Consider implementing API keys for external consumers
- Review OWASP security guidelines

## Testing
- **Unit Tests**: Filters and handlers
- **Integration Tests**: Security flow
- **Security Tests**: Attack scenarios
- **Load Tests**: Rate limit behavior
- **Test Command**: `./mvnw test -Dtest=*Security*,*RateLimit*`
- **Coverage Target**: 90%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| DDoS attacks | Medium | High | Rate limiting, monitoring |
| JWT misconfiguration | Low | Critical | Thorough testing |
| CORS issues | Medium | Medium | Proper configuration |

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/config/SecurityConfig.java`
- `/backend/src/main/java/com/caioniehues/app/config/RateLimitConfig.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/JwtAuthenticationFilter.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/JwtAuthenticationEntryPoint.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/CustomAccessDeniedHandler.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/RateLimitFilter.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/security/SecurityAuditLogger.java`
- `/backend/src/test/java/com/caioniehues/app/config/SecurityConfigTest.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/security/RateLimitFilterTest.java`

### Files to Modify
- `/backend/pom.xml` - Add Bucket4j dependency
- `/backend/src/main/resources/application.yml` - Security settings

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 1.3 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38