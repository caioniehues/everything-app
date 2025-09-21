# Story 2.2: Account Management API

## Story
As a family member,
I want RESTful endpoints to manage my financial accounts,
so that I can track different sources of money.

## Status
**Status**: Draft
**Epic**: Epic 2 - Financial Accounts & Core Data Model
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Core functionality
**Estimated Days**: 3 days
**Story Points**: 5

## Acceptance Criteria
- [ ] GET /api/v1/accounts returns paginated list of user's accounts
- [ ] GET /api/v1/accounts/{id} returns single account details
- [ ] POST /api/v1/accounts creates new account with validation
- [ ] PUT /api/v1/accounts/{id} updates account details
- [ ] DELETE /api/v1/accounts/{id} soft deletes account (if balance is zero)
- [ ] DTOs created for AccountRequest and AccountResponse with MapStruct mapping
- [ ] Service layer implements business logic with proper transaction boundaries
- [ ] Account balance cannot be directly modified (only through transactions)
- [ ] All endpoints require authentication
- [ ] Users can only access their own accounts

## Dependencies
### Requires (Blocked By)
- [ ] Story 2.1 - Account Entity & Database Schema
- [ ] Story 1.3 - Authentication API (For JWT validation)

### Enables (Blocks)
- [ ] Story 2.3 - Account List UI
- [ ] Story 2.4 - Add/Edit Account UI
- [ ] Story 3.2 - Transaction CRUD API

## Tasks

### TDD Test Tasks (Do First!)
- [ ] Write unit tests for AccountService
- [ ] Write tests for account validation logic
- [ ] Write tests for authorization checks
- [ ] Write controller integration tests
- [ ] Write tests for DTO mapping
- [ ] Write tests for pagination

### Implementation Tasks
- [ ] Create DTOs
  - [ ] AccountRequest DTO with validation
  - [ ] AccountResponse DTO
  - [ ] AccountSummaryResponse DTO
  - [ ] PagedAccountResponse DTO
- [ ] Create AccountMapper (MapStruct)
  - [ ] Entity to DTO mappings
  - [ ] DTO to entity mappings
  - [ ] Configure MapStruct
- [ ] Implement AccountService
  - [ ] Create account method
  - [ ] Get accounts with pagination
  - [ ] Get single account
  - [ ] Update account
  - [ ] Delete account (with balance check)
  - [ ] Authorization checks
  - [ ] Transaction boundaries
- [ ] Create AccountController
  - [ ] REST endpoints with proper HTTP methods
  - [ ] Request validation
  - [ ] Exception handling
  - [ ] OpenAPI documentation
  - [ ] Response status codes
- [ ] Add validation logic
  - [ ] Account name validation
  - [ ] Balance validation
  - [ ] Currency validation
  - [ ] Duplicate name check

### Security Tasks
- [ ] Implement @PreAuthorize annotations
- [ ] Add user context validation
- [ ] Prevent cross-user access
- [ ] Add audit logging
- [ ] Rate limiting considerations

### Testing Tasks
- [ ] Unit tests for service layer (>90% coverage)
- [ ] Integration tests for controller
- [ ] Test authorization scenarios
- [ ] Test validation edge cases
- [ ] Test pagination
- [ ] Test soft delete

### Validation Tasks
- [ ] Test all CRUD operations
- [ ] Verify authorization works
- [ ] Test with multiple users
- [ ] Verify OpenAPI documentation
- [ ] Performance testing with many accounts

## Dev Notes
- Use @Transactional carefully to avoid long-running transactions
- Consider implementing account archiving vs deletion
- Add support for account icons/colors in future iteration
- Implement optimistic locking for concurrent updates
- Consider adding account notes/description field
- Balance modifications should trigger events for audit

## Testing
- **Unit Tests**: Service layer business logic
- **Integration Tests**: Full API flow with TestContainers
- **Security Tests**: Authorization and authentication
- **Test Command**: `./mvnw test`
- **Coverage Target**: 90% for service, 80% for controller

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Unit tests written and passing (>90% coverage)
- [ ] Integration tests passing
- [ ] API documentation complete
- [ ] Code reviewed and approved
- [ ] No critical bugs or security issues
- [ ] Postman collection updated

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Concurrent update conflicts | Medium | Medium | Optimistic locking |
| Authorization bypass | Low | Critical | Thorough testing, security review |
| Performance with pagination | Low | Low | Proper indexing, query optimization |

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/application/dto/request/AccountRequest.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/response/AccountResponse.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/response/AccountSummaryResponse.java`
- `/backend/src/main/java/com/caioniehues/app/application/service/AccountService.java`
- `/backend/src/main/java/com/caioniehues/app/application/mapper/AccountMapper.java`
- `/backend/src/main/java/com/caioniehues/app/presentation/controller/AccountController.java`
- `/backend/src/test/java/com/caioniehues/app/application/service/AccountServiceTest.java`
- `/backend/src/test/java/com/caioniehues/app/presentation/controller/AccountControllerTest.java`
- `/backend/src/test/java/com/caioniehues/app/integration/AccountIntegrationTest.java`

### Files to Modify
- `/backend/src/main/java/com/caioniehues/app/config/SecurityConfig.java` - Add account endpoints

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53