# Story 5.1.3: Budget & Analytics Widgets

## Story
As a user,
I want to see my budget progress and spending analytics on the dashboard,
so that I can track my financial goals and spending patterns.

## Status
**Status**: Draft
**Epic**: Epic 5 - Dashboard & Analytics
**Parent Story**: 5.1 - Dashboard Implementation
**Started**: Not Started
**Completed**: Not Completed
**Developer**: Unassigned
**Priority**: MEDIUM - Enhanced insights
**Estimated Days**: 1 day
**Story Points**: 2

## Acceptance Criteria
- [ ] Budget progress widget shows current month's budget status
- [ ] Visual progress bars with color coding (green/yellow/red)
- [ ] Spending by category pie/donut chart
- [ ] Monthly spending trend line chart
- [ ] Click on budget to see details
- [ ] Charts are interactive with tooltips
- [ ] Period selector for analytics (week/month/year)
- [ ] Charts animate on load

## Dependencies
### Requires (Blocked By)
- [ ] Story 5.1.1 - Dashboard Layout & Navigation
- [ ] Story 4.1 - Budget Data Model
- [ ] Story 3.1 - Transaction categorization

### Enables (Blocks)
- [ ] Story 5.1.4 - Quick Actions & Performance
- [ ] Story 5.4 - Full Analytics UI

### Integration Points
- **Input**: Budget and transaction data
- **Output**: Visual analytics and insights
- **Handoff**: Navigation to detailed reports

## Tasks

### Budget Progress Widget (3 hours)
- [ ] Create budget widget
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/budget_progress_widget.dart`
  - [ ] Widget header with period
  - [ ] Budget category list
  - [ ] View all budgets link
- [ ] Build progress cards
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/budget_progress_card.dart`
  - [ ] Category name and icon
  - [ ] Spent vs budget amount
  - [ ] Progress bar visualization
  - [ ] Percentage display
  - [ ] Days remaining indicator
- [ ] Implement progress calculation
  - [ ] Calculate percentage spent
  - [ ] Determine status (on track/warning/over)
  - [ ] Project end-of-period spending
  - [ ] Color coding logic

### Spending Analytics Charts (4 hours)
- [ ] Create category breakdown chart
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/category_spending_chart.dart`
  - [ ] Donut chart implementation
  - [ ] Interactive segments
  - [ ] Center total display
  - [ ] Legend with amounts
  - [ ] Tap to highlight category
- [ ] Build spending trend chart
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/spending_trend_chart.dart`
  - [ ] Line chart for daily spending
  - [ ] 30-day rolling window
  - [ ] Average spending line
  - [ ] Touch to see values
  - [ ] Zoom and pan (desktop)
- [ ] Add chart controls
  - [ ] Period selector (week/month/quarter/year)
  - [ ] Category filter
  - [ ] Account filter
  - [ ] Export chart option

### Quick Stats Cards (2 hours)
- [ ] Create stats summary
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/quick_stats_row.dart`
  - [ ] This month's spending
  - [ ] Average daily spending
  - [ ] Most expensive category
  - [ ] Savings rate
- [ ] Build stat card component
  - [ ] `/frontend/lib/features/dashboard/presentation/widgets/stat_card.dart`
  - [ ] Icon and label
  - [ ] Large value display
  - [ ] Change from last period
  - [ ] Micro chart/sparkline

### Data Processing (2 hours)
- [ ] Create analytics service
  - [ ] `/frontend/lib/features/dashboard/domain/services/dashboard_analytics_service.dart`
  - [ ] Calculate spending by category
  - [ ] Generate trend data
  - [ ] Budget progress calculations
  - [ ] Period comparisons
- [ ] Implement data providers
  - [ ] `/frontend/lib/features/dashboard/presentation/providers/budget_progress_provider.dart`
  - [ ] `/frontend/lib/features/dashboard/presentation/providers/spending_analytics_provider.dart`
  - [ ] Data fetching and caching
  - [ ] Auto-refresh logic

### Chart Library Integration (1 hour)
- [ ] Configure fl_chart
  - [ ] Add to pubspec.yaml
  - [ ] Create chart themes
  - [ ] Configure animations
  - [ ] Setup touch callbacks
- [ ] Create chart utilities
  - [ ] Color palette
  - [ ] Data formatters
  - [ ] Axis configurations

### Testing (30 minutes)
- [ ] Chart rendering tests
- [ ] Calculation accuracy tests
- [ ] Provider state tests
- [ ] Interactive behavior tests

## Definition of Done
- [ ] Budget progress displaying correctly
- [ ] Charts rendering with real data
- [ ] Interactions working smoothly
- [ ] Period filtering functional
- [ ] Animations polished
- [ ] Tests passing
- [ ] Performance acceptable

## Dev Notes
- Use fl_chart for chart implementations
- Implement data aggregation in backend for performance
- Cache calculated values
- Use memoization for expensive calculations
- Consider WebGL for complex visualizations (web)
- Add loading skeletons for charts

## Testing
- **Widget Tests**: Chart components
- **Unit Tests**: Calculations and data processing
- **Visual Tests**: Chart rendering
- **Test Command**: `flutter test test/features/dashboard/`
- **Coverage Target**: 80%+

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Chart performance | Medium | Medium | Data pagination, caching |
| Complex calculations | Low | Low | Backend aggregation |
| Chart library issues | Low | Medium | Fallback to simple views |

## File List
### Files to Create
- `/frontend/lib/features/dashboard/presentation/widgets/budget_progress_widget.dart`
- `/frontend/lib/features/dashboard/presentation/widgets/budget_progress_card.dart`
- `/frontend/lib/features/dashboard/presentation/widgets/category_spending_chart.dart`
- `/frontend/lib/features/dashboard/presentation/widgets/spending_trend_chart.dart`
- `/frontend/lib/features/dashboard/presentation/widgets/quick_stats_row.dart`
- `/frontend/lib/features/dashboard/presentation/widgets/stat_card.dart`
- `/frontend/lib/features/dashboard/domain/services/dashboard_analytics_service.dart`
- `/frontend/lib/features/dashboard/presentation/providers/budget_progress_provider.dart`
- `/frontend/lib/features/dashboard/presentation/providers/spending_analytics_provider.dart`
- `/frontend/test/features/dashboard/domain/services/analytics_service_test.dart`

### Files to Modify
- `/frontend/pubspec.yaml` - Add fl_chart dependency
- `/frontend/lib/features/dashboard/presentation/screens/dashboard_screen.dart` - Add widgets

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:42:38 | Story created from 5.1 sharding | Sarah (PO) |

---
Last Updated: 21/09/2025 01:42:38