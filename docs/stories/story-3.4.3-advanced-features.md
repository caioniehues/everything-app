# Story 3.4.3: Advanced Transaction Features

## Story
As a power user,
I want advanced features like receipt capture and templates,
so that I can manage transactions more efficiently.

## Status
**Status**: Draft
**Epic**: Epic 3 - Transaction Management
**Parent Story**: 3.4 - Add/Edit Transaction Flow
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: MEDIUM - Enhanced features
**Estimated Days**: 0.5 days
**Story Points**: 1

## Acceptance Criteria
- [ ] Camera/gallery integration for receipt capture
- [ ] Receipt images stored as base64 with compression
- [ ] Transaction templates for recurring expenses
- [ ] "Add another" option for batch entry
- [ ] Split transaction support
- [ ] Keyboard shortcuts for desktop (Ctrl+N)
- [ ] Recent transactions quick-add
- [ ] All features properly tested

## Dependencies
### Requires (Blocked By)
- [ ] Story 3.4.1 - Transaction Form & Validation
- [ ] Story 3.4.2 - Category Selection & Calculator

### Enables (Blocks)
- [ ] Story 6.4 - Recurring Transactions
- [ ] Story 7.1 - Export functionality

### Integration Points
- **Input**: Images, template data, split rules
- **Output**: Enhanced transaction records
- **Handoff**: Templates for recurring transactions

## Tasks

### Receipt Capture (2 hours)
- [ ] Implement receipt widget
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/receipt_capture.dart`
  - [ ] Camera button
  - [ ] Gallery button
  - [ ] Image preview
  - [ ] Delete option
- [ ] Add image handling
  - [ ] `/frontend/lib/features/transactions/domain/services/image_service.dart`
  - [ ] Image picker integration
  - [ ] Compression to <500KB
  - [ ] Base64 encoding
  - [ ] Error handling
- [ ] Create image viewer
  - [ ] Full-screen preview
  - [ ] Pinch to zoom
  - [ ] Share functionality

### Transaction Templates (2 hours)
- [ ] Create template model
  - [ ] `/frontend/lib/features/transactions/domain/models/transaction_template.dart`
  - [ ] Template name
  - [ ] Pre-filled fields
  - [ ] Usage count
- [ ] Implement template UI
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/template_selector.dart`
  - [ ] Template list
  - [ ] Quick apply
  - [ ] Save as template option
  - [ ] Manage templates screen
- [ ] Add template persistence
  - [ ] Save to local storage
  - [ ] Load on form open
  - [ ] Update usage stats

### Batch Entry Features (1.5 hours)
- [ ] Add "Save and New" button
  - [ ] Save current transaction
  - [ ] Reset form with smart defaults
  - [ ] Keep account/category if similar
  - [ ] Show success toast
- [ ] Implement recent transactions
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/recent_transactions_quick_add.dart`
  - [ ] Last 5 transactions
  - [ ] One-tap duplicate
  - [ ] Edit before save option

### Split Transactions (1.5 hours)
- [ ] Create split dialog
  - [ ] `/frontend/lib/features/transactions/presentation/widgets/split_transaction_dialog.dart`
  - [ ] Split by amount
  - [ ] Split by percentage
  - [ ] Multiple categories
  - [ ] Preview splits
- [ ] Implement split logic
  - [ ] Calculate splits
  - [ ] Validate totals
  - [ ] Create sub-transactions
  - [ ] Link to parent

### Keyboard Shortcuts (30 minutes)
- [ ] Add shortcut handler
  - [ ] Ctrl/Cmd + N: New transaction
  - [ ] Ctrl/Cmd + S: Save
  - [ ] ESC: Cancel
  - [ ] Tab: Navigate fields
- [ ] Add tooltips
  - [ ] Show shortcuts on hover
  - [ ] Help dialog

### Testing (30 minutes)
- [ ] Receipt capture tests
- [ ] Template functionality tests
- [ ] Split transaction tests
- [ ] Keyboard shortcut tests

## Definition of Done
- [ ] Receipt capture working on all platforms
- [ ] Templates saving and loading
- [ ] Batch entry smooth and fast
- [ ] Split transactions calculating correctly
- [ ] Keyboard shortcuts functional on desktop
- [ ] Tests passing
- [ ] No memory leaks from images

## Dev Notes
- Limit image size to prevent memory issues
- Consider OCR for receipt scanning (future enhancement)
- Templates should sync across devices (future)
- Add haptic feedback for quick actions
- Consider drag-and-drop for desktop
- Implement undo for accidental saves

## Testing
- **Widget Tests**: UI components
- **Unit Tests**: Split calculations, image compression
- **Integration Tests**: Template flow, image capture
- **Test Command**: `flutter test test/features/transactions/`
- **Coverage Target**: 80%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Large images causing crashes | Medium | High | Strict size limits, compression |
| Platform-specific image issues | Medium | Medium | Thorough testing |
| Template complexity | Low | Low | Keep simple initially |

## File List
### Files to Create
- `/frontend/lib/features/transactions/presentation/widgets/receipt_capture.dart`
- `/frontend/lib/features/transactions/presentation/widgets/template_selector.dart`
- `/frontend/lib/features/transactions/presentation/widgets/split_transaction_dialog.dart`
- `/frontend/lib/features/transactions/presentation/widgets/recent_transactions_quick_add.dart`
- `/frontend/lib/features/transactions/domain/models/transaction_template.dart`
- `/frontend/lib/features/transactions/domain/services/image_service.dart`
- `/frontend/lib/features/transactions/domain/services/template_service.dart`
- `/frontend/test/features/transactions/domain/services/image_service_test.dart`

### Files to Modify
- `/frontend/lib/features/transactions/presentation/screens/transaction_form_screen.dart` - Add advanced features
- `/frontend/pubspec.yaml` - Add image_picker dependency

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 3.4 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38