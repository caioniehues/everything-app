# Everything App - Technical Architecture (Enhanced)

## System Architecture

### High-Level Design
- **Architecture Pattern:** Modular Monolith with Event Sourcing
- **Backend:** Spring Boot 3.5.6 (Java 25) with AOT & Virtual Threads
- **Frontend:** Flutter 3.35.4 (Dart 3.9.2) with Riverpod 2 Code Generation
- **Database:** PostgreSQL 15+ with Read Replicas
- **Caching:** Multi-tier (Caffeine L1, Redis L2)
- **Authentication:** JWT with refresh token rotation + Passkeys ready

## Database Schema

### Core Entities

```sql
-- Users and Authentication
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL, -- ADMIN, FAMILY_MEMBER
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE -- Soft delete
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    token_hash VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Financial Accounts
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    account_type VARCHAR(50) NOT NULL, -- CHECKING, SAVINGS, CREDIT_CARD, INVESTMENT, LOAN, CASH
    balance DECIMAL(19,2) NOT NULL DEFAULT 0.00,
    currency CHAR(3) NOT NULL DEFAULT 'USD', -- ISO 4217
    icon VARCHAR(50),
    color VARCHAR(7), -- Hex color
    is_included_in_totals BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT unique_account_name_per_user UNIQUE (user_id, name, deleted_at)
);

-- Categories
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id), -- NULL for system categories
    parent_id UUID REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    category_type VARCHAR(50) NOT NULL, -- INCOME, EXPENSE
    icon VARCHAR(50),
    color VARCHAR(7),
    is_system BOOLEAN DEFAULT false,
    display_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Transactions
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id),
    category_id UUID REFERENCES categories(id),
    amount DECIMAL(19,2) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- INCOME, EXPENSE, TRANSFER
    transaction_date DATE NOT NULL,
    description TEXT,
    notes TEXT,
    receipt_data TEXT, -- Base64 encoded image
    is_pending BOOLEAN DEFAULT false,
    recurring_transaction_id UUID,
    import_id UUID,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Budgets
CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    period_type VARCHAR(50) NOT NULL, -- WEEKLY, MONTHLY, YEARLY
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE budget_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    budget_id UUID NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id),
    limit_amount DECIMAL(19,2) NOT NULL,
    alert_threshold_percent INTEGER DEFAULT 80,
    rollover_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_budget_category UNIQUE (budget_id, category_id)
);

-- Recurring Transactions
CREATE TABLE recurring_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    account_id UUID NOT NULL REFERENCES accounts(id),
    category_id UUID REFERENCES categories(id),
    amount DECIMAL(19,2) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    description TEXT,
    frequency VARCHAR(50) NOT NULL, -- DAILY, WEEKLY, MONTHLY, YEARLY
    frequency_detail JSONB, -- {"dayOfWeek": 1, "dayOfMonth": 15, etc.}
    next_date DATE NOT NULL,
    end_date DATE,
    end_after_occurrences INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Audit Log
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL, -- CREATE, UPDATE, DELETE
    changes JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Performance
CREATE INDEX idx_accounts_user_id ON accounts(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_account_id ON transactions(account_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_date ON transactions(transaction_date) WHERE deleted_at IS NULL;
CREATE INDEX idx_transactions_category ON transactions(category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_budget_categories_budget ON budget_categories(budget_id);
CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_user ON audit_log(user_id, created_at DESC);

-- Event Sourcing Tables (NEW)
CREATE TABLE financial_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(50) NOT NULL, -- ACCOUNT, TRANSACTION
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    event_version INTEGER NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB -- Contains idempotency keys, correlation IDs
);

CREATE INDEX idx_events_aggregate ON financial_events(aggregate_id, event_version);
CREATE INDEX idx_events_occurred ON financial_events(occurred_at);
CREATE INDEX idx_events_idempotency ON financial_events((metadata->>'idempotency_key'));
```

## Enhanced Architecture Components

### Performance Optimizations

#### Spring Boot AOT & CDS Configuration
```java
// Enable AOT processing for 40-50% faster startup
@SpringBootApplication
@ImportRuntimeHints(FinanceRuntimeHints.class)
public class EverythingAppApplication {
    public static void main(String[] args) {
        SpringApplication.run(EverythingAppApplication.class, args);
    }
}

// Runtime hints for AOT
@Configuration
public class FinanceRuntimeHints implements RuntimeHintsRegistrar {
    @Override
    public void registerHints(RuntimeHints hints, ClassLoader classLoader) {
        // Register resources for reflection
        hints.resources()
            .registerPattern("db/migration/*.sql")
            .registerPattern("static/**");

        // Register serialization hints for DTOs
        hints.serialization()
            .registerType(TransactionDto.class)
            .registerType(AccountDto.class);
    }
}
```

