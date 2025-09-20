package com.caioniehues.app.domain.common;

import com.caioniehues.app.domain.user.User;
import com.fasterxml.jackson.databind.JsonNode;
import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.hibernate.annotations.Type;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "event_store")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(exclude = "user")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NotNull
    @Column(name = "aggregate_id", nullable = false)
    private UUID aggregateId;

    @NotBlank
    @Column(name = "aggregate_type", nullable = false, length = 100)
    private String aggregateType;

    @NotBlank
    @Column(name = "event_type", nullable = false, length = 100)
    private String eventType;

    @NotNull
    @Column(name = "event_version", nullable = false)
    private Integer eventVersion;

    @NotNull
    @Type(JsonType.class)
    @Column(name = "event_data", columnDefinition = "jsonb", nullable = false)
    private JsonNode eventData;

    @Type(JsonType.class)
    @Column(name = "metadata", columnDefinition = "jsonb")
    private JsonNode metadata;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "created_at", nullable = false, updatable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }
}