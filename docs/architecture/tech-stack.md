# Everything App - Technology Stack

## Overview
This document provides a comprehensive overview of the technology stack used in the Everything App. It serves as a reference for developers to understand the tools, frameworks, and libraries that power the application.

## Core Technologies

### Backend Stack

#### Primary Framework
- **Spring Boot 3.5.6**
  - Purpose: REST API server and business logic
  - Features: Auto-configuration, embedded server, production-ready
  - License: Apache 2.0

#### Programming Language
- **Java 25**
  - Purpose: Backend development language
  - Features: Virtual threads, pattern matching, records, sealed classes
  - JVM: Eclipse Temurin (OpenJDK)

#### Database
- **PostgreSQL 15+**
  - Purpose: Primary data store
  - Features: ACID compliance, JSON support, full-text search
  - Extensions: UUID generation (gen_random_uuid)

#### Build Tool
- **Apache Maven 3.9+**
  - Purpose: Dependency management and build automation
  - Wrapper: Included (mvnw)

### Frontend Stack

#### Primary Framework
- **Flutter 3.35.4**
  - Purpose: Cross-platform UI development
  - Platforms: Web, Desktop (Windows, Linux, macOS), Mobile (iOS, Android)
  - License: BSD

#### Programming Language
- **Dart 3.9.2**
  - Purpose: Frontend development language
  - Features: Null safety, async/await, strong typing

#### State Management
- **Riverpod 2.0**
  - Purpose: Reactive state management
  - Features: Code generation, compile-time safety, testing support

## Backend Dependencies

### Core Spring Boot Starters
```xml
spring-boot-starter-web          # REST APIs
spring-boot-starter-data-jpa     # Database ORM
spring-boot-starter-security     # Authentication & authorization
spring-boot-starter-validation   # Bean validation
spring-boot-starter-cache        # Caching abstraction
spring-boot-starter-actuator     # Production monitoring
spring-boot-starter-aop          # Aspect-oriented programming
```

### Security & Authentication
- **Spring Security** - Framework for authentication and access control
- **JJWT (0.12.6)** - JWT token generation and validation
- **BCrypt** - Password hashing (via Spring Security)
- **Bucket4j** - Rate limiting implementation

### Database & Persistence
- **Hibernate** - JPA implementation (via Spring Data JPA)
- **Liquibase** - Database schema version control
- **HikariCP** - High-performance connection pooling
- **PostgreSQL Driver** - Database connectivity

### Development Tools
- **Lombok** - Boilerplate code reduction
- **MapStruct (1.6.3)** - Object mapping
- **Spring Boot DevTools** - Hot reload during development
- **Jackson** - JSON serialization/deserialization

### Testing
- **JUnit 5** - Unit testing framework
- **Mockito** - Mocking framework
- **TestContainers** - Integration testing with real databases
- **REST Assured** - API testing
- **AssertJ** - Fluent assertions

### Documentation
- **SpringDoc OpenAPI (2.7.0)** - OpenAPI 3.0 documentation
- **Swagger UI** - Interactive API documentation

### Observability
- **Micrometer** - Metrics collection
- **Spring Boot Actuator** - Health checks and monitoring
- **SLF4J + Logback** - Logging

### Caching
- **Caffeine** - Local cache implementation
- **Spring Cache** - Caching abstraction
- **Redis** (optional) - Distributed cache

## Frontend Dependencies

### Core Flutter Packages
```yaml
flutter_riverpod: ^2.5.0           # State management
riverpod_annotation: ^2.3.0        # Code generation
go_router: ^14.0.0                 # Navigation
dio: ^5.4.0                        # HTTP client
```

### UI & Design
- **Material Design 3** - Design system
- **flutter_adaptive_scaffold** - Responsive layouts
- **cached_network_image** - Image caching
- **shimmer** - Loading animations
- **lottie** - Complex animations

### Data & Storage
- **sqflite** - Local SQLite database
- **shared_preferences** - Key-value storage
- **flutter_secure_storage** - Secure credential storage
- **path_provider** - File system access

### Utilities
- **intl** - Internationalization and formatting
- **freezed** - Immutable data classes
- **json_serializable** - JSON code generation
- **uuid** - UUID generation
- **collection** - Additional collection utilities

### Development & Testing
- **flutter_test** - Widget testing
- **mockito** - Mocking for tests
- **build_runner** - Code generation
- **flutter_lints** - Linting rules
- **integration_test** - Integration testing

## Development Environment

### Required Tools
| Tool | Version | Purpose |
|------|---------|---------|
| JDK | 25+ | Java development |
| Maven | 3.9+ | Build tool |
| Flutter | 3.35.4 | Frontend framework |
| Docker | 24+ | Containerization |
| Docker Compose | 2.20+ | Multi-container orchestration |
| Git | 2.40+ | Version control |
| Node.js | 20+ LTS | Frontend tooling (optional) |

### IDE Recommendations
- **IntelliJ IDEA** - Backend development (Ultimate recommended)
- **VS Code** - Frontend development with Flutter extension
- **Android Studio** - Alternative for Flutter development

### VS Code Extensions
- Flutter
- Dart
- Error Lens
- GitLens
- Thunder Client (API testing)

### IntelliJ IDEA Plugins
- Lombok
- Spring Boot Assistant
- Database Tools
- Docker
- Flutter (if using for Flutter development)

## Infrastructure Components

### Containerization
- **Docker** - Application containerization
- **Docker Compose** - Local development environment
- **Docker Hub** - Container registry

