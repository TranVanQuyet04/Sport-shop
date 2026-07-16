package org.example.service;

import org.example.dto.response.PaymentResponse;

import jakarta.servlet.http.HttpServletRequest;

import java.util.Map;

public interface PaymentService {
    PaymentResponse createVnPayPayment(HttpServletRequest request, Long orderId);

    PaymentResult processVnPayResult(Map<String, String> params, boolean updateOrder);

    record PaymentResult(boolean valid, boolean successful, Long orderId, String message) {
    }
}
