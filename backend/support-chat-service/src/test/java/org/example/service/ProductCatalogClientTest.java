package org.example.service;

import org.example.model.Product;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.ExpectedCount.once;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class ProductCatalogClientTest {
    private static final String CATALOG_URL = "http://catalog.test";

    private ProductCatalogClient client;
    private MockRestServiceServer server;

    @BeforeEach
    void setUp() {
        RestTemplate restTemplate = new RestTemplate();
        server = MockRestServiceServer.createServer(restTemplate);
        client = new ProductCatalogClient(restTemplate);
        ReflectionTestUtils.setField(client, "productCatalogUrl", CATALOG_URL);
    }

    @Test
    void loadsEveryProductAndVariantFromBulkCatalogSnapshot() {
        server.expect(once(), requestTo(CATALOG_URL + "/api/products/chat-catalog"))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess("""
                        [
                          {
                            "id": 1,
                            "productName": "Áo chạy bộ",
                            "description": "Thoáng khí",
                            "categoryName": "Áo thể thao",
                            "brandName": "Nike",
                            "sportName": "Chạy bộ",
                            "variants": [
                              {"id": 11, "sku": "AO-M", "size": "M", "color": "Đen", "price": 650000, "stockQuantity": 20},
                              {"id": 12, "sku": "AO-L", "size": "L", "color": "Trắng", "price": 650000, "stockQuantity": 15}
                            ]
                          },
                          {
                            "id": 2,
                            "productName": "Giày chạy bộ",
                            "description": "Đệm êm",
                            "categoryName": "Giày chạy bộ",
                            "brandName": "Nike",
                            "sportName": "Chạy bộ",
                            "variants": [
                              {"id": 21, "sku": "GIAY-42", "size": "42", "color": "Đen Trắng", "price": 3200000, "stockQuantity": 12}
                            ]
                          }
                        ]
                        """, MediaType.APPLICATION_JSON));

        List<Product> products = client.getProducts();

        assertThat(products).hasSize(2);
        assertThat(products).extracting(Product::getProductName)
                .containsExactly("Áo chạy bộ", "Giày chạy bộ");
        assertThat(products).flatExtracting(Product::getVariants).hasSize(3);
        assertThat(products.get(1).getSport().getSportName()).isEqualTo("Chạy bộ");
        server.verify();
    }

    @Test
    void fallsBackToLegacyDetailEndpointsDuringRollingDeployment() {
        server.expect(once(), requestTo(CATALOG_URL + "/api/products/chat-catalog"))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withStatus(HttpStatus.NOT_FOUND));
        server.expect(once(), requestTo(CATALOG_URL + "/api/products"))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess("[{\"id\":2}]", MediaType.APPLICATION_JSON));
        server.expect(once(), requestTo(CATALOG_URL + "/api/products/2"))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess("""
                        {
                          "id": 2,
                          "productName": "Giày chạy bộ",
                          "categoryName": "Giày chạy bộ",
                          "brandName": "Nike",
                          "sportName": "Chạy bộ",
                          "variants": [
                            {"id": 21, "sku": "GIAY-42", "size": "42", "color": "Đen", "price": 3200000, "stockQuantity": 12}
                          ]
                        }
                        """, MediaType.APPLICATION_JSON));

        List<Product> products = client.getProducts();

        assertThat(products).singleElement()
                .satisfies(product -> {
                    assertThat(product.getId()).isEqualTo(2L);
                    assertThat(product.getVariants()).hasSize(1);
                });
        server.verify();
    }
}
