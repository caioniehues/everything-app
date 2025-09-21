# Story 3.4.1: Transaction Form & Validation

## Story
As a user,
I want to add and edit transactions with a well-designed form,
so that I can accurately record my financial activities.

## Status
**Status**: Draft
**Epic**: Epic 3 - Transaction Management
**Parent Story**: 3.4 - Add/Edit Transaction Flow
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Core functionality
**Estimated Days**: 1.5 days
**Story Points**: 3

## Acceptance Criteria
- [ ] Floating action button opens transaction form
- [ ] Form includes: amount, account, category, date, description fields
- [ ] Amount field uses numeric keypad with decimal support
- [ ] Date picker defaults to today with easy navigation
- [ ] Account dropdown shows all active accounts
- [ ] Form validation prevents invalid submissions
- [ ] Edit mode pre-fills existing transaction data
- [ ] Responsive layout for mobile and desktop

## Dependencies
### Requires (Blocked By)
- [ ] Story 3.3 - Transaction List UI
- [ ] Story 3.2 - Transaction CRUD API
- [ ] Story 2.3 - Account List (for account selector)

### Enables (Blocks)
- [ ] Story 3.4.2 - Category Selection & Calculator
- [ ] Story 3.4.3 - Advanced Features

### Integration Points
- **Input**: Transaction data from user or existing record
- **Output**: Validated transaction ready for API
- **Handoff**: Form state to category selector and calculator

## Tasks

### Form Screen Setup (3 hours)
- [ ] Create TransactionFormScreen
  - [ ] `/frontend/lib/features/transactions/presentation/screens/transaction_form_screen.dart`
  - [ ] Configure route with parameters (edit mode)
  - [ ] Implement responsive layout
  - [ ] Handle keyboard appearance
  - [ ] Add app bar with save/cancel actions
- [ ] Create form provider
  - [ ] `/frontend/lib/features/transactions/presentation/providers/transaction_form_provider.dart`
  - [ ] Form state management
  - [ ] Validation logic
  - [ ] Draft saving
  - [ ] Edit mode handling

### Core Form Fields (4 hours)
- [ ] Implement amount field
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/amount_input_field.dart`
  - [ ] Custom numeric keyboard
  - [ ] Currency formatting
  - [ ] Decimal point handling
  - [ ] Negative amount toggle
  - [ ] Real-time formatting
- [ ] Create account selector
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/account_dropdown.dart`
  - [ ] Load accounts from provider
  - [ ] Display account name and balance
  - [ ] Handle no accounts scenario
- [ ] Add date picker
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/transaction_date_picker.dart`
  - [ ] Default to today
  - [ ] Quick date selections (yesterday, last week)
  - [ ] Calendar widget integration
- [ ] Implement description fields
  - [ ] Description text field
  - [ ] Optional notes field
  - [ ] Character limits

### Form Validation (2 hours)
- [ ] Create validation rules
  - [ ] `/frontend/lib/features/transactions/domain/validators/transaction_validator.dart`
  - [ ] Amount must be > 0
  - [ ] Account required
  - [ ] Category required (placeholder for now)
  - [ ] Date cannot be future (optional)
  - [ ] Description max length
- [ ] Implement error display
  - [ ] Field-level error messages
  - [ ] Form-level validation summary
  - [ ] Visual error indicators
  - [ ] Focus first error field

### Transaction Type Handling (2 hours)
- [ ] Add transaction type selector
  - [ ] Expense/Income toggle
  - [ ] Visual distinction (colors)
  - [ ] Update form based on type
- [ ] Implement type-specific logic
  - [ ] Default categories per type
  - [ ] Amount sign handling
  - [ ] Validation differences

### State Management (2 hours)
- [ ] Create form state model
  - [ ] `/frontend/lib/features/transactions/domain/models/transaction_form_state.dart`
  - [ ] Field values
  - [ ] Validation errors
  - [ ] Loading/saving states
  - [ ] Dirty flag for unsaved changes
- [ ] Implement save functionality
  - [ ] Call create/update API
  - [ ] Handle success/error responses
  - [ ] Navigate back on success
  - [ ] Show error messages

### Testing (1 hour)
- [ ] Widget tests
  - [ ] Form field rendering
  - [ ] Validation behavior
  - [ ] State changes
- [ ] Unit tests
  - [ ] Validation logic
  - [ ] Form state management

## Definition of Done
- [ ] Form renders correctly on all platforms
- [ ] All fields working with validation
- [ ] Create and edit modes functional
- [ ] Tests passing with >80% coverage
- [ ] No UI/UX issues
- [ ] Code reviewed and approved
- [ ] Integrated with API

## Dev Notes
- Use bottom sheet for mobile, modal for desktop
- Implement auto-save to prevent data loss
- Add loading states during API calls
- Consider field focus order for keyboard navigation
- Implement proper error recovery
- Add analytics for form completion rates

## Testing
- **Widget Tests**: Form components and interactions
- **Unit Tests**: Validation and state management
- **Integration Tests**: Complete form flow
- **Test Command**: `flutter test test/features/transactions/`
- **Coverage Target**: 80%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Keyboard issues | Medium | Medium | Proper keyboard handling |
| Validation complexity | Low | Low | Clear validation rules |
| State management | Low | Medium | Proper provider setup |

## File List
### Files to Create
- `/frontend/lib/features/transactions/presentation/screens/transaction_form_screen.dart`
- `/frontend/lib/features/transactions/presentation/widgets/transaction_form.dart`
- `/frontend/lib/features/transactions/presentation/widgets/amount_input_field.dart`
- `/frontend/lib/features/transactions/presentation/widgets/account_dropdown.dart`
- `/frontend/lib/features/transactions/presentation/widgets/transaction_date_picker.dart`
- `/frontend/lib/features/transactions/presentation/providers/transaction_form_provider.dart`
- `/frontend/lib/features/transactions/domain/models/transaction_form_state.dart`
- `/frontend/lib/features/transactions/domain/validators/transaction_validator.dart`
- `/frontend/test/features/transactions/presentation/screens/transaction_form_test.dart`

### Files to Modify
- `/frontend/lib/core/router/app_router.dart` - Add form route
- `/frontend/lib/features/transactions/presentation/screens/transaction_list_screen.dart` - Add FAB

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 3.4 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38