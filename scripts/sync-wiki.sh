#!/bin/bash

# Script to sync repository documentation to GitHub Wiki
# Usage: ./scripts/sync-wiki.sh

set -e

echo "🔄 Syncing documentation to GitHub Wiki..."

# Get the repository root directory (parent of scripts directory)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$REPO_ROOT/docs"

# Verify we're in a valid repository
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "❌ Error: Not in a git repository. Please run from the everything-app repository."
    exit 1
fi

# Configuration
REPO_URL="https://github.com/caioniehues/everything-app.wiki.git"
WIKI_DIR="/tmp/everything-app-wiki"

echo "📁 Repository root: $REPO_ROOT"
echo "📚 Docs directory: $DOCS_DIR"

# Clone or update wiki
if [ -d "$WIKI_DIR" ]; then
    echo "📥 Updating existing wiki clone..."
    cd "$WIKI_DIR"
    git pull
else
    echo "📥 Cloning wiki repository..."
    git clone "$REPO_URL" "$WIKI_DIR"
    cd "$WIKI_DIR"
fi

# Create Home page with navigation
cat > Home.md << 'EOF'
# Everything App Documentation

Welcome to the Everything App documentation wiki! This is a comprehensive family financial management platform built with Spring Boot and Flutter.

## 📚 Documentation Structure

### Getting Started
- [[README|Project Overview]]
- [[Development Setup]]
- [[Quick Start Guide]]

### Architecture
- [[Architecture Overview]]
- [[Frontend Architecture]]
- [[Tech Stack]]
- [[Coding Standards]]
- [[Source Tree]]

### User Stories & Planning
- [[Epic Story Summary]]
- [[Development Status]]
- [[Sprint Planning]]

### Development Guides
- [[BMAD Workflow]]
- [[TDD Guide]]
- [[API Documentation]]
- [[UI Specifications]]

### GitHub Actions
- [[Workflow Documentation]]
- [[CI/CD Pipeline]]

## 🚀 Quick Links

