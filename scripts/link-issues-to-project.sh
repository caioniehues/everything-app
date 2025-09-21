#!/bin/bash

# Script to link all issues to GitHub Project Board #2
set -e

echo "🔗 Linking issues to Project Board #2..."
echo "========================================"

PROJECT_NUMBER=2
OWNER="caioniehues"
REPO="everything-app"
LINKED=0
FAILED=0

# Get all issue URLs
echo "📋 Fetching all issues..."
issue_urls=$(gh issue list --repo "$OWNER/$REPO" --limit 100 --json url -q '.[].url')

total_issues=$(echo "$issue_urls" | wc -l)
echo "Found $total_issues issues to link"
echo ""

# Add each issue to the project
for url in $issue_urls; do
    issue_number=$(echo "$url" | grep -oE '[0-9]+$')
    echo -n "Linking issue #$issue_number... "

    if gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$url" 2>/dev/null; then
        echo "✅"
        ((LINKED++))
    else
        echo "❌ (may already be linked)"
        ((FAILED++))
    fi
done

echo ""
echo "========================================"
echo "📊 Summary:"
echo "  ✅ Successfully linked: $LINKED issues"
echo "  ⚠️  Already linked or failed: $FAILED issues"
echo ""
echo "🎯 Next Steps:"
echo "1. Visit: https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
echo "2. Configure custom fields (Epic, Story Points, Sprint)"
echo "3. Set up automation rules"
echo "4. Create your first sprint!"