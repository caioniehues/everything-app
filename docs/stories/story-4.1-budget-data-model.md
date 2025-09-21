# Story 4.1: Budget Data Model

## Story
As a developer,
I want to create the budget schema with period tracking,
so that spending limits can be enforced.

## Status
**Status**: Draft
**Epic**: Epic 4 - Budget Creation & Tracking
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: MEDIUM - Budget management
**Estimated Days**: 2 days
**Story Points**: 3

## Acceptance Criteria
- [ ] Budget entity: id, name, period (WEEKLY/MONTHLY/YEARLY), startDate, endDate
- [ ] BudgetCategory entity: budgetId, categoryId, limit, spent (calculated)
- [ ] Liquibase migration V4__create_budgets.sql with constraints
- [ ] Support for multiple active budgets
- [ ] Budget templates for reuse across periods
- [ ] Rollover settings for unused/overspent amounts
- [ ] Alert thresholds (50%, 75%, 90%, 100% of limit)
- [ ] Historical budget data retained for comparison
- [ ] Budget sharing between family members
- [ ] Budget goals and milestones

## Dependencies
### Requires (Blocked By)
- [ ] Story 3.1 - Transaction Data Model & Categories
- [ ] Story 2.1 - Account Entity & Database Schema

### Enables (Blocks)
- [ ] Story 4.2 - Budget Management API
- [ ] Story 4.3 - Budget Setup Wizard
- [ ] Story 4.4 - Budget Tracking Dashboard

## Tasks

### TDD Test Tasks (Do First!)
- [ ] Write tests for Budget entity validation
- [ ] Write tests for BudgetCategory relationships
- [ ] Write tests for period calculations
- [ ] Write tests for rollover logic
- [ ] Write tests for alert thresholds
- [ ] Write repository integration tests

### Implementation Tasks
- [ ] Create Budget entity
  - [ ] Define core fields
  - [ ] Period enum (WEEKLY/MONTHLY/YEARLY/CUSTOM)
  - [ ] Status field (DRAFT/ACTIVE/COMPLETED)
  - [ ] User relationship
  - [ ] Template flag
- [ ] Create BudgetCategory entity
  - [ ] Budget relationship
  - [ ] Category relationship
  - [ ] Limit amount
  - [ ] Spent amount (calculated)
  - [ ] Alert thresholds
  - [ ] Rollover settings
- [ ] Create BudgetPeriod value object
  - [ ] Start date
  - [ ] End date
  - [ ] Period type
  - [ ] Recurrence rules
- [ ] Create BudgetTemplate entity
  - [ ] Template name
  - [ ] Category limits
  - [ ] Default settings
  - [ ] User/system templates
- [ ] Create repositories
  - [ ] BudgetRepository
  - [ ] BudgetCategoryRepository
  - [ ] BudgetTemplateRepository
  - [ ] Custom queries
- [ ] Create database migrations
  - [ ] Budgets table
  - [ ] Budget_categories table
  - [ ] Budget_templates table
  - [ ] Indexes for performance
  - [ ] Constraints and triggers

### Business Logic Tasks
- [ ] Period calculation logic
  - [ ] Week start/end
  - [ ] Month boundaries
  - [ ] Year periods
  - [ ] Custom periods
- [ ] Rollover calculations
  - [ ] Carry forward unused
  - [ ] Reset to zero
  - [ ] Average adjustments
- [ ] Spending calculations
  - [ ] Real-time aggregation
  - [ ] Category totals
  - [ ] Period filtering

### Testing Tasks
- [ ] Unit tests for entities
- [ ] Integration tests for repositories
- [ ] Period calculation tests
- [ ] Rollover logic tests
- [ ] Alert threshold tests

### Validation Tasks
- [ ] Verify schema design
- [ ] Test constraint violations
- [ ] Validate calculations
- [ ] Performance with many budgets

## Dev Notes
- Consider using database views for spending calculations
- Implement audit trail for budget changes
- Add support for shared family budgets
- Consider envelope budgeting method
- Implement zero-based budgeting support
- Add budget versioning for history
- Consider implementing budget goals/milestones
- Cache calculations for performance

## Testing
- **Unit Tests**: Entity validation and logic
- **Integration Tests**: Repository and calculations
- **Test Command**: `./mvnw test`
- **Coverage Target**: 90% for critical logic

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Tests written and passing
- [ ] Database migrations tested
- [ ] Calculations accurate
- [ ] Code reviewed and approved
- [ ] Documentation updated

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Complex period calculations | Medium | Medium | Comprehensive testing |
| Performance with spending calc | Medium | High | Caching, indexing |
| Rollover logic errors | Low | Medium | Clear business rules |

## File List
### Files to Create
- `/backend/src/main/java/com/caioniehues/app/domain/budget/Budget.java`
- `/backend/src/main/java/com/caioniehues/app/domain/budget/BudgetCategory.java`
- `/backend/src/main/java/com/caioniehues/app/domain/budget/BudgetPeriod.java`
- `/backend/src/main/java/com/caioniehues/app/domain/budget/BudgetPeriodType.java`
- `/backend/src/main/java/com/caioniehues/app/domain/budget/BudgetTemplate.java`
- `/backend/src/main/java/com/caioniehues/app/domain/budget/RolloverType.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/persistence/BudgetRepository.java`
- `/backend/src/main/java/com/caioniehues/app/infrastructure/persistence/BudgetCategoryRepository.java`
- `/backend/src/main/resources/db/changelog/changes/006-create-budgets.yaml`
- `/backend/src/test/java/com/caioniehues/app/domain/budget/BudgetTest.java`
- `/backend/src/test/java/com/caioniehues/app/domain/budget/BudgetCategoryTest.java`
- `/backend/src/test/java/com/caioniehues/app/infrastructure/persistence/BudgetRepositoryTest.java`

### Files to Modify
- `/backend/src/main/resources/db/changelog/db.changelog-master.yaml` - Include migration

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53