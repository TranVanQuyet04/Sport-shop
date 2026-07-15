package org.example.service;

import org.example.dto.response.PaymentResponse;

import jakarta.servlet.http.HttpServletRequest;

public interface PaymentService {
    PaymentResponse createVnPayPayment(HttpServletRequest request, Long orderId);
}