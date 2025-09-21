# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Last Updated: 21/09/2025 05:04:35

## 🎯 Project Overview

**Everything App** is a family financial management platform designed to help households track expenses, manage budgets, and achieve financial goals together. This is an enterprise-grade application following Domain-Driven Design (DDD) principles with clean architecture.

### Core Principles
- **Test-Driven Development (TDD)** - ALWAYS write tests first
- **Clean Architecture** - Domain, Application, Infrastructure, Presentation layers
- **No TODOs Policy** - Complete features fully or don't merge
- **BMAD Workflow** - Business Modeling Agile Development methodology
- **80% Test Coverage** - Minimum for backend, 70% for frontend

## Project Architecture

This is a full-stack application with:
- **Backend**: Spring Boot 3.5.6 application (Java 25) with Maven build system
- **Frontend**: Flutter 3.35.4 cross-platform application (Dart 3.9.2)
- **Database**: PostgreSQL 15 with Liquibase migrations
- **Authentication**: JWT with 15-minute access tokens and 7-day refresh tokens

### System Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Frontend                         │
│        (Web, iOS, Android, Windows, macOS, Linux)           │
└───────────────────────┬─────────────────────────────────────┘
                        │ REST API
┌───────────────────────▼─────────────────────────────────────┐
│                  Spring Boot Backend                         │
│                  (Modular Monolith)                         │
│  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐         │
│  │Presentation │ │ Application │ │    Domain    │         │
│  │    Layer    │►│    Layer    │►│    Layer     │         │
│  └─────────────┘ └─────────────┘ └──────────────┘         │
└────────────────────────┬────────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │PostgreSQL│
                    └─────────┘
```

### Directory Structure
```
everything-app/
├── backend/                      # Spring Boot REST API
│   ├── src/main/java/com/caioniehues/app/
│   │   ├── domain/              # Business logic & entities
│   │   ├── application/         # Use cases & services
│   │   ├── infrastructure/      # External concerns
│   │   └── presentation/        # REST controllers
│   ├── src/test/                # Test files (mirror structure)
│   ├── pom.xml                  # Maven configuration
│   └── compose.yaml             # Docker services
├── frontend/                     # Flutter application
│   ├── lib/
│   │   ├── core/                # Shared infrastructure
│   │   ├── features/            # Feature modules
│   │   └── shared/              # Shared components
│   ├── test/                    # Tests (mirror lib structure)
│   └── pubspec.yaml             # Flutter dependencies
├── docs/                        # Comprehensive documentation
│   ├── architecture/            # Architecture docs
│   ├── stories/                 # User stories (38 items)
│   └── prd.md                   # Product requirements
└── .bmad-core/                  # BMAD workflow automation
```

## Common Development Commands

### Backend (Spring Boot)

```bash
# Start database services first (PostgreSQL + pgAdmin)
cd backend && docker compose up -d
# Access pgAdmin at: http://localhost:5050
# Login: admin@everything.app / admin
# Database: postgres:5432 / everythingapp / appuser / apppassword

# Run the application
cd backend && ./mvnw spring-boot:run
# API available at: http://localhost:8080

# Build the application
cd backend && ./mvnw clean package

# Run all tests with coverage
cd backend && ./mvnw clean test jacoco:report
# View coverage: open target/site/jacoco/index.html

# Run a single test class
cd backend && ./mvnw test -Dtest=UserServiceTest

# Run tests matching a pattern
cd backend && ./mvnw test -Dtest="*Service*"

# Run a specific test method
cd backend && ./mvnw test -Dtest=UserServiceTest#shouldCreateUser

# Run integration tests only
cd backend && ./mvnw test -Dtest="*IntegrationTest"

# Skip tests during build
cd backend && ./mvnw clean package -DskipTests

# Database migrations
cd backend && ./mvnw liquibase:update
cd backend && ./mvnw liquibase:rollback -Dliquibase.rollbackCount=1

# Run with hot reload (DevTools enabled)
cd backend && ./mvnw spring-boot:run -Dspring-boot.run.fork=false

# Run with specific profile
cd backend && ./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Build native image with GraalVM
cd backend && ./mvnw native:compile -Pnative

# Build Docker image with Cloud Native Buildpacks
cd backend && ./mvnw spring-boot:build-image -Pnative

# Run native tests
cd backend && ./mvnw test -PnativeTest

# Check for dependency updates
cd backend && ./mvnw versions:display-dependency-updates

# Generate dependency tree
cd backend && ./mvnw dependency:tree
```

### Frontend (Flutter)

```bash
# Get dependencies
cd frontend && flutter pub get

