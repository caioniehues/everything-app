# Development Workflow Guide

> Complete guide for using the Everything App's automated development workflow

Last Updated: 21/09/2025 02:13:30

## 📚 Table of Contents
- [Starting Development](#starting-development)
- [GitHub Commands](#github-commands)
- [Project Board Automation](#project-board-automation)
- [Branch Naming Convention](#branch-naming-convention)
- [Pull Request Workflow](#pull-request-workflow)
- [BMAD Compliance](#bmad-compliance)

---

## 🚀 Starting Development

### Method 1: Local Script (Recommended)
```bash
# Start development on Story-1.1 (Issue #3)
./scripts/start-story.sh 3

# Start a bugfix branch
./scripts/start-story.sh 3 bugfix

# Start a hotfix branch
./scripts/start-story.sh 3 hotfix
```

**What happens:**
1. Creates branch: `feature/story-1.1-backend-infrastructure`
2. Assigns issue to you
3. Updates project board Status to "In Progress"
4. Moves to "Current Sprint"
5. Sets Documentation Status to "In Progress"
6. Posts development instructions to issue

### Method 2: GitHub Comments
Comment on any issue with:
```
/start          # Creates feature branch
/start bugfix   # Creates bugfix branch
/start hotfix   # Creates hotfix branch
/develop        # Alias for /start
```

### Method 3: Manual Assignment
When an issue is assigned to you, the bot will:
- Post instructions for starting development
- Prompt you to use `/start` command
- Provide the exact script command to run

---

## 💬 GitHub Commands

### Development Commands
| Command | Description |
|---------|-------------|
| `/start [type]` | Start development (feature/bugfix/hotfix) |
| `/develop` | Alias for /start |
| `/begin` | Alias for /start |
| `/status` | Check current issue status |
| `/blocked <reason>` | Mark issue as blocked |
| `/unblock` | Remove blocked status |
| `/ready-for-review` | Move to review status |

### Sprint Management
| Command | Description |
|---------|-------------|
| `/sprint current` | Move to current sprint |
| `/sprint next` | Move to next sprint |
| `/sprint backlog` | Move back to backlog |

### Documentation
| Command | Description |
|---------|-------------|
| `/docs pending` | Mark documentation as pending |
| `/docs progress` | Mark documentation in progress |
| `/docs complete` | Mark documentation complete |

### Other Commands
| Command | Description |
|---------|-------------|
| `/help` | Show all available commands |
| `/assign @username` | Assign to specific user |
| `/estimate <points>` | Set story points |

---

## 📊 Project Board Automation

### Automatic Updates
The project board updates automatically when:

1. **Issue Created**: Added to Backlog
2. **Issue Assigned**: Prompts to start development
3. **Development Started**: Moves to In Progress
4. **PR Created**: Links to issue
5. **PR Approved**: Updates Review Status
6. **PR Merged**: Moves to Done
7. **Tests Pass**: Updates Test Coverage %

### Field Updates
BMAD fields are automatically maintained:
- **Status**: Todo → In Progress → Review → Done
- **Sprint**: Backlog → Current Sprint → Completed
- **Test Coverage %**: Updated from CI/CD
- **Documentation Status**: Tracked through workflow
- **Review Status**: Updated on PR reviews

---

## 🌿 Branch Naming Convention

### Format
`<type>/story-<number>-<description>`

### Examples
```
feature/story-1.1-backend-infrastructure
bugfix/story-2.1-fix-auth-token-expiry
hotfix/story-3.2-critical-security-patch
chore/story-4.1-update-dependencies
```

### For Non-Story Issues
`<type>/issue-<number>-<description>`

```
feature/issue-42-add-dark-mode
bugfix/issue-99-fix-login-error
```

---

## 🔀 Pull Request Workflow

### Creating a PR
```bash
# After completing development
gh pr create --title "feat: Story-1.1 Backend Infrastructure" \
             --body "Closes #3"
```

### PR Template
The PR should include:
```markdown
## Summary
Brief description of changes

## Story/Issue
Closes #<issue-number>

## Changes
- List of changes

## Test Coverage
- Backend: XX%
- Frontend: XX%

## Checklist
- [ ] Tests written (TDD)
- [ ] Documentation updated
- [ ] Coverage meets requirements
```

### Automatic Actions on PR
1. **Test Coverage Gate**: Blocks merge if < 80%/70%
2. **Documentation Gate**: Ensures docs are updated
3. **Project Board Update**: Moves to Review
4. **Status Checks**: Runs all CI/CD

---

## ✅ BMAD Compliance

### Required for Every Story

1. **Business Value Assessment**
   - Critical: Foundation/Security
   - High: Core Features
   - Medium: Enhancements

2. **Technical Risk Evaluation**
   - High: Complex integrations
   - Medium: Standard features
   - Low: UI/minor changes

3. **Test Coverage Requirements**
   - Backend: 80% minimum
   - Frontend: 70% minimum
   - Auth/Security: 90% minimum

4. **Documentation Requirements**
   - API documentation (JavaDoc/DartDoc)
   - Architecture updates
   - User guides
   - Sprint reports

---

## 📋 Development Checklist

### Before Starting
- [ ] Read the story/issue description
- [ ] Check dependencies
- [ ] Review acceptance criteria
- [ ] Run `/start` or use script

### During Development
- [ ] Write tests first (TDD)
- [ ] Implement feature
- [ ] Update documentation
- [ ] Check test coverage

### Before PR
- [ ] All tests passing
- [ ] Coverage meets requirements
- [ ] Documentation updated
- [ ] No TODO comments

### After PR
- [ ] Respond to reviews
- [ ] Update based on feedback
- [ ] Ensure CI/CD passes
- [ ] Merge when approved

---

## 🔄 Typical Workflow Example

```bash
# 1. Start development on Story-1.1
./scripts/start-story.sh 3

# 2. Write tests first
cd backend
./mvnw test

# 3. Implement feature
# ... code ...

# 4. Check coverage
./mvnw clean test jacoco:report

# 5. Commit changes
git add .
git commit -m "feat: implement backend infrastructure for Story-1.1"

# 6. Push branch
git push -u origin feature/story-1.1-backend-infrastructure

# 7. Create PR
gh pr create --title "feat: Story-1.1 Backend Infrastructure" \
             --body "Closes #3"

# 8. Monitor CI/CD
gh pr checks

# 9. Merge when approved
gh pr merge --squash
```

---

## 🚨 Troubleshooting

### Branch Already Exists
```bash
# If branch exists locally
git checkout feature/story-1.1-backend-infrastructure

# If branch exists on remote
git checkout -b feature/story-1.1-backend-infrastructure origin/feature/story-1.1-backend-infrastructure
```

### Project Board Not Updating
1. Check GitHub Actions are enabled
2. Verify PAT has `project` scope
3. Check workflow logs: Actions tab

### Permission Denied
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

### Can't Find Issue in Project
```bash
# Add issue to project manually
gh project item-add 2 --owner caioniehues --url https://github.com/caioniehues/everything-app/issues/3
```

---

## 📚 Related Documentation

- [BMAD Workflow](architecture/workflow.md)
- [Coding Standards](architecture/coding-standards.md)
- [TDD Guide](architecture/tdd-guide.md)
- [GitHub Actions](.github/workflows/README.md)
- [Sprint Planning](sprint-planning.md)

---

## 💡 Tips & Best Practices

1. **Always use the automation** - Ensures consistency
2. **Start with tests** - TDD is mandatory
3. **Update docs immediately** - Don't wait for PR
4. **Check coverage early** - Avoid last-minute fixes
5. **Use descriptive commits** - Follow conventional commits
6. **Review project board** - Stay aware of sprint status
7. **Communicate blockers** - Use `/blocked` command
8. **Small, focused PRs** - Easier to review
9. **Link issues properly** - Use "Closes #XX"
10. **Monitor CI/CD** - Fix failures immediately

---

*For questions or issues with the workflow, check the [GitHub Actions logs](https://github.com/caioniehues/everything-app/actions) or create an issue.*