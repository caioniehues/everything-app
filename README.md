# Everything App

A comprehensive personal and family life management platform built with Spring Boot and Flutter.

## Project Structure

This is a multi-module project managed with Maven at the root level:

```
everything-app/
├── pom.xml              # Parent POM - orchestrates the entire project
├── backend/             # Spring Boot backend service
│   ├── pom.xml         # Backend module POM
│   ├── src/            # Java source code
│   └── compose.yaml    # Docker services configuration
├── frontend/           # Flutter cross-platform application
│   ├── pubspec.yaml    # Flutter dependencies
│   ├── lib/            # Dart source code
│   └── test/           # Flutter tests
├── docs/               # Project documentation
│   ├── prd.md          # Product Requirements Document
│   ├── architecture.md # Technical Architecture
│   └── development-status.md # Current development status
└── .bmad-core/         # BMAD workflow configuration
```

## Quick Start

### Prerequisites

- Java 25
- Maven 3.9+
- Docker & Docker Compose
- Flutter 3.35.4+
- PostgreSQL (via Docker)

### Backend Development

```bash
# Start PostgreSQL and pgAdmin
cd backend
docker compose up -d

# Run the backend application
./mvnw spring-boot:run

# Run tests
./mvnw test
```

### Frontend Development

```bash
# Get Flutter dependencies
cd frontend
flutter pub get

# Run the application
flutter run

# Run tests
flutter test
```

### Full Project Commands (from root)

```bash
# Validate entire project structure
mvn validate

# Run backend tests
mvn test

# Build backend
mvn package

# Start Docker services (with profile)
mvn verify -Pdocker

# Work with Flutter (with profile)
mvn generate-resources -Pflutter
```

## Modules

### Backend Module
- **Technology**: Spring Boot 3.5.6, Java 25
- **Database**: PostgreSQL 15
- **Authentication**: JWT with refresh tokens
- **Architecture**: Modular monolith with event sourcing

### Frontend Module
- **Technology**: Flutter 3.35.4, Dart
- **State Management**: Riverpod
- **Platforms**: Web, Desktop (Linux/macOS/Windows), Mobile (Android/iOS)

### Documentation
- **PRD**: Product requirements and user stories
- **Architecture**: Technical design and decisions
- **Development Status**: Current sprint progress

## Development Approach

This project follows **Test-Driven Development (TDD)**:
1. Write failing tests first
2. Implement minimum code to pass tests
3. Refactor while keeping tests green

## Key Features (MVP)

- **Finance Module**: Budget tracking and management
- **Multi-user Support**: Family member accounts
- **Security**: JWT authentication with refresh token rotation
- **Audit Trail**: Event sourcing for complete history

## Future Modules

- Task Management
- Calendar Integration
- Health Tracking
- Document Storage

## Configuration

### Environment Variables

```bash
# JWT Secret (change in production)
JWT_SECRET=your-256-bit-secret-key-for-production

# Database (if not using Docker)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=everythingapp
DB_USER=appuser
DB_PASSWORD=apppassword
```

### Docker Services

- **PostgreSQL**: Port 5432
- **pgAdmin**: Port 5050 (admin@everything.app / admin)

## Testing

### Backend Tests
- Unit tests for domain entities
- Integration tests with TestContainers
- Repository tests with real PostgreSQL

### Frontend Tests
- Widget tests
- Integration tests
- Unit tests for business logic

## License

Private - Family use only

## Contact

Project maintained by Caio Niehues