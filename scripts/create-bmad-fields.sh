#!/bin/bash

# Create BMAD-specific custom fields in GitHub Project
set -e

echo "🔧 Creating BMAD Custom Fields in GitHub Project #2"
echo "===================================================="

PROJECT_NUMBER=2
OWNER="caioniehues"

# Function to create a single-select field with options
create_single_select_field() {
    local field_name="$1"
    shift
    local options=("$@")

    echo "📝 Creating field: $field_name"

    # Build options string for GitHub CLI
    local options_str=""
    for opt in "${options[@]}"; do
        if [ -n "$options_str" ]; then
            options_str="$options_str,"
        fi
        options_str="$options_str\"$opt\""
    done

    # Create field using GitHub CLI
    gh project field-create "$PROJECT_NUMBER" \
        --owner "$OWNER" \
        --name "$field_name" \
        --data-type "SINGLE_SELECT" \
        --single-select-options "$options_str" 2>/dev/null || echo "  ✓ Field '$field_name' already exists or creation failed"
}

# Function to create a number field
create_number_field() {
    local field_name="$1"

    echo "📊 Creating field: $field_name"

    gh project field-create "$PROJECT_NUMBER" \
        --owner "$OWNER" \
        --name "$field_name" \
        --data-type "NUMBER" 2>/dev/null || echo "  ✓ Field '$field_name' already exists or creation failed"
}

# Function to create a text field
create_text_field() {
    local field_name="$1"

    echo "📄 Creating field: $field_name"

    gh project field-create "$PROJECT_NUMBER" \
        --owner "$OWNER" \
        --name "$field_name" \
        --data-type "TEXT" 2>/dev/null || echo "  ✓ Field '$field_name' already exists or creation failed"
}

echo ""
echo "🎯 Creating BMAD Fields..."
echo "-------------------------"

# 1. Test Coverage % (Number field)
create_number_field "Test Coverage %"

# 2. Documentation Status (Single Select)
create_single_select_field "Documentation Status" \
    "📝 Pending" \
    "🔄 In Progress" \
    "✅ Complete" \
    "🔍 Review"

# 3. Business Value (Single Select)
create_single_select_field "Business Value" \
    "🔥 Critical" \
    "⭐ High" \
    "📈 Medium" \
    "🔮 Future"

# 4. Technical Risk (Single Select)
create_single_select_field "Technical Risk" \
    "🔴 High" \
    "🟡 Medium" \
    "🟢 Low" \
    "🆕 Unknown"

# 5. Review Status (Single Select)
create_single_select_field "Review Status" \
    "⏳ Pending" \
    "👀 Code Review" \
    "🧪 QA Review" \
    "📋 PO Review" \
    "✅ Approved" \
    "🔄 Changes Requested"

# 6. Sprint (Single Select)
create_single_select_field "Sprint" \
    "🎯 Current Sprint" \
    "📋 Next Sprint" \
    "🔮 Future Sprint" \
    "❄️ Backlog" \
    "🏁 Completed"

# 7. Dependencies (Text field for listing story IDs)
create_text_field "Dependencies"

# 8. Blocked Reason (Text field)
create_text_field "Blocked Reason"

echo ""
echo "===================================================="
echo "✅ Field creation complete!"
echo ""
echo "📋 Verifying all fields..."
echo ""

# List all fields to confirm
gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" | head -30

echo ""
echo "🎯 Next Steps:"
echo "  1. Visit https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
echo "  2. Check Settings → Fields to verify all custom fields"
echo "  3. Fields may need manual configuration for icons/emojis in the UI"