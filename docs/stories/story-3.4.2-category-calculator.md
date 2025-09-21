# Story 3.4.2: Category Selection & Calculator

## Story
As a user,
I want smart category selection and calculator features,
so that adding transactions is quick and accurate.

## Status
**Status**: Draft
**Epic**: Epic 3 - Transaction Management
**Parent Story**: 3.4 - Add/Edit Transaction Flow
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Enhanced UX
**Estimated Days**: 1 day
**Story Points**: 2

## Acceptance Criteria
- [ ] Category selector with search functionality
- [ ] Recent and favorite categories displayed prominently
- [ ] Category icons and colors visible
- [ ] Calculator with basic operations (+, -, *, /)
- [ ] Calculator history visible during input
- [ ] Smart category suggestions based on amount and time
- [ ] Quick category creation option
- [ ] Smooth animations and transitions

## Dependencies
### Requires (Blocked By)
- [ ] Story 3.4.1 - Transaction Form & Validation
- [ ] Story 3.1 - Category/Tag data model

### Enables (Blocks)
- [ ] Story 3.4.3 - Advanced Features
- [ ] Story 3.5 - Category Management

### Integration Points
- **Input**: Form context (amount, date, account)
- **Output**: Selected category, calculated amount
- **Handoff**: Category ID to form, final amount to amount field

## Tasks

### Category Selector Widget (4 hours)
- [ ] Create CategorySelector component
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/category_selector.dart`
  - [ ] Modal/bottom sheet container
  - [ ] Search bar at top
  - [ ] Tabbed sections (Recent, Favorites, All)
  - [ ] Grid layout for categories
- [ ] Implement category display
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/category_item.dart`
  - [ ] Icon and color display
  - [ ] Category name
  - [ ] Selection state
  - [ ] Usage frequency badge
- [ ] Add search functionality
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/category_search.dart`
  - [ ] Real-time search
  - [ ] Fuzzy matching
  - [ ] Search highlighting
  - [ ] No results state

### Category Intelligence (3 hours)
- [ ] Implement smart suggestions
  - [ ] `/frontend/lib/features/transactions/domain/services/category_suggestion_service.dart`
  - [ ] Time-based patterns (breakfast, lunch, dinner)
  - [ ] Amount-based patterns
  - [ ] Day of week patterns
  - [ ] Historical data analysis
- [ ] Create favorites system
  - [ ] Mark/unmark as favorite
  - [ ] Persist favorites
  - [ ] Sort by usage frequency
- [ ] Add recent categories
  - [ ] Track last 10 used
  - [ ] Include usage count
  - [ ] Time-decay algorithm

### Calculator Implementation (3 hours)
- [ ] Create calculator widget
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/amount_calculator.dart`
  - [ ] Calculator UI layout
  - [ ] Number pad
  - [ ] Operation buttons
  - [ ] Clear/delete buttons
- [ ] Implement calculator logic
  - [ ] `/frontend/lib/features/transactions/domain/services/calculator_service.dart`
  - [ ] Expression parsing
  - [ ] Operation precedence
  - [ ] Decimal handling
  - [ ] Error handling
- [ ] Add calculator features
  - [ ] Expression history
  - [ ] Running total display
  - [ ] Memory functions (M+, M-, MR, MC)
  - [ ] Percentage calculations

### Quick Category Creation (1.5 hours)
- [ ] Add "Create New" option
  - [ ] Quick create dialog
  - [ ] Name input
  - [ ] Icon picker (simplified)
  - [ ] Color picker (presets)
- [ ] Implement category creation
  - [ ] Validate uniqueness
  - [ ] Save to database
  - [ ] Add to selector immediately
  - [ ] Auto-select new category

### State Management (1.5 hours)
- [ ] Create category provider
  - [ ] `/frontend/lib/features/transactions/presentation/providers/category_selector_provider.dart`
  - [ ] Categories list
  - [ ] Search state
  - [ ] Selection state
  - [ ] Favorites management
- [ ] Create calculator provider
  - [ ] `/frontend/lib/features/transactions/presentation/providers/calculator_provider.dart`
  - [ ] Current expression
  - [ ] History
  - [ ] Result
  - [ ] Memory state

### Testing (1 hour)
- [ ] Category selector tests
  - [ ] Search functionality
  - [ ] Selection behavior
  - [ ] Favorites toggle
- [ ] Calculator tests
  - [ ] Operation accuracy
  - [ ] Edge cases
  - [ ] Expression parsing

## Definition of Done
- [ ] Category selector fully functional
- [ ] Search working with highlighting
- [ ] Calculator operations accurate
- [ ] Smart suggestions implemented
- [ ] Tests passing with coverage
- [ ] Smooth animations
- [ ] Code reviewed

## Dev Notes
- Cache category list for performance
- Use debouncing for search
- Implement haptic feedback for calculator
- Consider voice input for amount (future)
- Pre-load common categories
- Add keyboard support for desktop

## Testing
- **Widget Tests**: UI components
- **Unit Tests**: Calculator logic, suggestion service
- **Integration Tests**: Category selection flow
- **Test Command**: `flutter test test/features/transactions/`
- **Coverage Target**: 85%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Performance with many categories | Medium | Medium | Implement pagination |
| Calculator precision issues | Low | High | Use decimal package |
| Complex suggestion logic | Medium | Low | Start simple, iterate |

## File List
### Files to Create
- `/frontend/lib/features/transactions/presentation/widgets/category_selector.dart`
- `/frontend/lib/features/transactions/presentation/widgets/category_item.dart`
- `/frontend/lib/features/transactions/presentation/widgets/category_search.dart`
- `/frontend/lib/features/transactions/presentation/widgets/amount_calculator.dart`
- `/frontend/lib/features/transactions/presentation/widgets/quick_category_dialog.dart`
- `/frontend/lib/features/transactions/presentation/providers/category_selector_provider.dart`
- `/frontend/lib/features/transactions/presentation/providers/calculator_provider.dart`
- `/frontend/lib/features/transactions/domain/services/category_suggestion_service.dart`
- `/frontend/lib/features/transactions/domain/services/calculator_service.dart`
- `/frontend/test/features/transactions/presentation/widgets/category_selector_test.dart`
- `/frontend/test/features/transactions/domain/services/calculator_service_test.dart`

### Files to Modify
- `/frontend/lib/features/transactions/presentation/screens/transaction_form_screen.dart` - Integrate widgets

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 3.4 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38