#### Virtual Threads Configuration (Java 21+)
```java
@Configuration
@EnableAsync
public class VirtualThreadConfig {

    @Bean
    public TomcatProtocolHandlerCustomizer<?> protocolHandlerVirtualThreadExecutorCustomizer() {
        return protocolHandler -> {
            protocolHandler.setExecutor(Executors.newVirtualThreadPerTaskExecutor());
        };
    }

    @Bean(TaskExecutionAutoConfiguration.APPLICATION_TASK_EXECUTOR_BEAN_NAME)
    public AsyncTaskExecutor asyncTaskExecutor() {
        return new TaskExecutorAdapter(Executors.newVirtualThreadPerTaskExecutor());
    }

    @Bean
    public AsyncConfigurer asyncConfigurer() {
        return new AsyncConfigurer() {
            @Override
            public Executor getAsyncExecutor() {
                return Executors.newVirtualThreadPerTaskExecutor();
            }
        };
    }
}
```

### Event Sourcing Implementation

```java
// Event Store Service
@Service
@Transactional
public class EventStore {

    @Autowired
    private EventRepository eventRepository;

    public void saveEvent(DomainEvent event) {
        FinancialEvent entity = FinancialEvent.builder()
            .aggregateId(event.getAggregateId())
            .aggregateType(event.getAggregateType())
            .eventType(event.getClass().getSimpleName())
            .eventData(JsonUtils.toJsonb(event))
            .eventVersion(getNextVersion(event.getAggregateId()))
            .userId(SecurityUtils.getCurrentUserId())
            .metadata(Map.of(
                "idempotencyKey", event.getIdempotencyKey(),
                "correlationId", MDC.get("correlationId")
            ))
            .build();

        eventRepository.save(entity);
        publishEvent(event);
    }

    @Async
    protected void publishEvent(DomainEvent event) {
        // Publish to event bus for projections
        applicationEventPublisher.publishEvent(event);
    }
}

// Domain Event Example
@Value
@Builder
public class TransactionCreatedEvent implements DomainEvent {
    UUID aggregateId;
    BigDecimal amount;
    String description;
    UUID categoryId;
    LocalDate transactionDate;
    String idempotencyKey;

    @Override
    public String getAggregateType() {
        return "TRANSACTION";
    }
}
```

### CQRS Read Model Projections

```java
@Component
@EventListener
public class DashboardProjection {

    @Autowired
    private DashboardReadModelRepository repository;

    @Async
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void on(TransactionCreatedEvent event) {
        // Update denormalized read model
        DashboardReadModel model = repository.findByUserId(event.getUserId())
            .orElse(new DashboardReadModel());

        model.incrementTransactionCount();
        model.updateTotalSpent(event.getAmount());
        model.updateCategorySpending(event.getCategoryId(), event.getAmount());
        model.setLastUpdated(Instant.now());

        repository.save(model);
    }
}
```

### Enhanced Security Configuration

#### SSL Bundles (Spring Boot 3)
```yaml
spring:
  ssl:
    bundle:
      pem:
        server:
          reload-on-update: true
          keystore:
            certificate: "classpath:certs/server.crt"
            private-key: "classpath:certs/server.key"
          truststore:
            certificate: "classpath:certs/ca.crt"
        client:
          keystore:
            certificate: "classpath:certs/client.crt"
            private-key: "classpath:certs/client.key"
```

#### Rate Limiting with Bucket4j
```java
@Component
public class RateLimitingFilter extends OncePerRequestFilter {

    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                  HttpServletResponse response,
                                  FilterChain chain) throws ServletException, IOException {
        String key = getClientKey(request);
        Bucket bucket = buckets.computeIfAbsent(key, k -> createBucket());

        if (bucket.tryConsume(1)) {
            chain.doFilter(request, response);
        } else {
            response.setStatus(429);
            response.getWriter().write("Too Many Requests");
        }
    }

    private Bucket createBucket() {
        return Bucket.builder()
            .addLimit(Bandwidth.classic(100, Refill.intervally(100, Duration.ofMinutes(1))))
            .addLimit(Bandwidth.classic(1000, Refill.intervally(1000, Duration.ofHours(1))))
            .build();
    }
}
```

