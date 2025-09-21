#!/bin/bash

# Streamlined script to set BMAD field values
set -e

echo "🎯 Setting BMAD Field Values for All Issues"
echo "==========================================="

PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"

# Field IDs
BUSINESS_VALUE_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs58"
TECH_RISK_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs6A"
DOC_STATUS_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs54"
SPRINT_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fs6I"
TEST_COVERAGE_FIELD="PVTF_lAHOA_Xhjc4BDod6zg1fs50"

# Option IDs (from the API response)
BV_CRITICAL="941fbbf6"  # 🔥 Critical
BV_HIGH="b4e1d3fc"      # ⭐ High
BV_MEDIUM="78f77345"    # 📈 Medium

# Set a test value for issue #3 first
echo "🧪 Testing with Issue #3..."

# Get item ID for issue #3
ITEM_ID=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue {
              number
            }
          }
        }
      }
    }
  }
}' --jq '.data.node.items.nodes[] | select(.content.number == 3) | .id')

echo "Item ID for Issue #3: $ITEM_ID"

# Set Business Value to Critical for issue #3
echo "Setting Business Value to Critical..."
gh api graphql -f query='
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "'$PROJECT_ID'"
    itemId: "'$ITEM_ID'"
    fieldId: "'$BUSINESS_VALUE_FIELD'"
    value: { singleSelectOptionId: "'$BV_CRITICAL'" }
  }) {
    projectV2Item { id }
  }
}' && echo "✅ Success: Business Value set to Critical for Issue #3" || echo "❌ Failed to set Business Value"

# Set Test Coverage to 0 for issue #3
echo "Setting Test Coverage to 0%..."
gh api graphql -f query='
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "'$PROJECT_ID'"
    itemId: "'$ITEM_ID'"
    fieldId: "'$TEST_COVERAGE_FIELD'"
    value: { number: 0 }
  }) {
    projectV2Item { id }
  }
}' && echo "✅ Success: Test Coverage set to 0%" || echo "❌ Failed to set Test Coverage"

echo ""
echo "==========================================="
echo "✅ Test complete!"
echo ""
echo "If successful, run the full population script:"
echo "  ./scripts/populate-all-bmad-values.sh"
echo ""
echo "🔗 Check Issue #3: https://github.com/caioniehues/everything-app/issues/3"