#!/bin/bash

# Simple batch issue creator for Everything App
set -e

echo "📋 Creating GitHub issues for Everything App stories..."
echo "================================================"

CREATED=0
FAILED=0

# Process each story file
for story_file in docs/stories/story-*.md; do
    if [ -f "$story_file" ]; then
        # Extract story ID and title
        story_id=$(basename "$story_file" .md | sed 's/story-//')
        title=$(grep "^# " "$story_file" | head -1 | sed 's/^# //')

        # Check if already exists (exact match in title)
        existing=$(gh issue list --repo caioniehues/everything-app --search "\"Story-$story_id:\" in:title" --json number -q '.[0].number' 2>/dev/null || echo "")

        if [ -n "$existing" ]; then
            echo "⏩ Skipping Story-$story_id (already exists as #$existing)"
            continue
        fi

        echo "📝 Creating Story-$story_id: $title"

        # Create the issue
        issue_url=$(gh issue create \
            --repo caioniehues/everything-app \
            --title "Story-$story_id: $title" \
            --body "$(cat "$story_file")" 2>&1)

        if [ $? -eq 0 ]; then
            echo "✅ Created: $issue_url"

            # Add to project board #2
            gh project item-add 2 --owner caioniehues --url "$issue_url" 2>/dev/null || echo "  ⚠️  Could not add to project (manually add later)"

            ((CREATED++))
        else
            echo "❌ Failed to create Story-$story_id"
            ((FAILED++))
        fi

        # Small delay to avoid rate limiting
        sleep 0.5
    fi
done

echo ""
echo "================================================"
echo "📊 Summary:"
echo "  ✅ Created: $CREATED issues"
echo "  ❌ Failed: $FAILED issues"
echo ""
echo "Visit your project board: https://github.com/users/caioniehues/projects/2"