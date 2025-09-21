# Story 2.4: Add/Edit Account UI

## Story
As a user,
I want to add and edit financial accounts through an intuitive form,
so that I can keep my account information current.

## Status
**Status**: Draft
**Epic**: Epic 2 - Financial Accounts & Core Data Model
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Core functionality
**Estimated Days**: 2 days
**Story Points**: 3

## Acceptance Criteria
- [ ] Modal/screen form for adding new account
- [ ] Form fields: name (required), type dropdown, initial balance, currency
- [ ] Account type icons help identify different account types
- [ ] Real-time validation with helpful error messages
- [ ] Edit form pre-populates with existing account data
- [ ] Confirmation dialog for account deletion
- [ ] Success/error toast notifications after actions
- [ ] Form maintains state during validation errors
- [ ] Keyboard navigation and proper focus management
- [ ] Loading state during save operations

## Dependencies
### Requires (Blocked By)
- [ ] Story 2.3 - Account List UI
- [ ] Story 2.2 - Account Management API

### Enables (Blocks)
- [ ] Story 2.5 - Account Service Integration
- [ ] Story 3.4 - Add Transaction UI

## Tasks

### Design Tasks
- [ ] Review form design in UI/UX specs
- [ ] Confirm validation rules with PO
- [ ] Design confirmation dialogs
- [ ] Design success/error states

### Implementation Tasks
- [ ] Create AccountFormScreen
  - [ ] Route configuration
  - [ ] App bar with save action
  - [ ] Form layout
  - [ ] Navigation handling
- [ ] Create form widgets
  - [ ] Account name text field
  - [ ] Account type dropdown
  - [ ] Balance input field
  - [ ] Currency selector
  - [ ] Icon selector (optional)
- [ ] Implement form validation
  - [ ] Required field validation
  - [ ] Name length validation
  - [ ] Balance format validation
  - [ ] Real-time validation feedback
  - [ ] Form-level validation
- [ ] Create AccountTypeSelector widget
  - [ ] Dropdown with icons
  - [ ] Type descriptions
  - [ ] Visual feedback
- [ ] Create BalanceInputField widget
  - [ ] Currency formatting
  - [ ] Numeric keyboard
  - [ ] Decimal handling
  - [ ] Negative values for credit
- [ ] Implement edit mode
  - [ ] Load existing account data
  - [ ] Pre-populate form fields
  - [ ] Track changes
  - [ ] Update vs create logic
- [ ] Create delete functionality
  - [ ] Delete button (edit mode only)
  - [ ] Confirmation dialog
  - [ ] Balance check
  - [ ] Success handling
- [ ] Add loading states
  - [ ] Save button loading
  - [ ] Disable form during save
  - [ ] Progress indicator

### State Management Tasks
- [ ] Create form controller/provider
  - [ ] Form state management
  - [ ] Validation state
  - [ ] Submission handling
- [ ] Implement save logic
  - [ ] Create account API call
  - [ ] Update account API call
  - [ ] Error handling
  - [ ] Success navigation
- [ ] Add form persistence
  - [ ] Preserve form state on error
  - [ ] Clear form on success

### Testing Tasks
- [ ] Widget tests for form fields
- [ ] Test validation logic
- [ ] Test form submission
- [ ] Test edit mode
- [ ] Test delete functionality
- [ ] Test error scenarios
- [ ] Integration tests for full flow

### Validation Tasks
- [ ] Test all validation rules
- [ ] Test keyboard behavior
- [ ] Verify error messages
- [ ] Test on different screen sizes
- [ ] Verify accessibility

## Dev Notes
- Use Form widget with GlobalKey for validation
- Consider using flutter_form_builder for complex forms
- Implement debouncing for real-time validation
- Use FocusNode for keyboard management
- Consider autosave functionality for drafts
- Add analytics for form completion rate
- Implement proper error recovery

## Testing
- **Widget Tests**: Form fields and validation
- **Integration Tests**: Complete add/edit flow
- **Test Command**: `flutter test`
- **Coverage Target**: 85% overall

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Form validation working correctly
- [ ] Tests written and passing
- [ ] No UI/UX issues
- [ ] Keyboard navigation works
- [ ] Code reviewed and approved
- [ ] Accessibility compliant

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Complex validation logic | Medium | Low | Comprehensive testing |
| Keyboard handling issues | Medium | Medium | Test on devices |
| State loss on navigation | Low | High | Proper state management |

## File List
### Files to Create
- `/frontend/lib/features/accounts/presentation/screens/account_form_screen.dart`
- `/frontend/lib/features/accounts/presentation/widgets/account_form.dart`
- `/frontend/lib/features/accounts/presentation/widgets/account_type_selector.dart`
- `/frontend/lib/features/accounts/presentation/widgets/balance_input_field.dart`
- `/frontend/lib/features/accounts/presentation/widgets/currency_selector.dart`
- `/frontend/lib/features/accounts/presentation/widgets/delete_account_dialog.dart`
- `/frontend/lib/features/accounts/presentation/providers/account_form_provider.dart`
- `/frontend/lib/features/accounts/domain/validators/account_validators.dart`
- `/frontend/test/features/accounts/presentation/screens/account_form_screen_test.dart`
- `/frontend/test/features/accounts/presentation/widgets/account_form_test.dart`
- `/frontend/test/features/accounts/domain/validators/account_validators_test.dart`

### Files to Modify
- `/frontend/lib/core/router/app_router.dart` - Add form routes
- `/frontend/lib/features/accounts/presentation/screens/account_list_screen.dart` - Add navigation

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53