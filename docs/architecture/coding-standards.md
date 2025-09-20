# Everything App - Coding Standards

## Overview
This document defines the coding standards and conventions for the Everything App project. All code must adhere to these standards to ensure consistency, maintainability, and quality.

## General Principles

### 1. Clean Code
- **DRY** (Don't Repeat Yourself) - Extract common code into reusable components
- **KISS** (Keep It Simple, Stupid) - Favor simple, readable solutions
- **YAGNI** (You Aren't Gonna Need It) - Don't add functionality until necessary
- **SOLID** principles for object-oriented design
- **Separation of Concerns** - Each module/class has a single, well-defined purpose

### 2. Code Quality Requirements
- **NO TODO/FIXME/HACK comments** - Complete work or explicitly acknowledge incompleteness in documentation
- **NO placeholder code** - All code must be production-ready
- **NO commented-out code** - Remove dead code immediately
- **NO debug prints** in production code (use proper logging)
- **Test Coverage**: Minimum 80% for business logic, 60% overall

### 3. Development Workflow
- **TDD Required** - Write failing tests BEFORE implementation
- **Atomic Commits** - Each commit should be a complete, working change
- **PR Reviews** - All code requires review before merging
- **CI/CD** - All tests must pass before merge

## Java/Spring Boot Standards

### Package Structure
```
com.caioniehues.app/
├── domain/           # Domain entities and value objects
├── application/      # Use cases and services
├── infrastructure/   # External integrations
├── presentation/     # Controllers and REST endpoints
└── config/          # Configuration classes
```

### Naming Conventions
- **Classes**: PascalCase (e.g., `TransactionService`)
- **Interfaces**: PascalCase, no "I" prefix (e.g., `AccountRepository`)
- **Methods**: camelCase, verb phrases (e.g., `calculateBalance()`)
- **Variables**: camelCase, descriptive names
- **Constants**: UPPER_SNAKE_CASE
- **Packages**: lowercase, single word preferred

### Java Specific Standards

#### Modern Java Features (Java 25)
```java
// Use records for DTOs
public record TransactionDto(
    UUID id,
    BigDecimal amount,
    String description
) {}

// Use pattern matching
switch (operation) {
    case Deposit(var amount, var time, var accountId, _) -> {
        // Handle deposit
    }
    case Withdrawal w -> {
        // Handle withdrawal
    }
}

// Use Virtual Threads for concurrency
Executors.newVirtualThreadPerTaskExecutor()

// Use text blocks for multiline strings
String query = """
    SELECT * FROM transactions
    WHERE account_id = ?
    AND date >= ?
    """;
```

#### Annotations and Documentation
```java
/**
 * Service for managing financial transactions.
 * Handles creation, updates, and balance calculations.
 */
@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class TransactionService {

    /**
     * Creates a new transaction and updates account balance.
     *
     * @param dto Transaction details
     * @return Created transaction with updated balance
     * @throws InsufficientFundsException if account has insufficient funds
     */
    public Transaction createTransaction(TransactionDto dto) {
        // Implementation
    }
}
```

#### Exception Handling
```java
// Use specific exceptions
throw new InsufficientFundsException("Account %s has insufficient funds".formatted(accountId));

// Global exception handler
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException ex) {
        // Handle gracefully
    }
}
```

#### Testing Standards
```java
@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {

    @Mock
    private TransactionRepository repository;

    @InjectMocks
    private TransactionService service;

    @Test
    @DisplayName("Should create transaction and update balance")
    void createTransaction_WithValidData_ShouldUpdateBalance() {
        // Given - Arrange
        var transaction = createTestTransaction();
        when(repository.save(any())).thenReturn(transaction);

        // When - Act
        var result = service.createTransaction(dto);

        // Then - Assert
        assertThat(result).isNotNull();
        assertThat(result.getBalance()).isEqualTo(expectedBalance);
        verify(repository).save(any());
    }
}
```

### Database Standards
- **Use UUIDs** for primary keys
- **Use TIMESTAMP WITH TIME ZONE** for dates
- **Use DECIMAL(19,2)** for monetary values
- **Implement soft deletes** with deleted_at column
- **Add indexes** for frequently queried columns
- **Use Liquibase** for migrations

### REST API Standards
- **Use proper HTTP methods**: GET (read), POST (create), PUT (update), DELETE (delete)
- **Use proper status codes**: 200 (OK), 201 (Created), 400 (Bad Request), 404 (Not Found)
- **Version APIs**: `/api/v1/resource`
- **Use pagination**: `?page=0&size=20`
- **Return consistent responses**:
```json
{
  "data": {},
  "message": "Success",
  "timestamp": "2025-01-20T10:30:00Z"
}
```

## Flutter/Dart Standards

### Project Structure
```
lib/
├── core/           # Core utilities and constants
├── features/       # Feature-first organization
├── shared/         # Shared widgets and providers
└── main.dart       # Entry point
```

### Naming Conventions
- **Classes/Widgets**: PascalCase (e.g., `AccountListScreen`)
- **Files**: snake_case (e.g., `transaction_service.dart`)
- **Variables/Methods**: camelCase
- **Private members**: prefix with underscore (e.g., `_privateMethod`)
- **Constants**: lowerCamelCase with `k` prefix (e.g., `kDefaultPadding`)

### Flutter Specific Standards

#### Widget Organization
```dart
class TransactionCard extends StatelessWidget {
  // 1. Constructor and fields
  final Transaction transaction;
  const TransactionCard({Key? key, required this.transaction}) : super(key: key);

  // 2. Build method
  @override
  Widget build(BuildContext context) {
    return _buildCard(context);
  }

  // 3. Private helper methods
  Widget _buildCard(BuildContext context) {
    // Implementation
  }
}
```

#### State Management (Riverpod)
```dart
// Use code generation for type safety
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    final repository = ref.read(transactionRepositoryProvider);
    return repository.getTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    // Implementation
  }
}
```

#### Responsive Design
```dart
class ResponsiveBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return MobileLayout();
        } else if (constraints.maxWidth < 1200) {
          return TabletLayout();
        } else {
          return DesktopLayout();
        }
      },
    );
  }
}
```

#### Testing Standards
```dart
void main() {
  group('TransactionService', () {
    late TransactionService service;
    late MockRepository mockRepository;

    setUp(() {
      mockRepository = MockRepository();
      service = TransactionService(mockRepository);
    });

    test('should create transaction successfully', () async {
      // Arrange
      when(() => mockRepository.create(any())).thenAnswer((_) async => testTransaction);

      // Act
      final result = await service.createTransaction(dto);

      // Assert
      expect(result, isNotNull);
      expect(result.id, equals(testTransaction.id));
      verify(() => mockRepository.create(any())).called(1);
    });
  });
}
```

### Performance Guidelines
- **Use const constructors** where possible
- **Implement keys** for list items
- **Use lazy loading** for large lists
- **Minimize rebuilds** with proper state management
- **Cache network images**
- **Debounce user inputs**

## Git Standards

### Branch Naming
- `main` - Production-ready code
- `develop` - Development integration
- `feature/story-x-y-description` - Feature branches
- `bugfix/issue-description` - Bug fixes
- `hotfix/critical-issue` - Production hotfixes

### Commit Messages
```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Testing
- `chore`: Maintenance

Example:
```
feat(auth): implement JWT refresh token rotation

- Added refresh token rotation for enhanced security
- Implemented token blacklisting
- Added tests for rotation logic

Closes #123
```

## Code Review Checklist

Before submitting PR:
- [ ] All tests pass (`mvnw test` / `flutter test`)
- [ ] No linting errors (`mvnw verify` / `flutter analyze`)
- [ ] Code coverage meets requirements
- [ ] No TODO/FIXME comments
- [ ] Documentation updated
- [ ] Follows naming conventions
- [ ] No security vulnerabilities
- [ ] Performance optimizations considered
- [ ] Error handling implemented
- [ ] Logging added appropriately

## Security Standards

### Never Commit
- Passwords or secrets
- API keys or tokens
- Connection strings with credentials
- Private certificates
- Personal data

### Always Implement
- Input validation
- SQL injection prevention (use prepared statements)
- XSS prevention
- CSRF protection
- Rate limiting
- Audit logging for sensitive operations

## Documentation Standards

### Code Comments
- Explain "why", not "what"
- Document complex algorithms
- Add comments for non-obvious business logic
- Keep comments up-to-date with code

### API Documentation
- Use OpenAPI/Swagger annotations
- Include request/response examples
- Document error cases
- Specify authentication requirements

### README Files
- Clear setup instructions
- Prerequisites listed
- Common commands documented
- Troubleshooting section

## Monitoring & Logging

### Logging Levels
- **ERROR**: System errors requiring immediate attention
- **WARN**: Potential issues or deprecated usage
- **INFO**: Important business events
- **DEBUG**: Detailed diagnostic information
- **TRACE**: Very detailed diagnostic information

### What to Log
- Authentication attempts
- Financial transactions
- API requests/responses (without sensitive data)
- System errors with stack traces
- Performance metrics

### What NOT to Log
- Passwords or tokens
- Credit card numbers
- Personal identifying information
- Full request/response bodies with sensitive data

## Performance Standards

### Response Times
- API endpoints: < 2 seconds
- Dashboard load: < 3 seconds
- Transaction queries: < 1 second
- Report generation: < 5 seconds

### Resource Usage
- Memory: Monitor for leaks
- CPU: Optimize hot paths
- Database: Use indexes, avoid N+1 queries
- Network: Implement caching, pagination

## Accessibility Standards

### WCAG 2.1 AA Compliance
- Proper color contrast ratios
- Keyboard navigation support
- Screen reader compatibility
- Focus indicators
- Alternative text for images
- Proper heading hierarchy

## Environment-Specific Standards

### Development
- Use Docker for consistency
- Hot reload enabled
- Verbose logging
- Mock external services when needed

### Production
- No debug endpoints
- Minimal logging (INFO level)
- Monitoring enabled
- Security headers configured
- HTTPS only

## Enforcement

These standards are enforced through:
1. Pre-commit hooks
2. CI/CD pipeline checks
3. Code review process
4. Static analysis tools
5. Automated testing

Non-compliance will result in:
- PR rejection
- Build failures
- Required refactoring

## Updates to Standards

Standards evolve with the project. To propose changes:
1. Create an issue describing the change
2. Discuss with team
3. Update this document via PR
4. Communicate changes to all developers

---
Last Updated: 21/09/2025 00:16:59
Version: 1.0.0