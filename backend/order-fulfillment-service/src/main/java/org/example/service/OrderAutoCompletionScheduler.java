package org.example.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.model.Order;
import org.example.model.enums.OrderStatus;
import org.example.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class OrderAutoCompletionScheduler {
    private final OrderRepository orderRepository;

    @Value("${orders.auto-complete-after-days:7}")
    private long autoCompleteAfterDays;

    @Scheduled(cron = "${orders.auto-complete-cron:0 0 * * * *}")
    @Transactional
    public void completeDeliveredOrders() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime cutoff = now.minusDays(autoCompleteAfterDays);
        List<Order> orders = orderRepository.findDeliveredOrdersAwaitingConfirmation(cutoff);
        for (Order order : orders) {
            order.setStatus(OrderStatus.COMPLETED);
            order.setCompletedAt(now);
        }
        if (!orders.isEmpty()) {
            orderRepository.saveAll(orders);
            log.info("Automatically completed {} delivered orders after {} days",
                    orders.size(), autoCompleteAfterDays);
        }
    }
}
