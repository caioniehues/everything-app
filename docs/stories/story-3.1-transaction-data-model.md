# Story 3.1: Transaction Data Model & Categories

## Story
As a developer,
I want to create the transaction schema with categories,
so that all financial movements are properly tracked.

## Status
**Status**: Draft
**Epic**: Epic 3 - Transaction Management
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Core financial tracking
**Estimated Days**: 3 days
**Story Points**: 5

## Acceptance Criteria
- [ ] Transaction entity: id, accountId, amount, type (INCOME/EXPENSE), date, description, categoryId
- [ ] Category entity: id, name, type, icon, color, parentId (for subcategories)
- [ ] Default categories created via migration (Food, Transport, Bills, Entertainment, etc.)
- [ ] Liquibase migration V3__create_transactions.sql with proper indexes
- [ ] Foreign key constraints to accounts and categories
- [ ] Amount stored as DECIMAL(19,2) with positive values
- [ ] Transaction type determines if amount is added or subtracted from account
- [ ] Audit fields: createdBy, createdAt, updatedBy, updatedAt
- [ ] Support for transaction notes and tags
- [ ] Receipt attachment reference field

## Dependencies
### Requires (Blocked By)
- [ ] Story 2.1 - Account Entity & Database Schema
- [ ] Story 1.3 - Authentication API (For audit fields)

### Enables (Blocks)
- [ ] Story 3.2 - Transaction CRUD API
- [ ] Story 4.1 - Budget Data Model
- [ ] Story 5.1 - Dashboard Implementation

## Tasks

### TDD Test Tasks (Do First!)
- [ ] Write tests for Transaction entity validation
- [ ] Write tests for Category entity and hierarchy
- [ ] Write tests for amount calculations
- [ ] Write tests for transaction-account relationship
- [ ] Write tests for category hierarchy
- [ ] Write repository integration tests

### Implementation Tasks
- [ ] Create Transaction entity
  - [ ] Define all fields with JPA annotations
  - [ ] Add validation annotations
  - [ ] Configure relationships
  - [ ] Add audit fields
- [ ] Create TransactionType enum
  - [ ] INCOME and EXPENSE values
  - [ ] Helper methods for calculations
- [ ] Create Category entity
  - [ ] Define fields and relationships
  - [ ] Self-referential parent relationship
  - [ ] Icon and color fields
  - [ ] System vs user categories
- [ ] Create CategoryType enum
  - [ ] INCOME and EXPENSE categories
  - [ ] Validation logic
- [ ] Create repositories
  - [ ] TransactionRepository with queries
  - [ ] CategoryRepository with hierarchy queries
  - [ ] Custom query methods
- [ ] Create database migrations
  - [ ] Categories table with self-reference
  - [ ] Transactions table
  - [ ] Default categories data
  - [ ] Indexes for performance
- [ ] Update Account entity
  - [ ] Add transaction relationship
  - [ ] Balance calculation logic
  - [ ] Transaction count

### Default Categories Tasks
- [ ] Define default expense categories
  - [ ] Food & Dining
  - [ ] Transportation
  - [ ] Shopping
  - [ ] Bills & Utilities
  - [ ] Entertainment
  - [ ] Healthcare
  - [ ] Education
  - [ ] Personal Care
- [ ] Define default income categories
  - [ ] Salary
  - [ ] Freelance
  - [ ] Investments
  - [ ] Gifts
  - [ ] Refunds
  - [ ] Other Income
- [ ] Create icon mappings
- [ ] Create color schemes

### Testing Tasks
- [ ] Unit tests for entities
- [ ] Integration tests for repositories
- [ ] Test cascade operations
- [ ] Test balance calculations
- [ ] Test category hierarchy
- [ ] Verify migration scripts

### Validation Tasks
- [ ] Verify database schema
- [ ] Test foreign key constraints
- [ ] Validate decimal precision
- [ ] Test category hierarchy queries
- [ ] Performance test with many transactions

## Dev Notes
- Use BigDecimal for amount to avoid precision issues
- Consider partitioning transactions table by date for scale
- Implement database triggers for balance updates
- Add composite index on (accountId, date) for queries
- Consider materialized views for reporting
- Category deletion should reassign transactions
- Implement soft delete for audit trail
- Consider adding recurring transaction support

## Testing
- **Unit Tests**: Entity validation and business logic
- **Integration Tests**: Repository operations with TestContainers
- **Performance Tests**: Query optimization
- **Test Command**: `./mvnw test`
- **Coverage Target**: 90% for entities, 85% for repositories

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Tests written and passing (>85% coverage)
- [ ] Database migrations tested
- [ ] Performance benchmarks met
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] No critical issues

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Balance calculation errors | Medium | Critical | Extensive testing, triggers |
| Performance with many transactions | Medium | High | Proper indexing, partitioning |
| Category hierarchy complexity | Low | Medium | Limit depth, clear queries |
| Data integrity issues | Low | Critical | Foreign keys, transactions |

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/domain/transaction/Transaction.java`
- `/backend/src/main/java/com/caioniehues/app/domain/transaction/TransactionType.java`
- `/backend/src/main/java/com/caioniehues/app/domain/category/Category.java`
- `/backend/src/main/java/com/caioniehues/app/domain/category/CategoryType.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/persistence/TransactionRepository.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/persistence/CategoryRepository.java`
- `/backend/src/main/resources/db/changelog/changes/003-create-categories.yaml`
- `/backend/src/main/resources/db/changelog/changes/004-create-transactions.yaml`
- `/backend/src/main/resources/db/changelog/changes/005-default-categories.yaml`
- `/backend/src/test/java/com/caioniehues/app/domain/transaction/TransactionTest.java`
- `/backend/src/test/java/com/caioniehues/app/domain/category/CategoryTest.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/persistence/TransactionRepositoryTest.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/persistence/CategoryRepositoryTest.java`

### Files to Modify
- `/backend/src/main/java/com/caioniehues/app/domain/account/Account.java` - Add transaction relationship
- `/backend/src/main/resources/db/changelog/db.changelog-master.yaml` - Include new migrations

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53