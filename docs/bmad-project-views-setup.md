# BMAD-Optimized GitHub Project Views & Automation Guide

> Comprehensive setup guide for Everything App's GitHub Project board, perfectly tailored for BMAD methodology

Last Updated: 21/09/2025 15:42:18

## 🎯 Overview

This guide configures your GitHub Project board with 8 specialized views and 12 automation rules specifically designed for your BMAD workflow, Everything App requirements, and team structure.

## 📋 Custom Views to Create

### 1. 🏛️ **Epic Command Center** (Product Owner View)

**Purpose**: Strategic overview for Sarah (PO) to track epic progress and business value delivery

**View Type**: Table
**Group By**: Epic
**Sort By**: Business Value (Critical → High → Medium → Future)
**Fields to Show**:
- Title
- Epic
- Business Value
- Status
- Size
- Priority
- Documentation Status
- Assignees

**Filters**:
```
Status: NOT Done
Business Value: Critical OR High
```

**Use Case**: Sarah can see all high-value stories across epics, prioritize work, and ensure critical MVP features are progressing.

---

### 2. 🎯 **Sprint Planning Board** (Team Planning View)

**Purpose**: Select and organize stories for upcoming sprints

**View Type**: Board
**Group By**: Sprint
**Sort By**: Priority (High → Medium → Low)
**Fields to Show**:
- Title
- Epic
- Size
- Priority
- Technical Risk
- Business Value
- Dependencies

**Filters**:
```
Status: Backlog OR Sprint Ready OR Next Sprint
Size: IS NOT EMPTY
```

**Columns**:
- ❄️ Backlog (not yet planned)
- 📋 Next Sprint (planned for next iteration)
- 🎯 Current Sprint (active sprint work)

**Use Case**: Team planning sessions to move stories from backlog to sprints, ensuring 15-20 points per sprint with balanced risk.

---

### 3. 🚀 **Active Sprint Dashboard** (Daily Standup View)

**Purpose**: Daily progress tracking and blocker identification

**View Type**: Board
**Group By**: Status
**Sort By**: Priority, then Assignees
**Fields to Show**:
- Title
- Assignees
- Epic
- Size
- Review Status
- Test Coverage %

**Filters**:
```
Sprint: Current Sprint
Status: NOT Done AND NOT Backlog
```

**Columns**:
- 🎯 In Sprint (sprint work not started)
- 🔨 In Progress (active development)
- 👀 In Review (PR/code review)
- 🧪 QA Review (testing phase)
- ✅ Done (completed this sprint)
- 🚫 Blocked (impediments)

**Use Case**: Daily standups to see who's working on what, identify blockers, and track sprint progress.

---

### 4. 🏗️ **Architecture & Dependencies** (Technical Lead View)

**Purpose**: Winston (Architect) to manage technical complexity and dependencies

**View Type**: Table
**Group By**: Technical Risk
**Sort By**: Epic, then Priority
**Fields to Show**:
- Title
- Epic
- Technical Risk
- Dependencies
- Status
- Assignees
- Test Coverage %

**Filters**:
```
Technical Risk: High OR Medium OR Unknown
Status: NOT Done
```

**Use Case**: Identify high-risk stories needing architecture review, manage dependencies, and ensure proper technical planning.

---

### 5. 📝 **Documentation & Quality Gate** (BMAD Compliance)

**Purpose**: Track BMAD documentation requirements and quality gates

**View Type**: Table
**Group By**: Documentation Status
**Sort By**: Epic, then Priority
**Fields to Show**:
- Title
- Epic
- Documentation Status
- Review Status
- Test Coverage %
- Status

**Filters**:
```
Status: In Progress OR In Review OR Done
Documentation Status: IS NOT EMPTY
```

**Use Case**: Ensure all stories meet BMAD documentation standards before completion.

---

### 6. 🧪 **Test Coverage Tracker** (TDD Compliance)

**Purpose**: Monitor test-driven development compliance

**View Type**: Table
**Group By**: Test Coverage %
**Sort By**: Test Coverage % (ascending)
**Fields to Show**:
- Title
- Epic
- Test Coverage %
- Status
- Review Status
- Assignees

**Filters**:
```
Status: In Progress OR In Review
Test Coverage %: < 80 (for backend stories) OR < 70 (for frontend stories)
```

**Use Case**: Identify stories with insufficient test coverage before they can be marked complete.

---

### 7. 🎨 **UX/UI Stories** (Design-Focused View)

**Purpose**: Sally (UX Expert) to track UI/UX related work

**View Type**: Board
**Group By**: Status
**Sort By**: Priority
**Fields to Show**:
- Title
- Epic
- Priority
- Status
- Review Status

**Filters**:
```
Title: CONTAINS "UI" OR "UX" OR "Design" OR "Frontend" OR "Flutter"
Epic: NOT "Epic 1: Authentication" (backend-heavy)
```

**Use Case**: Focus on user experience stories, design consistency, and frontend work.

---

### 8. 📊 **Velocity & Metrics** (Performance Tracking)

**Purpose**: Track team velocity and sprint performance

**View Type**: Table
**Group By**: Sprint
**Sort By**: Epic, then Size
**Fields to Show**:
- Title
- Epic
- Size
- Status
- Sprint
- Business Value

**Filters**:
```
Status: Done OR In Progress
Sprint: Current Sprint OR Completed
```

**Use Case**: Calculate sprint velocity, plan future capacity, and track completion metrics.

---

## 🤖 Workflow Automations to Configure

### Core BMAD Automations

