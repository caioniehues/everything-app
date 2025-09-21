# Story 1.3.5: Authentication Integration Testing

## Story
As a QA engineer,
I want comprehensive integration tests for the authentication system,
so that we can ensure all auth flows work correctly end-to-end.

## Status
**Status**: In Progress
**Epic**: Epic 1 - Foundation & Authentication System
**Parent Story**: 1.3 - Authentication API & Security Layer
**Started**: 21/09/2025 09:30:00
**Completed**: Not Completed
**Developer**: James (AI Dev)
**Priority**: HIGH - Quality assurance
**Estimated Days**: 1 day
**Story Points**: 2

## Acceptance Criteria
- [ ] Integration tests cover complete registration flow
- [ ] Integration tests cover login with valid/invalid credentials
- [ ] Integration tests verify token refresh and rotation
- [ ] Integration tests confirm logout and token invalidation
- [ ] Rate limiting tests verify proper enforcement
- [ ] Security tests check for common vulnerabilities
- [ ] Performance tests establish baseline metrics
- [ ] All tests use TestContainers for database

## Dependencies
### Requires (Blocked By)
- [ ] Story 1.3.1 - JWT Service & Token Infrastructure
- [ ] Story 1.3.2 - Registration Endpoint
- [ ] Story 1.3.3 - Login/Logout Endpoints
- [ ] Story 1.3.4 - Security Configuration

### Enables (Blocks)
- [ ] Story 1.4 - Flutter Auth Screens
- [ ] Production deployment

### Integration Points
- **Input**: Complete auth system implementation
- **Output**: Verified, tested auth flows
- **Handoff**: Confidence for production deployment

## Tasks

### Test Infrastructure Setup (2 hours)
- [ ] Configure TestContainers
  - [ ] Add TestContainers dependencies
  - [ ] Configure PostgreSQL container
  - [ ] Setup test database migrations
  - [ ] Create base test class
- [ ] Create test data builders
  - [ ] UserTestDataBuilder
  - [ ] RegisterRequestBuilder
  - [ ] LoginRequestBuilder
  - [ ] Test data factory patterns
- [ ] Configure test security
  - [ ] Mock JWT tokens for testing
  - [ ] Test user authentication helper
  - [ ] Security context setup

### Registration Flow Tests (1.5 hours)
- [ ] Create AuthRegistrationIntegrationTest
  - [ ] `/backend/src/test/java/com/caioniehues/app/integration/AuthRegistrationIntegrationTest.java`
  - [ ] Test successful registration
  - [ ] Test duplicate email rejection
  - [ ] Test password validation rules
  - [ ] Test response format
  - [ ] Verify database persistence
  - [ ] Check password encryption
  - [ ] Test validation errors

### Login Flow Tests (1.5 hours)
- [ ] Create AuthLoginIntegrationTest
  - [ ] `/backend/src/test/java/com/caioniehues/app/integration/AuthLoginIntegrationTest.java`
  - [ ] Test successful login
  - [ ] Test invalid email
  - [ ] Test wrong password
  - [ ] Test token generation
  - [ ] Test token claims
  - [ ] Test concurrent logins
  - [ ] Verify audit logging

### Token Management Tests (1.5 hours)
- [ ] Create TokenManagementIntegrationTest
  - [ ] `/backend/src/test/java/com/caioniehues/app/integration/TokenManagementIntegrationTest.java`
  - [ ] Test token refresh flow
  - [ ] Test refresh token rotation
  - [ ] Test expired token rejection
  - [ ] Test token blacklisting
  - [ ] Test logout flow
  - [ ] Test token validation
  - [ ] Test protected endpoint access

### Rate Limiting Tests (1 hour)
- [ ] Create RateLimitIntegrationTest
  - [ ] `/backend/src/test/java/com/caioniehues/app/integration/RateLimitIntegrationTest.java`
  - [ ] Test login rate limiting
  - [ ] Test registration rate limiting
  - [ ] Test rate limit reset
  - [ ] Test 429 responses
  - [ ] Test retry-after header
  - [ ] Test per-IP limiting

### Security Tests (1 hour)
- [ ] Create SecurityIntegrationTest
  - [ ] `/backend/src/test/java/com/caioniehues/app/integration/SecurityIntegrationTest.java`
  - [ ] Test SQL injection prevention
  - [ ] Test XSS prevention
  - [ ] Test CORS configuration
  - [ ] Test security headers
  - [ ] Test unauthorized access
  - [ ] Test token tampering

### Performance Tests (30 minutes)
- [ ] Create basic performance tests
  - [ ] Login response time baseline
  - [ ] Token validation performance
  - [ ] Concurrent user handling
  - [ ] Database connection pooling

## Definition of Done
- [ ] All integration tests passing
- [ ] Test coverage >90% for auth code
- [ ] No security vulnerabilities found
- [ ] Performance baselines established
- [ ] Tests run in CI pipeline
- [ ] Test documentation complete
- [ ] Edge cases covered

## Dev Notes
- Use @SpringBootTest for full context
- Use @AutoConfigureMockMvc for API testing
- Use @Testcontainers for database
- Implement test data cleanup
- Use RestAssured for API assertions
- Consider contract testing with Pact
- Add mutation testing with PIT

## Testing
- **Integration Tests**: Full auth flows
- **Security Tests**: Vulnerability checks
- **Performance Tests**: Response times
- **Test Command**: `./mvnw test -Dtest=*IntegrationTest`
- **Coverage Command**: `./mvnw jacoco:report`
- **Coverage Target**: 90%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Test flakiness | Medium | Medium | Proper test isolation |
| Slow test execution | Medium | Low | Parallel execution |
| Missing edge cases | Low | High | Comprehensive scenarios |

## File List
### Files to Create
- `/backend/src/test/java/com/caioniehues/app/integration/AuthRegistrationIntegrationTest.java`
- `/backend/src/test/java/com/caioniehues/app/integration/AuthLoginIntegrationTest.java`
- `/backend/src/test/java/com/caioniehues/app/integration/TokenManagementIntegrationTest.java`
- `/backend/src/test/java/com/caioniehues/app/integration/RateLimitIntegrationTest.java`
- `/backend/src/test/java/com/caioniehues/app/integration/SecurityIntegrationTest.java`
- `/backend/src/test/java/com/caioniehues/app/integration/BaseIntegrationTest.java`
- `/backend/src/test/java/com/caioniehues/app/util/TestDataBuilder.java`
- `/backend/src/test/java/com/caioniehues/app/util/AuthTestHelper.java`

### Files to Modify
- `/backend/pom.xml` - Add TestContainers, RestAssured
- `/backend/src/test/resources/application-test.yml` - Test configuration

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 1.3 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38