package org.example.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

import java.util.List;

@Data
@Builder
public class DashboardReportResponse {
    private BigDecimal totalRevenue;
    private Long totalOrders;
    private Long newUsers;
    private Long pendingOrders;
    private List<DailyRevenueResponse> dailyRevenues;

    @Data
    @Builder
    @lombok.AllArgsConstructor
    @lombok.NoArgsConstructor
    public static class DailyRevenueResponse {
        private String dayOfWeek;
        private String dateStr;
        private BigDecimal revenueCurrent;
        private BigDecimal revenuePrevious;
        private Long ordersCount;
    }
}
