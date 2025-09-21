# Story 3.4: Add/Edit Transaction Flow

## Story
As a user,
I want to quickly add transactions with smart defaults,
so that recording expenses is effortless.

## Status
**Status**: Draft
**Epic**: Epic 3 - Transaction Management
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Core user flow
**Estimated Days**: 3 days
**Story Points**: 5
**Note**: Consider sharding due to complexity

## Acceptance Criteria
- [ ] Floating action button opens quick-add modal
- [ ] Form fields: amount (numeric keypad), account, category, date, description
- [ ] Smart defaults: today's date, last used account, recent categories
- [ ] Category selection with search and recent/favorites section
- [ ] Amount input with calculator functions (+, -, *, /)
- [ ] Photo attachment option for receipts (stored as base64)
- [ ] "Add another" option to quickly add multiple transactions
- [ ] Keyboard shortcuts for power users (Ctrl+N for new)
- [ ] Transaction templates for recurring expenses
- [ ] Split transaction support

## Dependencies
### Requires (Blocked By)
- [ ] Story 3.3 - Transaction List UI
- [ ] Story 3.2 - Transaction CRUD API
- [ ] Story 2.4 - Add/Edit Account UI (For patterns)

### Enables (Blocks)
- [ ] Story 3.5 - Category Management
- [ ] Story 4.3 - Budget Creation UI
- [ ] Story 6.4 - Recurring Transactions

## Tasks

### Design Tasks
- [ ] Review quick-add flow designs
- [ ] Design calculator interface
- [ ] Create category selector mockup
- [ ] Design receipt capture flow

### Core Implementation Tasks
- [ ] Create TransactionFormScreen
  - [ ] Route configuration
  - [ ] Form layout
  - [ ] Navigation handling
  - [ ] Keyboard management
- [ ] Build amount input component
  - [ ] Custom numeric keypad
  - [ ] Calculator functions
  - [ ] Currency formatting
  - [ ] Decimal handling
  - [ ] Negative amount support
- [ ] Create form fields
  - [ ] Account selector dropdown
  - [ ] Date picker
  - [ ] Description field
  - [ ] Note field (optional)
  - [ ] Tags input (optional)
- [ ] Implement form validation
  - [ ] Required field checks
  - [ ] Amount validation
  - [ ] Date validation
  - [ ] Balance checks

### Category Selection Tasks
- [ ] Build CategorySelector widget
  - [ ] Search functionality
  - [ ] Recent categories section
  - [ ] Favorite categories
  - [ ] Full category list
  - [ ] Category icons/colors
  - [ ] Create new category option
- [ ] Implement category search
  - [ ] Fuzzy search
  - [ ] Search highlighting
  - [ ] Category hierarchy

### Advanced Features Tasks
- [ ] Add receipt capture
  - [ ] Camera integration
  - [ ] Gallery picker
  - [ ] Image preview
  - [ ] Base64 encoding
  - [ ] Image compression
- [ ] Implement calculator
  - [ ] Basic operations
  - [ ] Expression evaluation
  - [ ] History display
- [ ] Add templates
  - [ ] Save as template
  - [ ] Load from template
  - [ ] Manage templates
- [ ] Split transactions
  - [ ] Split by amount
  - [ ] Split by percentage
  - [ ] Multiple categories

### UX Enhancement Tasks
- [ ] Smart defaults
  - [ ] Learn user patterns
  - [ ] Time-based suggestions
  - [ ] Location-based (future)
- [ ] Quick actions
  - [ ] Recent transactions
  - [ ] Duplicate transaction
  - [ ] Quick expense buttons
- [ ] Keyboard shortcuts
  - [ ] Tab navigation
  - [ ] Enter to save
  - [ ] ESC to cancel

### State Management Tasks
- [ ] Form state provider
- [ ] Calculator state
- [ ] Category selection state
- [ ] Image handling
- [ ] Template management

### Testing Tasks
- [ ] Widget tests for form
- [ ] Calculator logic tests
- [ ] Category search tests
- [ ] Image handling tests
- [ ] Form validation tests
- [ ] Integration tests

### Validation Tasks
- [ ] Test all input methods
- [ ] Verify calculations
- [ ] Test image capture
- [ ] Verify quick-add flow
- [ ] Test on various devices

## Dev Notes
- This story is large and should be considered for sharding
- Use bottom sheet for mobile, modal for desktop
- Implement auto-save draft functionality
- Add haptic feedback for calculator
- Consider voice input for amount
- Cache recent categories for performance
- Implement undo functionality
- Add transaction preview before save
- Consider OCR for receipt scanning (future)

## Testing
- **Widget Tests**: Form components and validation
- **Unit Tests**: Calculator and business logic
- **Integration Tests**: Complete transaction flow
- **Test Command**: `flutter test`
- **Coverage Target**: 85% overall

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Form validation complete
- [ ] Calculator working correctly
- [ ] Tests written and passing
- [ ] No UI/UX issues
- [ ] Code reviewed and approved
- [ ] Performance optimized

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Complex form logic | High | Medium | Consider sharding story |
| Image handling issues | Medium | Low | Proper compression, limits |
| Calculator bugs | Low | Medium | Extensive testing |
| Performance issues | Medium | Medium | Optimize category list |

## File List
### Files to Create
- `/frontend/lib/features/transactions/presentation/screens/transaction_form_screen.dart`
- `/frontend/lib/features/transactions/presentation/widgets/transaction_form.dart`
- `/frontend/lib/features/transactions/presentation/widgets/amount_calculator.dart`
- `/frontend/lib/features/transactions/presentation/widgets/category_selector.dart`
- `/frontend/lib/features/transactions/presentation/widgets/category_search.dart`
- `/frontend/lib/features/transactions/presentation/widgets/receipt_capture.dart`
- `/frontend/lib/features/transactions/presentation/widgets/transaction_template_list.dart`
- `/frontend/lib/features/transactions/presentation/widgets/split_transaction_dialog.dart`
- `/frontend/lib/features/transactions/presentation/providers/transaction_form_provider.dart`
- `/frontend/lib/features/transactions/presentation/providers/calculator_provider.dart`
- `/frontend/lib/features/transactions/domain/usecases/create_transaction.dart`
- `/frontend/lib/features/transactions/domain/usecases/update_transaction.dart`
- `/frontend/test/features/transactions/presentation/screens/transaction_form_screen_test.dart`
- `/frontend/test/features/transactions/presentation/widgets/amount_calculator_test.dart`
- `/frontend/test/features/transactions/presentation/widgets/category_selector_test.dart`

### Files to Modify
- `/frontend/lib/core/router/app_router.dart` - Add form route
- `/frontend/lib/features/transactions/presentation/screens/transaction_list_screen.dart` - Add FAB

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53