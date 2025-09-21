# 🚀 Quick Setup: GitHub Project Views & Automation

> Step-by-step guide to create your 8 BMAD-optimized project views and activate automation

## 📋 Part 1: Creating Custom Views (5 minutes)

### 1. Navigate to Your Project
Go to: https://github.com/users/caioniehues/projects/2

### 2. Create Epic Command Center View

1. **Click the "+" next to "Table" view**
2. **Select "New view"**
3. **Name**: `🏛️ Epic Command Center`
4. **View type**: Table
5. **Click the Group dropdown** → Select "Epic"
6. **Click the Sort dropdown** → Select "Priority" → "High to Low"
7. **Click the Filter button** → Add filter:
   - `Status` is not `Done`
   - `Business Value` is `🔥 Critical` OR `⭐ High`
8. **Click Fields (eye icon)** → Show these fields:
   - ✅ Title
   - ✅ Epic
   - ✅ Business Value
   - ✅ Status
   - ✅ Size
   - ✅ Priority
   - ✅ Documentation Status
   - ✅ Assignees
9. **Click "Save changes"**

### 3. Create Sprint Planning Board

1. **Click "+" → "New view"**
2. **Name**: `🎯 Sprint Planning Board`
3. **View type**: Board
4. **Group by**: Sprint
5. **Sort by**: Priority (High to Low)
6. **Filter**:
   - `Status` is `Backlog` OR `Sprint Ready` OR `Next Sprint`
   - `Size` is not empty
7. **Save changes**

### 4. Create Active Sprint Dashboard

1. **Click "+" → "New view"**
2. **Name**: `🚀 Active Sprint Dashboard`
3. **View type**: Board
4. **Group by**: Status
5. **Filter**:
   - `Sprint` is `🎯 Current Sprint`
   - `Status` is not `Done` AND not `Backlog`
6. **Save changes**

### 5. Quick Setup for Remaining Views

For the other 5 views, use this pattern:
- **Architecture & Dependencies**: Table, Group by "Technical Risk", Filter "Technical Risk" High/Medium
- **Documentation & Quality Gate**: Table, Group by "Documentation Status"
- **Test Coverage Tracker**: Table, Sort by "Test Coverage %" ascending
- **UX/UI Stories**: Board, Filter Title contains "UI" OR "Flutter" OR "Frontend"
- **Velocity & Metrics**: Table, Group by "Sprint", Filter Status "Done"

## 🎮 Part 2: How to Use Each View

### 🏛️ **Epic Command Center** (Your main dashboard)
**When to use**: Daily PO check-ins, epic planning
**What you see**: All high-value work across epics
**Actions you can take**:
- Drag items between Status columns
- Update Business Value priorities
- Assign team members
- Track epic progress

### 🎯 **Sprint Planning Board** (Every 2 weeks)
**When to use**: Sprint planning meetings
**What you see**: Backlog organized by sprint allocation
**Actions you can take**:
- Drag stories from Backlog → Current Sprint
- Balance story points (aim for 15-20 total)
- Check technical risk distribution
- Verify dependencies

### 🚀 **Active Sprint Dashboard** (Daily standups)
**When to use**: Daily team standups
**What you see**: Current sprint work by status
**Actions you can take**:
- Move work through workflow columns
- Identify blocked items
- Check who's working on what
- Monitor review status

## 🤖 Part 3: GitHub Actions Automation

The views are just the interface - now let's automate the workflow!