### Observability & Monitoring

#### Distributed Tracing Configuration
```java
@Configuration
public class TracingConfig {

    @Bean
    public MicrometerObservationCapability micrometerObservationCapability(ObservationRegistry registry) {
        return MicrometerObservationCapability.create(registry);
    }

    @Bean
    public ObservationRegistryCustomizer<ObservationRegistry> observationRegistryCustomizer() {
        return (registry) -> registry.observationConfig()
            .observationHandler(new PerformanceObservationHandler());
    }
}

// Custom observation for financial operations
@Component
@Observed(name = "financial.transaction", contextualName = "financial-transaction")
public class TransactionService {

    @Observed(name = "transaction.create")
    public Transaction createTransaction(TransactionDto dto) {
        // Method implementation with automatic tracing
    }
}
```

#### Structured Logging
```java
@Component
public class CorrelationIdFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                  HttpServletResponse response,
                                  FilterChain chain) throws ServletException, IOException {
        String correlationId = request.getHeader("X-Correlation-Id");
        if (correlationId == null) {
            correlationId = UUID.randomUUID().toString();
        }

        MDC.put("correlationId", correlationId);
        MDC.put("userId", SecurityUtils.getCurrentUserId());
        response.setHeader("X-Correlation-Id", correlationId);

        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
```

## Backend Architecture (Spring Boot)

### Package Structure
```
com.caioniehues.app/
├── EverythingAppApplication.java
├── common/
│   ├── config/
│   │   ├── SecurityConfig.java
│   │   ├── CacheConfig.java
│   │   ├── OpenApiConfig.java
│   │   └── AuditConfig.java
│   ├── exception/
│   │   ├── GlobalExceptionHandler.java
│   │   ├── BusinessException.java
│   │   └── ValidationException.java
│   ├── dto/
│   │   ├── ApiResponse.java
│   │   ├── PageRequest.java
│   │   └── ErrorResponse.java
│   └── util/
│       ├── DateUtils.java
│       ├── MoneyUtils.java
│       └── SecurityUtils.java
├── auth/
│   ├── controller/
│   │   └── AuthController.java
│   ├── service/
│   │   ├── AuthService.java
│   │   ├── JwtService.java
│   │   └── RefreshTokenService.java
│   ├── dto/
│   │   ├── LoginRequest.java
│   │   ├── RegisterRequest.java
│   │   └── TokenResponse.java
│   ├── entity/
│   │   ├── User.java
│   │   └── RefreshToken.java
│   └── repository/
│       ├── UserRepository.java
│       └── RefreshTokenRepository.java
├── finance/
│   ├── controller/
│   │   ├── AccountController.java
│   │   ├── TransactionController.java
│   │   ├── CategoryController.java
│   │   └── BudgetController.java
│   ├── service/
│   │   ├── AccountService.java
│   │   ├── TransactionService.java
│   │   ├── CategoryService.java
│   │   ├── BudgetService.java
│   │   └── BalanceCalculationService.java
│   ├── dto/
│   │   ├── AccountDto.java
│   │   ├── TransactionDto.java
│   │   ├── CategoryDto.java
│   │   └── BudgetDto.java
│   ├── entity/
│   │   ├── Account.java
│   │   ├── Transaction.java
│   │   ├── Category.java
│   │   └── Budget.java
│   ├── repository/
│   │   ├── AccountRepository.java
│   │   ├── TransactionRepository.java
│   │   ├── CategoryRepository.java
│   │   └── BudgetRepository.java
│   └── mapper/
│       └── FinanceMapper.java (MapStruct)
├── analytics/
│   ├── service/
│   │   ├── DashboardService.java
│   │   ├── ReportService.java
│   │   └── InsightService.java
│   └── dto/
│       ├── DashboardData.java
│       ├── FinancialReport.java
│       └── Insight.java
└── import/
    ├── controller/
    │   └── ImportController.java
    ├── service/
    │   ├── ImportService.java
    │   ├── CsvParser.java
    │   ├── OfxParser.java
    │   └── TransactionMatcher.java
    └── dto/
        ├── ImportRequest.java
        └── ImportResult.java
```

### API Design

