#!/bin/bash

# Simplified script to populate basic GitHub Project fields
# Focuses on fields that definitely exist: Epic, Story Points, Priority, Size

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🎯 Populating Basic Issue Fields${NC}"
echo "========================================"

# Configuration
PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"

# Known field IDs from the query
EPIC_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fn60"        # Epic
STORY_POINTS_FIELD="PVTF_lAHOA_Xhjc4BDod6zg1fn_Y"  # Story Points
PRIORITY_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fnxc"    # Priority
SIZE_FIELD="PVTSSF_lAHOA_Xhjc4BDod6zg1fnxg"        # Size
ESTIMATE_FIELD="PVTF_lAHOA_Xhjc4BDod6zg1fnxk"      # Estimate

echo -e "${CYAN}📋 Getting field options...${NC}"

# Get Epic options
EPIC_OPTIONS=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      field(name: "Epic") {
        ... on ProjectV2SingleSelectField {
          options { id, name }
        }
      }
    }
  }
}' --jq '.data.node.field.options' 2>/dev/null || echo "[]")

# Get Priority options
PRIORITY_OPTIONS=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      field(name: "Priority") {
        ... on ProjectV2SingleSelectField {
          options { id, name }
        }
      }
    }
  }
}' --jq '.data.node.field.options' 2>/dev/null || echo "[]")

