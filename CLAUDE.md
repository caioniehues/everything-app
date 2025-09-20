# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Architecture

This is a full-stack application with:
- **Backend**: Spring Boot 3.5.6 application (Java 25) with Maven build system
- **Frontend**: Flutter 3.35.4 cross-platform application (Dart 3.9.2)

### Directory Structure
- `backend/` - Spring Boot REST API server
  - `src/main/java/com/caioniehues/app/` - Main application code
  - `src/test/` - Test files
  - `pom.xml` - Maven configuration
  - `compose.yaml` - Docker Compose configuration (currently empty)
- `frontend/` - Flutter mobile/web/desktop application
  - `lib/` - Dart source code
  - `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` - Platform-specific code
  - `test/` - Widget and unit tests
  - `pubspec.yaml` - Flutter dependencies

## Common Development Commands

### Backend (Spring Boot)

```bash
# Run the application
cd backend && ./mvnw spring-boot:run

# Build the application
cd backend && ./mvnw clean package

# Run tests
cd backend && ./mvnw test

# Run with hot reload (DevTools enabled)
cd backend && ./mvnw spring-boot:run -Dspring-boot.run.fork=false

# Build native image with GraalVM
cd backend && ./mvnw native:compile -Pnative

# Build Docker image with Cloud Native Buildpacks
cd backend && ./mvnw spring-boot:build-image -Pnative

# Run native tests
cd backend && ./mvnw test -PnativeTest
```

### Frontend (Flutter)

```bash
# Get dependencies
cd frontend && flutter pub get

# Run on default device/browser
cd frontend && flutter run

# Run on specific platform
cd frontend && flutter run -d chrome    # Web
cd frontend && flutter run -d linux     # Linux desktop
cd frontend && flutter run -d macos     # macOS desktop
cd frontend && flutter run -d windows   # Windows desktop

# Analyze code for issues
cd frontend && flutter analyze

# Run tests
cd frontend && flutter test

# Build for release
cd frontend && flutter build web        # Web release
cd frontend && flutter build apk        # Android APK
cd frontend && flutter build ios        # iOS (requires macOS)
cd frontend && flutter build linux      # Linux executable
cd frontend && flutter build macos      # macOS app
cd frontend && flutter build windows    # Windows executable

# Format code
cd frontend && dart format lib/

# Check outdated packages
cd frontend && flutter pub outdated
```

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

### Frontend File Organization
- `lib/main.dart` - Application entry point
- Platform-specific implementations in respective directories
- Widget tests in `test/` directory

## Current State
Both backend and frontend are starter projects ready for feature development. The backend requires Docker Compose services to be configured before it can start properly with compose support.
- ALWAYS USE !date BASH COMMAND TO FETCH TIMESTAMP FOR DOCS CHANGELOGS AND RELATED FIELDS; ALWAYS USE DD/MM/YYYY HH:MM:SS FORMAT