- [Main Repository](https://github.com/caioniehues/everything-app)
- [Pull Requests](https://github.com/caioniehues/everything-app/pulls)
- [Issues](https://github.com/caioniehues/everything-app/issues)

## 📊 Project Status

- **Current Sprint**: Planning
- **Stories Completed**: 0/38
- **Test Coverage**: TBD
- **Next Milestone**: Authentication System

---
*Last Updated: $(date '+%d/%m/%Y %H:%M:%S')*
EOF

# Create sidebar navigation
cat > _Sidebar.md << 'EOF'
## Navigation

**Getting Started**
- [[Home]]
- [[README|Overview]]
- [[Development Setup]]

**Architecture**
- [[Architecture Overview]]
- [[Frontend Architecture]]
- [[Tech Stack]]
- [[Coding Standards]]

**Stories**
- [[Epic Story Summary]]
- [[Epic 1 - Authentication]]
- [[Epic 2 - Accounts]]
- [[Epic 3 - Transactions]]
- [[Epic 4 - Budgets]]
- [[Epic 5 - Dashboard]]

**Development**
- [[BMAD Workflow]]
- [[TDD Guide]]
- [[GitHub Actions]]

**References**
- [[API Documentation]]
- [[UI Specifications]]
- [[Glossary]]
EOF

# Copy and convert main documentation files
echo "📄 Converting main documentation..."

# README
if [ -f "$REPO_ROOT/README.md" ]; then
    cp "$REPO_ROOT/README.md" "README.md"
    echo "  ✓ README.md"
fi

# Architecture docs
if [ -f "$DOCS_DIR/architecture.md" ]; then
    cp "$DOCS_DIR/architecture.md" "Architecture-Overview.md"
    echo "  ✓ Architecture Overview"
fi

if [ -f "$DOCS_DIR/architecture/frontend-architecture.md" ]; then
    cp "$DOCS_DIR/architecture/frontend-architecture.md" "Frontend-Architecture.md"
    echo "  ✓ Frontend Architecture"
fi

if [ -f "$DOCS_DIR/architecture/tech-stack.md" ]; then
    cp "$DOCS_DIR/architecture/tech-stack.md" "Tech-Stack.md"
    echo "  ✓ Tech Stack"
fi

if [ -f "$DOCS_DIR/architecture/coding-standards.md" ]; then
    cp "$DOCS_DIR/architecture/coding-standards.md" "Coding-Standards.md"
    echo "  ✓ Coding Standards"
fi

if [ -f "$DOCS_DIR/architecture/source-tree.md" ]; then
    cp "$DOCS_DIR/architecture/source-tree.md" "Source-Tree.md"
    echo "  ✓ Source Tree"
fi

if [ -f "$DOCS_DIR/architecture/workflow.md" ]; then
    cp "$DOCS_DIR/architecture/workflow.md" "BMAD-Workflow.md"
    echo "  ✓ BMAD Workflow"
fi

if [ -f "$DOCS_DIR/architecture/ui-specification.md" ]; then
    cp "$DOCS_DIR/architecture/ui-specification.md" "UI-Specifications.md"
    echo "  ✓ UI Specifications"
fi

# Development docs
if [ -f "$DOCS_DIR/development-status.md" ]; then
    cp "$DOCS_DIR/development-status.md" "Development-Status.md"
    echo "  ✓ Development Status"
else
    echo "# Development Status\n\nNot yet created" > "Development-Status.md"
    echo "  ⚠ Development Status (placeholder created)"
fi

if [ -f "$DOCS_DIR/prd.md" ]; then
    cp "$DOCS_DIR/prd.md" "Product-Requirements.md"
    echo "  ✓ Product Requirements"
fi

# Story documentation
if [ -f "$DOCS_DIR/stories/epic-story-summary.md" ]; then
    cp "$DOCS_DIR/stories/epic-story-summary.md" "Epic-Story-Summary.md"
    echo "  ✓ Epic Story Summary"
fi

# Create epic-specific pages
echo "📚 Creating epic pages..."

# Epic 1 - Authentication
cat > "Epic-1-Authentication.md" << 'EPIC1'
# Epic 1: Foundation & Authentication System

## Stories

### Completed
- [[Story 1.1 - Backend Infrastructure]]

### In Progress
- [[Story 1.2.1 - Flutter Project Initialization]]
- [[Story 1.2.2 - Core Package Architecture]]
- [[Story 1.2.3 - State Management Setup]]
- [[Story 1.2.4 - Navigation & Theming]]
- [[Story 1.2.5 - API Client Layer]]

### Planned
- [[Story 1.3.1 - JWT Service]]
- [[Story 1.3.2 - Registration Endpoint]]
- [[Story 1.3.3 - Login/Logout]]
- [[Story 1.3.4 - Security Configuration]]
- [[Story 1.3.5 - Integration Testing]]
EPIC1

# Copy individual story files (if needed)
for story_file in "$DOCS_DIR/stories"/story-*.md; do
    if [ -f "$story_file" ]; then
        filename=$(basename "$story_file")
        # Convert story-1.2.1-flutter-init.md to Story-1.2.1-Flutter-Init.md
        wiki_name=$(echo "$filename" | sed 's/story-/Story-/g' | sed 's/\.md$/\.md/')
        cp "$story_file" "$wiki_name"
    fi
done

# GitHub Actions documentation
if [ -f "$REPO_ROOT/.github/workflows/README.md" ]; then
    cp "$REPO_ROOT/.github/workflows/README.md" "GitHub-Actions.md"
fi

# Create additional helpful pages
echo "📝 Creating additional wiki pages..."

# TDD Guide
cat > "TDD-Guide.md" << 'TDD'
# Test-Driven Development Guide

## Overview
This project strictly follows TDD principles. All features must be developed test-first.

## Coverage Requirements
- **Backend**: 80% minimum (90% for auth/security)
- **Frontend**: 70% minimum (80% for business logic)

## TDD Workflow
1. **RED**: Write failing test
2. **GREEN**: Write minimum code to pass
3. **REFACTOR**: Improve code quality
4. **REPEAT**: Continue cycle

## Best Practices
- Write tests before implementation
- One test for one behavior
- Keep tests isolated and fast
- Use descriptive test names
- Follow Given-When-Then pattern

## Resources
- [[Coding Standards]]
- [[Backend Testing Guide]]
- [[Frontend Testing Guide]]
TDD

# Development Setup
cat > "Development-Setup.md" << 'SETUP'
# Development Environment Setup

## Prerequisites
- Java 25
- Maven 3.9+
- Flutter 3.35.4
- Docker & Docker Compose
- PostgreSQL 15 (via Docker)

## Backend Setup
```bash
cd backend
docker compose up -d
./mvnw spring-boot:run
```

## Frontend Setup
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

## IDE Configuration
- IntelliJ IDEA for backend
- VS Code or Android Studio for Flutter
- Install Flutter and Dart plugins

See [[README]] for detailed instructions.
SETUP

# Commit and push to wiki
echo "💾 Committing changes to wiki..."
git add -A
git commit -m "docs: sync documentation from main repository

- Updated all architecture documentation
- Added story documentation
- Created navigation structure
- Added guides and references

Synced on $(date '+%d/%m/%Y %H:%M:%S')" || echo "No changes to commit"

echo "📤 Pushing to GitHub Wiki..."
git push origin master || git push origin main

echo "✅ Wiki sync complete!"
echo "🔗 View at: https://github.com/caioniehues/everything-app/wiki"

# Cleanup
cd -
rm -rf "$WIKI_DIR"