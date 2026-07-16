package org.example.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.example.dto.response.PaymentResponse;
import org.example.service.PaymentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/payment")
@RequiredArgsConstructor
@Tag(name = "Payment", description = "VNPay Integration")
public class PaymentController {
    private final PaymentService paymentService;

    @GetMapping("/create_payment/{orderId}")
    @Operation(summary = "Generate VNPay URL")
    public ResponseEntity<PaymentResponse> createPayment(HttpServletRequest request, @PathVariable Long orderId) {
        return ResponseEntity.ok(paymentService.createVnPayPayment(request, orderId));
    }

    @GetMapping("/vnpay_return")
    @Operation(summary = "VNPay browser return URL")
    public void vnpayReturn(HttpServletRequest request, HttpServletResponse response) throws IOException {
        PaymentService.PaymentResult result = paymentService.processVnPayResult(parameters(request), true);
        String status = result.valid() && result.successful() ? "success" : "failed";
        String orderId = result.orderId() == null ? "" : result.orderId().toString();
        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().write(paymentResultPage(status, orderId));
    }

    @GetMapping("/vnpay_ipn")
    @Operation(summary = "VNPay server-to-server payment notification")
    public ResponseEntity<Map<String, String>> vnpayIpn(HttpServletRequest request) {
        PaymentService.PaymentResult result = paymentService.processVnPayResult(parameters(request), true);
        if (!result.valid()) {
            String responseCode = switch (result.message()) {
                case "Order not found" -> "01";
                case "Amount does not match order", "Invalid amount" -> "04";
                default -> "97";
            };
            return ResponseEntity.ok(Map.of("RspCode", responseCode, "Message", result.message()));
        }
        return ResponseEntity.ok(Map.of("RspCode", "00", "Message", result.message()));
    }

    private Map<String, String> parameters(HttpServletRequest request) {
        Map<String, String> params = new HashMap<>();
        for (String name : Collections.list(request.getParameterNames())) {
            params.put(name, request.getParameter(name));
        }
        return params;
    }

    private String paymentResultPage(String status, String orderId) {
        boolean success = "success".equals(status);
        String title = success ? "Thanh toán thành công" : "Thanh toán chưa thành công";
        String color = success ? "#15803d" : "#b91c1c";
        return """
                <!doctype html><html lang="vi"><head><meta charset="utf-8">
                <meta name="viewport" content="width=device-width,initial-scale=1">
                <title>%s</title></head><body style="font-family:Arial,sans-serif;text-align:center;padding:48px 20px">
                <h1 style="color:%s">%s</h1><p>Đơn hàng #%s</p>
                <p>Bạn có thể đóng trang này và quay lại ứng dụng SportShop.</p>
                </body></html>
                """.formatted(title, color, title, orderId);
    }
}
