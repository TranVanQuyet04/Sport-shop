package org.example.client;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.time.LocalDateTime;
import java.util.List;

@Component
@RequiredArgsConstructor
public class AuthServiceClient {
    private final HttpServletRequest request;

    @Value("${services.auth.base-url}")
    private String authBaseUrl;

    public AuthUser getUser(Long id) {
        return client().get().uri("/api/internal/users/{id}", id)
                .retrieve().body(AuthUser.class);
    }

    public AuthAddress getMyAddress(Long addressId) {
        List<AuthAddress> addresses = client().get().uri("/api/internal/users/me/addresses")
                .retrieve().body(new ParameterizedTypeReference<>() {});
        return addresses == null ? null : addresses.stream()
                .filter(address -> address.id().equals(addressId)).findFirst().orElse(null);
    }

    public long countUsers(LocalDateTime start, LocalDateTime end) {
        Long count = client().get().uri(builder -> builder.path("/api/internal/users/count")
                        .queryParam("start", start).queryParam("end", end).build())
                .retrieve().body(Long.class);
        return count == null ? 0 : count;
    }

    private RestClient client() {
        String authorization = request.getHeader(HttpHeaders.AUTHORIZATION);
        return RestClient.builder().baseUrl(authBaseUrl)
                .defaultHeader(HttpHeaders.AUTHORIZATION, authorization == null ? "" : authorization)
                .build();
    }
}
