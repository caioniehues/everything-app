#!/bin/bash

# Script to create GitHub issues from story markdown files
# Usage: ./scripts/create-github-issues.sh [--project PROJECT_NUMBER]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="caioniehues"
REPO_NAME="everything-app"
PROJECT_NUMBER=${1:-1}  # Get first parameter, default to project 1
if [[ "$1" == "--project" ]]; then
    PROJECT_NUMBER=${2:-1}
fi
DRY_RUN=${DRY_RUN:-false}

echo -e "${BLUE}🚀 GitHub Issues Creator for Everything App${NC}"
echo "================================================"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Error: Not authenticated with GitHub${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Function to extract story metadata
extract_metadata() {
    local file=$1
    local story_id=$(basename "$file" .md | sed 's/story-//')

    # Extract first heading as title
    local title=$(grep "^# " "$file" | head -1 | sed 's/^# //')

    # Extract epic from content
    local epic=""
    if [[ $story_id == 1.* ]]; then
        epic="Epic-1-Authentication"
    elif [[ $story_id == 2.* ]]; then
        epic="Epic-2-Accounts"
    elif [[ $story_id == 3.* ]]; then
        epic="Epic-3-Transactions"
    elif [[ $story_id == 4.* ]]; then
        epic="Epic-4-Budgets"
    elif [[ $story_id == 5.* ]]; then
        epic="Epic-5-Dashboard"
    fi

    # Estimate story points (simplified)
    local points=5
    if [[ $story_id == *.*.* ]]; then
        points=3  # Sub-stories are smaller
    fi

    echo "$story_id|$title|$epic|$points"
}

# Function to create issue body with metadata
create_issue_body() {
    local file=$1
    local story_id=$2
    local epic=$3
    local points=$4

    cat << EOF
## 📋 Story Information

**Story ID**: Story-$story_id
**Epic**: $epic
**Story Points**: $points
**Status**: Backlog

---

$(cat "$file")

---

## 🔗 Related Links

- [Story Documentation](/docs/stories/$(basename "$file"))
- [Epic Documentation](/docs/stories/epic-story-summary.md)
- [Project Wiki](https://github.com/$REPO_OWNER/$REPO_NAME/wiki)

## ✅ Definition of Done

- [ ] All acceptance criteria met
- [ ] Unit tests written and passing
- [ ] Integration tests completed
- [ ] Code review approved
- [ ] Documentation updated
- [ ] Test coverage meets requirements (Backend: 80%, Frontend: 70%)
EOF
}

# Function to create a single issue
create_issue() {
    local file=$1
    local metadata=$(extract_metadata "$file")

    IFS='|' read -r story_id title epic points <<< "$metadata"

    echo -e "${YELLOW}📝 Creating issue for Story-$story_id: $title${NC}"

    # Create issue body
    local body=$(create_issue_body "$file" "$story_id" "$epic" "$points")

    # Determine labels based on epic and type
    local labels="story,$epic"
    if [[ $story_id == *.*.* ]]; then
        labels="$labels,sub-story"
    fi

    # Priority based on story number
    local priority="medium"
    if [[ $story_id == 1.* ]]; then
        priority="high"
    elif [[ $story_id == 5.* ]]; then
        priority="low"
    fi
    labels="$labels,priority/$priority"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}[DRY RUN] Would create issue:${NC}"
        echo "  Title: Story-$story_id: $title"
        echo "  Labels: $labels"
        echo "  Epic: $epic"
        echo "  Points: $points"
        return 0
    else
        # Create the issue (without labels for now as they don't exist)
        issue_url=$(gh issue create \
            --repo "$REPO_OWNER/$REPO_NAME" \
            --title "Story-$story_id: $title" \
            --body "$body" 2>&1)

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Issue created: $issue_url${NC}"

            # Add to project if specified
            if [ -n "$PROJECT_NUMBER" ]; then
                gh project item-add "$PROJECT_NUMBER" --owner "$REPO_OWNER" --url "$issue_url" 2>/dev/null || true
            fi
            return 0
        else
            echo -e "${RED}❌ Failed to create issue for Story-$story_id${NC}"
            return 1
        fi
    fi
}

# Function to check if issue already exists
issue_exists() {
    local story_id=$1
    local result=$(gh issue list --repo "$REPO_OWNER/$REPO_NAME" --search "Story-$story_id in:title" --json number -q '.[0].number' 2>/dev/null)
    if [ -n "$result" ]; then
        return 0  # Issue exists
    else
        return 1  # Issue does not exist
    fi
}

# Main execution
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo "Project: #$PROJECT_NUMBER"
echo ""

# Count total stories
total_stories=$(find docs/stories -name "story-*.md" | wc -l)
echo -e "${BLUE}Found $total_stories story files${NC}"
echo ""

# Ask for confirmation
if [ "$DRY_RUN" != true ]; then
    read -p "Do you want to create issues for all stories? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    echo ""
fi

# Process each story file
created=0
skipped=0
failed=0

for story_file in docs/stories/story-*.md; do
    if [ -f "$story_file" ]; then
        story_id=$(basename "$story_file" .md | sed 's/story-//')

        # Check if issue already exists
        if issue_exists "$story_id"; then
            echo -e "${YELLOW}⏩ Skipping Story-$story_id (issue already exists)${NC}"
            ((skipped++))
            continue
        fi

        # Create the issue
        create_issue "$story_file"
        if [ $? -eq 0 ]; then
            ((created++))
        else
            ((failed++))
        fi

        # Rate limiting protection
        if [ "$DRY_RUN" != true ]; then
            sleep 1
        fi
    fi
done

# Summary
echo "================================================"
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "  ${GREEN}Created: $created${NC}"
echo -e "  ${YELLOW}Skipped: $skipped${NC}"
echo -e "  ${RED}Failed: $failed${NC}"
echo ""

# Create project board if needed
if [ "$created" -gt 0 ] && [ "$DRY_RUN" != true ]; then
    echo -e "${BLUE}📋 Setting up Project Board...${NC}"

    # Create sprint milestones
    echo "Creating milestones..."
    for i in {1..5}; do
        gh api repos/$REPO_OWNER/$REPO_NAME/milestones \
            --method POST \
            -f title="Sprint $i" \
            -f description="Sprint $i objectives" \
            -f due_on="$(date -d "+$((i*2)) weeks" -Iseconds)" 2>/dev/null || true
    done

    echo -e "${GREEN}✅ Project setup complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Visit: https://github.com/$REPO_OWNER/$REPO_NAME/projects"
    echo "2. Create a new project using 'Team planning' template"
    echo "3. Add custom fields as per documentation"
    echo "4. Configure automation rules"
    echo "5. Start your first sprint planning!"
fi

echo ""
echo -e "${GREEN}✨ Done!${NC}"