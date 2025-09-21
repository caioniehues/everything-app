#!/bin/bash

# Script to automatically populate missing GitHub Project fields for all issues
# This analyzes each issue and sets appropriate values based on story patterns

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🎯 Everything App - Automatic Issue Field Population${NC}"
echo "======================================================="

# Configuration
REPO_OWNER="caioniehues"
REPO_NAME="everything-app"
PROJECT_NUMBER=2
PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"

# Field IDs (actual IDs from project)
STATUS_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fnvA"       # Status
EPIC_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fn60"        # Epic
STORY_POINTS_FIELD="PVTF_lAHOA_Xhjc4BDod6zg1fn_Y"  # Story Points
PRIORITY_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fnxc"    # Priority
SIZE_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fnxg"        # Size (will use for Business Value)
ESTIMATE_FIELD="PVTF_lAHOA_Xhjc4BDod6zg1fnxk"      # Estimate (will use for Tech Risk percentage)

# Fields that need to be created or mapped differently
BUSINESS_VALUE_FIELD="$SIZE_FIELD"  # Using Size field as Business Value proxy
TECH_RISK_FIELD="$SIZE_FIELD"       # Also using Size field for risk assessment
SPRINT_FIELD=""                      # Need to create or identify
TEST_COVERAGE_FIELD=""               # Need to create or identify
DEPENDENCIES_FIELD=""                # Need to create or identify
DOC_STATUS_FIELD=""                  # Need to create or identify

# Statistics
TOTAL_UPDATES=0
FAILED_UPDATES=0

echo -e "${CYAN}📋 Fetching field options...${NC}"

# Function to get field options
get_field_options() {
    local field_name=$1
    gh api graphql -f query='
    {
      node(id: "'$PROJECT_ID'") {
        ... on ProjectV2 {
          field(name: "'$field_name'") {
            ... on ProjectV2SingleSelectField {
              options { id, name }
            }
          }
        }
      }
    }' --jq '.data.node.field.options'
}

# Get all field options
EPIC_OPTIONS=$(get_field_options "Epic" 2>/dev/null || echo "[]")
PRIORITY_OPTIONS=$(get_field_options "Priority" 2>/dev/null || echo "[]")
BV_OPTIONS=$(get_field_options "Business Value" 2>/dev/null || echo "[]")
TR_OPTIONS=$(get_field_options "Technical Risk" 2>/dev/null || echo "[]")
SPRINT_OPTIONS=$(get_field_options "Sprint" 2>/dev/null || echo "[]")
DOC_OPTIONS=$(get_field_options "Documentation Status" 2>/dev/null || echo "[]")

echo -e "${GREEN}✅ Field options loaded${NC}\n"

# Function to determine Epic based on story number
get_epic_for_story() {
    local story_num=$1
    if [[ $story_num == 1.* ]]; then
        echo "Epic 1: Foundation & Authentication"
    elif [[ $story_num == 2.* ]]; then
        echo "Epic 2: Account Management"
    elif [[ $story_num == 3.* ]]; then
        echo "Epic 3: Transaction Management"
    elif [[ $story_num == 4.* ]]; then
        echo "Epic 4: Budget & Goals"
    elif [[ $story_num == 5.* ]]; then
        echo "Epic 5: Dashboard & Analytics"
    elif [[ $story_num == 6.* ]]; then
        echo "Epic 6: Data Management"
    else
        echo ""
    fi
}

# Function to determine Story Points based on story number
get_story_points() {
    local story_num=$1
    local title=$2

    # Infrastructure and setup stories
    if [[ $story_num == 1.1* ]] || [[ $story_num == 1.2.1* ]]; then
        echo 8
    # Authentication and security stories
    elif [[ $story_num == 1.3* ]]; then
        echo 5
    # Core feature stories
    elif [[ $story_num == 2.* ]] || [[ $story_num == 3.1* ]] || [[ $story_num == 3.2* ]]; then
        echo 5
    # UI stories
    elif [[ $story_num == *.3* ]] || [[ $story_num == *.4* ]]; then
        echo 3
    # Dashboard and complex features
    elif [[ $story_num == 5.* ]]; then
        echo 8
    # Default for standard stories
    else
        echo 3
    fi
}

# Function to determine Priority
get_priority() {
    local story_num=$1

    # Critical: Foundation stories
    if [[ $story_num == 1.1* ]] || [[ $story_num == 1.2.1* ]] || [[ $story_num == 1.2.2* ]]; then
        echo "🔴 Critical"
    # High: Authentication and core features
    elif [[ $story_num == 1.* ]] || [[ $story_num == 2.1* ]] || [[ $story_num == 3.1* ]]; then
        echo "🟠 High"
    # Medium: Most features
    elif [[ $story_num == 2.* ]] || [[ $story_num == 3.* ]]; then
        echo "🟡 Medium"
    # Low: Enhancements
    else
        echo "🟢 Low"
    fi
}

