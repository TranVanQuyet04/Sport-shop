package org.example.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "order_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private Order order;

    @Column(name = "variant_id", nullable = false)
    private Long variantId;
    private String productName;
    private String size;
    private String color;
    private String variantImage;

    private Integer quantity;

    // Lưu giá tại thời điểm mua (đề phòng giá sản phẩm thay đổi sau này)
    private BigDecimal price;
}
