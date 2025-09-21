#!/bin/bash

# Populate BMAD field values for all issues
set -e

echo "🎯 Populating BMAD Field Values for All Issues"
echo "=============================================="

PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"

# Field IDs from the field list
BUSINESS_VALUE_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs58"
TECH_RISK_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs6A"
DOC_STATUS_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs54"
REVIEW_STATUS_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs6E"
SPRINT_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs6I"
TEST_COVERAGE_FIELD="PVTF_lAHOA_Xhjc4BDod6zg1fs50"
DEPENDENCIES_FIELD="PVTF_lAHOA_Xhjc4BDod6zg1fs6Q"

# Get field options for each single-select field
echo "📋 Fetching field options..."

# Get Business Value options
BV_OPTIONS=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      field(name: "Business Value") {
        ... on ProjectV2SingleSelectField {
          options { id, name }
        }
      }
    }
  }
}' --jq '.data.node.field.options')

BV_CRITICAL=$(echo "$BV_OPTIONS" | jq -r '.[] | select(.name | contains("Critical")) | .id')
BV_HIGH=$(echo "$BV_OPTIONS" | jq -r '.[] | select(.name | contains("High")) | .id')
BV_MEDIUM=$(echo "$BV_OPTIONS" | jq -r '.[] | select(.name | contains("Medium")) | .id')

# Get Technical Risk options
TR_OPTIONS=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      field(name: "Technical Risk") {
        ... on ProjectV2SingleSelectField {
          options { id, name }
        }
      }
    }
  }
}' --jq '.data.node.field.options')

TR_HIGH=$(echo "$TR_OPTIONS" | jq -r '.[] | select(.name | contains("High")) | .id')
TR_MEDIUM=$(echo "$TR_OPTIONS" | jq -r '.[] | select(.name | contains("Medium")) | .id')
TR_LOW=$(echo "$TR_OPTIONS" | jq -r '.[] | select(.name | contains("Low")) | .id')

# Get Documentation Status options
DOC_OPTIONS=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      field(name: "Documentation Status") {
        ... on ProjectV2SingleSelectField {
          options { id, name }
        }
      }
    }
  }
}' --jq '.data.node.field.options')

DOC_PENDING=$(echo "$DOC_OPTIONS" | jq -r '.[] | select(.name | contains("Pending")) | .id')

# Get Sprint options
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
}' --jq '.data.node.field.options')

SPRINT_BACKLOG=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name | contains("Backlog")) | .id')

echo "✅ Field options loaded"
echo ""

# Get all project items
echo "📊 Updating field values for all items..."
echo "----------------------------------------"

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

total_items=$(echo "$items" | jq -s 'length')
current_item=0

