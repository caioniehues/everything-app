# Story 3.2: Transaction CRUD API

## Story
As a user,
I want API endpoints to manage transactions,
so that I can record all money movements.

## Status
**Status**: Draft
**Epic**: Epic 3 - Transaction Management
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Core functionality
**Estimated Days**: 4 days
**Story Points**: 5

## Acceptance Criteria
- [ ] GET /api/v1/transactions with filters (account, date range, category, type)
- [ ] GET /api/v1/transactions/{id} returns single transaction
- [ ] POST /api/v1/transactions creates transaction and updates account balance
- [ ] PUT /api/v1/transactions/{id} updates transaction and recalculates balances
- [ ] DELETE /api/v1/transactions/{id} removes transaction and adjusts balance
- [ ] Bulk operations endpoint for multiple transactions
- [ ] Transaction validation ensures sufficient funds for expenses
- [ ] All operations wrapped in database transactions for consistency
- [ ] Pagination support for transaction lists
- [ ] Audit trail for all modifications

## Dependencies
### Requires (Blocked By)
- [ ] Story 3.1 - Transaction Data Model & Categories
- [ ] Story 2.2 - Account Management API
- [ ] Story 1.3 - Authentication API

### Enables (Blocks)
- [ ] Story 3.3 - Transaction List & Filtering UI
- [ ] Story 4.2 - Budget CRUD API
- [ ] Story 5.3 - Analytics & Reports API

## Tasks

### TDD Test Tasks (Do First!)
- [ ] Write tests for transaction validation
- [ ] Write tests for balance calculations
- [ ] Write tests for filter logic
- [ ] Write tests for bulk operations
- [ ] Write tests for concurrent updates
- [ ] Write integration tests for endpoints

### Implementation Tasks
- [ ] Create DTOs
  - [ ] TransactionRequest DTO
  - [ ] TransactionResponse DTO
  - [ ] TransactionFilterRequest DTO
  - [ ] BulkTransactionRequest DTO
  - [ ] TransactionSummaryResponse DTO
- [ ] Create TransactionMapper
  - [ ] Entity to DTO mappings
  - [ ] DTO to entity mappings
  - [ ] Include category and account info
- [ ] Implement TransactionService
  - [ ] Create transaction with balance update
  - [ ] Update transaction with balance recalc
  - [ ] Delete transaction with balance revert
  - [ ] Filter and search logic
  - [ ] Bulk operations
  - [ ] Validation logic
  - [ ] Balance calculation service
- [ ] Create TransactionController
  - [ ] GET endpoints with filters
  - [ ] POST create endpoint
  - [ ] PUT update endpoint
  - [ ] DELETE endpoint
  - [ ] Bulk operations endpoint
  - [ ] Export endpoint (CSV/JSON)
- [ ] Implement balance management
  - [ ] Atomic balance updates
  - [ ] Transaction rollback on failure
  - [ ] Balance history tracking
  - [ ] Running balance calculation
- [ ] Add validation
  - [ ] Amount validation
  - [ ] Date validation
  - [ ] Category validation
  - [ ] Sufficient funds check
  - [ ] Account ownership

### Business Logic Tasks
- [ ] Transaction rules
  - [ ] Cannot modify locked transactions
  - [ ] Cannot delete reconciled transactions
  - [ ] Transfer between accounts
  - [ ] Split transactions support
- [ ] Balance integrity
  - [ ] Pessimistic locking
  - [ ] Consistency checks
  - [ ] Recovery procedures

### Testing Tasks
- [ ] Unit tests for service (>90% coverage)
- [ ] Integration tests for controller
- [ ] Concurrent update tests
- [ ] Performance tests with large datasets
- [ ] Test transaction rollback

### Validation Tasks
- [ ] Test all CRUD operations
- [ ] Verify balance calculations
- [ ] Test filter combinations
- [ ] Load test with 10k+ transactions
- [ ] Test bulk operations

## Dev Notes
- Use database transactions for all operations
- Implement optimistic locking for accounts
- Consider event sourcing for transaction history
- Add database triggers for balance consistency
- Implement caching for frequently accessed data
- Use batch operations for bulk imports
- Consider implementing double-entry bookkeeping
- Add support for pending transactions

## Testing
- **Unit Tests**: Business logic and calculations
- **Integration Tests**: Full API flow with balance updates
- **Performance Tests**: Large dataset handling
- **Test Command**: `./mvnw test`
- **Coverage Target**: 90% for critical paths

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Tests written and passing (>90% coverage)
- [ ] Balance integrity maintained
- [ ] API documentation complete
- [ ] Performance benchmarks met
- [ ] Code reviewed and approved
- [ ] No data integrity issues

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Balance calculation errors | Medium | Critical | Extensive testing, DB triggers |
| Race conditions | Medium | High | Proper locking strategy |
| Performance degradation | Medium | Medium | Indexing, pagination |
| Data loss | Low | Critical | Transaction rollback, backups |

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/application/dto/request/TransactionRequest.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/request/TransactionFilterRequest.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/request/BulkTransactionRequest.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/response/TransactionResponse.java`
- `/backend/src/main/java/com/caioniehues/app/application/dto/response/TransactionSummaryResponse.java`
- `/backend/src/main/java/com/caioniehues/app/application/service/TransactionService.java`
- `/backend/src/main/java/com/caioniehues/app/application/service/BalanceService.java`
- `/backend/src/main/java/com/caioniehues/app/application/mapper/TransactionMapper.java`
- `/backend/src/main/java/com/caioniehues/app/presentation/controller/TransactionController.java`
- `/backend/src/test/java/com/caioniehues/app/application/service/TransactionServiceTest.java`
- `/backend/src/test/java/com/caioniehues/app/application/service/BalanceServiceTest.java`
- `/backend/src/test/java/com/caioniehues/app/presentation/controller/TransactionControllerTest.java`
- `/backend/src/test/java/com/caioniehues/app/integration/TransactionIntegrationTest.java`

### Files to Modify
- `/backend/src/main/java/com/caioniehues/app/domain/account/Account.java` - Add balance update methods

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53