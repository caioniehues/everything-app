/**
 * Everything App - Family Financial Management Platform
 *
 * <p>This application helps households track expenses, manage budgets, and achieve
 * financial goals together. Built using Clean Architecture principles with Domain-Driven Design.</p>
 *
 * <h2>Architecture Layers</h2>
 * <ul>
 *   <li>{@link com.caioniehues.app.domain} - Business logic and entities (no external dependencies)</li>
 *   <li>{@link com.caioniehues.app.application} - Use cases and application services</li>
 *   <li>{@link com.caioniehues.app.infrastructure} - External concerns (database, APIs)</li>
 *   <li>{@link com.caioniehues.app.presentation} - REST controllers and API endpoints</li>
 * </ul>
 *
 * <h2>Key Features</h2>
 * <ul>
 *   <li>Multi-user household management</li>
 *   <li>Transaction tracking and categorization</li>
 *   <li>Budget planning and monitoring</li>
 *   <li>Financial goal setting</li>
 *   <li>Real-time dashboard analytics</li>
 * </ul>
 *
 * <h2>Technology Stack</h2>
 * <ul>
 *   <li>Spring Boot 3.5.6</li>
 *   <li>Java 25 with Virtual Threads</li>
 *   <li>PostgreSQL 15</li>
 *   <li>JWT Authentication</li>
 *   <li>Liquibase migrations</li>
 * </ul>
 *
 * <h2>BMAD Compliance</h2>
 * <p>This project follows BMAD (Business Modeling Agile Development) methodology with:</p>
 * <ul>
 *   <li>80% minimum test coverage requirement</li>
 *   <li>TDD (Test-Driven Development) approach</li>
 *   <li>Complete documentation for all public APIs</li>
 *   <li>Clean Architecture compliance</li>
 * </ul>
 *
 * @author Caio Niehues
 * @version 1.0.0
 * @since 2025-09-21
 */
package com.caioniehues.app;