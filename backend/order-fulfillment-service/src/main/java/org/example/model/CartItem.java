package org.example.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "cart_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CartItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cart_id")
    private Cart cart;

    @Column(name = "variant_id", nullable = false)
    private Long variantId;
    private String productName;
    private String size;
    private String color;
    private java.math.BigDecimal unitPrice;
    private String imageUrl;
    private Integer availableStock;

    private Integer quantity;
}
