# Everything App - Source Tree Structure

## Overview
This document describes the project structure and organization of the Everything App monorepo. The project follows a clean architecture pattern with clear separation between backend and frontend components.

## Project Root Structure

```
everything-app/                    # Project root directory
├── backend/                       # Spring Boot backend application
├── frontend/                      # Flutter frontend application
├── docs/                         # Project documentation
├── .bmad-core/                   # BMAD framework configuration (when present)
├── .ai/                          # AI agent workspace
├── CLAUDE.md                     # Claude AI instructions
├── README.md                     # Project overview
└── pom.xml                       # Root Maven configuration (if needed)
```

## Backend Structure (`/backend`)

### Root Level
```
backend/
├── src/                          # Source code directory
├── target/                       # Build output (gitignored)
├── compose.yaml                  # Docker Compose configuration
├── pom.xml                       # Maven configuration
├── mvnw                          # Maven wrapper script (Unix)
├── mvnw.cmd                      # Maven wrapper script (Windows)
└── .mvn/                         # Maven wrapper JAR
```

### Source Code (`/backend/src`)

#### Main Application (`/backend/src/main/java/com/caioniehues/app`)
```
com.caioniehues.app/
├── EverythingAppApplication.java # Main application class
├── domain/                       # Domain layer (entities, value objects)
│   ├── common/                   # Shared domain components
│   │   ├── BaseEntity.java      # Base entity with common fields
│   │   ├── AuditableEntity.java # Entity with audit fields
│   │   ├── DomainEvent.java     # Base domain event
│   │   └── ValueObject.java     # Base value object
│   └── user/                     # User domain
│       ├── User.java            # User entity
│       ├── Role.java            # Role enum
│       ├── RefreshToken.java    # Refresh token entity
│       └── Event.java           # Event sourcing entity
├── application/                  # Application layer (use cases)
│   ├── dto/                     # Data Transfer Objects
│   │   ├── request/             # Request DTOs
│   │   └── response/            # Response DTOs
│   ├── mapper/                  # MapStruct mappers
│   │   └── UserMapper.java      # Entity-DTO mapping
│   └── service/                 # Application services
│       ├── AuthService.java     # Authentication service
│       ├── UserService.java     # User management
│       └── EventStore.java      # Event sourcing service
├── infrastructure/              # Infrastructure layer
│   ├── persistence/             # Database implementation
│   │   ├── repository/          # JPA repositories
│   │   └── specification/       # JPA specifications
│   └── security/                # Security infrastructure
│       ├── JwtService.java      # JWT token handling
│       └── SecurityConfig.java  # Spring Security config
├── presentation/                # Presentation layer
│   └── controller/              # REST controllers
│       ├── AuthController.java  # Authentication endpoints
│       └── UserController.java  # User endpoints
└── config/                      # Configuration classes
    ├── ApplicationConfig.java   # General configuration
    ├── CacheConfig.java        # Caching configuration
    ├── OpenApiConfig.java      # Swagger/OpenAPI config
    └── WebConfig.java          # Web/CORS configuration
```

#### Resources (`/backend/src/main/resources`)
```
resources/
├── application.yml              # Main configuration
├── application-dev.yml         # Development profile
├── application-prod.yml        # Production profile
├── db/                         # Database resources
│   └── changelog/              # Liquibase migrations
│       ├── db.changelog-master.yaml
│       └── changes/
│           ├── 001-create-users-table.yaml
│           └── 002-create-events-table.yaml
├── static/                     # Static resources
├── templates/                  # Email/report templates
└── messages/                   # i18n message bundles
```

#### Test Structure (`/backend/src/test`)
```
test/java/com/caioniehues/app/
├── unit/                       # Unit tests
│   ├── domain/                # Domain tests
│   ├── application/           # Service tests
│   └── presentation/          # Controller tests
├── integration/               # Integration tests
│   ├── repository/            # Repository tests
│   └── controller/            # API tests
├── fixtures/                  # Test fixtures
└── TestcontainersConfig.java # TestContainers setup
```

## Frontend Structure (`/frontend`)

### Root Level
```
frontend/
├── lib/                       # Dart source code
├── test/                      # Test files
├── web/                       # Web platform files
├── android/                   # Android platform files
├── ios/                       # iOS platform files
├── linux/                     # Linux desktop files
├── macos/                     # macOS desktop files
├── windows/                   # Windows desktop files
├── pubspec.yaml              # Flutter dependencies
├── pubspec.lock              # Dependency lock file
└── analysis_options.yaml     # Dart analysis rules
```

### Library Structure (`/frontend/lib`)
```
lib/
├── main.dart                  # Application entry point
├── app.dart                   # App configuration
├── core/                      # Core functionality
│   ├── config/               # App configuration
│   │   ├── app_config.dart
│   │   ├── theme_config.dart
│   │   └── api_config.dart
│   ├── constants/            # App constants
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_dimensions.dart
│   ├── errors/               # Error handling
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/              # Network layer
│   │   ├── api_client.dart
│   │   ├── auth_interceptor.dart
│   │   └── error_interceptor.dart
│   └── utils/                # Utility functions
│       ├── currency_formatter.dart
│       ├── date_formatter.dart
│       └── validators.dart
├── features/                  # Feature modules
│   ├── auth/                 # Authentication feature
│   │   ├── data/            # Data layer
│   │   ├── domain/         # Domain layer
│   │   └── presentation/   # Presentation layer
│   ├── dashboard/           # Dashboard feature
│   ├── accounts/            # Accounts feature
│   ├── transactions/        # Transactions feature
│   └── budgets/            # Budgets feature
└── shared/                   # Shared components
    ├── widgets/             # Reusable widgets
    └── providers/           # Global providers
```

