package com.caioniehues.app.presentation.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.info.BuildProperties;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
public class HealthController {

    @Autowired(required = false)
    private BuildProperties buildProperties;

    @Autowired
    private DataSource dataSource;

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", Instant.now());

        // Add application info if available
        if (buildProperties != null) {
            Map<String, String> app = new HashMap<>();
            app.put("name", buildProperties.getName());
            app.put("version", buildProperties.getVersion());
            response.put("application", app);
        }

        // Check database connectivity
        Map<String, String> database = new HashMap<>();
        try (Connection connection = dataSource.getConnection()) {
            database.put("status", "UP");
            database.put("database", connection.getMetaData().getDatabaseProductName());
            database.put("version", connection.getMetaData().getDatabaseProductVersion());
        } catch (Exception e) {
            database.put("status", "DOWN");
            database.put("error", e.getMessage());
        }
        response.put("database", database);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/live")
    public ResponseEntity<Map<String, String>> liveness() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/ready")
    public ResponseEntity<Map<String, String>> readiness() {
        Map<String, String> response = new HashMap<>();

        // Check if database is accessible
        try (Connection connection = dataSource.getConnection()) {
            response.put("status", "UP");
        } catch (Exception e) {
            response.put("status", "DOWN");
            response.put("error", "Database not ready");
            return ResponseEntity.status(503).body(response);
        }

        return ResponseEntity.ok(response);
    }
}