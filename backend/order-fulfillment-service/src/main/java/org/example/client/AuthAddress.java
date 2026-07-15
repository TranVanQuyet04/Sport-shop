package org.example.client;

public record AuthAddress(Long id, String recipientName, String phoneNumber, String city,
                          String district, String ward, String street, Boolean isDefault,
                          String fullAddress) {
}
