package com.caioniehues.app.domain.user;

import com.caioniehues.app.domain.common.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.Instant;

@Entity
@Table(name = "token_blacklist", indexes = {
    @Index(name = "idx_token_blacklist_jti", columnList = "jti"),
    @Index(name = "idx_token_blacklist_expires_at", columnList = "expires_at")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString
public class TokenBlacklist extends BaseEntity {

    @NotBlank
    @Column(unique = true, nullable = false)
    private String jti;  // JWT ID from the token

    @NotNull
    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "blacklisted_at", nullable = false)
    private Instant blacklistedAt;

    @Column(length = 500)
    private String reason;

    @PrePersist
    protected void onCreate() {
        if (blacklistedAt == null) {
            blacklistedAt = Instant.now();
        }
    }

    /**
     * Check if this blacklist entry is still relevant (not expired)
     */
    public boolean isActive() {
        return Instant.now().isBefore(expiresAt);
    }
}