# Function to determine Business Value
get_business_value() {
    local story_num=$1

    if [[ $story_num == 1.1* ]] || [[ $story_num == 1.2.1* ]] || [[ $story_num == 1.2.2* ]]; then
        echo "🔥 Critical"
    elif [[ $story_num == 1.* ]] || [[ $story_num == 2.* ]] || [[ $story_num == 3.* ]]; then
        echo "⭐ High"
    else
        echo "📈 Medium"
    fi
}

# Function to determine Technical Risk
get_tech_risk() {
    local story_num=$1

    # High risk: Authentication, security, infrastructure
    if [[ $story_num == 1.3* ]] || [[ $story_num == 1.1* ]]; then
        echo "🔴 High"
    # Medium risk: Core features with integrations
    elif [[ $story_num == 1.* ]] || [[ $story_num == 3.4* ]] || [[ $story_num == 5.* ]]; then
        echo "🟡 Medium"
    # Low risk: UI and simple features
    else
        echo "🟢 Low"
    fi
}

# Function to determine Dependencies
get_dependencies() {
    local story_num=$1

    case $story_num in
        1.2.2*) echo "Story-1.2.1" ;;
        1.2.3*) echo "Story-1.2.1, Story-1.2.2" ;;
        1.2.4*) echo "Story-1.2.1, Story-1.2.2" ;;
        1.2.5*) echo "Story-1.2.1, Story-1.2.2" ;;
        1.3.*) echo "Story-1.1" ;;
        2.*) echo "Story-1.3" ;;
        3.*) echo "Story-2.1" ;;
        4.*) echo "Story-3.1" ;;
        5.*) echo "Story-3.1, Story-4.1" ;;
        *) echo "" ;;
    esac
}

# Function to update a field
update_field() {
    local item_id=$1
    local field_id=$2
    local field_type=$3
    local value=$4
    local field_name=$5

    if [ -z "$value" ]; then
        return 0
    fi

    local mutation_value=""
    case $field_type in
        "select")
            mutation_value="{ singleSelectOptionId: \"$value\" }"
            ;;
        "number")
            mutation_value="{ number: $value }"
            ;;
        "text")
            mutation_value="{ text: \"$value\" }"
            ;;
    esac

    gh api graphql -f query='
    mutation {
      updateProjectV2ItemFieldValue(input: {
        projectId: "'$PROJECT_ID'"
        itemId: "'$item_id'"
        fieldId: "'$field_id'"
        value: '$mutation_value'
      }) {
        projectV2Item { id }
      }
    }' >/dev/null 2>&1 && {
        echo -e "    ${GREEN}✓${NC} $field_name set to: $value"
        ((TOTAL_UPDATES++))
        return 0
    } || {
        echo -e "    ${RED}✗${NC} Failed to set $field_name"
        ((FAILED_UPDATES++))
        return 1
    }
}

# Main processing
echo -e "${CYAN}📊 Processing all issues...${NC}"
echo "----------------------------------------"

# Get all open issues
ISSUES=$(gh issue list --repo $REPO_OWNER/$REPO_NAME --state open --limit 100 --json number,title)

# Get all project items
ITEMS=$(gh api graphql -f query='
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
          fieldValues(first: 20) {
            nodes {
              ... on ProjectV2ItemFieldTextValue {
                field {
                  ... on ProjectV2Field {
                    name
                  }
                }
                text
              }
              ... on ProjectV2ItemFieldNumberValue {
                field {
                  ... on ProjectV2Field {
                    name
                  }
                }
                number
              }
              ... on ProjectV2ItemFieldSingleSelectValue {
                field {
                  ... on ProjectV2SingleSelectField {
                    name
                  }
                }
                name
              }
            }
          }
        }
      }
    }
  }
}' --jq '.data.node.items.nodes')

