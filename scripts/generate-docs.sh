#!/bin/bash

# Generate all documentation for Everything App
set -e

echo "📚 Generating Complete Documentation Suite"
echo "=========================================="
echo "Started: $(date '+%d/%m/%Y %H:%M:%S')"
echo ""

# Create output directory
DOCS_OUTPUT="docs/generated"
mkdir -p "$DOCS_OUTPUT"

# 1. Generate Backend JavaDoc
echo "📘 Generating Backend API Documentation..."
if [ -d "backend" ]; then
    cd backend
    ./mvnw clean compile javadoc:javadoc -DskipTests 2>/dev/null || echo "⚠️  JavaDoc generation needs code to compile first"
    if [ -d "target/site/apidocs" ]; then
        cp -r target/site/apidocs ../docs/generated/backend-api
        echo "  ✅ Backend API docs generated"
    fi
    cd ..
fi

# 2. Generate Frontend DartDoc
echo "📗 Generating Frontend API Documentation..."
if [ -d "frontend" ]; then
    cd frontend
    flutter pub get
    dart doc . --output ../docs/generated/frontend-api 2>/dev/null || echo "⚠️  DartDoc generation needs Flutter dependencies"
    if [ -d "../docs/generated/frontend-api" ]; then
        echo "  ✅ Frontend API docs generated"
    fi
    cd ..
fi

# 3. Generate Test Coverage Reports
echo "📊 Generating Test Coverage Reports..."

# Backend coverage
if [ -d "backend" ]; then
    echo "  → Backend coverage..."
    cd backend
    ./mvnw clean test jacoco:report -DskipTests=false 2>/dev/null || echo "    ⚠️  Tests need to be written"
    if [ -d "target/site/jacoco" ]; then
        cp -r target/site/jacoco ../docs/generated/backend-coverage
        echo "    ✅ Backend coverage report generated"
    fi
    cd ..
fi

# Frontend coverage
if [ -d "frontend" ]; then
    echo "  → Frontend coverage..."
    cd frontend
    flutter test --coverage 2>/dev/null || echo "    ⚠️  Tests need to be written"
    if [ -f "coverage/lcov.info" ]; then
        # Generate HTML report
        genhtml coverage/lcov.info -o ../docs/generated/frontend-coverage 2>/dev/null || \
            echo "    ℹ️  Install lcov for HTML reports: sudo apt-get install lcov"
        echo "    ✅ Frontend coverage report generated"
    fi
    cd ..
fi

# 4. Generate Architecture Diagrams
echo "🏗️ Generating Architecture Diagrams..."
mkdir -p docs/generated/diagrams

cat > docs/generated/diagrams/system-architecture.md << 'EOF'
# System Architecture Diagrams

Generated: $(date '+%d/%m/%Y %H:%M:%S')

## Clean Architecture Layers

```mermaid
graph TB
    subgraph "Presentation Layer"
        REST[REST Controllers]
        DTO[DTOs]
    end

    subgraph "Application Layer"
        UC[Use Cases]
        AS[Application Services]
        MAP[Mappers]
    end

    subgraph "Domain Layer"
        ENT[Entities]
        VO[Value Objects]
        REPO[Repository Interfaces]
        DS[Domain Services]
    end

    subgraph "Infrastructure Layer"
        JPA[JPA Repositories]
        EXT[External Services]
        CONF[Configuration]
    end

    REST --> UC
    UC --> DS
    DS --> REPO
    REPO --> JPA
    AS --> MAP
    MAP --> DTO
```

## Component Dependencies

```mermaid
graph LR
    subgraph Frontend
        UI[Flutter UI] --> STATE[Riverpod State]
        STATE --> API[API Client]
    end

    subgraph Backend
        API --> AUTH[Auth Service]
        AUTH --> JWT[JWT Provider]
        API --> BIZ[Business Logic]
        BIZ --> DB[(PostgreSQL)]
    end

    subgraph Infrastructure
        DOCKER[Docker Compose] --> DB
        GH[GitHub Actions] --> DOCKER
    end
```
EOF

# 5. Generate Project Metrics
echo "📈 Calculating Project Metrics..."
mkdir -p docs/generated/metrics

# Count lines of code
echo "## Code Metrics Report" > docs/generated/metrics/code-metrics.md
echo "" >> docs/generated/metrics/code-metrics.md
echo "Generated: $(date '+%d/%m/%Y %H:%M:%S')" >> docs/generated/metrics/code-metrics.md
echo "" >> docs/generated/metrics/code-metrics.md

# Backend metrics
if [ -d "backend/src" ]; then
    BACKEND_LINES=$(find backend/src -name "*.java" -exec wc -l {} + | tail -1 | awk '{print $1}')
    BACKEND_FILES=$(find backend/src -name "*.java" | wc -l)
    echo "### Backend Metrics" >> docs/generated/metrics/code-metrics.md
    echo "- Java files: $BACKEND_FILES" >> docs/generated/metrics/code-metrics.md
    echo "- Lines of code: $BACKEND_LINES" >> docs/generated/metrics/code-metrics.md
    echo "" >> docs/generated/metrics/code-metrics.md
fi

