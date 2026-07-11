package com.team6.ecommercesystem.service;

import com.team6.ecommercesystem.dto.response.DashboardReportResponse;
import com.team6.ecommercesystem.model.Order;
import com.team6.ecommercesystem.model.enums.OrderStatus;
import com.team6.ecommercesystem.repository.OrderRepository;
import com.team6.ecommercesystem.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ReportService {
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;

    public DashboardReportResponse getDashboardReport(LocalDateTime startDate, LocalDateTime endDate) {
        if (startDate == null || endDate == null) {
            throw new IllegalArgumentException("Ngày bắt đầu và ngày kết thúc không được để trống");
        }
        if (startDate.isAfter(endDate)) {
            throw new IllegalArgumentException("Ngày bắt đầu không được lớn hơn ngày kết thúc");
        }

        BigDecimal revenue = orderRepository.sumRevenueByDateRange(startDate, endDate);
        if (revenue == null) {
            revenue = BigDecimal.ZERO;
        }

        Long orders = orderRepository.countOrdersByDateRange(startDate, endDate);
        Long pending = orderRepository.countPendingOrders(startDate, endDate);
        Long users = userRepository.countNewUsers(startDate, endDate);

        long daysBetween = ChronoUnit.DAYS.between(startDate.toLocalDate(), endDate.toLocalDate()) + 1;
        if (daysBetween <= 0) {
            daysBetween = 7;
        }
        LocalDateTime startDatePrev = startDate.minusDays(daysBetween);
        LocalDateTime endDatePrev = startDate.minusNanos(1);

        List<Order> currentOrders = orderRepository.findAllOrdersByDateRange(startDate, endDate);
        List<Order> prevOrders = orderRepository.findAllOrdersByDateRange(startDatePrev, endDatePrev);

        List<DashboardReportResponse.DailyRevenueResponse> dailyList = new ArrayList<>();
        String[] labels = {"T2", "T3", "T4", "T5", "T6", "T7", "CN"};
        String[] fullLabels = {"Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"};

        for (int i = 1; i <= 7; i++) {
            final int dayWeekVal = i;

            BigDecimal currentRevenue = currentOrders.stream()
                    .filter(o -> o.getStatus() == OrderStatus.COMPLETED)
                    .filter(o -> o.getOrderDate().getDayOfWeek().getValue() == dayWeekVal)
                    .map(Order::getTotalAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal prevRevenue = prevOrders.stream()
                    .filter(o -> o.getStatus() == OrderStatus.COMPLETED)
                    .filter(o -> o.getOrderDate().getDayOfWeek().getValue() == dayWeekVal)
                    .map(Order::getTotalAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            long ordersCount = currentOrders.stream()
                    .filter(o -> o.getOrderDate().getDayOfWeek().getValue() == dayWeekVal)
                    .count();

            dailyList.add(DashboardReportResponse.DailyRevenueResponse.builder()
                    .dayOfWeek(fullLabels[i - 1])
                    .dateStr(labels[i - 1])
                    .revenueCurrent(currentRevenue)
                    .revenuePrevious(prevRevenue)
                    .ordersCount(ordersCount)
                    .build());
        }

        return DashboardReportResponse.builder()
                .totalRevenue(revenue)
                .totalOrders(orders)
                .pendingOrders(pending)
                .newUsers(users)
                .dailyRevenues(dailyList)
                .build();
    }
}
