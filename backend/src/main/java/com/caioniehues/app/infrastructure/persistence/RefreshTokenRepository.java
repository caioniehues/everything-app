package com.caioniehues.app.infrastructure.persistence;

import com.caioniehues.app.domain.user.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByToken(String token);

    @Query("SELECT rt FROM RefreshToken rt JOIN FETCH rt.user WHERE rt.token = :token")
    Optional<RefreshToken> findByTokenWithUser(String token);

    @Modifying
    @Query("DELETE FROM RefreshToken rt WHERE rt.user.id = :userId")
    void deleteAllByUserId(UUID userId);

    @Modifying
    @Query("DELETE FROM RefreshToken rt WHERE rt.expiresAt < :now")
    void deleteExpiredTokens(Instant now);

    @Modifying
    @Query("UPDATE RefreshToken rt SET rt.revoked = true, rt.revokedAt = :now WHERE rt.user.id = :userId AND rt.revoked = false")
    void revokeAllValidTokensForUser(UUID userId, Instant now);

    long countByUserIdAndRevokedFalseAndExpiresAtAfter(UUID userId, Instant now);
}