#### Authentication Endpoints
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
GET    /api/v1/auth/me
```

#### Account Endpoints
```
GET    /api/v1/accounts?page=0&size=20
GET    /api/v1/accounts/{id}
POST   /api/v1/accounts
PUT    /api/v1/accounts/{id}
DELETE /api/v1/accounts/{id}
GET    /api/v1/accounts/{id}/transactions?from=2024-01-01&to=2024-12-31
GET    /api/v1/accounts/summary
```

#### Transaction Endpoints
```
GET    /api/v1/transactions?accountId=&categoryId=&from=&to=&page=0&size=50
GET    /api/v1/transactions/{id}
POST   /api/v1/transactions
PUT    /api/v1/transactions/{id}
DELETE /api/v1/transactions/{id}
POST   /api/v1/transactions/bulk
```

#### Category Endpoints
```
GET    /api/v1/categories?type=EXPENSE
GET    /api/v1/categories/{id}
POST   /api/v1/categories
PUT    /api/v1/categories/{id}
DELETE /api/v1/categories/{id}
PUT    /api/v1/categories/reorder
```

#### Budget Endpoints
```
GET    /api/v1/budgets?active=true
GET    /api/v1/budgets/{id}
POST   /api/v1/budgets
PUT    /api/v1/budgets/{id}
DELETE /api/v1/budgets/{id}
GET    /api/v1/budgets/{id}/progress
POST   /api/v1/budgets/{id}/copy
```

#### Dashboard & Analytics Endpoints
```
GET    /api/v1/dashboard
GET    /api/v1/analytics/cashflow?period=MONTHLY&months=6
GET    /api/v1/analytics/spending-by-category?from=&to=
GET    /api/v1/analytics/trends?metric=spending&period=MONTHLY
GET    /api/v1/analytics/insights
```

#### Import Endpoints
```
POST   /api/v1/import/preview
POST   /api/v1/import/confirm
GET    /api/v1/import/history
POST   /api/v1/import/{id}/rollback
```

### Security Configuration

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) {
        return http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/auth/**", "/actuator/health").permitAll()
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter(), UsernamePasswordAuthenticationFilter.class)
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint(new JwtAuthenticationEntryPoint())
                .accessDeniedHandler(new CustomAccessDeniedHandler())
            )
            .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }
}
```

### Caching Strategy

```java
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager();
        cacheManager.setCaffeine(caffeineCacheBuilder());
        cacheManager.setCacheNames(Arrays.asList(
            "accounts",
            "categories",
            "dashboard",
            "analytics",
            "userSettings"
        ));
        return cacheManager;
    }

    Caffeine<Object, Object> caffeineCacheBuilder() {
        return Caffeine.newBuilder()
            .maximumSize(1000)
            .expireAfterWrite(5, TimeUnit.MINUTES)
            .recordStats();
    }
}

// Service usage example
@Service
public class DashboardService {

    @Cacheable(value = "dashboard", key = "#userId")
    public DashboardData getDashboard(UUID userId) {
        // Expensive calculation
    }

    @CacheEvict(value = "dashboard", key = "#userId")
    public void invalidateDashboard(UUID userId) {
        // Called when transactions change
    }
}
```

## Java 24/25 Modern Features

### Pattern Matching with Records
```java
// Domain modeling with sealed interfaces and pattern matching
public sealed interface FinancialOperation
    permits Deposit, Withdrawal, Transfer {

    BigDecimal amount();
    LocalDateTime timestamp();
}

public record Deposit(
    BigDecimal amount,
    LocalDateTime timestamp,
    UUID accountId,
    String description
) implements FinancialOperation {}

public record Withdrawal(
    BigDecimal amount,
    LocalDateTime timestamp,
    UUID accountId,
    String category
) implements FinancialOperation {}

public record Transfer(
    BigDecimal amount,
    LocalDateTime timestamp,
    UUID fromAccountId,
    UUID toAccountId
) implements FinancialOperation {}

// Service using pattern matching
@Service
public class FinancialOperationProcessor {

    public void processOperation(FinancialOperation operation) {
        switch (operation) {
            case Deposit(var amount, var time, var accountId, var desc) -> {
                // Direct variable extraction from record
                accountService.credit(accountId, amount);
                auditService.log("Deposit: %s at %s".formatted(desc, time));
            }
            case Withdrawal(var amount, _, var accountId, var category) -> {
                // Can ignore components with _
                accountService.debit(accountId, amount);
                budgetService.trackSpending(category, amount);
            }
            case Transfer(var amount, _, var from, var to) -> {
                accountService.transfer(from, to, amount);
            }
        }
    }

    // Exhaustive pattern matching for validation
    public ValidationResult validateOperation(FinancialOperation op) {
        return switch (op) {
            case Deposit d when d.amount().compareTo(BigDecimal.ZERO) <= 0 ->
                ValidationResult.error("Deposit amount must be positive");
            case Withdrawal w when w.amount().compareTo(getBalance(w.accountId())) > 0 ->
                ValidationResult.error("Insufficient funds");
            case Transfer t when t.fromAccountId().equals(t.toAccountId()) ->
                ValidationResult.error("Cannot transfer to same account");
            default -> ValidationResult.success();
        };
    }
}
```