# Run on web (fastest for development)
cd frontend && flutter run -d chrome

# Run with hot reload (default in debug mode)
cd frontend && flutter run -d chrome --hot

# Run tests with coverage
cd frontend && flutter test --coverage
# Generate HTML coverage report
cd frontend && genhtml coverage/lcov.info -o coverage/html
# View coverage: open coverage/html/index.html

# Run a single test file
cd frontend && flutter test test/widget_test.dart

# Run tests matching a name pattern
cd frontend && flutter test --name="should create user"

# Run tests in a specific directory
cd frontend && flutter test test/features/auth/

# Run tests with detailed output
cd frontend && flutter test --reporter expanded

# Run on specific platform
cd frontend && flutter run -d chrome    # Web
cd frontend && flutter run -d linux     # Linux desktop
cd frontend && flutter run -d macos     # macOS desktop
cd frontend && flutter run -d windows   # Windows desktop

# List available devices
cd frontend && flutter devices

# Analyze code for issues
cd frontend && flutter analyze

# Analyze with additional info
cd frontend && flutter analyze --suggestions

# Build for release
cd frontend && flutter build web        # Web release
cd frontend && flutter build apk        # Android APK
cd frontend && flutter build ios        # iOS (requires macOS)
cd frontend && flutter build linux      # Linux executable
cd frontend && flutter build macos      # macOS app
cd frontend && flutter build windows    # Windows executable

# Format code
cd frontend && dart format lib/
cd frontend && dart format lib/ --fix  # Apply fixes

# Check outdated packages
cd frontend && flutter pub outdated

# Upgrade packages
cd frontend && flutter pub upgrade

# Clean build artifacts
cd frontend && flutter clean
```

### API Testing

```bash
# Test API endpoints with curl (examples)
# Health check
curl http://localhost:8080/actuator/health

# Register a new user (when implemented)
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!"}'

# Login (when implemented)
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!"}'

# Test authenticated endpoint (when implemented)
curl -H "Authorization: Bearer <token>" \
  http://localhost:8080/api/v1/users/profile

# Using httpie (more user-friendly)
# Install: pip install httpie
http POST localhost:8080/api/v1/auth/login \
  email=test@example.com password=SecurePass123!

# Using Spring Boot Actuator endpoints
curl http://localhost:8080/actuator/info
curl http://localhost:8080/actuator/metrics
curl http://localhost:8080/actuator/env
```

## 📋 Development Workflow (BMAD)

### Story-Driven Development Process
1. **Select Story** from `/docs/stories/epic-story-summary.md`
2. **Create Branch**: `feature/story-x.x-description`
3. **Write Tests First** (TDD approach)
4. **Implement Feature** to make tests pass
5. **Document Changes** in relevant docs
6. **Submit PR** with story reference

### Automated Workflow Scripts
```bash
# Start work on a story (creates branch, assigns issue, updates project board)
./scripts/start-story.sh <issue-number>
./scripts/start-story.sh 3          # Start Story-1.1 (Issue #3)
./scripts/start-story.sh 3 bugfix   # Create bugfix branch
./scripts/start-story.sh 3 hotfix   # Create hotfix branch

# GitHub Issue Management
./scripts/create-github-issues.sh   # Create issues from story templates
./scripts/link-issues-to-project.sh # Link issues to project board
./scripts/populate-issue-fields.sh  # Populate custom fields

# BMAD Project Configuration
./scripts/configure-all-bmad-values.sh  # Set up all BMAD fields
./scripts/populate-bmad-fields.sh       # Populate BMAD-specific data

# Generate documentation
./scripts/generate-docs.sh          # Update all auto-generated docs