### Feature Structure Pattern
Each feature follows clean architecture:
```
feature_name/
├── data/                     # Data layer
│   ├── models/              # Data models
│   ├── repositories/        # Repository implementations
│   └── datasources/         # Remote/local data sources
├── domain/                  # Domain layer
│   ├── entities/            # Business entities
│   ├── repositories/        # Repository interfaces
│   └── usecases/           # Business logic
└── presentation/           # Presentation layer
    ├── providers/          # State management
    ├── screens/            # Screen widgets
    └── widgets/            # Feature-specific widgets
```

## Documentation Structure (`/docs`)

```
docs/
├── architecture/             # Architecture documentation
│   ├── coding-standards.md  # Coding conventions
│   ├── tech-stack.md        # Technology choices
│   └── source-tree.md       # This document
├── architecture.md          # Main architecture document
├── development-status.md    # Current development status
├── prd.md                  # Product requirements
├── prd/                    # Sharded PRD documents
│   └── epic-*.md           # Individual epic documents
├── stories/                # User stories
│   └── story-*.md          # Individual story files
└── qa/                     # QA documentation
    ├── test-plans/         # Test plans
    └── test-results/       # Test execution results
```

## BMAD Framework Structure (`/.bmad-core`)

When BMAD is initialized:
```
.bmad-core/
├── agents/                  # Agent definitions
├── tasks/                   # Reusable tasks
├── templates/              # Document templates
├── checklists/             # Quality checklists
├── data/                   # Reference data
├── utils/                  # Utility scripts
└── core-config.yaml        # BMAD configuration
```

## AI Workspace (`/.ai`)

```
.ai/
├── debug-log.md            # Development debug log
├── session-notes/          # Session-specific notes
└── artifacts/              # Generated artifacts
```

## Configuration Files

### Root Level Configurations
- `CLAUDE.md` - Claude AI instructions for the project
- `README.md` - Project overview and setup instructions

### Backend Configurations
- `pom.xml` - Maven dependencies and build configuration
- `compose.yaml` - Docker Compose for local development
- `application.yml` - Spring Boot configuration

### Frontend Configurations
- `pubspec.yaml` - Flutter dependencies
- `analysis_options.yaml` - Dart linting rules

## Build Outputs (Gitignored)

```
# Backend
backend/target/              # Maven build output
backend/*.iml                # IntelliJ files
backend/.idea/               # IntelliJ project files

# Frontend
frontend/build/              # Flutter build output
frontend/.dart_tool/         # Dart tool cache
frontend/.flutter-plugins    # Flutter plugin registry
frontend/.flutter-plugins-dependencies

# General
*.log                        # Log files
.DS_Store                    # macOS files
Thumbs.db                    # Windows files
```

## Naming Conventions

### Java/Backend
- **Packages**: lowercase, single word (e.g., `domain`, `service`)
- **Classes**: PascalCase (e.g., `UserService`)
- **Methods**: camelCase (e.g., `getUserById`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRIES`)

### Dart/Frontend
- **Files**: snake_case (e.g., `user_service.dart`)
- **Classes**: PascalCase (e.g., `UserService`)
- **Variables**: camelCase (e.g., `userName`)
- **Private**: prefix with underscore (e.g., `_privateMethod`)

### Database
- **Tables**: snake_case plural (e.g., `users`, `transactions`)
- **Columns**: snake_case (e.g., `created_at`, `user_id`)
- **Indexes**: idx_table_column (e.g., `idx_users_email`)

## Module Boundaries

### Backend Modules
Each module is self-contained with clear boundaries:
- `auth` - Authentication and authorization
- `finance` - Financial operations (accounts, transactions)
- `analytics` - Reporting and insights
- `import` - Data import functionality

### Frontend Features
Each feature is independent and can be developed in isolation:
- `auth` - Login, registration, token management
- `dashboard` - Overview and widgets
- `accounts` - Account management
- `transactions` - Transaction CRUD
- `budgets` - Budget management

## Development Workflow Paths

### Adding a New Backend Feature
1. Create domain entities in `/domain/feature/`
2. Add repository interfaces in `/domain/feature/repository/`
3. Implement repositories in `/infrastructure/persistence/`
4. Create DTOs in `/application/dto/`
5. Implement services in `/application/service/`
6. Add controllers in `/presentation/controller/`
7. Write tests in `/test/`

### Adding a New Frontend Feature
1. Create feature folder in `/lib/features/`
2. Define entities in `/domain/entities/`
3. Create repository interfaces in `/domain/repositories/`
4. Implement data layer in `/data/`
5. Create providers in `/presentation/providers/`
6. Build screens in `/presentation/screens/`
7. Add widgets in `/presentation/widgets/`
8. Write tests in `/test/`

## Import Hierarchy

### Backend Import Order
1. Java standard library
2. Spring Framework
3. Third-party libraries
4. Project imports (domain → application → infrastructure → presentation)

### Frontend Import Order
1. Dart SDK
2. Flutter SDK
3. Third-party packages
4. Project imports (core → domain → data → presentation)

## Security Considerations

### Sensitive Files (Never Commit)
- `.env` files
- `*.key`, `*.pem`, `*.p12` files
- `local.properties`
- Database credentials
- API keys

### Configuration Management
- Use environment variables for secrets
- Use Spring profiles for environment-specific config
- Use Flutter flavors for build variants
- Store secrets in secure vaults

---
Last Updated: 21/09/2025 00:18:22
Version: 1.0.0
Next Review: 21/10/2025