package com.caioniehues.app;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@SpringBootTest
@Testcontainers
@Import(TestContainersConfiguration.class)
class AppApplicationTests {

	@Container
	static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
		.withDatabaseName("testdb")
		.withUsername("test")
		.withPassword("test");

	@DynamicPropertySource
	static void properties(DynamicPropertyRegistry registry) {
		registry.add("spring.datasource.url", postgres::getJdbcUrl);
		registry.add("spring.datasource.username", postgres::getUsername);
		registry.add("spring.datasource.password", postgres::getPassword);
		registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
		registry.add("spring.liquibase.enabled", () -> "false");
		registry.add("spring.security.jwt.secret", () -> "test-secret-key-for-testing-purposes-only-minimum-256-bits");
	}

	@Test
	@DisplayName("Should load application context")
	void contextLoads() {
		// This test verifies that the Spring Boot application context loads successfully
		// with all beans properly configured
	}
}
