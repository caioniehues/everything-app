# Story 2.1: Account Entity & Database Schema

## Story
As a developer,
I want to create the account data model with proper relationships,
so that financial data is structured correctly in the database.

## Status
**Status**: Draft
**Epic**: Epic 2 - Financial Accounts & Core Data Model
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Foundation for all financial features
**Estimated Days**: 2 days
**Story Points**: 3

## Acceptance Criteria
- [ ] Account entity created with fields: id, name, type, balance, currency, userId, createdAt, updatedAt
- [ ] Account types enum: CHECKING, SAVINGS, CREDIT_CARD, INVESTMENT, LOAN, CASH
- [ ] Liquibase migration V2__create_accounts.sql creates accounts table with indexes
- [ ] JPA relationships established between User and Account entities (One-to-Many)
- [ ] Currency stored as ISO 4217 code (USD, EUR, etc.)
- [ ] Balance field uses DECIMAL(19,2) for precise financial calculations
- [ ] Soft delete implemented with deletedAt timestamp field
- [ ] Database constraints ensure account names are unique per user

## Dependencies
### Requires (Blocked By)
- [x] Story 1.1 - Backend Infrastructure (Complete)
- [ ] Story 1.3 - Authentication API (For user context)

### Enables (Blocks)
- [ ] Story 2.2 - Account Management API
- [ ] Story 3.1 - Transaction Data Model
- [ ] Story 4.1 - Budget Data Model

## Tasks

### TDD Test Tasks (Do First!)
- [ ] Write tests for Account entity validation
- [ ] Write tests for Account-User relationship
- [ ] Write tests for AccountType enum
- [ ] Write tests for currency validation
- [ ] Write tests for balance precision
- [ ] Write repository integration tests

### Implementation Tasks
- [ ] Create Account entity
  - [ ] Define all fields with JPA annotations
  - [ ] Add validation annotations
  - [ ] Implement soft delete
  - [ ] Add audit fields
- [ ] Create AccountType enum
  - [ ] Define all account types
  - [ ] Add display names
  - [ ] Add icon mappings
- [ ] Create AccountRepository
  - [ ] Extend JpaRepository
  - [ ] Add custom query methods
  - [ ] Add soft delete queries
- [ ] Create database migration
  - [ ] Create accounts table
  - [ ] Add indexes on userId, type
  - [ ] Add unique constraint on (userId, name, deletedAt)
  - [ ] Add foreign key to users table
- [ ] Update User entity
  - [ ] Add OneToMany relationship to accounts
  - [ ] Configure cascade options
  - [ ] Add helper methods

### Testing Tasks
- [ ] Unit tests for Account entity
- [ ] Integration tests for AccountRepository
- [ ] Test cascade operations
- [ ] Test soft delete functionality
- [ ] Test unique constraints
- [ ] Verify migration script

### Validation Tasks
- [ ] Verify database schema matches requirements
- [ ] Test all constraint violations
- [ ] Confirm decimal precision for money
- [ ] Validate relationship mappings
- [ ] Check index performance

## Dev Notes
- Use BigDecimal for balance to avoid floating point issues
- Consider adding 'isActive' flag for account status
- Implement @SQLDelete and @Where for soft delete
- Add database triggers for updated_at timestamp
- Consider currency conversion requirements for future
- Account balance should never be directly modified (only through transactions)

## Testing
- **Unit Tests**: Account entity validation
- **Integration Tests**: Repository operations with TestContainers
- **Test Command**: `./mvnw test`
- **Coverage Target**: 90% for entity and repository

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Unit tests written and passing (>90% coverage)
- [ ] Integration tests passing
- [ ] Code reviewed and approved
- [ ] Database migration tested on clean database
- [ ] No critical bugs or security issues
- [ ] Documentation updated

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Decimal precision issues | Medium | High | Use BigDecimal, extensive testing |
| Cascade delete problems | Low | High | Careful cascade configuration |
| Performance with many accounts | Low | Medium | Proper indexing strategy |

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/domain/account/Account.java`
- `/backend/src/main/java/com/caioniehues/app/domain/account/AccountType.java`
- `/backend/src/main/java/com/caioniehues/app/domain/account/Currency.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/persistence/AccountRepository.java`
- `/backend/src/main/resources/db/changelog/changes/002-create-accounts.yaml`
- `/backend/src/test/java/com/caioniehues/app/domain/account/AccountTest.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/persistence/AccountRepositoryTest.java`

### Files to Modify
- `/backend/src/main/java/com/caioniehues/app/domain/user/User.java` - Add account relationship
- `/backend/src/main/resources/db/changelog/db.changelog-master.yaml` - Include new migration

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53