### Database Management
- **pgAdmin 4** - PostgreSQL administration
- **Liquibase** - Schema migrations
- **Connection Pool** - HikariCP configuration

### API Gateway (Future)
- **Spring Cloud Gateway** - API routing and filtering
- **Kong** - Alternative API gateway option

### Message Queue (Future)
- **RabbitMQ** - Asynchronous messaging
- **Apache Kafka** - Event streaming platform

## External Services

### Current Integrations
- **ExchangeRate-API** - Currency conversion rates
- **OpenAI API** (optional) - Financial insights

### Planned Integrations
- **Plaid** - Bank account connections
- **SendGrid** - Email notifications
- **Twilio** - SMS notifications
- **AWS S3** - File storage

## Performance Tools

### Backend Performance
- **Java Flight Recorder** - JVM profiling
- **async-profiler** - CPU and memory profiling
- **JMH** - Microbenchmarking

### Frontend Performance
- **Flutter DevTools** - Performance profiling
- **Observatory** - Dart VM service protocol
- **Performance Overlay** - Real-time metrics

### Load Testing
- **Apache JMeter** - Load testing
- **Gatling** - High-performance load testing
- **K6** - Modern load testing tool

## Security Tools

### Static Analysis
- **SonarQube** - Code quality and security
- **OWASP Dependency Check** - Vulnerability scanning
- **SpotBugs** - Java bug detection

### Runtime Security
- **Spring Security** - Authentication/authorization
- **Helmet** - Security headers
- **CORS** - Cross-origin resource sharing

## CI/CD Pipeline

### Version Control
- **Git** - Source control
- **GitHub** - Repository hosting
- **GitHub Actions** - CI/CD automation

### Build Pipeline
1. **Maven** - Compile and package
2. **Flutter build** - Frontend compilation
3. **Docker build** - Container creation
4. **Test execution** - Automated testing

### Quality Gates
- Unit test coverage (80% minimum)
- Integration test pass rate (100%)
- Static analysis pass
- Security scan pass

## Monitoring Stack

### Application Monitoring
- **Spring Actuator** - Health and metrics
- **Prometheus** (optional) - Metrics collection
- **Grafana** (optional) - Metrics visualization

### Log Management
- **Logback** - Structured logging
- **ELK Stack** (optional) - Log aggregation
  - Elasticsearch
  - Logstash
  - Kibana

### Error Tracking
- **Sentry** (optional) - Error monitoring
- **Rollbar** (alternative) - Error tracking

## Database Tools

### Migration Management
- **Liquibase** - Schema versioning
- **Flyway** (alternative) - Database migrations

### Backup & Recovery
- **pg_dump** - PostgreSQL backup
- **pgBackRest** - Advanced backup solution
- **WAL-G** - Continuous archiving

## Development Practices

### Code Quality
- **Checkstyle** - Code style enforcement
- **PMD** - Code analysis
- **ESLint** (for any JavaScript) - Linting

### Documentation
- **JavaDoc** - Java documentation
- **DartDoc** - Dart documentation
- **OpenAPI/Swagger** - API documentation
- **Markdown** - General documentation

## Version Matrix

| Component | Version | EOL Date | Notes |
|-----------|---------|----------|-------|
| Spring Boot | 3.5.6 | 2026-05 | Latest stable |
| Java | 25 | 2025-09 | Latest release |
| Flutter | 3.35.4 | Active | Stable channel |
| PostgreSQL | 15 | 2027-11 | LTS version |
| Node.js | 20 | 2026-04 | LTS version |

## Technology Decisions

### Why Spring Boot?
- Mature ecosystem
- Excellent PostgreSQL support
- Built-in security features
- Production-ready features
- Large community

### Why Flutter?
- True cross-platform from single codebase
- Native performance
- Hot reload for development
- Material Design support
- Growing ecosystem

### Why PostgreSQL?
- ACID compliance critical for financial data
- Excellent performance
- JSON support for flexibility
- Mature and stable
- Open source

### Why Modular Monolith?
- Simpler deployment initially
- Easier development and debugging
- Can evolve to microservices
- Lower operational complexity
- Cost-effective for small team

## Future Technology Considerations

### Potential Additions
- **GraphQL** - Alternative API approach
- **gRPC** - High-performance APIs
- **Apache Pulsar** - Event streaming
- **Kubernetes** - Container orchestration
- **Istio** - Service mesh

### Migration Paths
- Monolith → Microservices (when scale demands)
- REST → GraphQL (for complex queries)
- PostgreSQL → PostgreSQL + TimescaleDB (for time-series data)
- Local deployment → Cloud (AWS/GCP/Azure)

## License Information

| Component | License | Commercial Use |
|-----------|---------|----------------|
| Spring Boot | Apache 2.0 | Yes |
| PostgreSQL | PostgreSQL License | Yes |
| Flutter | BSD | Yes |
| Java (OpenJDK) | GPL v2 + Classpath | Yes |
| Docker CE | Apache 2.0 | Yes |

## Support & Resources

### Documentation Links
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Flutter Documentation](https://flutter.dev/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

### Community Resources
- Spring Boot: Stack Overflow, GitHub Discussions
- Flutter: Flutter Community, Discord
- PostgreSQL: PostgreSQL Slack, Mailing Lists

### Training Resources
- Spring Academy
- Flutter Codelabs
- PostgreSQL Tutorial
- Docker Training

---
Last Updated: 21/09/2025 00:17:18
Version: 1.0.0
Next Review: 21/10/2025