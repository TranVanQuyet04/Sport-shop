package org.example.repository;

import org.example.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByUserIdOrderByOrderDateDesc(Long userId);

    // TÃ­nh tá»•ng doanh thu, chá»‰ tÃ­nh Ä‘Æ¡n COMPLETED.
    @Query("SELECT SUM(o.totalAmount) FROM Order o WHERE o.status = 'COMPLETED' AND o.orderDate >= :startDate AND o.orderDate <= :endDate")
    BigDecimal sumRevenueByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    // Äáº¿m tá»•ng sá»‘ Ä‘Æ¡n hÃ ng trong khoáº£ng thá»i gian.
    @Query("SELECT COUNT(o) FROM Order o WHERE o.orderDate >= :startDate AND o.orderDate <= :endDate")
    Long countOrdersByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    // Äáº¿m sá»‘ Ä‘Æ¡n Ä‘ang chá» xá»­ lÃ½.
    @Query("SELECT COUNT(o) FROM Order o WHERE o.status = 'PENDING' AND o.orderDate >= :startDate AND o.orderDate <= :endDate")
    Long countPendingOrders(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query("SELECT o FROM Order o WHERE o.orderDate >= :startDate AND o.orderDate <= :endDate")
    List<Order> findAllOrdersByDateRange(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);
}
