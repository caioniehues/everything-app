#!/bin/bash

# Script to configure GitHub Project fields for all issues
set -e

echo "🎨 Configuring GitHub Project Fields..."
echo "========================================"

PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"
EPIC_FIELD_ID="PVTSSF_lAHOA_Xhjc4BDod6zg1fn60"

# Epic option IDs from the API response
EPIC_1_ID="6b04c6a5"  # Epic 1: Authentication
EPIC_2_ID="0208b8b2"  # Epic 2: Accounts
EPIC_3_ID="5575a97c"  # Epic 3: Transactions
EPIC_4_ID="f5fcbd65"  # Epic 4: Budget
EPIC_5_ID="86f8cb2b"  # Epic 5: Dashboard

echo "📋 Getting project items..."

# Get all project items with their issue numbers
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

        # Extract story number from title
        if echo "$title" | grep -q "Story-"; then
            story_num=$(echo "$title" | grep -oE 'Story-[0-9.]+' | sed 's/Story-//')

            # Determine epic based on story number
            epic_option_id=""
            if [[ $story_num == 1.* ]]; then
                epic_option_id=$EPIC_1_ID
                epic_name="Epic 1: Authentication"
            elif [[ $story_num == 2.* ]]; then
                epic_option_id=$EPIC_2_ID
                epic_name="Epic 2: Accounts"
            elif [[ $story_num == 3.* ]]; then
                epic_option_id=$EPIC_3_ID
                epic_name="Epic 3: Transactions"
            elif [[ $story_num == 4.* ]]; then
                epic_option_id=$EPIC_4_ID
                epic_name="Epic 4: Budget"
            elif [[ $story_num == 5.* ]]; then
                epic_option_id=$EPIC_5_ID
                epic_name="Epic 5: Dashboard"
            fi

            if [ -n "$epic_option_id" ]; then
                echo "Setting issue #$issue_number (Story-$story_num) to $epic_name"

                # Update the Epic field
                gh api graphql -f query='
                mutation {
                  updateProjectV2ItemFieldValue(
                    input: {
                      projectId: "'$PROJECT_ID'"
                      itemId: "'$item_id'"
                      fieldId: "'$EPIC_FIELD_ID'"
                      value: {
                        singleSelectOptionId: "'$epic_option_id'"
                      }
                    }
                  ) {
                    projectV2Item {
                      id
                    }
                  }
                }' >/dev/null 2>&1 || echo "  ⚠️  Failed to update"
            fi
        fi
    fi
done

echo ""
echo "========================================"
echo "✅ Epic fields configured!"
echo ""
echo "🔗 View your project: https://github.com/users/caioniehues/projects/2"