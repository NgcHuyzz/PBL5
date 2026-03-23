package com.ice.pbl5.Util;

import com.ice.pbl5.Entity.Detection;
import com.ice.pbl5.Enum.DetectionStatus;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDateTime;
import java.util.UUID;

public class DetectionSpecification {
    public static Specification<Detection> hasSystemId(UUID systemId) {
        return (root, query, cb) ->
                systemId == null
                        ? null
                        : cb.equal(root.get("system").get("id"), systemId);
    }

    public static Specification<Detection> hasFruitType(String fruitType) {
        return (root, query, cb) ->
                (fruitType == null || fruitType.isBlank())
                        ? null
                        : cb.equal(root.get("fruitType"), fruitType);
    }

    public static Specification<Detection> hasStatus(DetectionStatus status) {
        return (root, query, cb) ->
                status == null
                        ? null
                        : cb.equal(root.get("status"), status);
    }

    public static Specification<Detection> createdFrom(LocalDateTime from) {
        return (root, query, cb) ->
                from == null
                        ? null
                        : cb.greaterThanOrEqualTo(root.get("createdAt"), from);
    }

    public static Specification<Detection> createdTo(LocalDateTime to) {
        return (root, query, cb) ->
                to == null
                        ? null
                        : cb.lessThanOrEqualTo(root.get("createdAt"), to);
    }
}
