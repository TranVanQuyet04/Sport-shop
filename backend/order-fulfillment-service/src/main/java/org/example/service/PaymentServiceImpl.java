package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.example.configuration.PaymentConfig;
import org.example.dto.response.PaymentResponse;
import org.example.model.Order;
import org.example.model.enums.OrderStatus;
import org.example.model.enums.PaymentMethod;
import org.example.repository.OrderRepository;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.SortedMap;
import java.util.StringJoiner;
import java.util.TreeMap;

@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {
    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter VNPAY_DATE = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    private static final int TRANSACTION_SUFFIX_LENGTH = 13;

    private final PaymentConfig paymentConfig;
    private final OrderRepository orderRepository;

    @Override
    @Transactional(readOnly = true)
    public PaymentResponse createVnPayPayment(HttpServletRequest request, Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (!order.getUserId().equals(getCurrentUserId())) {
            throw new RuntimeException("Order not found");
        }
        if (order.getPaymentMethod() != PaymentMethod.VNPAY) {
            throw new IllegalStateException("Order is not configured for VNPay payment");
        }
        if (order.getStatus() != OrderStatus.PENDING) {
            throw new IllegalStateException("Order is not awaiting payment");
        }
        validateConfiguration();

        long amount = order.getTotalAmount().multiply(new BigDecimal("100")).longValueExact();
        String transactionReference = orderId + String.valueOf(Instant.now().toEpochMilli());
        var createdAt = java.time.ZonedDateTime.now(VIETNAM_ZONE);

        SortedMap<String, String> params = new TreeMap<>();
        params.put("vnp_Version", paymentConfig.getVnp_Version());
        params.put("vnp_Command", paymentConfig.getVnp_Command());
        params.put("vnp_TmnCode", paymentConfig.getVnp_TmnCode());
        params.put("vnp_Amount", String.valueOf(amount));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", transactionReference);
        params.put("vnp_OrderInfo", "Thanh toan don hang " + orderId);
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", paymentConfig.getVnp_ReturnUrl());
        params.put("vnp_IpAddr", getIpAddress(request));
        params.put("vnp_CreateDate", VNPAY_DATE.format(createdAt));
        params.put("vnp_ExpireDate", VNPAY_DATE.format(createdAt.plusMinutes(15)));

        String query = canonicalData(params);
        String secureHash = PaymentConfig.hmacSHA512(paymentConfig.getVnp_HashSecret(), query);
        return PaymentResponse.builder()
                .status("OK")
                .message("Successfully generated payment URL")
                .paymentUrl(paymentConfig.getVnp_PayUrl() + "?" + query + "&vnp_SecureHash=" + secureHash)
                .build();
    }

    @Override
    @Transactional
    public PaymentResult processVnPayResult(Map<String, String> params, boolean updateOrder) {
        String receivedHash = params.get("vnp_SecureHash");
        if (receivedHash == null || !receivedHash.equalsIgnoreCase(signCallback(params))) {
            return new PaymentResult(false, false, null, "Invalid signature");
        }

        Long orderId;
        try {
            orderId = extractOrderId(params.get("vnp_TxnRef"));
        } catch (RuntimeException exception) {
            return new PaymentResult(false, false, null, "Invalid transaction reference");
        }

        Order order = orderRepository.findById(orderId).orElse(null);
        if (order == null) {
            return new PaymentResult(false, false, orderId, "Order not found");
        }

        long receivedAmount;
        try {
            receivedAmount = Long.parseLong(params.getOrDefault("vnp_Amount", ""));
        } catch (NumberFormatException exception) {
            return new PaymentResult(false, false, orderId, "Invalid amount");
        }
        long expectedAmount = order.getTotalAmount().multiply(new BigDecimal("100")).longValueExact();
        if (receivedAmount != expectedAmount) {
            return new PaymentResult(false, false, orderId, "Amount does not match order");
        }

        boolean successful = "00".equals(params.get("vnp_ResponseCode"))
                && "00".equals(params.get("vnp_TransactionStatus"));
        if (updateOrder && successful && order.getStatus() == OrderStatus.PENDING) {
            order.setStatus(OrderStatus.PAID);
            orderRepository.save(order);
        }
        return new PaymentResult(true, successful, orderId,
                successful ? "Payment successful" : "Payment was not successful");
    }

    private String signCallback(Map<String, String> input) {
        SortedMap<String, String> fields = new TreeMap<>();
        input.forEach((key, value) -> {
            if (key.startsWith("vnp_") && !"vnp_SecureHash".equals(key)
                    && !"vnp_SecureHashType".equals(key) && value != null && !value.isEmpty()) {
                fields.put(key, value);
            }
        });
        return PaymentConfig.hmacSHA512(paymentConfig.getVnp_HashSecret(), canonicalData(fields));
    }

    private String canonicalData(Map<String, String> fields) {
        StringJoiner result = new StringJoiner("&");
        fields.forEach((key, value) -> {
            if (value != null && !value.isEmpty()) {
                result.add(encode(key) + "=" + encode(value));
            }
        });
        return result.toString();
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.US_ASCII);
    }

    private Long extractOrderId(String transactionReference) {
        if (transactionReference == null || transactionReference.length() <= TRANSACTION_SUFFIX_LENGTH) {
            throw new IllegalArgumentException("Invalid transaction reference");
        }
        return Long.parseLong(transactionReference.substring(
                0, transactionReference.length() - TRANSACTION_SUFFIX_LENGTH));
    }

    private Long getCurrentUserId() {
        return Long.parseLong(SecurityContextHolder.getContext().getAuthentication().getName());
    }

    private String getIpAddress(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private void validateConfiguration() {
        if (isBlank(paymentConfig.getVnp_PayUrl()) || isBlank(paymentConfig.getVnp_ReturnUrl())
                || isBlank(paymentConfig.getVnp_TmnCode()) || isBlank(paymentConfig.getVnp_HashSecret())) {
            throw new IllegalStateException("VNPay configuration is incomplete");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank() || value.contains("CHANGE_ME");
    }
}
