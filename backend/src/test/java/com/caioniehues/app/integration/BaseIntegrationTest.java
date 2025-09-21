package com.caioniehues.app.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import io.restassured.RestAssured;
import io.restassured.config.ObjectMapperConfig;
import io.restassured.config.RestAssuredConfig;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@Testcontainers
@ActiveProfiles("test")
@TestPropertySource(properties = {
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "spring.liquibase.enabled=false",
    "logging.level.org.springframework.security=DEBUG",
    "logging.level.com.caioniehues.app=DEBUG"
})
@Transactional
public abstract class BaseIntegrationTest {

    @Container
    @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
        .withDatabaseName("testdb")
        .withUsername("testuser")
        .withPassword("testpass")
        .withInitScript("test-init.sql");

    @LocalServerPort
    protected int port;

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected ObjectMapper objectMapper;

    @Autowired
    protected JdbcTemplate jdbcTemplate;

    @Autowired
    protected AuthenticationManager authenticationManager;

    @Autowired
    protected UserDetailsService userDetailsService;

    @BeforeEach
    void baseSetUp() {
        RestAssured.port = port;
        RestAssured.config = RestAssuredConfig.config()
            .objectMapperConfig(ObjectMapperConfig.objectMapperConfig()
                .jackson2ObjectMapperFactory((cls, charset) -> objectMapper));

        cleanupTestData();
    }

    protected void cleanupTestData() {
        // Clean up test data in order to respect foreign key constraints
        jdbcTemplate.execute("DELETE FROM token_blacklist");
        jdbcTemplate.execute("DELETE FROM refresh_tokens");
        jdbcTemplate.execute("DELETE FROM users");

        // Reset sequences
        jdbcTemplate.execute("ALTER SEQUENCE IF EXISTS users_id_seq RESTART WITH 1");
        jdbcTemplate.execute("ALTER SEQUENCE IF EXISTS refresh_tokens_id_seq RESTART WITH 1");
        jdbcTemplate.execute("ALTER SEQUENCE IF EXISTS token_blacklist_id_seq RESTART WITH 1");
    }

    protected String toJson(Object object) throws Exception {
        return objectMapper.writeValueAsString(object);
    }

    protected <T> T fromJson(String json, Class<T> clazz) throws Exception {
        return objectMapper.readValue(json, clazz);
    }

    protected String getBaseUrl() {
        return "http://localhost:" + port;
    }

    protected String getApiBaseUrl() {
        return getBaseUrl() + "/api/v1";
    }
}