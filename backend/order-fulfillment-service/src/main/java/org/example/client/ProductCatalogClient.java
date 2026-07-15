package org.example.client;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
@RequiredArgsConstructor
public class ProductCatalogClient {
    private final HttpServletRequest request;

    @Value("${services.product-catalog.base-url}")
    private String baseUrl;

    public CatalogVariant getVariant(Long id) {
        return client().get().uri("/api/internal/variants/{id}", id)
                .retrieve().body(CatalogVariant.class);
    }

    public CatalogVariant reserve(Long id, int quantity) {
        return client().post().uri(builder -> builder.path("/api/internal/variants/{id}/reserve")
                        .queryParam("quantity", quantity).build(id))
                .retrieve().body(CatalogVariant.class);
    }

    private RestClient client() {
        String authorization = request.getHeader(HttpHeaders.AUTHORIZATION);
        return RestClient.builder().baseUrl(baseUrl)
                .defaultHeader(HttpHeaders.AUTHORIZATION, authorization == null ? "" : authorization)
                .build();
    }
}
