package com.caioniehues.app.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import java.util.List;

@Configuration
@Profile({"dev", "development", "local"})
public class OpenApiConfig {

    @Value("${spring.application.name:Everything App}")
    private String applicationName;

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(apiInfo())
            .servers(servers())
            .components(components())
            .security(List.of(securityRequirement()));
    }

    private Info apiInfo() {
        return new Info()
            .title(applicationName + " API")
            .description("REST API for Everything App - Family Financial Management Platform")
            .version("1.0.0")
            .contact(new Contact()
                .name("Development Team")
                .email("dev@everything.app"))
            .license(new License()
                .name("Private License")
                .url("https://everything.app/license"));
    }

    private List<Server> servers() {
        Server localServer = new Server()
            .url("http://localhost:8080")
            .description("Local development server");

        Server dockerServer = new Server()
            .url("http://localhost:8080")
            .description("Docker container");

        return List.of(localServer, dockerServer);
    }

    private Components components() {
        return new Components()
            .addSecuritySchemes("bearer-jwt", bearerAuthScheme());
    }

    private SecurityScheme bearerAuthScheme() {
        return new SecurityScheme()
            .type(SecurityScheme.Type.HTTP)
            .scheme("bearer")
            .bearerFormat("JWT")
            .description("JWT Bearer Token Authentication. Use the login endpoint to obtain a token.");
    }

    private SecurityRequirement securityRequirement() {
        return new SecurityRequirement()
            .addList("bearer-jwt");
    }
}