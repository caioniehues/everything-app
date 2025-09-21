# Story 5.1.2: Account & Transaction Widgets

## Story
As a user,
I want to see my account balances and recent transactions on the dashboard,
so that I can quickly understand my current financial position.

## Status
**Status**: Draft
**Epic**: Epic 5 - Dashboard & Analytics
**Parent Story**: 5.1 - Dashboard Implementation
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: HIGH - Core dashboard data
**Estimated Days**: 1.5 days
**Story Points**: 3

## Acceptance Criteria
- [ ] Account summary widget shows all account balances
- [ ] Total net worth calculated and displayed
- [ ] Recent transactions widget shows last 5-10 transactions
- [ ] Transactions grouped by day with relative dates
- [ ] Account cards clickable to view details
- [ ] Transaction items clickable to edit
- [ ] Real-time balance updates after transactions
- [ ] Currency formatting with proper symbols

## Dependencies
### Requires (Blocked By)
- [ ] Story 5.1.1 - Dashboard Layout & Navigation
- [ ] Story 2.3 - Account List UI
- [ ] Story 3.3 - Transaction List UI
- [ ] Story 2.2 - Account Management API
- [ ] Story 3.2 - Transaction CRUD API

### Enables (Blocks)
- [ ] Story 5.1.4 - Quick Actions & Performance
- [ ] Story 5.2 - Dashboard State Management

### Integration Points
- **Input**: Account and transaction data from APIs
- **Output**: Visual representation of financial data
- **Handoff**: Click handlers to detail screens

## Tasks

### Account Summary Widget (4 hours)
- [ ] Create account summary component
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/account_summary_widget.dart`
  - [ ] Widget header with total
  - [ ] Account list layout
  - [ ] Expand/collapse functionality
- [ ] Build account card
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/account_summary_card.dart`
  - [ ] Account name and type icon
  - [ ] Current balance display
  - [ ] Change indicator (+/- from yesterday)
  - [ ] Last updated timestamp
  - [ ] Click handler to account details
- [ ] Implement balance calculations
  - [ ] `/frontend/lib/features/dashboard/domain/services/balance_calculator_service.dart`
  - [ ] Sum account balances
  - [ ] Handle multiple currencies
  - [ ] Calculate net worth
  - [ ] Track daily changes

### Net Worth Display (2 hours)
- [ ] Create net worth widget
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/net_worth_card.dart`
  - [ ] Large balance display
  - [ ] Change from last period
  - [ ] Percentage change
  - [ ] Trend arrow/indicator
- [ ] Add mini chart
  - [ ] 7-day sparkline
  - [ ] Touch to see values
  - [ ] Animate on load

### Recent Transactions Widget (4 hours)
- [ ] Create transaction list widget
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/recent_transactions_widget.dart`
  - [ ] Widget header with "See all" link
  - [ ] Scrollable list container
  - [ ] Group by date headers
- [ ] Build transaction item
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/transaction_list_item_compact.dart`
  - [ ] Category icon and color
  - [ ] Description and account
  - [ ] Amount with +/- indicator
  - [ ] Relative time (e.g., "2 hours ago")
  - [ ] Click handler to edit
- [ ] Implement date grouping
  - [ ] Today, Yesterday, This Week
  - [ ] Date section headers
  - [ ] Collapsible sections

### Data Integration (3 hours)
- [ ] Create data providers
  - [ ] `/frontend/lib/features/dashboard/presentation/providers/account_summary_provider.dart`
  - [ ] Fetch account data
  - [ ] Calculate totals
  - [ ] Handle loading/error states
  - [ ] Auto-refresh interval
- [ ] Create transaction provider
  - [ ] `/frontend/lib/features/dashboard/presentation/providers/recent_transactions_provider.dart`
  - [ ] Fetch recent transactions
  - [ ] Apply sorting/filtering
  - [ ] Pagination support
  - [ ] Real-time updates
- [ ] Implement data formatting
  - [ ] Currency formatting
  - [ ] Number abbreviations (1.2K, 1.5M)
  - [ ] Date formatting
  - [ ] Percentage calculations

### Interactive Features (1.5 hours)
- [ ] Add pull-to-refresh
  - [ ] Refresh account data
  - [ ] Update transactions
  - [ ] Show loading indicator
- [ ] Implement click handlers
  - [ ] Navigate to account details
  - [ ] Open transaction editor
  - [ ] Show transaction details bottom sheet
- [ ] Add animations
  - [ ] Number counting animation
  - [ ] List item animations
  - [ ] Expand/collapse transitions

### Testing (1 hour)
- [ ] Widget tests
  - [ ] Account summary rendering
  - [ ] Transaction list display
  - [ ] Data formatting
- [ ] Provider tests
  - [ ] Data fetching
  - [ ] State management
  - [ ] Error handling

## Definition of Done
- [ ] Account summary displaying correctly
- [ ] Net worth calculated accurately
- [ ] Recent transactions showing with grouping
- [ ] All click handlers working
- [ ] Real-time updates functional
- [ ] Tests passing with coverage
- [ ] Performance optimized

## Dev Notes
- Cache account data for offline access
- Use `StreamBuilder` for real-time updates
- Implement skeleton screens while loading
- Consider virtualized list for transactions
- Add swipe actions for quick edit/delete
- Use `Hero` animations for transitions

## Testing
- **Widget Tests**: Component rendering
- **Unit Tests**: Calculations and formatting
- **Integration Tests**: Data flow
- **Test Command**: `flutter test test/features/dashboard/`
- **Coverage Target**: 85%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Data sync issues | Medium | High | Proper state management |
| Performance with many accounts | Low | Medium | Pagination, virtualization |
| Currency conversion | Low | Low | Clear single currency MVP |

## File List
### Files to Create
- `/frontend/lib/features/dashboard/presentation/widgets/account_summary_widget.dart`
- `/frontend/lib/features/dashboard/presentation/widgets/account_summary_card.dart`
- `/frontend/lib/features/dashboard/presentation/widgets/net_worth_card.dart`
- `/frontend/lib/features/dashboard/presentation/widgets/recent_transactions_widget.dart`
- `/frontend/lib/features/dashboard/presentation/widgets/transaction_list_item_compact.dart`
- `/frontend/lib/features/dashboard/presentation/providers/account_summary_provider.dart`
- `/frontend/lib/features/dashboard/presentation/providers/recent_transactions_provider.dart`
- `/frontend/lib/features/dashboard/domain/services/balance_calculator_service.dart`
- `/frontend/test/features/dashboard/presentation/widgets/account_summary_test.dart`
- `/frontend/test/features/dashboard/presentation/widgets/recent_transactions_test.dart`

### Files to Modify
- `/frontend/lib/features/dashboard/presentation/screens/dashboard_screen.dart` - Add widgets

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 5.1 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38