### Structured Concurrency (Preview)
```java
@Service
public class DashboardAggregationService {

    // Use structured concurrency for dashboard data aggregation
    public DashboardData aggregateDashboardData(UUID userId) throws InterruptedException {
        try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {

            // Launch parallel subtasks
            Subtask<List<Account>> accountsTask = scope.fork(() ->
                accountService.getUserAccounts(userId));

            Subtask<List<Transaction>> recentTransactionsTask = scope.fork(() ->
                transactionService.getRecentTransactions(userId, 10));

            Subtask<BudgetStatus> budgetStatusTask = scope.fork(() ->
                budgetService.getCurrentMonthStatus(userId));

            Subtask<Map<String, BigDecimal>> categorySpendingTask = scope.fork(() ->
                analyticsService.getCategorySpending(userId));

            Subtask<CashFlow> cashFlowTask = scope.fork(() ->
                analyticsService.getCashFlow(userId));

            // Wait for all tasks or fail fast if any fails
            scope.join()           // Join all subtasks
                 .throwIfFailed(); // Propagate any exceptions

            // All tasks completed successfully
            return DashboardData.builder()
                .accounts(accountsTask.get())
                .recentTransactions(recentTransactionsTask.get())
                .budgetStatus(budgetStatusTask.get())
                .categorySpending(categorySpendingTask.get())
                .cashFlow(cashFlowTask.get())
                .build();
        }
    }

    // Structured concurrency with timeout
    public Optional<FinancialInsight> generateInsight(UUID userId) {
        try (var scope = new StructuredTaskScope.ShutdownOnSuccess<FinancialInsight>()) {

            // Try multiple insight generators in parallel
            scope.fork(() -> patternAnalyzer.findSpendingPatterns(userId));
            scope.fork(() -> anomalyDetector.detectUnusualTransactions(userId));
            scope.fork(() -> savingsOptimizer.suggestSavings(userId));
            scope.fork(() -> budgetAdvisor.recommendBudgetAdjustments(userId));

            // Return first successful insight
            scope.joinUntil(Instant.now().plusSeconds(5)); // 5 second timeout

            return Optional.ofNullable(scope.result());
        } catch (TimeoutException | InterruptedException e) {
            return Optional.empty();
        }
    }
}
```

### Enhanced Domain Modeling with Sealed Classes
```java
// Financial domain model using sealed hierarchies
public sealed abstract class FinancialAccount {
    private final UUID id;
    private final String name;
    private final BigDecimal balance;
    private final Currency currency;

    // Sealed permits for account types
    public static final class Checking extends FinancialAccount {
        private final BigDecimal overdraftLimit;
        // ...
    }

    public static final class Savings extends FinancialAccount {
        private final BigDecimal interestRate;
        private final LocalDate maturityDate;
        // ...
    }

    public static final class CreditCard extends FinancialAccount {
        private final BigDecimal creditLimit;
        private final BigDecimal apr;
        private final int billingDayOfMonth;
        // ...
    }

    public static final class Investment extends FinancialAccount {
        private final String ticker;
        private final BigDecimal shares;
        private final BigDecimal costBasis;
        // ...
    }

    // Pattern matching for account-specific operations
    public BigDecimal getAvailableBalance() {
        return switch (this) {
            case Checking c -> c.balance.add(c.overdraftLimit);
            case CreditCard cc -> cc.creditLimit.subtract(cc.balance.abs());
            case Savings s, Investment i -> balance;
        };
    }
}
```