#### 1. **Story Lifecycle Management**
```yaml
Trigger: Pull request opened
Action: Move item to "In Review" + Set Review Status to "👀 Code Review"

Trigger: Pull request merged
Action: Move item to "Done" + Set Review Status to "✅ Approved"

Trigger: Pull request closed (not merged)
Action: Move item back to "In Progress" + Set Review Status to "🔄 Changes Requested"
```

#### 2. **Documentation Enforcement**
```yaml
Trigger: Status changed to "In Review"
Condition: Documentation Status = "📝 Pending"
Action: Add comment "⚠️ BMAD Requirement: Update documentation before review"

Trigger: Status changed to "Done"
Condition: Documentation Status ≠ "✅ Complete"
Action: Move back to "In Review" + Add label "documentation-required"
```

#### 3. **Test Coverage Gates**
```yaml
Trigger: Status changed to "In Review"
Condition: Test Coverage % < 80 (backend) OR < 70 (frontend)
Action: Add comment "❌ TDD Gate Failed: Insufficient test coverage"
Action: Set Review Status to "🔄 Changes Requested"
```

#### 4. **Sprint Boundary Management**
```yaml
Trigger: Sprint iteration ends
Condition: Status ≠ "Done"
Action: Move to "Backlog" + Set Sprint to "❄️ Backlog"
Action: Add comment "🔄 Moved to backlog - incomplete in sprint"
```

#### 5. **Epic Progress Tracking**
```yaml
Trigger: Story status changed to "Done"
Action: Calculate epic completion percentage
Action: Update epic milestone description with progress
```

#### 6. **Critical Path Monitoring**
```yaml
Trigger: Business Value = "🔥 Critical" AND Status = "🚫 Blocked"
Action: Add label "critical-blocked"
Action: Assign to project maintainer
Action: Send notification to team
```

---

## 🛠️ Step-by-Step Setup Instructions

### Creating Views in GitHub Projects UI

1. **Navigate to your project**: https://github.com/users/caioniehues/projects/2

2. **For each view above**:
   - Click the "+" next to existing views
   - Choose "New view"
   - Select view type (Table/Board)
   - Configure fields, filters, grouping, and sorting as specified
   - Save with the exact name provided

### Setting Up Automations

1. **Access Project Settings**:
   - Go to project → Settings (⚙️)
   - Click "Workflows" in sidebar

2. **Create Built-in Workflows**:
   - "Auto-archive items" → Enable for Done items
   - "Auto-add to project" → Enable for new issues in repo
   - "Item added to project" → Set default Status to "Backlog"

3. **Advanced Automations** (requires GitHub Actions):
   - Use the workflow files in `.github/workflows/`
   - Claude GitHub Actions already configured for some automation

---

## 📈 BMAD Workflow Implementation

### Sprint Planning Process (Every 2 weeks)

1. **Epic Command Center** → Review business priorities with Sarah
2. **Sprint Planning Board** → Move 15-20 points from Backlog to Current Sprint
3. **Architecture & Dependencies** → Winston reviews technical risks
4. **Active Sprint Dashboard** → Set up for daily standups

### Daily Standup Process

1. **Active Sprint Dashboard** → Review In Progress and Blocked items
2. **Test Coverage Tracker** → Identify coverage gaps
3. **Documentation & Quality Gate** → Check BMAD compliance

### Sprint Review Process

1. **Velocity & Metrics** → Calculate completed story points
2. **Documentation & Quality Gate** → Ensure all Done items have docs
3. **Sprint Planning Board** → Move incomplete items back to Backlog

---

## 🎯 Board Usage by Role

### Sarah (Product Owner)
- **Primary View**: Epic Command Center
- **Daily Check**: Business Value tracking
- **Sprint Planning**: Prioritize Critical/High value items

### Winston (Architect)
- **Primary View**: Architecture & Dependencies
- **Daily Check**: Technical Risk assessment
- **Code Reviews**: Ensure architecture compliance

### Ruby (Backend Developer)
- **Primary View**: Active Sprint Dashboard
- **Daily Check**: Test Coverage Tracker
- **Focus**: Backend stories with 80%+ coverage

### Sally (UX Expert)
- **Primary View**: UX/UI Stories
- **Daily Check**: Frontend/Flutter stories
- **Focus**: User experience consistency

### Marcus (DevOps)
- **Primary View**: Architecture & Dependencies
- **Daily Check**: Infrastructure stories
- **Focus**: CI/CD and deployment readiness

---

## 🔥 Quick Actions for BMAD Compliance

### Starting a New Story
1. Move from Backlog → In Sprint
2. Set Documentation Status → "🔄 In Progress"
3. Assign to yourself
4. Update Test Coverage % as you add tests

### Completing a Story
1. Ensure Test Coverage % ≥ threshold
2. Set Documentation Status → "✅ Complete"
3. Set Review Status → "📋 PO Review"
4. Create PR with "Closes #issue-number"

### Sprint Planning
1. Review Epic Command Center for business priorities
2. Use Sprint Planning Board to allocate work
3. Balance Technical Risk across sprint
4. Aim for 15-20 story points per sprint

---

## 📊 Success Metrics

**Sprint Velocity**: 15-20 story points per 2-week sprint
**Test Coverage**: 80% backend, 70% frontend (minimum)
**Documentation Compliance**: 100% of Done stories
**Technical Debt**: <20% high-risk stories in active development
**Epic Progress**: Visible progress each sprint on Critical/High value stories

---

Your GitHub Project board is now configured as a powerful BMAD command center that enforces quality gates, tracks progress, and optimizes your Everything App development workflow! 🚀