# Get Size options
SIZE_OPTIONS=$(gh api graphql -f query='
{
  node(id: "'$PROJECT_ID'") {
    ... on ProjectV2 {
      field(name: "Size") {
        ... on ProjectV2SingleSelectField {
          options { id, name }
        }
      }
    }
  }
}' --jq '.data.node.field.options' 2>/dev/null || echo "[]")

echo -e "${GREEN}✅ Field options loaded${NC}\n"

# Process with Python for better handling
python3 << 'EOF'
import json
import subprocess
import re

project_id = "PVT_kwHOA_Xhjc4BDod6"

# Field IDs
fields = {
    'Epic': 'PVTSSF_lAHOA_Xhjc4BDod6zg1fn60',
    'Story Points': 'PVTF_lAHOA_Xhjc4BDod6zg1fn_Y',
    'Priority': 'PVTSSF_lAHOA_Xhjc4BDod6zg1fnxc',
    'Size': 'PVTSSF_lAHOA_Xhjc4BDod6zg1fnxg',
    'Estimate': 'PVTF_lAHOA_Xhjc4BDod6zg1fnxk'
}

# Get all project items
query = '''
{
  node(id: "%s") {
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
                field { ... on ProjectV2Field { name } }
                text
              }
              ... on ProjectV2ItemFieldNumberValue {
                field { ... on ProjectV2Field { name } }
                number
              }
              ... on ProjectV2ItemFieldSingleSelectValue {
                field { ... on ProjectV2SingleSelectField { name } }
                name
              }
            }
          }
        }
      }
    }
  }
}
''' % project_id

result = subprocess.run(
    ['gh', 'api', 'graphql', '-f', f'query={query}'],
    capture_output=True,
    text=True
)

data = json.loads(result.stdout)
items = data['data']['node']['items']['nodes']

# Get field options
def get_field_options(field_name):
    query = '''
    {
      node(id: "%s") {
        ... on ProjectV2 {
          field(name: "%s") {
            ... on ProjectV2SingleSelectField {
              options { id, name }
            }
          }
        }
      }
    }
    ''' % (project_id, field_name)

    result = subprocess.run(
        ['gh', 'api', 'graphql', '-f', f'query={query}'],
        capture_output=True,
        text=True
    )

    try:
        options = json.loads(result.stdout)['data']['node']['field']['options']
        return {opt['name']: opt['id'] for opt in options}
    except:
        return {}

# Get options for select fields
epic_options = get_field_options('Epic')
priority_options = get_field_options('Priority')
size_options = get_field_options('Size')

print("📊 Processing Issues:")
print("-" * 40)

updates = 0
failures = 0

for item in items:
    if not item.get('content') or item['content'].get('state') != 'OPEN':
        continue

    title = item['content'].get('title', '')
    if 'Story' not in title:
        continue

    item_id = item['id']
    issue_number = item['content']['number']

    # Extract story number
    match = re.search(r'Story[- ](\d+\.\d+(?:\.\d+)?)', title)
    if not match:
        continue

    story_num = match.group(1)

    print(f"\n📌 Issue #{issue_number}: Story-{story_num}")

    # Get current fields
    current_fields = set()
    for fv in item.get('fieldValues', {}).get('nodes', []):
        if 'field' in fv and 'name' in fv['field']:
            current_fields.add(fv['field']['name'])

    # Update Epic if missing
    if 'Epic' not in current_fields:
        epic_num = story_num.split('.')[0]
        epic_name = f"Epic {epic_num}: "
        if epic_num == '1':
            epic_name += "Foundation & Authentication"
        elif epic_num == '2':
            epic_name += "Account Management"
        elif epic_num == '3':
            epic_name += "Transaction Management"
        elif epic_num == '4':
            epic_name += "Budget & Goals"
        elif epic_num == '5':
            epic_name += "Dashboard & Analytics"

        if epic_name in epic_options:
            mutation = '''
            mutation {
              updateProjectV2ItemFieldValue(input: {
                projectId: "%s"
                itemId: "%s"
                fieldId: "%s"
                value: { singleSelectOptionId: "%s" }
              }) {
                projectV2Item { id }
              }
            }
            ''' % (project_id, item_id, fields['Epic'], epic_options[epic_name])

            result = subprocess.run(
                ['gh', 'api', 'graphql', '-f', f'query={mutation}'],
                capture_output=True,
                text=True
            )

            if 'errors' not in result.stdout:
                print(f"  ✓ Epic set to: {epic_name}")
                updates += 1
            else:
                print(f"  ✗ Failed to set Epic")
                failures += 1

    # Update Story Points if missing
    if 'Story Points' not in current_fields:
        # Determine points based on story type
        points = 5  # default
        if story_num.startswith('1.1') or story_num.startswith('1.2.1'):
            points = 8
        elif story_num.startswith('5.'):
            points = 8
        elif '.3' in story_num or '.4' in story_num:
            points = 3

        mutation = '''
        mutation {
          updateProjectV2ItemFieldValue(input: {
            projectId: "%s"
            itemId: "%s"
            fieldId: "%s"
            value: { number: %d }
          }) {
            projectV2Item { id }
          }
        }
        ''' % (project_id, item_id, fields['Story Points'], points)

        result = subprocess.run(
            ['gh', 'api', 'graphql', '-f', f'query={mutation}'],
            capture_output=True,
            text=True
        )

        if 'errors' not in result.stdout:
            print(f"  ✓ Story Points set to: {points}")
            updates += 1
        else:
            print(f"  ✗ Failed to set Story Points")
            failures += 1

    # Update Priority if missing
    if 'Priority' not in current_fields and priority_options:
        # Determine priority
        if story_num.startswith('1.1') or story_num.startswith('1.2'):
            priority_name = '🔴 Critical'
        elif story_num.startswith('1.') or story_num.startswith('2.1'):
            priority_name = '🟠 High'
        elif story_num.startswith('2.') or story_num.startswith('3.'):
            priority_name = '🟡 Medium'
        else:
            priority_name = '🟢 Low'

        if priority_name in priority_options:
            mutation = '''
            mutation {
              updateProjectV2ItemFieldValue(input: {
                projectId: "%s"
                itemId: "%s"
                fieldId: "%s"
                value: { singleSelectOptionId: "%s" }
              }) {
                projectV2Item { id }
              }
            }
            ''' % (project_id, item_id, fields['Priority'], priority_options[priority_name])

            result = subprocess.run(
                ['gh', 'api', 'graphql', '-f', f'query={mutation}'],
                capture_output=True,
                text=True
            )

            if 'errors' not in result.stdout:
                print(f"  ✓ Priority set to: {priority_name}")
                updates += 1
            else:
                print(f"  ✗ Failed to set Priority")
                failures += 1

    # Update Size if missing
    if 'Size' not in current_fields and size_options:
        # Map story points to T-shirt sizes
        if 'Story Points' in current_fields:
            # Get the current story points value
            points = 5  # default
        else:
            points = 5

        if points <= 3:
            size_name = '🔵 S'
        elif points <= 5:
            size_name = '🟡 M'
        elif points <= 8:
            size_name = '🟠 L'
        else:
            size_name = '🔴 XL'

        if size_name in size_options:
            mutation = '''
            mutation {
              updateProjectV2ItemFieldValue(input: {
                projectId: "%s"
                itemId: "%s"
                fieldId: "%s"
                value: { singleSelectOptionId: "%s" }
              }) {
                projectV2Item { id }
              }
            }
            ''' % (project_id, item_id, fields['Size'], size_options[size_name])

            result = subprocess.run(
                ['gh', 'api', 'graphql', '-f', f'query={mutation}'],
                capture_output=True,
                text=True
            )

            if 'errors' not in result.stdout:
                print(f"  ✓ Size set to: {size_name}")
                updates += 1
            else:
                print(f"  ✗ Failed to set Size")
                failures += 1

print("\n" + "=" * 40)
print(f"✅ Updates applied: {updates}")
print(f"❌ Failed updates: {failures}")
print("\n🔗 View your board: https://github.com/users/caioniehues/projects/2")

EOF