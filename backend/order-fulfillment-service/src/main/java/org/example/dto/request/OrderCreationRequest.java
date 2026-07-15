package org.example.dto.request;

import org.example.model.enums.PaymentMethod;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class OrderCreationRequest {
    @NotNull(message = "Vui lÃ²ng chá»n Ä‘á»‹a chá»‰ giao hÃ ng")
    private Long addressId;

    @NotNull(message = "Vui lÃ²ng chá»n phÆ°Æ¡ng thá»©c thanh toÃ¡n")
    private PaymentMethod paymentMethod;

    private String note;
}
