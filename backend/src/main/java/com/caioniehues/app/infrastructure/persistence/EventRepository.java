package com.caioniehues.app.infrastructure.persistence;

import com.caioniehues.app.domain.common.Event;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
public interface EventRepository extends JpaRepository<Event, UUID> {

    List<Event> findByAggregateIdAndAggregateTypeOrderByEventVersion(UUID aggregateId, String aggregateType);

    List<Event> findByAggregateTypeOrderByCreatedAtDesc(String aggregateType);

    Page<Event> findByEventTypeOrderByCreatedAtDesc(String eventType, Pageable pageable);

    @Query("SELECT e FROM Event e WHERE e.createdAt >= :startDate AND e.createdAt < :endDate ORDER BY e.createdAt")
    List<Event> findEventsBetweenDates(Instant startDate, Instant endDate);

    @Query("SELECT e FROM Event e WHERE e.user.id = :userId ORDER BY e.createdAt DESC")
    Page<Event> findByUserId(UUID userId, Pageable pageable);

    @Query("SELECT MAX(e.eventVersion) FROM Event e WHERE e.aggregateId = :aggregateId AND e.aggregateType = :aggregateType")
    Integer findMaxEventVersion(UUID aggregateId, String aggregateType);

    long countByAggregateTypeAndCreatedAtAfter(String aggregateType, Instant after);
}