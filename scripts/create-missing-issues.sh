#!/bin/bash

# Script to create missing GitHub issues
set -e

echo "🔍 Finding and creating missing story issues..."
echo "=============================================="

# Get list of already created stories
echo "Fetching existing issues..."
created_stories=$(gh issue list --repo caioniehues/everything-app --limit 100 --json title | jq -r '.[].title' | grep -oE 'Story-[0-9.]+' | sort -u)

echo "Already created:"
echo "$created_stories"
echo ""

CREATED=0
SKIPPED=0

# Check each story file
for story_file in docs/stories/story-*.md; do
    if [ -f "$story_file" ]; then
        story_id=$(basename "$story_file" .md | sed 's/story-//')
        story_id_formatted="Story-$story_id"
        title=$(grep "^# " "$story_file" | head -1 | sed 's/^# //')

        # Check if this story ID exists
        if echo "$created_stories" | grep -q "^$story_id_formatted$"; then
            echo "✓ $story_id_formatted already exists"
            ((SKIPPED++))
        else
            echo "📝 Creating $story_id_formatted: $title"

            issue_url=$(gh issue create \
                --repo caioniehues/everything-app \
                --title "$story_id_formatted: $title" \
                --body "$(cat "$story_file")" 2>&1)

            if [ $? -eq 0 ]; then
                echo "  ✅ Created: $issue_url"
                ((CREATED++))
            else
                echo "  ❌ Failed to create"
            fi

            sleep 0.5
        fi
    fi
done

echo ""
echo "=============================================="
echo "📊 Summary:"
echo "  ✅ Created: $CREATED new issues"
echo "  ⏩ Skipped: $SKIPPED existing issues"
echo ""
echo "Total issues now: $(gh issue list --repo caioniehues/everything-app --limit 100 --json number | jq '. | length')"