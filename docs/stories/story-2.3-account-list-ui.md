# Story 2.3: Account List UI

## Story
As a user,
I want to view all my financial accounts in one place,
so that I can see my overall financial position.

## Status
**Status**: Draft
**Epic**: Epic 2 - Financial Accounts & Core Data Model
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Primary user interface
**Estimated Days**: 2 days
**Story Points**: 3

## Acceptance Criteria
- [ ] Accounts screen displays grid/list of account cards
- [ ] Each card shows: account name, type icon, current balance, last updated
- [ ] Color coding for positive (green) and negative (red) balances
- [ ] Total net worth calculation displayed prominently
- [ ] Responsive layout: grid on desktop, list on mobile
- [ ] Pull-to-refresh updates account data
- [ ] Loading states while fetching data
- [ ] Empty state when no accounts exist with "Add Account" prompt
- [ ] Account cards are tappable for detail view
- [ ] Smooth animations for list updates

## Dependencies
### Requires (Blocked By)
- [ ] Story 1.2 - Flutter Project Structure
- [ ] Story 2.2 - Account Management API
- [ ] Story 1.4 - Flutter Auth Screens (For authenticated state)

### Enables (Blocks)
- [ ] Story 2.4 - Add/Edit Account UI
- [ ] Story 3.3 - Transaction List UI
- [ ] Story 5.1 - Dashboard Implementation

## Tasks

### Design Tasks
- [ ] Review UI/UX specifications for account cards
- [ ] Confirm color scheme for account types
- [ ] Design loading shimmer effect
- [ ] Design empty state illustration

### Implementation Tasks
- [ ] Create Account feature structure
  - [ ] `/lib/features/accounts/` folder structure
  - [ ] Domain entities
  - [ ] Data models
  - [ ] Presentation layer
- [ ] Create Account models
  - [ ] Account entity
  - [ ] AccountType enum
  - [ ] Account model for API
- [ ] Create AccountCard widget
  - [ ] Card layout with icon, name, balance
  - [ ] Type-specific icons
  - [ ] Balance formatting
  - [ ] Color coding logic
  - [ ] Tap handler
- [ ] Create AccountListScreen
  - [ ] App bar with title and actions
  - [ ] Net worth summary header
  - [ ] Responsive grid/list view
  - [ ] Pull-to-refresh
  - [ ] FAB for add account
- [ ] Implement responsive layout
  - [ ] Grid view for tablet/desktop
  - [ ] List view for mobile
  - [ ] Breakpoint handling
- [ ] Create empty state
  - [ ] Illustration/icon
  - [ ] Helpful message
  - [ ] Add account button
- [ ] Add loading states
  - [ ] Shimmer effect for cards
  - [ ] Loading indicator
  - [ ] Error state handling

### State Management Tasks
- [ ] Create account providers
  - [ ] Account list provider
  - [ ] Net worth calculation provider
  - [ ] Selected account provider
- [ ] Implement data fetching
  - [ ] API integration
  - [ ] Error handling
  - [ ] Retry logic
- [ ] Add caching logic
  - [ ] Cache account data
  - [ ] Background refresh

### Testing Tasks
- [ ] Widget tests for AccountCard
- [ ] Widget tests for AccountListScreen
- [ ] Test responsive breakpoints
- [ ] Test pull-to-refresh
- [ ] Test empty state
- [ ] Test loading states
- [ ] Integration tests for data flow

### Validation Tasks
- [ ] Test on multiple screen sizes
- [ ] Verify responsive layout
- [ ] Test with 0, 1, many accounts
- [ ] Verify balance calculations
- [ ] Test error scenarios

## Dev Notes
- Use NumberFormat for currency display
- Consider account ordering (by type, balance, or custom)
- Implement skeleton loading for better perceived performance
- Add haptic feedback for interactions
- Consider implementing account grouping by type
- Cache net worth calculation for performance
- Use Hero animations for account card transitions

## Testing
- **Widget Tests**: All UI components
- **Integration Tests**: Data flow and state management
- **Test Command**: `flutter test`
- **Coverage Target**: 80% for widgets, 90% for logic

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Widget tests written and passing
- [ ] Responsive on all screen sizes
- [ ] Smooth animations (60 FPS)
- [ ] No UI glitches or layout issues
- [ ] Code reviewed and approved
- [ ] Accessibility tested

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Performance with many accounts | Low | Medium | Virtual scrolling, pagination |
| Complex responsive layout | Medium | Low | Thorough testing on devices |
| State synchronization | Low | Medium | Proper provider setup |

## File List
### Files to Create
- `/frontend/lib/features/accounts/domain/entities/account.dart`
- `/frontend/lib/features/accounts/domain/entities/account_type.dart`
- `/frontend/lib/features/accounts/data/models/account_model.dart`
- `/frontend/lib/features/accounts/data/repositories/account_repository.dart`
- `/frontend/lib/features/accounts/data/datasources/account_remote_datasource.dart`
- `/frontend/lib/features/accounts/presentation/screens/account_list_screen.dart`
- `/frontend/lib/features/accounts/presentation/widgets/account_card.dart`
- `/frontend/lib/features/accounts/presentation/widgets/net_worth_header.dart`
- `/frontend/lib/features/accounts/presentation/widgets/account_empty_state.dart`
- `/frontend/lib/features/accounts/presentation/providers/account_providers.dart`
- `/frontend/test/features/accounts/presentation/screens/account_list_screen_test.dart`
- `/frontend/test/features/accounts/presentation/widgets/account_card_test.dart`

### Files to Modify
- `/frontend/lib/core/router/app_router.dart` - Add accounts route
- `/frontend/lib/shared/widgets/responsive_builder.dart` - Use for layout

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53