#!/bin/bash

# Comprehensive script to configure all project fields
set -e

echo "🎨 Configuring All GitHub Project Fields..."
echo "==========================================="

PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"

# Field IDs (from the field-list output)
STATUS_FIELD_ID="PVTSSF_lAHOA_Xhjc4BDod6zg1fnvA"
PRIORITY_FIELD_ID="PVTSSF_lAHOA_Xhjc4BDod6zg1fnxc"
SIZE_FIELD_ID="PVTSSF_lAHOA_Xhjc4BDod6zg1fnxg"

# Status option IDs
STATUS_BACKLOG="c60477e0"

# Get Priority options
echo "📋 Fetching Priority field options..."
priority_options=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      field(name: "Priority") {
        ... on ProjectV2SingleSelectField {
          options {
            id
            name
          }
        }
      }
    }
  }
}' --jq '.data.node.field.options')

# Extract Priority IDs
PRIORITY_HIGH=$(echo "$priority_options" | jq -r '.[] | select(.name == "🔴 High" or .name == "High" or .name == "P1") | .id' | head -1)
PRIORITY_MEDIUM=$(echo "$priority_options" | jq -r '.[] | select(.name == "🟡 Medium" or .name == "Medium" or .name == "P2") | .id' | head -1)
PRIORITY_LOW=$(echo "$priority_options" | jq -r '.[] | select(.name == "🟢 Low" or .name == "Low" or .name == "P3") | .id' | head -1)

# If priorities don't exist, create them
if [ -z "$PRIORITY_HIGH" ]; then
    echo "Creating Priority options..."
    # For now, we'll use existing options or skip
    echo "⚠️  Priority options need to be configured manually in the UI"
fi

# Get Size options
echo "📋 Fetching Size field options..."
size_options=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      field(name: "Size") {
        ... on ProjectV2SingleSelectField {
          options {
            id
            name
          }
        }
      }
    }
  }
}' --jq '.data.node.field.options')

# Extract Size IDs (Story Points)
SIZE_SMALL=$(echo "$size_options" | jq -r '.[] | select(.name == "🦐 S (3pts)" or .name == "S" or .name == "3") | .id' | head -1)
SIZE_MEDIUM=$(echo "$size_options" | jq -r '.[] | select(.name == "🐂 M (5pts)" or .name == "M" or .name == "5") | .id' | head -1)
SIZE_LARGE=$(echo "$size_options" | jq -r '.[] | select(.name == "🐋 L (8pts)" or .name == "L" or .name == "8") | .id' | head -1)

echo ""
echo "📊 Configuring fields for all items..."
echo "--------------------------------------"

# Get all project items
items=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue {
              number
              title
            }
          }
        }
      }
    }
  }
}' --jq '.data.node.items.nodes[] | select(.content.number != null) | {id: .id, number: .content.number, title: .content.title}')

echo "$items" | while IFS= read -r item; do
    if [ -n "$item" ]; then
        item_id=$(echo "$item" | jq -r '.id')
        issue_number=$(echo "$item" | jq -r '.number')
        title=$(echo "$item" | jq -r '.title')

        echo "📝 Configuring Issue #$issue_number"

        # Extract story number from title
        if echo "$title" | grep -q "Story-"; then
            story_num=$(echo "$title" | grep -oE 'Story-[0-9.]+' | sed 's/Story-//')

            # Determine priority based on epic
            priority_id=""
            if [[ $story_num == 1.* ]]; then
                priority_id=$PRIORITY_HIGH
                priority_name="High"
            elif [[ $story_num == 5.* ]]; then
                priority_id=$PRIORITY_LOW
                priority_name="Low"
            else
                priority_id=$PRIORITY_MEDIUM
                priority_name="Medium"
            fi

            # Determine size (story points)
            size_id=""
            if [[ $story_num == *.*.* ]]; then
                # Sub-story = 3 points
                size_id=$SIZE_SMALL
                size_name="S (3 pts)"
            else
                # Regular story = 5 points
                size_id=$SIZE_MEDIUM
                size_name="M (5 pts)"
            fi

            echo "  - Status: Backlog"
            echo "  - Priority: $priority_name"
            echo "  - Size: $size_name"

            # Update Status to Backlog
            gh api graphql -f query='
            mutation {
              updateProjectV2ItemFieldValue(
                input: {
                  projectId: "'$PROJECT_ID'"
                  itemId: "'$item_id'"
                  fieldId: "'$STATUS_FIELD_ID'"
                  value: {
                    singleSelectOptionId: "'$STATUS_BACKLOG'"
                  }
                }
              ) {
                projectV2Item { id }
              }
            }' >/dev/null 2>&1 || echo "    ⚠️  Failed to update Status"

            # Update Priority if we have the ID
            if [ -n "$priority_id" ]; then
                gh api graphql -f query='
                mutation {
                  updateProjectV2ItemFieldValue(
                    input: {
                      projectId: "'$PROJECT_ID'"
                      itemId: "'$item_id'"
                      fieldId: "'$PRIORITY_FIELD_ID'"
                      value: {
                        singleSelectOptionId: "'$priority_id'"
                      }
                    }
                  ) {
                    projectV2Item { id }
                  }
                }' >/dev/null 2>&1 || echo "    ⚠️  Failed to update Priority"
            fi

            # Update Size if we have the ID
            if [ -n "$size_id" ]; then
                gh api graphql -f query='
                mutation {
                  updateProjectV2ItemFieldValue(
                    input: {
                      projectId: "'$PROJECT_ID'"
                      itemId: "'$item_id'"
                      fieldId: "'$SIZE_FIELD_ID'"
                      value: {
                        singleSelectOptionId: "'$size_id'"
                      }
                    }
                  ) {
                    projectV2Item { id }
                  }
                }' >/dev/null 2>&1 || echo "    ⚠️  Failed to update Size"
            fi
        fi
    fi
done

echo ""
echo "==========================================="
echo "✅ All fields configured!"
echo ""
echo "📊 Summary:"
echo "  - All issues set to Backlog status"
echo "  - Priority: Epic 1 = High, Epic 2-4 = Medium, Epic 5 = Low"
echo "  - Story Points: Sub-stories = 3 pts, Regular stories = 5 pts"
echo ""
echo "🔗 View your project: https://github.com/users/caioniehues/projects/2"
echo ""
echo "📝 Next steps:"
echo "  1. Review the board layout"
echo "  2. Move stories to 'Sprint Ready' for your first sprint"
echo "  3. Begin with Story-1.1 (Backend Infrastructure)"