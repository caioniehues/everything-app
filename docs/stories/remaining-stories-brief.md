# Remaining Stories - Brief Definitions

## Document Information
| Field | Value |
|-------|-------|
| Date | 21/09/2025 01:17:53 |
| Author | Winston (Architect) |
| Purpose | Quick reference for remaining stories to be fully documented |
| Note | These need to be expanded into full story files |

## Epic 4: Budget Creation & Tracking (Remaining)

### Story 4.2: Budget Management API
**Priority**: MEDIUM | **Est. Days**: 3 | **Points**: 5
- Create budget CRUD endpoints
- Calculate spending in real-time
- Trigger alerts at thresholds
- Support budget templates

### Story 4.3: Budget Setup Wizard
**Priority**: MEDIUM | **Est. Days**: 3 | **Points**: 5
- Multi-step wizard UI
- Suggest limits based on history
- Template selection
- Visual budget preview

### Story 4.4: Budget Tracking Dashboard
**Priority**: MEDIUM | **Est. Days**: 2 | **Points**: 3
- Budget progress widgets
- Color-coded progress bars
- Spending pace warnings
- Quick transaction entry

### Story 4.5: Budget Analysis & Reports
**Priority**: LOW | **Est. Days**: 2 | **Points**: 3
- Budget vs actual comparison
- Historical performance
- Export reports
- Spending insights

## Epic 5: Dashboard & Analytics

### Story 5.1: Dashboard Implementation
**Priority**: HIGH | **Est. Days**: 4 | **Points**: 8
**Note**: Needs sharding - multiple widgets
- Account summary widget
- Recent transactions widget
- Budget progress widget
- Quick actions widget
- Net worth chart

### Story 5.2: Dashboard State Management
**Priority**: HIGH | **Est. Days**: 2 | **Points**: 3
- Real-time data updates
- Widget refresh logic
- Cache management
- Performance optimization

### Story 5.3: Analytics & Reports API
**Priority**: MEDIUM | **Est. Days**: 3 | **Points**: 5
- Cash flow analysis endpoint
- Spending by category endpoint
- Trend calculations
- Report generation

### Story 5.4: Analytics UI & Charts
**Priority**: MEDIUM | **Est. Days**: 3 | **Points**: 5
- Interactive charts
- Spending breakdown
- Trend visualizations
- Custom date ranges

## Epic 6: Data Import & Recurring Transactions

### Story 6.1: Import Data Model & Parser
**Priority**: LOW | **Est. Days**: 3 | **Points**: 5
- CSV parser implementation
- OFX/QFX parser
- Data validation
- Mapping rules

### Story 6.2: Import API & Processing
**Priority**: LOW | **Est. Days**: 3 | **Points**: 5
- Upload endpoints
- Async processing
- Duplicate detection
- Import history

### Story 6.3: Import UI & Mapping
**Priority**: LOW | **Est. Days**: 2 | **Points**: 3
- File upload interface
- Column mapping UI
- Preview imported data
- Conflict resolution

### Story 6.4: Recurring Transactions
**Priority**: LOW | **Est. Days**: 3 | **Points**: 5
- Recurring transaction model
- Scheduling engine
- Auto-creation logic
- Management UI

## Additional Stories (Phase 2)

### Story 7.1: Family Member Management
**Priority**: MEDIUM | **Est. Days**: 2 | **Points**: 3
- Invite family members
- Role management
- Permissions system

### Story 7.2: Mobile-Specific Features
**Priority**: MEDIUM | **Est. Days**: 3 | **Points**: 5
- Biometric authentication
- Push notifications
- Offline sync
- Location-based suggestions

### Story 7.3: Advanced Search
**Priority**: LOW | **Est. Days**: 2 | **Points**: 3
- Full-text search
- Advanced filters
- Saved searches
- Search suggestions

### Story 7.4: Data Export & Backup
**Priority**: MEDIUM | **Est. Days**: 2 | **Points**: 3
- Export all data
- Automated backups
- Data portability
- Archive old data

## Summary Statistics

| Epic | Remaining Stories | Points | Est. Days |
|------|------------------|--------|-----------|
| Epic 4 | 4 | 16 | 10 |
| Epic 5 | 4 | 21 | 12 |
| Epic 6 | 4 | 18 | 11 |
| Phase 2 | 4 | 14 | 9 |
| **Total** | **16** | **69** | **42** |

## Next Actions

1. **Expand Priority Stories**: Convert high-priority stories to full documentation
2. **Story Sharding**: Break down large stories (5.1, 6.2)
3. **Sprint Planning**: Assign stories to sprints based on dependencies
4. **Resource Allocation**: Assign developers to stories

## Notes

- Story 5.1 (Dashboard) is too large and needs sharding into 4 sub-stories
- Story 6.2 (Import Processing) could be split by file format
- Phase 2 stories are post-MVP and can be deferred
- Consider parallel development tracks for backend/frontend stories

---
*This document provides quick reference for remaining stories. Each should be expanded into a full story file following the established template.*