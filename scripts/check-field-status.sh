#!/bin/bash

# Simple script to check field status of GitHub issues
set -e

echo "🔍 Checking GitHub Project Field Status..."
echo "=========================================="

PROJECT_ID="PVT_kwHOA_Xhjc4BDod6"

# Get current field status using Python for better JSON handling
python3 << 'EOF'
import json
import subprocess
import os

project_id = "PVT_kwHOA_Xhjc4BDod6"

# Query for all items
query = '''
{
  node(id: "%s") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
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

# Run GraphQL query
result = subprocess.run(
    ['gh', 'api', 'graphql', '-f', f'query={query}'],
    capture_output=True,
    text=True
)

data = json.loads(result.stdout)
items = data['data']['node']['items']['nodes']

# Expected fields
expected = [
    "Epic", "Story Points", "Priority", "Business Value",
    "Technical Risk", "Sprint", "Documentation Status",
    "Test Coverage", "Dependencies"
]

# Analyze each issue
print("\n📊 Field Coverage Report:")
print("-" * 50)

story_issues = []
for item in items:
    if not item.get('content'):
        continue
    if item['content'].get('state') != 'OPEN':
        continue

    title = item['content'].get('title', '')
    if 'Story' not in title:
        continue

    number = item['content']['number']

    # Get fields
    fields = set()
    for fv in item.get('fieldValues', {}).get('nodes', []):
        if 'field' in fv and 'name' in fv['field']:
            fields.add(fv['field']['name'])

    missing = [f for f in expected if f not in fields]
    story_issues.append({
        'number': number,
        'title': title,
        'missing': missing,
        'fields': fields
    })

# Summary statistics
total = len(story_issues)
complete = sum(1 for s in story_issues if not s['missing'])

print(f"\n✅ Issues with ALL fields: {complete}/{total} ({complete/total*100:.0f}%)")
print(f"⚠️  Issues MISSING fields: {total-complete}/{total} ({(total-complete)/total*100:.0f}%)")

# Field coverage
print("\n📈 Field Coverage:")
for field in expected:
    count = sum(1 for s in story_issues if field in s['fields'])
    pct = count/total*100 if total > 0 else 0
    status = "✅" if pct == 100 else "⚠️" if pct >= 50 else "❌"
    print(f"  {status} {field:<25} {count}/{total} ({pct:.0f}%)")

# Show issues missing fields
if total - complete > 0:
    print("\n⚠️  Issues Missing Fields:")
    print("-" * 50)
    for issue in story_issues:
        if issue['missing']:
            print(f"Issue #{issue['number']}: Missing {len(issue['missing'])} fields")
            print(f"  → {', '.join(issue['missing'])}")

print("\n" + "=" * 50)
if total - complete > 0:
    print("💡 Run './scripts/populate-issue-fields.sh' to auto-populate missing fields")
else:
    print("✅ All fields are populated!")

EOF