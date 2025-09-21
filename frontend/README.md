# Everything App - Flutter Frontend

Everything App is a comprehensive family financial management platform designed to help households track expenses, manage budgets, and achieve financial goals together.

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK 3.35.4 or higher
- Dart SDK 3.9.2 or higher
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)
- Git

### Platform-Specific Requirements

**Web Development:**
- Chrome browser for debugging

**Desktop Development:**
- **Linux**: Linux desktop development tools
- **Windows**: Windows 10/11 with Visual Studio 2019 or later
- **macOS**: Xcode for macOS development

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/everything-app.git
   cd everything-app/frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code files:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Environment Setup

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` file with your configuration:**
   - `API_BASE_URL`: Backend API URL (default: `http://localhost:8080/api/v1`)
   - `ENVIRONMENT`: Current environment (`development`, `staging`, `production`)
   - Other configuration as needed

3. **Verify environment configuration:**
   ```bash
   cat .env | grep API_BASE_URL
   ```

## Running the Application

### Web Browser
```bash
flutter run -d chrome
```

### Desktop Platforms
```bash
# Linux
flutter run -d linux

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

### List Available Devices
```bash
flutter devices
```

### Hot Reload
While the app is running, press `r` for hot reload or `R` for hot restart.

## Development

### Code Generation
Run this command whenever you modify files that require code generation:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/specific_test.dart
```

### Code Analysis
```bash
# Run analyzer
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Formatting
```bash
# Format all Dart files
dart format lib/ test/
```

## Building for Production

### Web
```bash
flutter build web --release
```

### Desktop
```bash
# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── app.dart                  # App configuration
├── core/                     # Core functionality
│   ├── config/              # App configuration
│   ├── constants/           # Constants and strings
│   ├── network/             # API client and interceptors
│   ├── router/              # Navigation configuration
│   ├── theme/               # Theme and styling
│   └── utils/               # Utility functions
├── features/                 # Feature modules
│   ├── auth/                # Authentication
│   ├── dashboard/           # Dashboard
│   ├── accounts/            # Account management
│   ├── transactions/        # Transaction management
│   └── budgets/             # Budget management
└── shared/                   # Shared components
    ├── widgets/             # Reusable widgets
    └── providers/           # Global state providers
```

## Available Scripts

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run the application |
| `flutter test` | Run tests |
| `flutter analyze` | Analyze code |
| `flutter build` | Build for production |
| `flutter clean` | Clean build artifacts |

## State Management

This project uses Riverpod for state management. Providers are organized by feature and can be found in the respective `providers/` directories.

## Navigation

Navigation is handled by go_router. Route definitions can be found in `lib/core/router/app_router.dart`.

## Environment Variables

The app uses flutter_dotenv for environment configuration. Required variables:
- `API_BASE_URL` - Backend API endpoint
- `ENVIRONMENT` - Current environment mode
- `ENABLE_DEBUG_MODE` - Enable debug features
- `API_TIMEOUT` - API request timeout in milliseconds

## Troubleshooting

### Dependencies Issues
```bash
flutter clean
flutter pub get
```

### Code Generation Issues
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Platform-Specific Issues
- **Linux**: Ensure GTK development libraries are installed
- **Windows**: Ensure Visual Studio is properly configured
- **Web**: Clear browser cache if hot reload isn't working

## Contributing

1. Create a feature branch from `develop`
2. Follow the coding standards defined in `/docs/architecture/coding-standards.md`
3. Write tests for new features
4. Ensure all tests pass before submitting PR
5. Update documentation as needed

## License

Copyright (c) 2025 Everything App. All rights reserved.