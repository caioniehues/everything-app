#!/bin/bash

# Script to analyze which GitHub Project fields are missing for each issue
# Shows a comprehensive report before running populate-issue-fields.sh

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}📊 GitHub Project Field Analysis Report${NC}"
echo "======================================================="

# Configuration
PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"
PROJECT_NUMBER=2

echo -e "${CYAN}🔍 Analyzing all issue fields...${NC}\n"

# Get all project items with their field values
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
              state
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

# Define expected fields
EXPECTED_FIELDS=(
    "Epic"
    "Story Points"
    "Priority"
    "Business Value"
    "Technical Risk"
    "Sprint"
    "Documentation Status"
    "Test Coverage"
    "Dependencies"
)

# Statistics
TOTAL_ISSUES=0
ISSUES_WITH_ALL_FIELDS=0
ISSUES_MISSING_FIELDS=0

echo -e "${MAGENTA}📋 Issue-by-Issue Analysis:${NC}"
echo "----------------------------------------"

# Process each issue
echo "$ITEMS" | jq -c '.[] | select(.content.number != null and .content.state == "OPEN")' | while read -r item; do
    issue_number=$(echo "$item" | jq -r '.content.number')
    title=$(echo "$item" | jq -r '.content.title')

    # Extract story number from title
    story_num=""
    if echo "$title" | grep -q "Story"; then
        story_num=$(echo "$title" | grep -oE 'Story[- ]([0-9]+\.[0-9]+(\.[0-9]+)?)' | sed 's/Story[- ]//')
    fi

    if [ -z "$story_num" ]; then
        continue  # Skip non-story issues
    fi

    ((TOTAL_ISSUES++))

    # Get current field values
    current_fields=$(echo "$item" | jq -r '.fieldValues.nodes[] | .field.name')

    # Check which fields are missing
    missing_fields=()
    for field in "${EXPECTED_FIELDS[@]}"; do
        if ! echo "$current_fields" | grep -q "^$field$"; then
            missing_fields+=("$field")
        fi
    done

    if [ ${#missing_fields[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ Issue #$issue_number${NC}: Story-$story_num - All fields populated"
        ((ISSUES_WITH_ALL_FIELDS++))
    else
        echo -e "${YELLOW}⚠️  Issue #$issue_number${NC}: Story-$story_num"
        echo -e "    Missing fields: ${RED}${missing_fields[*]}${NC}"
        ((ISSUES_MISSING_FIELDS++))
    fi
done

# Get summary statistics using Python for more complex analysis
python3 << 'EOF'
import json
import sys
import os

# Read the items data
items_json = os.popen(f'''gh api graphql -f query='
{{
  node(id: "{os.environ.get("PROJECT_ID", "PVT_kwHOA_Xhjc4BDod6")}") {{
    ... on ProjectV2 {{
      items(first: 100) {{
        nodes {{
          content {{
            ... on Issue {{
              number
              title
              state
            }}
          }}
          fieldValues(first: 20) {{
            nodes {{
              ... on ProjectV2ItemFieldTextValue {{
                field {{
                  ... on ProjectV2Field {{
                    name
                  }}
                }}
                text
              }}
              ... on ProjectV2ItemFieldNumberValue {{
                field {{
                  ... on ProjectV2Field {{
                    name
                  }}
                }}
                number
              }}
              ... on ProjectV2ItemFieldSingleSelectValue {{
                field {{
                  ... on ProjectV2SingleSelectField {{
                    name
                  }}
                }}
                name
              }}
            }}
          }}
        }}
      }}
    }}
  }}
}}' --jq '.data.node.items.nodes' ''').read()

items = json.loads(items_json)

expected_fields = [
    "Epic",
    "Story Points",
    "Priority",
    "Business Value",
    "Technical Risk",
    "Sprint",
    "Documentation Status",
    "Test Coverage",
    "Dependencies"
]

# Statistics
field_coverage = {field: 0 for field in expected_fields}
total_issues = 0
issues_with_all_fields = 0
issues_by_epic = {}

for item in items:
    if item.get('content', {}).get('state') != 'OPEN':
        continue
    if not item.get('content', {}).get('number'):
        continue

    title = item['content'].get('title', '')
    if 'Story' not in title:
        continue

    total_issues += 1

    # Get field names
    current_fields = set()
    for fv in item.get('fieldValues', {}).get('nodes', []):
        if 'field' in fv and 'name' in fv['field']:
            field_name = fv['field']['name']
            current_fields.add(field_name)
            if field_name in field_coverage:
                field_coverage[field_name] += 1

    # Check if all fields are present
    missing_count = 0
    for field in expected_fields:
        if field not in current_fields:
            missing_count += 1

    if missing_count == 0:
        issues_with_all_fields += 1

    # Categorize by epic
    import re
    story_match = re.search(r'Story[- ](\d+)', title)
    if story_match:
        epic_num = story_match.group(1).split('.')[0]
        epic_name = f"Epic {epic_num}"
        if epic_name not in issues_by_epic:
            issues_by_epic[epic_name] = {'total': 0, 'complete': 0}
        issues_by_epic[epic_name]['total'] += 1
        if missing_count == 0:
            issues_by_epic[epic_name]['complete'] += 1

print("\n\033[0;36m📈 Field Coverage Statistics:\033[0m")
print("-" * 50)

for field in expected_fields:
    coverage_pct = (field_coverage[field] / total_issues * 100) if total_issues > 0 else 0
    status = "✅" if coverage_pct == 100 else "⚠️" if coverage_pct >= 50 else "❌"
    bar_length = int(coverage_pct / 5)
    bar = "█" * bar_length + "░" * (20 - bar_length)
    print(f"{status} {field:<25} [{bar}] {coverage_pct:5.1f}% ({field_coverage[field]}/{total_issues})")

print("\n\033[0;36m🎯 Epic-Level Analysis:\033[0m")
print("-" * 50)

for epic in sorted(issues_by_epic.keys()):
    data = issues_by_epic[epic]
    complete_pct = (data['complete'] / data['total'] * 100) if data['total'] > 0 else 0
    status = "✅" if complete_pct == 100 else "⚠️" if complete_pct >= 50 else "❌"
    print(f"{status} {epic}: {data['complete']}/{data['total']} issues with all fields ({complete_pct:.0f}%)")

print("\n\033[0;36m📊 Overall Summary:\033[0m")
print("=" * 50)
print(f"Total Story Issues: {total_issues}")
print(f"Issues with ALL fields: {issues_with_all_fields} ({issues_with_all_fields/total_issues*100:.1f}%)")
print(f"Issues MISSING fields: {total_issues - issues_with_all_fields} ({(total_issues - issues_with_all_fields)/total_issues*100:.1f}%)")

# Recommendations
print("\n\033[0;35m💡 Recommendations:\033[0m")
print("-" * 50)

critical_missing = []
for field, count in field_coverage.items():
    if count < total_issues:
        missing_count = total_issues - count
        critical_missing.append((field, missing_count))

if critical_missing:
    critical_missing.sort(key=lambda x: x[1], reverse=True)
    print("Fields that need the most attention:")
    for field, missing in critical_missing[:5]:
        print(f"  • {field}: {missing} issues missing this field")
    print(f"\n\033[0;33m→ Run './scripts/populate-issue-fields.sh' to auto-populate missing fields\033[0m")
else:
    print("\033[0;32m✅ All fields are fully populated! No action needed.\033[0m")

EOF

echo ""
echo "======================================================="
echo -e "${GREEN}✅ Analysis Complete!${NC}"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo "  1. Review the missing fields above"
echo "  2. Run: ${CYAN}./scripts/populate-issue-fields.sh${NC} to auto-populate"
echo "  3. Check your project board: https://github.com/users/caioniehues/projects/$PROJECT_NUMBER"