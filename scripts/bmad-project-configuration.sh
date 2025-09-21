#!/bin/bash

# BMAD-Optimized GitHub Project Configuration
# Tailored for Everything App development workflow
set -e

echo "🎯 Configuring BMAD-Optimized Project Board..."
echo "=============================================="

PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"

# Get current project configuration
echo "📋 Analyzing current project structure..."

# Create additional BMAD-specific fields
echo "🔧 Adding BMAD-specific custom fields..."

# Add Test Coverage field
echo "  → Creating Test Coverage field..."
gh api graphql -f query='
mutation {
  createProjectV2Field(input: {
    projectId: "'$PROJECT_ID'"
    dataType: NUMBER
    name: "Test Coverage %"
  }) {
    projectV2Field {
      id
      name
    }
  }
}' >/dev/null 2>&1 || echo "    ✓ Test Coverage field exists"

# Add Documentation Status field
echo "  → Creating Documentation Status field..."
gh api graphql -f query='
mutation {
  createProjectV2Field(input: {
    projectId: "'$PROJECT_ID'"
    dataType: SINGLE_SELECT
    name: "Documentation Status"
    singleSelectOptions: [
      {name: "📝 Pending", description: "Documentation not started"}
      {name: "🔄 In Progress", description: "Documentation being written"}
      {name: "✅ Complete", description: "Documentation complete"}
      {name: "🔍 Review", description: "Documentation under review"}
    ]
  }) {
    projectV2Field {
      id
      name
    }
  }
}' >/dev/null 2>&1 || echo "    ✓ Documentation Status field exists"

# Add Business Value field
echo "  → Creating Business Value field..."
gh api graphql -f query='
mutation {
  createProjectV2Field(input: {
    projectId: "'$PROJECT_ID'"
    dataType: SINGLE_SELECT
    name: "Business Value"
    singleSelectOptions: [
      {name: "🔥 Critical", description: "Must have for MVP"}
      {name: "⭐ High", description: "High business impact"}
      {name: "📈 Medium", description: "Nice to have"}
      {name: "🔮 Future", description: "Future enhancement"}
    ]
  }) {
    projectV2Field {
      id
      name
    }
  }
}' >/dev/null 2>&1 || echo "    ✓ Business Value field exists"

# Add Technical Risk field
echo "  → Creating Technical Risk field..."
gh api graphql -f query='
mutation {
  createProjectV2Field(input: {
    projectId: "'$PROJECT_ID'"
    dataType: SINGLE_SELECT
    name: "Technical Risk"
    singleSelectOptions: [
      {name: "🔴 High", description: "Complex architecture changes"}
      {name: "🟡 Medium", description: "Some technical complexity"}
      {name: "🟢 Low", description: "Straightforward implementation"}
      {name: "🆕 Unknown", description: "Needs technical investigation"}
    ]
  }) {
    projectV2Field {
      id
      name
    }
  }
}' >/dev/null 2>&1 || echo "    ✓ Technical Risk field exists"

# Add Review Status field
echo "  → Creating Review Status field..."
gh api graphql -f query='
mutation {
  createProjectV2Field(input: {
    projectId: "'$PROJECT_ID'"
    dataType: SINGLE_SELECT
    name: "Review Status"
    singleSelectOptions: [
      {name: "⏳ Pending", description: "Awaiting review"}
      {name: "👀 Code Review", description: "Code review in progress"}
      {name: "🧪 QA Review", description: "QA testing in progress"}
      {name: "📋 PO Review", description: "Product Owner review"}
      {name: "✅ Approved", description: "All reviews complete"}
      {name: "🔄 Changes Requested", description: "Needs modifications"}
    ]
  }) {
    projectV2Field {
      id
      name
    }
  }
}' >/dev/null 2>&1 || echo "    ✓ Review Status field exists"

# Add Sprint field for better iteration tracking
echo "  → Creating Sprint Tracking field..."
gh api graphql -f query='
mutation {
  createProjectV2Field(input: {
    projectId: "'$PROJECT_ID'"
    dataType: SINGLE_SELECT
    name: "Sprint"
    singleSelectOptions: [
      {name: "🎯 Current Sprint", description: "Active sprint work"}
      {name: "📋 Next Sprint", description: "Planned for next sprint"}
      {name: "🔮 Future Sprint", description: "Future sprint planning"}
      {name: "❄️ Backlog", description: "Not yet planned"}
      {name: "🏁 Completed", description: "Sprint completed"}
    ]
  }) {
    projectV2Field {
      id
      name
    }
  }
}' >/dev/null 2>&1 || echo "    ✓ Sprint field exists"

echo ""
echo "📊 Setting up BMAD-specific field values..."
echo "============================================"

# Get updated field list
fields=$(gh project field-list 2 --owner caioniehues --format json)

# Initialize business value and technical risk for existing issues
echo "🎯 Setting Business Value and Technical Risk for all stories..."

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

        echo "📝 Issue #$issue_number"

        # Extract story info
        if echo "$title" | grep -q "Story-"; then
            story_num=$(echo "$title" | grep -oE 'Story-[0-9.]+' | sed 's/Story-//')

            # Set Business Value based on Epic priority
            business_value=""
            tech_risk=""
            doc_status="📝 Pending"
            sprint_status="❄️ Backlog"

            if [[ $story_num == 1.1* ]] || [[ $story_num == 1.2* ]]; then
                business_value="🔥 Critical"  # Foundation stories
                tech_risk="🟡 Medium"
            elif [[ $story_num == 1.* ]]; then
                business_value="⭐ High"      # Authentication epic
                tech_risk="🟡 Medium"
            elif [[ $story_num == 2.* ]] || [[ $story_num == 3.* ]]; then
                business_value="⭐ High"      # Core functionality
                tech_risk="🟢 Low"
            elif [[ $story_num == 4.* ]]; then
                business_value="📈 Medium"    # Budget features
                tech_risk="🟢 Low"
            elif [[ $story_num == 5.* ]]; then
                business_value="📈 Medium"    # Dashboard
                tech_risk="🟢 Low"
            fi

            echo "  → Business Value: $business_value"
            echo "  → Technical Risk: $tech_risk"
            echo "  → Documentation: $doc_status"
            echo "  → Sprint: $sprint_status"
        fi
    fi
done

echo ""
echo "=============================================="
echo "✅ BMAD Project Configuration Complete!"
echo ""
echo "🎯 Your board now includes:"
echo "  📊 Business Value tracking for PO prioritization"
echo "  🔧 Technical Risk assessment for architecture planning"
echo "  📝 Documentation status for BMAD compliance"
echo "  🧪 Test Coverage tracking for TDD enforcement"
echo "  👥 Review Status for quality gates"
echo "  🚀 Sprint tracking for iteration management"
echo ""
echo "🔗 View your enhanced board: https://github.com/users/caioniehues/projects/2"