# Sync with GitHub Wiki
./scripts/sync-wiki.sh              # Push docs to GitHub Wiki
```

### Current Story Status
- **Total Stories**: 38 items (17 sharded from 4 oversized stories)
- **Sharded Stories**:
  - Story 1.2 → 5 sub-stories (Flutter Setup)
  - Story 1.3 → 5 sub-stories (Authentication API)
  - Story 3.4 → 3 sub-stories (Transaction Flow)
  - Story 5.1 → 4 sub-stories (Dashboard)

## Development Considerations

### Backend
- Uses Java 25 (latest version) - ensure compatibility when adding dependencies
- Lombok is configured for reducing boilerplate code
- Spring Boot DevTools provides automatic restart on code changes
- Docker Compose support is enabled but needs services to be configured in `compose.yaml`
- GraalVM native compilation is configured for improved performance

### Frontend
- Targets all major platforms (Android, iOS, Web, Linux, macOS, Windows)
- Material Design is enabled by default
- Currently using default Flutter starter template
- Some packages have newer versions available but are constrained by dependencies

## Package Structure

### Backend Package Convention
Base package: `com.caioniehues.app`

**Layer Organization**:
- `domain/` - Entities, repositories (interfaces), value objects
- `application/` - Services, DTOs, mappers, use cases
- `infrastructure/` - JPA repositories, external services, config
- `presentation/` - REST controllers, exception handlers

### Frontend File Organization
```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App configuration
├── core/                        # Shared infrastructure
│   ├── router/                  # Navigation (go_router)
│   ├── theme/                   # Material Design 3
│   ├── network/                 # API client (Dio)
│   └── constants/               # App constants
├── features/                    # Feature modules
│   └── {feature}/
│       ├── domain/              # Business logic
│       ├── data/                # Data sources
│       └── presentation/        # UI layer
└── shared/                      # Shared components
```

## 🧪 Testing Requirements

### Test Coverage Goals
- **Backend**: 80% minimum (90% for auth/security)
- **Frontend**: 70% minimum (80% for business logic)

### TDD Workflow
```
1. RED: Write failing test
2. GREEN: Write minimum code to pass
3. REFACTOR: Improve code quality
4. REPEAT: Continue cycle
```

### Test Structure Example (Backend)
```java
@Test
@DisplayName("Should create user with valid data")
void createUser_WithValidData_ReturnsCreated() {
    // Given
    var request = createValidRequest();

    // When
    var response = performPost("/api/v1/users", request);

    // Then
    assertThat(response.getStatus()).isEqualTo(201);
}
```

## 📝 Coding Standards

### General Rules
1. **NO TODO/FIXME comments** - Complete work or document explicitly
2. **Test Coverage**: Meet minimum requirements
3. **Naming**: Use descriptive, self-documenting names
4. **Documentation**: Update docs with changes
5. **Commits**: Follow conventional commits format

### API Design
- RESTful conventions: GET, POST, PUT, DELETE
- Version API: `/api/v1/...`
- Use proper HTTP status codes
- Implement pagination for lists
- Consistent error responses

## ⚡ Important Reminders

### Timestamp Format
**ALWAYS USE `date '+%d/%m/%Y %H:%M:%S'` FOR TIMESTAMPS IN DOCUMENTATION**

### Security Considerations
- Never commit secrets or credentials
- Use environment variables for configuration
- Implement rate limiting on auth endpoints (5 attempts/minute)
- Validate all inputs, sanitize outputs
- JWT tokens: 15-minute access, 7-day refresh

### Performance Guidelines
- Implement caching strategies
- Use pagination for large datasets
- Lazy load data when possible
- Profile before optimizing

## 📚 Key Documentation References

### Must Read Documents
1. [Product Requirements](docs/prd.md) - Vision and user stories
2. [Architecture Overview](docs/architecture.md) - System design
3. [Coding Standards](docs/architecture/coding-standards.md) - Conventions
4. [Epic Story Summary](docs/stories/epic-story-summary.md) - All stories
5. [Development Status](docs/development-status.md) - Current progress
6. [Frontend Architecture](docs/architecture/frontend-architecture.md) - Flutter patterns
7. [UI Specification](docs/architecture/ui-specification.md) - Design guidelines

## 🚨 Common Pitfalls to Avoid

1. **Creating files unnecessarily** - Always prefer editing existing files
2. **Incomplete implementations** - Finish features completely
3. **Skipping tests** - TDD is mandatory
4. **Ignoring documentation** - Keep docs updated
5. **Breaking conventions** - Follow established patterns
6. **Using TODO comments** - Complete or document incompleteness explicitly

## 🎭 Virtual Team Roles

When simulating team members, use these personalities:
- **Sarah (PO)**: Product-focused, user advocate, prioritizes business value
- **Winston (Architect)**: Technical excellence, clean code advocate
- **Ruby (Backend Dev)**: Spring Boot expert, TDD practitioner
- **Sally (UX Expert)**: User experience focused, accessibility advocate
- **Marcus (DevOps)**: Infrastructure, CI/CD, monitoring

## Current State
Project has comprehensive documentation, 38 user stories (17 sharded), and is ready for TDD development following BMAD workflow. Backend and frontend have starter code with proper architecture setup.

---
**Remember**: Quality > Speed. Follow TDD. Maintain documentation. No TODOs.