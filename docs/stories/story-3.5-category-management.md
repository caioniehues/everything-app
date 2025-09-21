# Story 3.5: Category Management

## Story
As a user,
I want to customize transaction categories,
so that they match my spending patterns.

## Status
**Status**: Draft
**Epic**: Epic 3 - Transaction Management
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: MEDIUM - Customization feature
**Estimated Days**: 2 days
**Story Points**: 3

## Acceptance Criteria
- [ ] Settings screen section for category management
- [ ] Add/edit/delete custom categories with name, icon, color
- [ ] Reorder categories by drag-and-drop or move buttons
- [ ] Subcategory support with parent-child relationships
- [ ] Category usage statistics (number of transactions, total amount)
- [ ] Bulk re-categorization when deleting a category
- [ ] Import/export categories as JSON for backup
- [ ] Icon picker with 50+ options and color palette
- [ ] System categories cannot be deleted
- [ ] Category merge functionality

## Dependencies
### Requires (Blocked By)
- [ ] Story 3.1 - Transaction Data Model & Categories
- [ ] Story 3.4 - Add/Edit Transaction Flow

### Enables (Blocks)
- [ ] Story 4.1 - Budget Data Model
- [ ] Story 5.3 - Analytics & Reports API

## Tasks

### Implementation Tasks
- [ ] Create CategoryManagementScreen
  - [ ] List of all categories
  - [ ] Add category FAB
  - [ ] Edit/delete actions
  - [ ] Reorder functionality
- [ ] Build CategoryFormDialog
  - [ ] Name input field
  - [ ] Type selector (Income/Expense)
  - [ ] Parent category dropdown
  - [ ] Icon picker
  - [ ] Color picker
- [ ] Create IconPicker widget
  - [ ] Grid of available icons
  - [ ] Search functionality
  - [ ] Category grouping
  - [ ] Preview display
- [ ] Create ColorPicker widget
  - [ ] Predefined color palette
  - [ ] Custom color option
  - [ ] Preview display
- [ ] Implement drag-and-drop
  - [ ] Reorderable list
  - [ ] Visual feedback
  - [ ] Save order changes
- [ ] Add usage statistics
  - [ ] Transaction count
  - [ ] Total amount
  - [ ] Last used date
  - [ ] Spending trends
- [ ] Category operations
  - [ ] Merge categories
  - [ ] Bulk reassignment
  - [ ] Archive unused
- [ ] Import/export functionality
  - [ ] Export to JSON
  - [ ] Import from JSON
  - [ ] Validation
  - [ ] Conflict resolution

### Backend Tasks
- [ ] Category management endpoints
- [ ] Reorder endpoint
- [ ] Merge categories logic
- [ ] Usage statistics queries
- [ ] Import/export API

### State Management Tasks
- [ ] Category list provider
- [ ] Category form state
- [ ] Reorder state management
- [ ] Statistics provider

### Testing Tasks
- [ ] Widget tests
- [ ] Drag-and-drop tests
- [ ] Import/export tests
- [ ] API integration tests

### Validation Tasks
- [ ] Test category hierarchy
- [ ] Verify reordering
- [ ] Test bulk operations
- [ ] Validate statistics

## Dev Notes
- Consider category templates for common use cases
- Add category suggestions based on merchant names
- Implement category rules for auto-categorization
- Cache category icons for performance
- Consider category budgets integration
- Add category insights and recommendations

## Testing
- **Widget Tests**: UI components
- **Unit Tests**: Category operations
- **Integration Tests**: Full management flow
- **Test Command**: `flutter test`
- **Coverage Target**: 80% overall

## Definition of Done
- [ ] All acceptance criteria met
- [ ] Categories manageable
- [ ] Tests written and passing
- [ ] No data loss issues
- [ ] Code reviewed and approved
- [ ] Documentation updated

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Data loss during operations | Low | High | Proper transactions, backups |
| Complex hierarchy management | Medium | Low | Limit nesting levels |
| Icon loading performance | Low | Low | Lazy loading, caching |

## File List
### Files to Create
- `/frontend/lib/features/categories/presentation/screens/category_management_screen.dart`
- `/frontend/lib/features/categories/presentation/widgets/category_form_dialog.dart`
- `/frontend/lib/features/categories/presentation/widgets/icon_picker.dart`
- `/frontend/lib/features/categories/presentation/widgets/color_picker.dart`
- `/frontend/lib/features/categories/presentation/widgets/category_list_item.dart`
- `/frontend/lib/features/categories/presentation/widgets/category_statistics.dart`
- `/frontend/lib/features/categories/presentation/providers/category_management_provider.dart`
- `/backend/src/main/java/com/caioniehues/app/application/service/CategoryService.java`
- `/backend/src/main/java/com/caioniehues/app/presentation/controller/CategoryController.java`

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:17:53 | Story created from PRD | Winston |

---
Last Updated: 21/09/2025 01:17:53