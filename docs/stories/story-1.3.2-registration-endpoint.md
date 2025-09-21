# Story 1.3.2: Registration Endpoint & User Creation

## Story
As a family administrator,
I want to register new family members with secure password requirements,
so that each member has their own secure account.

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
- [ ] POST /api/v1/auth/register creates new users
- [ ] Password hashed with BCrypt (strength 12)
- [ ] Email uniqueness validated
- [ ] Password complexity rules enforced (8+ chars, uppercase, lowercase, number, special)
- [ ] Registration returns user details (without password)
- [ ] Proper validation error messages returned
- [ ] Registration events logged for audit
- [ ] Integration tests cover all scenarios

## Dependencies
### Requires (Blocked By)
- [ ] Story 1.3.1 - JWT Service & Token Infrastructure
- [ ] Story 1.1 - User entity and repository created

### Enables (Blocks)
- [ ] Story 1.3.3 - Login/Logout Endpoints
- [ ] Story 1.4 - Flutter Auth Screens (registration UI)

### Integration Points
- **Input**: Registration request with user details
- **Output**: Created user with hashed password
- **Handoff**: User available for login

## Tasks

### TDD Test Tasks (2 hours)
- [ ] Write AuthServiceTest for registration
  - [ ] Test successful registration
  - [ ] Test duplicate email rejection
  - [ ] Test password validation
  - [ ] Test password hashing
  - [ ] Test role assignment
  - [ ] Test audit logging
- [ ] Write AuthControllerTest for registration
  - [ ] Test valid registration request
  - [ ] Test invalid email format
  - [ ] Test weak password rejection
  - [ ] Test missing fields
  - [ ] Test response format

### DTOs Creation (1 hour)
- [ ] Create RegisterRequest DTO
  - [ ] `/backend/src/main/java/com/caioniehues/app/application/dto/request/RegisterRequest.java`
  - [ ] Email field with validation
  - [ ] Password field with validation
  - [ ] First name and last name
  - [ ] Optional phone number
- [ ] Create UserResponse DTO
  - [ ] `/backend/src/main/java/com/caioniehues/app/application/dto/response/UserResponse.java`
  - [ ] User ID, email, names
  - [ ] Role information
  - [ ] Created/updated timestamps
  - [ ] Exclude sensitive data

### Password Validation (1.5 hours)
- [ ] Create PasswordValidator
  - [ ] `/backend/src/main/java/com/caioniehues/app/application/validation/PasswordValidator.java`
  - [ ] Minimum length check (8 chars)
  - [ ] Uppercase letter requirement
  - [ ] Lowercase letter requirement
  - [ ] Number requirement
  - [ ] Special character requirement
  - [ ] Common password check
- [ ] Create custom annotation @ValidPassword
  - [ ] Apply to RegisterRequest DTO
  - [ ] Return meaningful error messages

### Service Implementation (2 hours)
- [ ] Implement AuthService.register()
  - [ ] `/backend/src/main/java/com/caioniehues/app/application/service/AuthService.java`
  - [ ] Check email uniqueness
  - [ ] Hash password with BCrypt
  - [ ] Create user entity
  - [ ] Assign default role (FAMILY_MEMBER)
  - [ ] Save to database
  - [ ] Log registration event
  - [ ] Return UserResponse DTO
- [ ] Handle registration exceptions
  - [ ] DuplicateEmailException
  - [ ] InvalidPasswordException
  - [ ] RegistrationFailedException

### Controller Implementation (1 hour)
- [ ] Create AuthController.register()
  - [ ] `/backend/src/main/java/com/caioniehues/app/presentation/controller/AuthController.java`
  - [ ] POST /api/v1/auth/register
  - [ ] Validate request body
  - [ ] Call AuthService
  - [ ] Return 201 Created
  - [ ] Handle validation errors (400)
  - [ ] Handle duplicate email (409)

### Integration Testing (30 minutes)
- [ ] Write integration test
  - [ ] Test full registration flow
  - [ ] Verify database persistence
  - [ ] Check password encryption
  - [ ] Validate response format

## Definition of Done
- [ ] Registration endpoint working
- [ ] Passwords properly hashed
- [ ] Email uniqueness enforced
- [ ] Password complexity validated
- [ ] All tests passing (90%+ coverage)
- [ ] Audit logging implemented
- [ ] API documented

## Dev Notes
- Use BCrypt with cost factor 12
- Consider email verification flow (future)
- Add rate limiting to prevent abuse
- Log failed registration attempts
- Sanitize error messages to prevent information leakage
- Consider GDPR compliance for data storage

## Testing
- **Unit Tests**: Service logic, validation
- **Controller Tests**: Request/response handling
- **Integration Tests**: Full registration flow
- **Test Command**: `./mvnw test -Dtest=*Registration*,*AuthService*`
- **Coverage Target**: 90%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Weak passwords | Medium | High | Strong validation rules |
| Email enumeration | Medium | Medium | Generic error messages |
| Registration spam | Medium | Low | Rate limiting (Story 1.3.4) |

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/application/dto/request/RegisterRequest.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/response/UserResponse.java`
- `/backend/src/main/java/com/caioniehues/app/application/validation/PasswordValidator.java`
- `/backend/src/main/java/com/caioniehues/app/application/validation/ValidPassword.java`
- `/backend/src/main/java/com/caioniehues/app/application/service/AuthService.java`
- `/backend/src/main/java/com/caioniehues/app/application/exception/DuplicateEmailException.java`
- `/backend/src/test/java/com/caioniehues/app/application/service/AuthServiceRegistrationTest.java`

### Files to Modify
- `/backend/src/main/java/com/caioniehues/app/presentation/controller/AuthController.java`

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 1.3 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38