# Process each issue
echo "$ITEMS" | jq -c '.[] | select(.content.number != null)' | while read -r item; do
    item_id=$(echo "$item" | jq -r '.id')
    issue_number=$(echo "$item" | jq -r '.content.number')
    title=$(echo "$item" | jq -r '.content.title')

    # Extract story number from title
    story_num=""
    if echo "$title" | grep -q "Story"; then
        story_num=$(echo "$title" | grep -oE 'Story[- ]([0-9]+\.[0-9]+(\.[0-9]+)?)' | sed 's/Story[- ]//')
    fi

    if [ -z "$story_num" ]; then
        echo -e "${YELLOW}⚠ Issue #$issue_number: Not a story issue, skipping${NC}"
        continue
    fi

    echo -e "${BLUE}📌 Issue #$issue_number: Story-$story_num${NC}"

    # Get current field values
    current_fields=$(echo "$item" | jq -r '.fieldValues.nodes[] | .field.name + "=" + (.text // .name // (.number | tostring) // "null")')

    # Determine values for each field
    epic_value=$(get_epic_for_story "$story_num")
    story_points=$(get_story_points "$story_num" "$title")
    priority=$(get_priority "$story_num")
    business_value=$(get_business_value "$story_num")
    tech_risk=$(get_tech_risk "$story_num")
    dependencies=$(get_dependencies "$story_num")

    # Check and update Epic
    if ! echo "$current_fields" | grep -q "^Epic="; then
        if [ -n "$epic_value" ]; then
            epic_id=$(echo "$EPIC_OPTIONS" | jq -r '.[] | select(.name == "'"$epic_value"'") | .id' | head -1)
            if [ -n "$epic_id" ]; then
                update_field "$item_id" "$EPIC_FIELD" "select" "$epic_id" "Epic"
            fi
        fi
    fi

    # Check and update Story Points
    if ! echo "$current_fields" | grep -q "^Story Points="; then
        update_field "$item_id" "$STORY_POINTS_FIELD" "number" "$story_points" "Story Points"
    fi

    # Check and update Priority
    if ! echo "$current_fields" | grep -q "^Priority="; then
        priority_id=$(echo "$PRIORITY_OPTIONS" | jq -r '.[] | select(.name == "'"$priority"'") | .id' | head -1)
        if [ -n "$priority_id" ]; then
            update_field "$item_id" "$PRIORITY_FIELD" "select" "$priority_id" "Priority"
        fi
    fi

    # Check and update Business Value
    if ! echo "$current_fields" | grep -q "^Business Value="; then
        bv_id=$(echo "$BV_OPTIONS" | jq -r '.[] | select(.name == "'"$business_value"'") | .id' | head -1)
        if [ -n "$bv_id" ]; then
            update_field "$item_id" "$BUSINESS_VALUE_FIELD" "select" "$bv_id" "Business Value"
        fi
    fi

    # Check and update Technical Risk
    if ! echo "$current_fields" | grep -q "^Technical Risk="; then
        tr_id=$(echo "$TR_OPTIONS" | jq -r '.[] | select(.name == "'"$tech_risk"'") | .id' | head -1)
        if [ -n "$tr_id" ]; then
            update_field "$item_id" "$TECH_RISK_FIELD" "select" "$tr_id" "Technical Risk"
        fi
    fi

    # Check and update Sprint (default to Backlog)
    if ! echo "$current_fields" | grep -q "^Sprint="; then
        backlog_id=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name | contains("Backlog")) | .id' | head -1)
        if [ -n "$backlog_id" ]; then
            update_field "$item_id" "$SPRINT_FIELD" "select" "$backlog_id" "Sprint"
        fi
    fi

    # Check and update Documentation Status (default to Pending)
    if ! echo "$current_fields" | grep -q "^Documentation Status="; then
        pending_id=$(echo "$DOC_OPTIONS" | jq -r '.[] | select(.name | contains("Pending")) | .id' | head -1)
        if [ -n "$pending_id" ]; then
            update_field "$item_id" "$DOC_STATUS_FIELD" "select" "$pending_id" "Documentation Status"
        fi
    fi

    # Check and update Test Coverage (initialize to 0)
    if ! echo "$current_fields" | grep -q "^Test Coverage="; then
        update_field "$item_id" "$TEST_COVERAGE_FIELD" "number" "0" "Test Coverage %"
    fi

    # Check and update Dependencies
    if ! echo "$current_fields" | grep -q "^Dependencies=" && [ -n "$dependencies" ]; then
        update_field "$item_id" "$DEPENDENCIES_FIELD" "text" "$dependencies" "Dependencies"
    fi

    echo ""
done

echo "======================================================="
echo -e "${GREEN}✅ Field Population Complete!${NC}"
echo ""
echo -e "${CYAN}📊 Summary:${NC}"
echo -e "  • Total updates applied: ${GREEN}$TOTAL_UPDATES${NC}"
echo -e "  • Failed updates: ${RED}$FAILED_UPDATES${NC}"
echo ""
echo -e "${BLUE}📋 Field Assignment Logic:${NC}"
echo "  • Epic: Based on story number prefix"
echo "  • Story Points: 8 (infrastructure), 5 (core), 3 (UI)"
echo "  • Priority: Critical (foundation), High (auth), Medium (features), Low (enhancements)"
echo "  • Business Value: Critical (foundation), High (core), Medium (enhancements)"
echo "  • Technical Risk: High (auth/security), Medium (integrations), Low (UI)"
echo "  • Sprint: All set to Backlog (ready for planning)"
echo "  • Documentation: All set to Pending"
echo "  • Test Coverage: Initialized to 0%"
echo "  • Dependencies: Mapped based on story relationships"
echo ""
echo -e "${GREEN}🔗 View your updated board:${NC} https://github.com/users/$REPO_OWNER/projects/$PROJECT_NUMBER"