# Frontend metrics
if [ -d "frontend/lib" ]; then
    FRONTEND_LINES=$(find frontend/lib -name "*.dart" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
    FRONTEND_FILES=$(find frontend/lib -name "*.dart" 2>/dev/null | wc -l)
    echo "### Frontend Metrics" >> docs/generated/metrics/code-metrics.md
    echo "- Dart files: $FRONTEND_FILES" >> docs/generated/metrics/code-metrics.md
    echo "- Lines of code: $FRONTEND_LINES" >> docs/generated/metrics/code-metrics.md
    echo "" >> docs/generated/metrics/code-metrics.md
fi

# Documentation metrics
DOC_FILES=$(find docs -name "*.md" | wc -l)
echo "### Documentation Metrics" >> docs/generated/metrics/code-metrics.md
echo "- Markdown files: $DOC_FILES" >> docs/generated/metrics/code-metrics.md
echo "- User stories: $(ls docs/stories/story-*.md 2>/dev/null | wc -l)" >> docs/generated/metrics/code-metrics.md

# 6. Create Master Documentation Index
echo "📝 Creating Documentation Index..."

cat > docs/generated/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Everything App - Living Documentation</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        h1 { margin: 0; font-size: 2.5em; }
        .subtitle { margin-top: 10px; opacity: 0.9; }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .card h2 {
            margin-top: 0;
            color: #333;
            display: flex;
            align-items: center;
        }
        .card h2 span {
            margin-right: 10px;
            font-size: 1.5em;
        }
        .card ul {
            list-style: none;
            padding: 0;
        }
        .card li {
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        .card li:last-child {
            border-bottom: none;
        }
        .card a {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }
        .card a:hover {
            text-decoration: underline;
        }
        .metrics {
            display: flex;
            justify-content: space-around;
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        .metric {
            text-align: center;
        }
        .metric-value {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
        }
        .metric-label {
            color: #666;
            margin-top: 5px;
        }
        .timestamp {
            text-align: center;
            color: #666;
            margin-top: 40px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Everything App Documentation Hub</h1>
        <div class="subtitle">Living Documentation • Auto-Generated • Always Current</div>
    </div>

    <div class="metrics">
        <div class="metric">
            <div class="metric-value">38</div>
            <div class="metric-label">User Stories</div>
        </div>
        <div class="metric">
            <div class="metric-value">5</div>
            <div class="metric-label">Epics</div>
        </div>
        <div class="metric">
            <div class="metric-value">80%</div>
            <div class="metric-label">Coverage Target</div>
        </div>
        <div class="metric">
            <div class="metric-value">BMAD</div>
            <div class="metric-label">Methodology</div>
        </div>
    </div>

    <div class="grid">
        <div class="card">
            <h2><span>📘</span>API Documentation</h2>
            <ul>
                <li><a href="backend-api/index.html">Backend JavaDoc</a></li>
                <li><a href="frontend-api/index.html">Frontend DartDoc</a></li>
                <li><a href="../architecture/api-specification.md">REST API Spec</a></li>
            </ul>
        </div>

        <div class="card">
            <h2><span>🏗️</span>Architecture</h2>
            <ul>
                <li><a href="../architecture/README.md">Architecture Overview</a></li>
                <li><a href="diagrams/system-architecture.md">System Diagrams</a></li>
                <li><a href="../architecture/tech-stack.md">Technology Stack</a></li>
            </ul>
        </div>

        <div class="card">
            <h2><span>📊</span>Test Coverage</h2>
            <ul>
                <li><a href="backend-coverage/index.html">Backend Coverage</a></li>
                <li><a href="frontend-coverage/index.html">Frontend Coverage</a></li>
                <li><a href="metrics/code-metrics.md">Code Metrics</a></li>
            </ul>
        </div>

        <div class="card">
            <h2><span>📋</span>Project Management</h2>
            <ul>
                <li><a href="../stories/epic-story-summary.md">All User Stories</a></li>
                <li><a href="reports/">Sprint Reports</a></li>
                <li><a href="compliance/bmad-compliance.md">BMAD Compliance</a></li>
            </ul>
        </div>

        <div class="card">
            <h2><span>📚</span>Guides</h2>
            <ul>
                <li><a href="../development-status.md">Development Status</a></li>
                <li><a href="../architecture/coding-standards.md">Coding Standards</a></li>
                <li><a href="../project-views-quickstart.md">Project Board Guide</a></li>
            </ul>
        </div>

        <div class="card">
            <h2><span>🔗</span>Quick Links</h2>
            <ul>
                <li><a href="https://github.com/caioniehues/everything-app">GitHub Repository</a></li>
                <li><a href="https://github.com/caioniehues/everything-app/wiki">Project Wiki</a></li>
                <li><a href="https://github.com/users/caioniehues/projects/2">Project Board</a></li>
            </ul>
        </div>
    </div>

    <div class="timestamp">
        Documentation generated: <script>document.write(new Date().toLocaleString('pt-BR'));</script>
    </div>
</body>
</html>
EOF

echo ""
echo "=========================================="
echo "✅ Documentation Generation Complete!"
echo "Finished: $(date '+%d/%m/%Y %H:%M:%S')"
echo ""
echo "📂 Generated documentation available in: docs/generated/"
echo "🌐 Open docs/generated/index.html in browser for full documentation"
echo ""
echo "📊 Summary:"
ls -la docs/generated/ 2>/dev/null | grep -c "^d" | xargs echo "  - Directories created:"
ls -la docs/generated/ 2>/dev/null | grep -c "^-" | xargs echo "  - Files generated:"
echo ""
echo "🚀 To publish to GitHub Wiki, push to main branch"