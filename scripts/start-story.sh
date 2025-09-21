#!/bin/bash

# Start development on a story - creates branch, updates project board, assigns issue
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Everything App - Story Development Starter${NC}"
echo "=============================================="

# Check if issue number was provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: ./scripts/start-story.sh <issue-number> [branch-type]${NC}"
    echo ""
    echo "Examples:"
    echo "  ./scripts/start-story.sh 3          # Creates feature/story-1.1-backend-infrastructure"
    echo "  ./scripts/start-story.sh 3 bugfix   # Creates bugfix/story-1.1-backend-infrastructure"
    echo "  ./scripts/start-story.sh 3 hotfix   # Creates hotfix/story-1.1-backend-infrastructure"
    echo ""
    echo "Branch types: feature (default), bugfix, hotfix, chore"
    exit 1
fi

ISSUE_NUMBER=$1
BRANCH_TYPE=${2:-feature}
REPO_OWNER="caioniehues"
REPO_NAME="everything-app"

# Validate branch type
if [[ ! "$BRANCH_TYPE" =~ ^(feature|bugfix|hotfix|chore)$ ]]; then
    echo -e "${RED}❌ Invalid branch type: $BRANCH_TYPE${NC}"
    echo "Valid types: feature, bugfix, hotfix, chore"
    exit 1
fi

echo -e "${BLUE}📋 Fetching issue #$ISSUE_NUMBER...${NC}"

# Get issue details
ISSUE_DATA=$(gh issue view $ISSUE_NUMBER --repo $REPO_OWNER/$REPO_NAME --json title,state,assignees,body 2>/dev/null)

if [ -z "$ISSUE_DATA" ]; then
    echo -e "${RED}❌ Issue #$ISSUE_NUMBER not found${NC}"
    exit 1
fi

# Extract issue title and state
ISSUE_TITLE=$(echo "$ISSUE_DATA" | jq -r '.title')
ISSUE_STATE=$(echo "$ISSUE_DATA" | jq -r '.state')
ASSIGNEES=$(echo "$ISSUE_DATA" | jq -r '.assignees[].login' | paste -sd "," -)

# Check if issue is already closed
if [ "$ISSUE_STATE" == "CLOSED" ]; then
    echo -e "${YELLOW}⚠️  Warning: Issue #$ISSUE_NUMBER is already closed${NC}"
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo -e "${GREEN}✅ Found: $ISSUE_TITLE${NC}"

# Extract story number from title if it exists
STORY_NUMBER=""
if echo "$ISSUE_TITLE" | grep -q "Story-"; then
    STORY_NUMBER=$(echo "$ISSUE_TITLE" | grep -oE 'Story-[0-9.]+' | head -1 | sed 's/Story-//')
    echo -e "${BLUE}📖 Story Number: $STORY_NUMBER${NC}"
fi

# Generate branch name
if [ -n "$STORY_NUMBER" ]; then
    # Extract story description from title (remove Story-X.X: prefix)
    STORY_DESC=$(echo "$ISSUE_TITLE" | sed -E 's/Story-[0-9.]+[: ]*//' | tr '[:upper:]' '[:lower:]')
    # Clean up the description for branch name
    STORY_DESC=$(echo "$STORY_DESC" | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | cut -c1-50)
    BRANCH_NAME="$BRANCH_TYPE/story-$STORY_NUMBER-$STORY_DESC"
else
    # For non-story issues, use issue number and title
    ISSUE_DESC=$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | cut -c1-50)
    BRANCH_NAME="$BRANCH_TYPE/issue-$ISSUE_NUMBER-$ISSUE_DESC"
fi

echo -e "${BLUE}🌿 Branch name: $BRANCH_NAME${NC}"

# Check if branch already exists locally
if git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
    echo -e "${YELLOW}⚠️  Branch '$BRANCH_NAME' already exists locally${NC}"
    echo "Switching to existing branch..."
    git checkout $BRANCH_NAME
else
    # Check if branch exists on remote
    if git ls-remote --heads origin $BRANCH_NAME | grep -q $BRANCH_NAME; then
        echo -e "${YELLOW}⚠️  Branch exists on remote, checking out...${NC}"
        git checkout -b $BRANCH_NAME origin/$BRANCH_NAME
    else
        # Create new branch from master
        echo -e "${GREEN}✅ Creating new branch from master...${NC}"
        git checkout master
        git pull origin master
        git checkout -b $BRANCH_NAME
        echo -e "${GREEN}✅ Branch created: $BRANCH_NAME${NC}"
    fi
fi

# Assign issue to current user if not already assigned
CURRENT_USER=$(gh api user --jq '.login')
if [ -z "$ASSIGNEES" ] || [[ ! "$ASSIGNEES" =~ $CURRENT_USER ]]; then
    echo -e "${BLUE}👤 Assigning issue to @$CURRENT_USER...${NC}"
    gh issue edit $ISSUE_NUMBER --add-assignee @me
    echo -e "${GREEN}✅ Issue assigned${NC}"
else
    echo -e "${BLUE}✓ Issue already assigned to: $ASSIGNEES${NC}"
fi

# Update project board status to "In Progress"
echo -e "${BLUE}📊 Updating project board...${NC}"

PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"
STATUS_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fnvA"
SPRINT_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs6I"

# Get the project item ID for this issue
ITEM_ID=$(gh api graphql -f query='
{
  repository(owner: "'$REPO_OWNER'", name: "'$REPO_NAME'") {
    issue(number: '$ISSUE_NUMBER') {
      projectItems(first: 10) {
        nodes {
          id
          project {
            number
          }
        }
      }
    }
  }
}' --jq '.data.repository.issue.projectItems.nodes[] | select(.project.number == 2) | .id' 2>/dev/null || echo "")

if [ -n "$ITEM_ID" ]; then
    # Get Status field options
    STATUS_OPTIONS=$(gh api graphql -f query='
    {
      node(id: "'$PROJECT_ID'") {
        ... on ProjectV2 {
          field(name: "Status") {
            ... on ProjectV2SingleSelectField {
              options { id, name }
            }
          }
        }
      }
    }' --jq '.data.node.field.options' 2>/dev/null || echo "")

    # Get Sprint field options
    SPRINT_OPTIONS=$(gh api graphql -f query='
    {
      node(id: "'$PROJECT_ID'") {
        ... on ProjectV2 {
          field(name: "Sprint") {
            ... on ProjectV2SingleSelectField {
              options { id, name }
            }
          }
        }
      }
    }' --jq '.data.node.field.options' 2>/dev/null || echo "")

    # Find "In Progress" status ID
    IN_PROGRESS_ID=$(echo "$STATUS_OPTIONS" | jq -r '.[] | select(.name == "In Progress") | .id' 2>/dev/null || echo "")
    CURRENT_SPRINT_ID=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name | contains("Current Sprint")) | .id' 2>/dev/null || echo "")

    if [ -n "$IN_PROGRESS_ID" ]; then
        # Update Status to "In Progress"
        gh api graphql -f query='
        mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "'$PROJECT_ID'"
            itemId: "'$ITEM_ID'"
            fieldId: "'$STATUS_FIELD'"
            value: { singleSelectOptionId: "'$IN_PROGRESS_ID'" }
          }) {
            projectV2Item { id }
          }
        }' >/dev/null 2>&1 && echo -e "${GREEN}✅ Status updated to 'In Progress'${NC}" || echo -e "${YELLOW}⚠️  Could not update status${NC}"
    fi

    if [ -n "$CURRENT_SPRINT_ID" ]; then
        # Update Sprint to "Current Sprint"
        gh api graphql -f query='
        mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "'$PROJECT_ID'"
            itemId: "'$ITEM_ID'"
            fieldId: "'$SPRINT_FIELD'"
            value: { singleSelectOptionId: "'$CURRENT_SPRINT_ID'" }
          }) {
            projectV2Item { id }
          }
        }' >/dev/null 2>&1 && echo -e "${GREEN}✅ Moved to Current Sprint${NC}" || echo -e "${YELLOW}⚠️  Could not update sprint${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Issue not found in project board${NC}"
fi

# Add a comment to the issue
echo -e "${BLUE}💬 Adding development started comment...${NC}"
COMMENT="🚀 **Development Started**

- **Branch**: \`$BRANCH_NAME\`
- **Developer**: @$CURRENT_USER
- **Started**: $(date '+%d/%m/%Y %H:%M:%S')

To check out this branch:
\`\`\`bash
git fetch origin
git checkout $BRANCH_NAME
\`\`\`

---
*This comment was automatically generated by the start-story script*"

gh issue comment $ISSUE_NUMBER --body "$COMMENT"
echo -e "${GREEN}✅ Comment added to issue${NC}"

# Create initial commit if this is a new story
if [ -n "$STORY_NUMBER" ] && [ ! -f ".story-$STORY_NUMBER" ]; then
    echo -e "${BLUE}📝 Creating story tracking file...${NC}"
    cat > .story-$STORY_NUMBER << EOF
# Story $STORY_NUMBER Development

Issue: #$ISSUE_NUMBER
Branch: $BRANCH_NAME
Started: $(date '+%d/%m/%Y %H:%M:%S')
Developer: $CURRENT_USER

## Story Details
$ISSUE_TITLE

## Development Log
- Development started: $(date '+%d/%m/%Y %H:%M:%S')
EOF

    git add .story-$STORY_NUMBER
    git commit -m "chore: start development on Story-$STORY_NUMBER

Issue: #$ISSUE_NUMBER
Branch: $BRANCH_NAME"
    echo -e "${GREEN}✅ Initial commit created${NC}"
fi

echo ""
echo "=============================================="
echo -e "${GREEN}🎉 Ready for Development!${NC}"
echo ""
echo "You are now on branch: $BRANCH_NAME"
echo "Issue #$ISSUE_NUMBER is assigned to you and marked as 'In Progress'"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "  1. Write tests first (TDD approach)"
echo "  2. Implement the feature"
echo "  3. Ensure test coverage meets BMAD requirements (80% backend, 70% frontend)"
echo "  4. Create PR with: gh pr create --title \"feat: Story-$STORY_NUMBER description\" --body \"Closes #$ISSUE_NUMBER\""
echo ""
echo -e "${YELLOW}💡 Tip: The PR will automatically update the project board when merged${NC}"