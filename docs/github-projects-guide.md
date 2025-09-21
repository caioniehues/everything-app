# GitHub Projects Setup Guide for Everything App

## Overview

GitHub Projects provides integrated project management directly within GitHub, perfect for managing the Everything App's 38 stories across 5 epics.

## Project Structure

### Board Configuration

#### 1. Main Project Board: "Everything App Development"
```
Columns:
├── 📋 Backlog        (New stories)
├── 🎯 Sprint Ready   (Refined, ready for sprint)
├── 🚀 In Sprint      (Current sprint work)
├── 🔨 In Progress    (Active development)
├── 👀 In Review      (PR created)
├── ✅ Done           (Merged to main)
└── 🚫 Blocked        (Dependencies/issues)
```

#### 2. Custom Fields

| Field Name    | Type          | Options/Purpose             |
|---------------|---------------|-----------------------------|
| Epic          | Single select | Epic 1-5                    |
| Story ID      | Text          | Story-X.Y.Z format          |
| Story Points  | Number        | Fibonacci (1,2,3,5,8,13)    |
| Sprint        | Iteration     | Sprint 1-10                 |
| Priority      | Single select | Critical, High, Medium, Low |
| Team Member   | Single select | Ruby, Sally, Winston, etc.  |
| Test Coverage | Number        | Percentage achieved         |
| Dependencies  | Text          | Comma-separated story IDs   |

### Views Configuration

#### View 1: Sprint Board (Default)
- **Layout**: Board
- **Group by**: Status
- **Filter**: Sprint = Current
- **Sort**: Priority (desc), Story Points (asc)

#### View 2: Epic Overview
- **Layout**: Table
- **Group by**: Epic
- **Fields shown**: Story ID, Title, Status, Sprint, Dependencies
- **Sort**: Story ID (asc)

#### View 3: Backlog Planning
- **Layout**: Table
- **Filter**: Status = Backlog OR Sprint Ready
- **Group by**: Epic
- **Sort**: Priority, Dependencies

#### View 4: Sprint Timeline
- **Layout**: Roadmap
- **Date field**: Sprint iteration
- **Group by**: Epic
- **Shows**: Current sprint progress

#### View 5: Team Workload
- **Layout**: Table
- **Group by**: Team Member
- **Filter**: Status = In Progress OR In Sprint
- **Shows**: Story points per person

## Implementation Steps

### Step 1: Create the Project

1. Go to https://github.com/caioniehues/everything-app
2. Click "Projects" tab → "New project"
3. Choose "Team planning" template
4. Name: "Everything App - BMAD Development"

### Step 2: Configure Custom Fields

```javascript
// Custom fields to add:
{
  "epic": {
    "type": "single_select",
    "options": [
      "Epic 1: Authentication",
      "Epic 2: Accounts",
      "Epic 3: Transactions",
      "Epic 4: Budgets",
      "Epic 5: Dashboard"
    ]
  },
  "story_id": {
    "type": "text",
    "description": "Story-X.Y.Z format"
  },
  "story_points": {
    "type": "number",
    "description": "Estimated effort"
  },
  "acceptance_criteria": {
    "type": "text",
    "description": "Checklist of requirements"
  }
}
```

### Step 3: Automation Rules

#### Auto-move based on Issue/PR status:
```yaml
# When issue created → Backlog
trigger: issues.opened
action: move_to_column("Backlog")

# When PR opened → In Review
trigger: pull_request.opened
action: move_to_column("In Review")

# When PR merged → Done
trigger: pull_request.merged
action: move_to_column("Done")

# When issue closed → Done
trigger: issues.closed
action: move_to_column("Done")
```

#### Label-based automation:
```yaml
# When labeled "blocked" → Blocked column
trigger: labeled("blocked")
action: move_to_column("Blocked")

# When labeled "ready-for-sprint" → Sprint Ready
trigger: labeled("ready-for-sprint")
action: move_to_column("Sprint Ready")
```

### Step 4: Create Issues from Stories

Use this script to bulk-create issues from your stories:

```bash
#!/bin/bash
# create-github-issues.sh

# Function to create issue from story file
create_issue_from_story() {
    local story_file=$1
    local story_id=$(basename "$story_file" .md | sed 's/story-/Story-/')

    # Extract title and content
    local title=$(grep "^# " "$story_file" | head -1 | sed 's/^# //')
    local body=$(cat "$story_file")

    # Create issue using GitHub CLI
    gh issue create \
        --title "$story_id: $title" \
        --body "$body" \
        --label "story" \
        --project "Everything App - BMAD Development"
}

# Create issues for all stories
for story in docs/stories/story-*.md; do
    if [ -f "$story" ]; then
        echo "Creating issue for: $story"
        create_issue_from_story "$story"
    fi
done
```

