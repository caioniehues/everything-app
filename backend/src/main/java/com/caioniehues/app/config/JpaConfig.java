package com.caioniehues.app.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Configuration
@EnableJpaRepositories(basePackages = "com.caioniehues.app.infrastructure.persistence")
@EnableJpaAuditing
@EnableTransactionManagement
public class JpaConfig {
}