echo "$items" | while IFS= read -r item; do
    if [ -n "$item" ]; then
        item_id=$(echo "$item" | jq -r '.id')
        issue_number=$(echo "$item" | jq -r '.number')
        title=$(echo "$item" | jq -r '.title')

        ((current_item++))
        echo "[$current_item/$total_items] Issue #$issue_number"

        # Extract story number from title
        if echo "$title" | grep -q "Story-"; then
            story_num=$(echo "$title" | grep -oE 'Story-[0-9.]+' | sed 's/Story-//')

            # Determine values based on story number
            business_value=""
            tech_risk=""
            test_coverage=0
            dependencies=""

            # Business Value logic
            if [[ $story_num == 1.1* ]] || [[ $story_num == 1.2.1* ]] || [[ $story_num == 1.2.2* ]]; then
                business_value=$BV_CRITICAL
                echo "  → Business Value: 🔥 Critical"
            elif [[ $story_num == 1.* ]] || [[ $story_num == 2.* ]] || [[ $story_num == 3.* ]]; then
                business_value=$BV_HIGH
                echo "  → Business Value: ⭐ High"
            else
                business_value=$BV_MEDIUM
                echo "  → Business Value: 📈 Medium"
            fi

            # Technical Risk logic
            if [[ $story_num == 1.* ]]; then
                tech_risk=$TR_MEDIUM
                echo "  → Technical Risk: 🟡 Medium"
            else
                tech_risk=$TR_LOW
                echo "  → Technical Risk: 🟢 Low"
            fi

            # Set dependencies for specific stories
            if [[ $story_num == 1.2.3* ]]; then
                dependencies="Story-1.2.1, Story-1.2.2"
                echo "  → Dependencies: $dependencies"
            elif [[ $story_num == 2.* ]]; then
                dependencies="Story-1.3"
                echo "  → Dependencies: $dependencies"
            elif [[ $story_num == 3.* ]]; then
                dependencies="Story-2.1"
                echo "  → Dependencies: $dependencies"
            fi

            # Update Business Value
            if [ -n "$business_value" ]; then
                gh api graphql -f query='
                mutation {
                  updateProjectV2ItemFieldValue(input: {
                    projectId: "'$PROJECT_ID'"
                    itemId: "'$item_id'"
                    fieldId: "'$BUSINESS_VALUE_FIELD'"
                    value: { singleSelectOptionId: "'$business_value'" }
                  }) { projectV2Item { id } }
                }' >/dev/null 2>&1 || echo "    ⚠️  Failed: Business Value"
            fi

            # Update Technical Risk
            if [ -n "$tech_risk" ]; then
                gh api graphql -f query='
                mutation {
                  updateProjectV2ItemFieldValue(input: {
                    projectId: "'$PROJECT_ID'"
                    itemId: "'$item_id'"
                    fieldId: "'$TECH_RISK_FIELD'"
                    value: { singleSelectOptionId: "'$tech_risk'" }
                  }) { projectV2Item { id } }
                }' >/dev/null 2>&1 || echo "    ⚠️  Failed: Technical Risk"
            fi

            # Update Documentation Status
            gh api graphql -f query='
            mutation {
              updateProjectV2ItemFieldValue(input: {
                projectId: "'$PROJECT_ID'"
                itemId: "'$item_id'"
                fieldId: "'$DOC_STATUS_FIELD'"
                value: { singleSelectOptionId: "'$DOC_PENDING'" }
              }) { projectV2Item { id } }
            }' >/dev/null 2>&1 || echo "    ⚠️  Failed: Documentation Status"

            # Update Sprint to Backlog
            gh api graphql -f query='
            mutation {
              updateProjectV2ItemFieldValue(input: {
                projectId: "'$PROJECT_ID'"
                itemId: "'$item_id'"
                fieldId: "'$SPRINT_FIELD'"
                value: { singleSelectOptionId: "'$SPRINT_BACKLOG'" }
              }) { projectV2Item { id } }
            }' >/dev/null 2>&1 || echo "    ⚠️  Failed: Sprint"

            # Update Test Coverage (start at 0)
            gh api graphql -f query='
            mutation {
              updateProjectV2ItemFieldValue(input: {
                projectId: "'$PROJECT_ID'"
                itemId: "'$item_id'"
                fieldId: "'$TEST_COVERAGE_FIELD'"
                value: { number: '$test_coverage' }
              }) { projectV2Item { id } }
            }' >/dev/null 2>&1 || echo "    ⚠️  Failed: Test Coverage"

            # Update Dependencies if any
            if [ -n "$dependencies" ]; then
                gh api graphql -f query='
                mutation {
                  updateProjectV2ItemFieldValue(input: {
                    projectId: "'$PROJECT_ID'"
                    itemId: "'$item_id'"
                    fieldId: "'$DEPENDENCIES_FIELD'"
                    value: { text: "'$dependencies'" }
                  }) { projectV2Item { id } }
                }' >/dev/null 2>&1 || echo "    ⚠️  Failed: Dependencies"
            fi
        fi
    fi
done

echo ""
echo "=============================================="
echo "✅ BMAD field population complete!"
echo ""
echo "📊 Summary of Values Applied:"
echo "  • Business Value: Critical (foundation), High (core features), Medium (enhancements)"
echo "  • Technical Risk: Medium (Epic 1), Low (others)"
echo "  • Documentation Status: All set to Pending"
echo "  • Sprint: All set to Backlog"
echo "  • Test Coverage: All initialized to 0%"
echo "  • Dependencies: Set for dependent stories"
echo ""
echo "🔗 View your updated board: https://github.com/users/caioniehues/projects/2"