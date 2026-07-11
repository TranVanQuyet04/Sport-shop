package com.team6.ecommercesystem.configuration;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DatabaseConstraintMigrator implements ApplicationRunner {
    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(ApplicationArguments args) {
        syncOrderStatusConstraint();
    }

    private void syncOrderStatusConstraint() {
        try {
            jdbcTemplate.execute("ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check");
            jdbcTemplate.execute("""
                    ALTER TABLE orders
                    ADD CONSTRAINT orders_status_check
                    CHECK (status IN (
                        'PENDING',
                        'CONFIRMED',
                        'PACKING',
                        'SHIPPED',
                        'COMPLETED',
                        'CANCELLED',
                        'PAID',
                        'SHIPPING',
                        'DELIVERED'
                    ))
                    """);
            log.info("Synchronized orders_status_check constraint with OrderStatus enum");
        } catch (Exception error) {
            log.warn("Could not synchronize orders_status_check constraint: {}", error.getMessage());
        }
    }
}
