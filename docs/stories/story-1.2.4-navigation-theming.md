# Story 1.2.4: Navigation & Theming

## Story
As a developer,
I want to implement go_router navigation and Material Design 3 theming with responsive layouts,
so that the app has consistent UX across all platforms.

## Status
**Status**: Mostly Complete (80%)
**Epic**: Epic 1 - Foundation & Authentication System
**Parent Story**: 1.2 - Flutter Project Structure & Core Setup
**Started**: 21/09/2025
**Completed**: In Progress
**Developer**: Unassigned
**Priority**: HIGH - User-facing foundation
**Estimated Days**: 2 days
**Story Points**: 3

## Acceptance Criteria
- [ ] go_router configured with initial routes (/login, /dashboard, /settings)
- [ ] Route guards implemented for authentication
- [ ] Material Design 3 theme configured
- [ ] Light and dark mode working with system preference
- [ ] Responsive breakpoint system implemented
- [ ] Custom color scheme based on brand colors
- [ ] Navigation animations configured
- [ ] Deep linking support enabled

## Dependencies
### Requires (Blocked By)
- [ ] Story 1.2.1 - Flutter Project Initialization
- [ ] Story 1.2.2 - Core Package Architecture
- [ ] Story 1.2.3 - State Management Setup (for theme provider)

### Enables (Blocks)
- [ ] Story 1.2.5 - API Client Layer
- [ ] Story 1.4 - Flutter Auth Screens
- [ ] All UI implementation stories

### Integration Points
- **Input**: State management from 1.2.3, constants from 1.2.2
- **Output**: Navigation and theming ready for features
- **Handoff**: Routes available for feature screens

## Tasks

### Navigation Setup (4 hours)
- [ ] Configure go_router
  - [ ] Create `/lib/core/router/app_router.dart`
  - [ ] Define initial routes
  - [ ] Configure route parameters
  - [ ] Set up route transitions
- [ ] Implement route structure
  - [ ] Public routes (/login, /register)
  - [ ] Protected routes (/dashboard, /accounts, /settings)
  - [ ] Nested routes for features
  - [ ] Error route (404)
- [ ] Create route guards
  - [ ] AuthGuard for protected routes
  - [ ] RedirectLogic for authenticated users
  - [ ] Role-based guards (future)
- [ ] Configure deep linking
  - [ ] Web URL strategy
  - [ ] Mobile deep link handling
  - [ ] Path parameters

### Theme Implementation (3 hours)
- [ ] Configure Material Design 3
  - [ ] Create `/lib/core/theme/app_theme.dart`
  - [ ] Define color schemes
  - [ ] Configure typography
  - [ ] Set component themes
- [ ] Implement color system
  - [ ] Primary colors from brand
  - [ ] Secondary colors
  - [ ] Semantic colors (error, success, warning)
  - [ ] Surface colors
- [ ] Configure typography
  - [ ] Define text styles
  - [ ] Responsive font sizes
  - [ ] Font family setup
- [ ] Dark mode support
  - [ ] Dark color scheme
  - [ ] Proper contrast ratios
  - [ ] System preference detection
  - [ ] Manual toggle option

### Responsive System (3 hours)
- [ ] Create responsive utilities
  - [ ] `/lib/shared/widgets/responsive_builder.dart`
  - [ ] Breakpoint definitions (mobile, tablet, desktop)
  - [ ] Responsive padding/margins
  - [ ] Orientation handling
- [ ] Implement adaptive layouts
  - [ ] AdaptiveScaffold widget
  - [ ] Responsive grid system
  - [ ] Adaptive navigation (bottom/side/rail)
  - [ ] Platform-specific adaptations
- [ ] Create responsive helpers
  - [ ] Screen size extensions
  - [ ] Responsive text scaling
  - [ ] Image size adapters

### Component Theming (2 hours)
- [ ] Configure component themes
  - [ ] AppBar theme
  - [ ] Button themes (elevated, text, outlined)
  - [ ] Card theme
  - [ ] Input decoration theme
  - [ ] Dialog theme
  - [ ] Bottom sheet theme
- [ ] Create custom components
  - [ ] Branded loading indicator
  - [ ] Custom snackbar
  - [ ] Themed dividers

### Testing & Validation (2 hours)
- [ ] Test navigation
  - [ ] Route navigation tests
  - [ ] Guard logic tests
  - [ ] Deep link tests
- [ ] Test theming
  - [ ] Theme switching
  - [ ] Dark mode rendering
  - [ ] Responsive breakpoints
- [ ] Visual regression tests setup

### Documentation (1 hour)
- [ ] Document navigation patterns
- [ ] Create theme usage guide
- [ ] Document responsive utilities
- [ ] Add examples

## Definition of Done
- [ ] All routes navigable
- [ ] Theme applied consistently
- [ ] Dark mode working
- [ ] Responsive on all screen sizes
- [ ] Route guards protecting pages
- [ ] No UI inconsistencies
- [ ] Documentation complete

## Dev Notes
- Use Material You dynamic theming where appropriate
- Implement route transitions for better UX
- Consider implementing breadcrumbs for deep navigation
- Use Hero animations for shared elements
- Implement proper focus management
- Test on multiple screen sizes

## Testing
- **Widget Tests**: Navigation and theme switching
- **Integration Tests**: Full navigation flow
- **Visual Tests**: Theme consistency
- **Test Command**: `flutter test test/navigation/ test/theme/`

## Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Route complexity | Medium | Medium | Clear route hierarchy |
| Theme inconsistency | Low | Medium | Component catalog |
| Responsive issues | Medium | High | Test on devices early |

## File List
### Files to Create
- `/frontend/lib/core/router/app_router.dart`
- `/frontend/lib/core/router/route_guards.dart`
- `/frontend/lib/core/router/route_paths.dart`
- `/frontend/lib/core/theme/app_theme.dart`
- `/frontend/lib/core/theme/color_schemes.dart`
- `/frontend/lib/core/theme/typography.dart`
- `/frontend/lib/shared/widgets/responsive_builder.dart`
- `/frontend/lib/shared/widgets/adaptive_scaffold.dart`
- `/frontend/lib/shared/widgets/responsive_grid.dart`
- `/frontend/test/navigation/router_test.dart`
- `/frontend/test/theme/theme_test.dart`
- `/frontend/test/responsive/responsive_test.dart`

### Files to Modify
- `/frontend/lib/main.dart` - Add router configuration
- `/frontend/lib/app.dart` - Apply theme

## Change Log
| Timestamp | Change | Author |
|-----------|--------|---------|
| 21/09/2025 01:36:19 | Story created from 1.2 sharding | Sarah (PO) |
| 21/09/2025 10:15:00 | Status updated to 80% - found 5 files implemented | John (PM) |

---
Last Updated: 21/09/2025 10:15:00