### String Templates (Preview Feature)
```java
@Service
public class NotificationService {

    // String templates for cleaner formatting (Java 21+ preview)
    public String formatTransactionNotification(Transaction tx) {
        // Using string templates when available
        return STR."""
            Transaction Alert:
            Amount: ${formatCurrency(tx.amount())}
            Account: ${tx.accountName()}
            Category: ${tx.category()}
            Date: ${tx.date().format(DateTimeFormatter.ISO_LOCAL_DATE)}
            Balance after: ${formatCurrency(tx.balanceAfter())}
            """;
    }

    public String generateMonthlyReport(MonthlyReport report) {
        return STR."""
            Monthly Financial Report for ${report.month()}
            ================================================

            Income:    ${formatCurrency(report.totalIncome())}
            Expenses:  ${formatCurrency(report.totalExpenses())}
            Net:       ${formatCurrency(report.netAmount())}

            Top Categories:
            ${report.topCategories()
                .stream()
                .map(c -> STR."  • ${c.name()}: ${formatCurrency(c.amount())}")
                .collect(Collectors.joining("\n"))}

            Savings Rate: ${report.savingsRate()}%
            Budget Adherence: ${report.budgetAdherence()}%
            """;
    }
}
```

## Frontend Architecture (Flutter)

### Project Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── theme_config.dart
│   │   └── api_config.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_dimensions.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── auth_interceptor.dart
│   │   └── error_interceptor.dart
│   └── utils/
│       ├── currency_formatter.dart
│       ├── date_formatter.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── accounts/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── transactions/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── budgets/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── widgets/
    │   ├── responsive_builder.dart
    │   ├── loading_indicator.dart
    │   ├── error_widget.dart
    │   └── empty_state.dart
    └── providers/
        ├── app_state_provider.dart
        └── theme_provider.dart
```

### State Management (Riverpod)

```dart
// Auth State
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// Account Providers
final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (authState is! Authenticated) return [];

  final repository = ref.read(accountRepositoryProvider);
  return repository.getAccounts();
});

final selectedAccountProvider = StateProvider<Account?>((ref) => null);

// Transaction Providers with Pagination
final transactionListProvider = StateNotifierProvider.family<
    TransactionListNotifier,
    AsyncValue<TransactionPage>,
    TransactionFilter
>((ref, filter) {
  return TransactionListNotifier(
    ref.read(transactionRepositoryProvider),
    filter,
  );
});

// Dashboard Provider with Caching
final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  // Auto-refresh when accounts or transactions change
  ref.watch(accountsProvider);
  ref.watch(latestTransactionsProvider);

  final repository = ref.read(dashboardRepositoryProvider);
  return repository.getDashboard();
});
```

### Responsive Design System

```dart
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints, ScreenType) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = _getScreenType(constraints.maxWidth);
        return builder(context, constraints, screenType);
      },
    );
  }

  ScreenType _getScreenType(double width) {
    if (width < ResponsiveBreakpoints.mobile) return ScreenType.mobile;
    if (width < ResponsiveBreakpoints.tablet) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}
```

### API Client Configuration

```dart
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      if (kDebugMode) LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get<T>(path, queryParameters: queryParameters);
    return response.data!;
  }

  // POST, PUT, DELETE methods...
}
```

## Performance Optimization

### Backend Optimizations
1. **Query Optimization**
   - Use database indexes effectively
   - Implement pagination for all list endpoints
   - Use projections to fetch only required fields
   - Batch database operations where possible

2. **Caching Strategy**
   - Cache dashboard data (5-minute TTL)
   - Cache category list (1-hour TTL)
   - Cache user settings (30-minute TTL)
   - Invalidate on relevant mutations

3. **Async Processing**
   - Use @Async for email notifications
   - Background jobs for recurring transactions
   - Async import processing for large files

### Frontend Optimizations
1. **Widget Performance**
   - Use const constructors where possible
   - Implement widget keys for list items
   - Lazy load dashboard widgets
   - Virtual scrolling for transaction lists

2. **State Management**
   - Selective rebuilds with select()
   - Cache API responses in providers
   - Optimistic updates for better UX
   - Debounce search inputs

3. **Asset Optimization**
   - Use SVG for icons
   - Lazy load images
   - Implement image caching
   - Minimize bundle size

## Deployment Architecture

### Docker Configuration

```dockerfile
# Backend Dockerfile
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /app
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN ./mvnw dependency:go-offline
COPY src src
RUN ./mvnw package -DskipTests

FROM eclipse-temurin:25-jre-alpine
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: everything_app
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build: ./backend
    environment:
      SPRING_PROFILES_ACTIVE: prod
      DB_HOST: postgres
      DB_NAME: everything_app
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
    ports:
      - "8080:8080"
    depends_on:
      - postgres

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend

volumes:
  postgres_data:
```

## Testing Strategy

### Backend Testing
```java
// Unit Test Example
@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {
    @Mock
    private TransactionRepository repository;

    @InjectMocks
    private TransactionService service;

    @Test
    void createTransaction_ShouldUpdateAccountBalance() {
        // Given
        var transaction = createTestTransaction();
        when(repository.save(any())).thenReturn(transaction);

        // When
        var result = service.createTransaction(transaction);

        // Then
        assertThat(result).isNotNull();
        verify(accountService).updateBalance(any(), any());
    }
}

// Integration Test with TestContainers
@SpringBootTest
@Testcontainers
@AutoConfigureMockMvc
class AccountControllerIntegrationTest {
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

    @Test
    void getAccounts_ShouldReturnPagedResults() {
        // Test implementation
    }
}
```

### Frontend Testing
```dart
// Widget Test
testWidgets('Dashboard displays account summary', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardProvider.overrideWith((ref) async => testDashboardData),
      ],
      child: const MaterialApp(home: DashboardScreen()),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Net Worth'), findsOneWidget);
  expect(find.text('\$10,000.00'), findsOneWidget);
});

// Integration Test
testWidgets('Create transaction flow', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Navigate to transaction screen
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Fill form
  await tester.enterText(find.byKey(Key('amount_field')), '50.00');
  await tester.tap(find.text('Save'));

  // Verify
  expect(find.text('Transaction created'), findsOneWidget);
});
```

## Monitoring & Observability

### Spring Boot Actuator Configuration
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: ${spring.application.name}
```

### Logging Strategy
```java
@Slf4j
@Aspect
@Component
public class LoggingAspect {

    @Around("@annotation(Loggable)")
    public Object logExecutionTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long startTime = System.currentTimeMillis();

        Object result = joinPoint.proceed();

        long endTime = System.currentTimeMillis();
        log.info("Method {} executed in {} ms",
            joinPoint.getSignature().getName(),
            endTime - startTime);

        return result;
    }
}
```

## Security Considerations

1. **Authentication & Authorization**
   - JWT tokens with 15-minute expiry
   - Refresh tokens with rotation
   - Role-based access control (ADMIN, FAMILY_MEMBER)
   - Rate limiting on auth endpoints

2. **Data Protection**
   - AES-256 encryption at rest
   - TLS 1.3 for data in transit
   - Sensitive data masking in logs
   - GDPR-compliant data handling

3. **Input Validation**
   - Bean Validation on DTOs
   - SQL injection prevention via JPA
   - XSS prevention in Flutter
   - File upload restrictions

4. **Audit Trail**
   - All financial operations logged
   - User actions tracked
   - IP address and user agent recorded
   - Immutable audit log

## Migration Strategy

### Database Migrations (Flyway)
```sql
-- V1__initial_schema.sql
-- V2__create_accounts.sql
-- V3__create_transactions.sql
-- V4__create_budgets.sql
-- V5__add_recurring_transactions.sql
-- V6__add_import_tables.sql
```

### API Versioning
- URL path versioning: `/api/v1/`, `/api/v2/`
- Deprecation notices in headers
- Backward compatibility for 2 versions
- Migration guides for breaking changes

## Documentation

### API Documentation (OpenAPI 3.0)
- Auto-generated from annotations
- Available at `/swagger-ui.html`
- Includes request/response examples
- Authentication requirements specified

### Architecture Decision Records (ADRs)
1. ADR-001: Use Modular Monolith Architecture
2. ADR-002: Choose PostgreSQL for Financial Data
3. ADR-003: Implement JWT Authentication
4. ADR-004: Use Riverpod for State Management
5. ADR-005: Adopt Clean Architecture Pattern

## Next Steps

1. **Implementation Priority**
   - Set up development environment
   - Initialize Spring Boot project with dependencies
   - Create database schema with Flyway
   - Implement authentication module
   - Build Flutter project structure

2. **Technical Spikes Needed**
   - CSV/OFX parsing library evaluation
   - Performance testing of dashboard queries
   - Flutter web vs desktop platform differences
   - Optimal widget grid implementation

3. **Risk Mitigation**
   - Plan for concurrent user edits
   - Handle network disconnections gracefully
   - Implement data consistency checks
   - Design for horizontal scaling