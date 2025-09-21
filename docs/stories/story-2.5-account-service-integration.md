# Story 2.5: Account Service Integration & State

## Story
As a developer,
I want to integrate the account UI with backend APIs using proper state management,
so that account data stays synchronized.

## Status
**Status**: Draft
**Epic**: Epic 2 - Financial Accounts & Core Data Model
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Critical integration layer
**Estimated Days**: 2 days
**Story Points**: 3

## Acceptance Criteria
- [ ] Riverpod providers created for account list and individual accounts
- [ ] API service methods for all account CRUD operations
- [ ] Optimistic updates for better perceived performance
- [ ] Error handling with retry logic for failed requests
- [ ] Account state persists across navigation
- [ ] Real-time balance updates when modified by transactions
- [ ] Proper loading and error states in UI
- [ ] Unit tests for account providers and services
- [ ] Offline support with local caching
- [ ] Automatic refresh on app resume

## Dependencies
### Requires (Blocked By)
- [ ] Story 2.3 - Account List UI
- [ ] Story 2.4 - Add/Edit Account UI
- [ ] Story 2.2 - Account Management API

### Enables (Blocks)
- [ ] Story 3.5 - Transaction Service Integration
- [ ] Story 5.2 - Dashboard State Management

## Tasks

### Implementation Tasks
- [ ] Create account service layer
  - [ ] AccountService class
  - [ ] API endpoint mappings
  - [ ] Request/response handling
  - [ ] Error transformation
- [ ] Implement API methods
  - [ ] fetchAccounts()
  - [ ] fetchAccount(id)
  - [ ] createAccount(data)
  - [ ] updateAccount(id, data)
  - [ ] deleteAccount(id)
  - [ ] fetchAccountSummary()
- [ ] Create Riverpod providers
  - [ ] accountListProvider (FutureProvider)
  - [ ] accountProvider(id) (FutureProvider.family)
  - [ ] selectedAccountProvider (StateProvider)
  - [ ] netWorthProvider (computed)
  - [ ] accountFormProvider (StateNotifier)
- [ ] Implement state management
  - [ ] Account list state
  - [ ] Individual account state
  - [ ] Form state
  - [ ] Selection state
  - [ ] Filter/sort state
- [ ] Add optimistic updates
  - [ ] Immediate UI update on create
  - [ ] Immediate UI update on edit
  - [ ] Rollback on failure
  - [ ] Sync with server response
- [ ] Implement caching
  - [ ] Cache account list
  - [ ] Cache individual accounts
  - [ ] Cache invalidation strategy
  - [ ] Background refresh
- [ ] Add error handling
  - [ ] Network error recovery
  - [ ] Validation error display
  - [ ] Retry mechanism
  - [ ] User-friendly messages
- [ ] Implement real-time updates
  - [ ] Balance change listeners
  - [ ] Transaction impact updates
  - [ ] WebSocket integration (future)

### State Synchronization Tasks
- [ ] Cross-screen state sync
  - [ ] List to detail sync
  - [ ] Form to list sync
  - [ ] Dashboard sync
- [ ] Background refresh
  - [ ] On app resume
  - [ ] Periodic refresh
  - [ ] Pull-to-refresh trigger
- [ ] Conflict resolution
  - [ ] Optimistic update conflicts
  - [ ] Concurrent edit handling

### Testing Tasks
- [ ] Unit tests for AccountService
- [ ] Unit tests for providers
- [ ] Test optimistic updates
- [ ] Test error scenarios
- [ ] Test caching logic
- [ ] Test state persistence
- [ ] Integration tests for data flow

### Validation Tasks
- [ ] Verify state consistency
- [ ] Test offline scenarios
- [ ] Verify memory leaks
- [ ] Performance profiling
- [ ] Test with slow network

## Dev Notes
- Use AsyncValue for proper loading/error states
- Implement proper disposal for providers
- Consider using freezed for state classes
- Add logging for debugging state changes
- Implement exponential backoff for retries
- Use select() for granular rebuilds
- Consider implementing undo functionality
- Add telemetry for state changes

## Testing
- **Unit Tests**: All providers and services
- **Integration Tests**: Full data flow scenarios
- **Test Command**: `flutter test`
- **Coverage Target**: 90% for business logic

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Unit tests written and passing (>90%)
- [ ] Integration tests passing
- [ ] No memory leaks
- [ ] Performance benchmarks met
- [ ] Code reviewed and approved
- [ ] Documentation updated

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| State synchronization bugs | Medium | High | Comprehensive testing |
| Memory leaks from providers | Low | High | Proper disposal, profiling |
| Race conditions | Medium | Medium | Proper async handling |
| Cache invalidation issues | Medium | Low | Clear cache strategy |

## File List
### Files to Create
- `/frontend/lib/features/accounts/data/services/account_service.dart`
- `/frontend/lib/features/accounts/presentation/providers/account_list_provider.dart`
- `/frontend/lib/features/accounts/presentation/providers/account_detail_provider.dart`
- `/frontend/lib/features/accounts/presentation/providers/account_form_state.dart`
- `/frontend/lib/features/accounts/presentation/providers/net_worth_provider.dart`
- `/frontend/lib/features/accounts/domain/usecases/fetch_accounts.dart`
- `/frontend/lib/features/accounts/domain/usecases/create_account.dart`
- `/frontend/lib/features/accounts/domain/usecases/update_account.dart`
- `/frontend/lib/features/accounts/domain/usecases/delete_account.dart`
- `/frontend/lib/shared/providers/cache_provider.dart`
- `/frontend/test/features/accounts/data/services/account_service_test.dart`
- `/frontend/test/features/accounts/presentation/providers/account_providers_test.dart`

### Files to Modify
- `/frontend/lib/core/network/api_client.dart` - Add account endpoints
- `/frontend/lib/shared/providers/app_state_provider.dart` - Add account state

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53