### Step 5: Sprint Planning Workflow

#### Sprint Planning Meeting (Start of Sprint)
1. Review backlog items in "Sprint Ready" column
2. Assign story points collectively
3. Move selected stories to "In Sprint"
4. Set Sprint field to current iteration
5. Assign team members

#### Daily Standup View
- Filter: Sprint = Current AND Status != Done
- Group by: Team Member
- Shows blockers and progress

#### Sprint Review (End of Sprint)
- Filter: Sprint = Current
- Calculate velocity (sum of story points in Done)
- Move incomplete items back to Sprint Ready
- Archive completed sprint view

## Integrations

### 1. With GitHub Actions

Your existing Claude workflows can update the project board:

```yaml
# In .github/workflows/claude-sprint-assistant.yml
- name: Update Project Board
  uses: actions/add-to-project@v0.5.0
  with:
    project-url: https://github.com/users/caioniehues/projects/1
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### 2. With Commit Messages

Use conventional commits to auto-update:
```bash
git commit -m "feat(Story-1.2.1): Initialize Flutter project

Closes #15
Moves Story-1.2.1 to Done"
```

### 3. With Pull Requests

PR template to link to project:
```markdown
## Story Reference
Story: Story-X.Y.Z
Epic: Epic X
Sprint: Sprint Y

## Acceptance Criteria
- [ ] Criteria 1 met
- [ ] Criteria 2 met
- [ ] Tests passing
- [ ] Coverage > 80%
```

## Metrics and Insights

### Key Metrics to Track

1. **Velocity Chart**
   - Story points completed per sprint
   - Rolling 3-sprint average

2. **Burndown Chart**
   - Daily progress within sprint
   - Remaining story points

3. **Cycle Time**
   - Time from "In Progress" to "Done"
   - Identify bottlenecks

4. **Epic Progress**
   - Percentage complete per epic
   - Dependencies blocking progress

### Custom Insights Queries

```graphql
# Stories blocked by dependencies
{
  project(number: 1) {
    items(first: 100) {
      nodes {
        fieldValues(first: 10) {
          nodes {
            ... on ProjectV2ItemFieldTextValue {
              field { name }
              text
            }
          }
        }
      }
    }
  }
}
```

## Best Practices

### Do's
✅ Update status daily during active development
✅ Add context in issue comments
✅ Link PRs to issues with "Closes #X"
✅ Review board in sprint planning
✅ Keep acceptance criteria as checklist
✅ Use milestones for epics

### Don'ts
❌ Create duplicate issues for same story
❌ Skip updating story points
❌ Move cards without updating issue
❌ Leave items in "In Progress" when blocked
❌ Forget to update sprint field

## Advanced Features

### 1. Dependency Tracking
Create a "Blocked By" field linking to other issues:
```yaml
blocked_by:
  type: issue_reference
  allows_multiple: true
```

### 2. Time Tracking
Add fields for:
- Estimated hours
- Actual hours
- Time remaining

### 3. Risk Management
Add risk field with options:
- Low
- Medium
- High
- Critical

### 4. Sub-tasks
Use task lists in issues:
```markdown
## Tasks
- [ ] Write unit tests
- [ ] Implement feature
- [ ] Update documentation
- [ ] Code review
```

## Migration from Docs to Projects

### Quick Start Script
```bash
#!/bin/bash
# Migrate all stories to GitHub issues

# 1. Create project
gh project create "Everything App - BMAD" --owner @me

# 2. Create issues from stories
for story in docs/stories/story-*.md; do
    gh issue create --title "$(head -1 $story)" --body-file "$story"
done

# 3. Add issues to project
gh project item-add 1 --owner @me --url $(gh issue list --json url -q '.[].url')
```

## Project Templates

### Sprint Planning Template
```markdown
# Sprint X Planning

**Sprint Goal**: [Main objective]
**Duration**: DD/MM/YYYY - DD/MM/YYYY

## Selected Stories
- [ ] Story-X.Y.Z (X points)
- [ ] Story-A.B.C (Y points)
Total: XX points

## Team Capacity
- Ruby: XX hours
- Sally: XX hours
Total: XXX hours

## Risks
- [Risk description]

## Dependencies
- [External dependencies]
```

## 📚 Additional Resources

### Internal Documentation
- [Development Workflow Guide](development-workflow.md) - Complete guide for using automation
- [BMAD Workflow Guide](architecture/workflow.md) - BMAD methodology details
- [GitHub Actions Documentation](.github/workflows/README.md) - Workflow configurations
- [Epic Story Summary](stories/epic-story-summary.md) - All 38 stories

### External Documentation
- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [GitHub GraphQL API](https://docs.github.com/en/graphql)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---
*Last Updated: 21/09/2025 14:33:45*