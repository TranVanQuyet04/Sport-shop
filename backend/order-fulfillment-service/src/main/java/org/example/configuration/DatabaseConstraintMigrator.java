package org.example.configuration;

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
        removeCrossServiceForeignKeys();
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

    private void removeCrossServiceForeignKeys() {
        dropForeignKeys("orders", "user_id");
        dropForeignKeys("carts", "user_id");
        dropForeignKeys("work_shifts", "user_id");
        dropForeignKeys("leave_requests", "user_id");
        dropForeignKeys("leave_requests", "decided_by");
        dropForeignKeys("order_assignments", "staff_id");
        dropForeignKeys("order_assignments", "assigned_by");
        dropForeignKeys("delivery_reports", "reported_by");
        dropForeignKeys("cart_items", "variant_id");
        dropForeignKeys("order_items", "variant_id");
    }

    private void dropForeignKeys(String table, String column) {
        try {
            var constraints = jdbcTemplate.queryForList("""
                    SELECT tc.constraint_name
                    FROM information_schema.table_constraints tc
                    JOIN information_schema.key_column_usage kcu
                      ON tc.constraint_name = kcu.constraint_name
                     AND tc.constraint_schema = kcu.constraint_schema
                    WHERE tc.constraint_type = 'FOREIGN KEY'
                      AND tc.table_schema = current_schema()
                      AND tc.table_name = ?
                      AND kcu.column_name = ?
                    """, String.class, table, column);
            for (String constraint : constraints) {
                jdbcTemplate.execute("ALTER TABLE \"" + table + "\" DROP CONSTRAINT IF EXISTS \""
                        + constraint.replace("\"", "\"\"") + "\"");
                log.info("Removed cross-service foreign key {}.{} ({})", table, column, constraint);
            }
        } catch (Exception error) {
            log.warn("Could not remove foreign key for {}.{}: {}", table, column, error.getMessage());
        }
    }
}
