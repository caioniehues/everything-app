package com.caioniehues.app.infrastructure.persistence;

import com.caioniehues.app.domain.user.TokenBlacklist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TokenBlacklistRepository extends JpaRepository<TokenBlacklist, UUID> {

    /**
     * Check if a token with given JTI is blacklisted
     */
    boolean existsByJti(String jti);

    /**
     * Find blacklist entry by JTI
     */
    Optional<TokenBlacklist> findByJti(String jti);

    /**
     * Delete expired blacklist entries (cleanup job)
     */
    @Modifying
    @Query("DELETE FROM TokenBlacklist t WHERE t.expiresAt < :now")
    int deleteExpiredEntries(Instant now);

    /**
     * Count active (non-expired) blacklist entries
     */
    @Query("SELECT COUNT(t) FROM TokenBlacklist t WHERE t.expiresAt >= :now")
    long countActiveEntries(Instant now);
}