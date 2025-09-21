#!/bin/bash

# Configure all BMAD field values for all project items
set -e

echo "🎯 Configuring BMAD Values for All 33 Issues"
echo "============================================="

PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"

# Field IDs
BUSINESS_VALUE_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs58"
TECH_RISK_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs6A"
DOC_STATUS_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs54"
SPRINT_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs6I"
TEST_COVERAGE_FIELD="PVTF_lAHOA_Xhjc4BDod6zg1fs50"
DEPENDENCIES_FIELD="PVTF_lAHOA_Xhjc4BDod6zg1fs6Q"
REVIEW_STATUS_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs6E"

# Get all option IDs
echo "📋 Loading field options..."

# Business Value options
BV_CRITICAL="941fbbf6"  # 🔥 Critical
BV_HIGH="b4e1d3fc"      # ⭐ High
BV_MEDIUM="78f77345"    # 📈 Medium
BV_FUTURE="d5c9bf45"    # 🔮 Future

# Technical Risk options (fetch dynamically)
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

TR_HIGH=$(echo "$TR_OPTIONS" | jq -r '.[] | select(.name | contains("High")) | .id' | head -1)
TR_MEDIUM=$(echo "$TR_OPTIONS" | jq -r '.[] | select(.name | contains("Medium")) | .id' | head -1)
TR_LOW=$(echo "$TR_OPTIONS" | jq -r '.[] | select(.name | contains("Low")) | .id' | head -1)

# Documentation Status options
DOC_PENDING=$(gh api graphql -f query='
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
}' --jq '.data.node.field.options[] | select(.name | contains("Pending")) | .id')

# Sprint options
SPRINT_BACKLOG=$(gh api graphql -f query='
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
}' --jq '.data.node.field.options[] | select(.name | contains("Backlog")) | .id')

# Review Status options
REVIEW_PENDING=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      field(name: "Review Status") {
        ... on ProjectV2SingleSelectField {
          options { id, name }
        }
      }
    }
  }
}' --jq '.data.node.field.options[] | select(.name | contains("Pending")) | .id')

echo "✅ Options loaded successfully"
echo ""

# Function to update a single field
update_field() {
    local item_id=$1
    local field_id=$2
    local field_type=$3
    local value=$4
    local field_name=$5

    if [ "$field_type" == "select" ]; then
        gh api graphql -f query='
        mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "'$PROJECT_ID'"
            itemId: "'$item_id'"
            fieldId: "'$field_id'"
            value: { singleSelectOptionId: "'$value'" }
          }) { projectV2Item { id } }
        }' >/dev/null 2>&1 && echo "    ✓ $field_name" || echo "    ⚠️ Failed: $field_name"
    elif [ "$field_type" == "number" ]; then
        gh api graphql -f query='
        mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "'$PROJECT_ID'"
            itemId: "'$item_id'"
            fieldId: "'$field_id'"
            value: { number: '$value' }
          }) { projectV2Item { id } }
        }' >/dev/null 2>&1 && echo "    ✓ $field_name" || echo "    ⚠️ Failed: $field_name"
    elif [ "$field_type" == "text" ]; then
        gh api graphql -f query='
        mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "'$PROJECT_ID'"
            itemId: "'$item_id'"
            fieldId: "'$field_id'"
            value: { text: "'$value'" }
          }) { projectV2Item { id } }
        }' >/dev/null 2>&1 && echo "    ✓ $field_name" || echo "    ⚠️ Failed: $field_name"
    fi
}

# Get all project items with their issue info
echo "📊 Configuring fields for all items..."
echo "--------------------------------------"

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
}' --jq '.data.node.items.nodes[] | select(.content.number != null)')

# Process each item
echo "$items" | jq -c '.' | while read -r item; do
    item_id=$(echo "$item" | jq -r '.id')
    issue_number=$(echo "$item" | jq -r '.content.number')
    title=$(echo "$item" | jq -r '.content.title')

    echo "📝 Issue #$issue_number"

    # Extract story number from title
    if echo "$title" | grep -q "Story-"; then
        story_num=$(echo "$title" | grep -oE 'Story-[0-9.]+' | sed 's/Story-//')

        # Determine Business Value
        business_value=""
        if [[ $story_num == 1.1* ]] || [[ $story_num == 1.2.1* ]] || [[ $story_num == 1.2.2* ]]; then
            business_value=$BV_CRITICAL
        elif [[ $story_num == 1.* ]] || [[ $story_num == 2.* ]] || [[ $story_num == 3.[1-3]* ]]; then
            business_value=$BV_HIGH
        elif [[ $story_num == 3.* ]] || [[ $story_num == 4.* ]]; then
            business_value=$BV_MEDIUM
        else
            business_value=$BV_MEDIUM
        fi

        # Determine Technical Risk
        tech_risk=""
        if [[ $story_num == 1.1* ]] || [[ $story_num == 1.2* ]] || [[ $story_num == 1.3* ]]; then
            tech_risk=$TR_MEDIUM
        else
            tech_risk=$TR_LOW
        fi

        # Determine Dependencies
        dependencies=""
        if [[ $story_num == 1.2.3* ]]; then
            dependencies="Story-1.2.1, Story-1.2.2"
        elif [[ $story_num == 1.2.4* ]]; then
            dependencies="Story-1.2.1, Story-1.2.2, Story-1.2.3"
        elif [[ $story_num == 1.2.5* ]]; then
            dependencies="Story-1.2.1, Story-1.2.2"
        elif [[ $story_num == 1.3* ]]; then
            dependencies="Story-1.1"
        elif [[ $story_num == 2.* ]]; then
            dependencies="Story-1.3"
        elif [[ $story_num == 3.* ]]; then
            dependencies="Story-2.1"
        elif [[ $story_num == 4.* ]]; then
            dependencies="Story-2.1, Story-3.1"
        elif [[ $story_num == 5.* ]]; then
            dependencies="Story-2.1, Story-3.1"
        fi

        # Update fields
        update_field "$item_id" "$BUSINESS_VALUE_FIELD" "select" "$business_value" "Business Value"
        update_field "$item_id" "$TECH_RISK_FIELD" "select" "$tech_risk" "Technical Risk"
        update_field "$item_id" "$DOC_STATUS_FIELD" "select" "$DOC_PENDING" "Documentation Status"
        update_field "$item_id" "$SPRINT_FIELD" "select" "$SPRINT_BACKLOG" "Sprint"
        update_field "$item_id" "$REVIEW_STATUS_FIELD" "select" "$REVIEW_PENDING" "Review Status"
        update_field "$item_id" "$TEST_COVERAGE_FIELD" "number" "0" "Test Coverage"

        if [ -n "$dependencies" ]; then
            update_field "$item_id" "$DEPENDENCIES_FIELD" "text" "$dependencies" "Dependencies"
        fi
    fi
done

echo ""
echo "============================================="
echo "✅ BMAD configuration complete!"
echo ""
echo "📊 Applied Configuration:"
echo "  • Business Value: Critical (foundation), High (core), Medium (features)"
echo "  • Technical Risk: Medium (Epic 1), Low (others)"
echo "  • Documentation: All Pending"
echo "  • Sprint: All in Backlog"
echo "  • Review Status: All Pending"
echo "  • Test Coverage: All at 0%"
echo "  • Dependencies: Set based on story relationships"
echo ""
echo "🎯 Your board is now ready for BMAD workflow!"
echo "🔗 View at: https://github.com/users/caioniehues/projects/2"