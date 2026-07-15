package org.example.utils;

import org.example.dto.response.AddressResponse;
import org.example.model.UserAddress;

public class AddressMapper {
    public static AddressResponse toResponse(UserAddress address) {
        String fullAddr = String.format("%s, %s, %s, %s",
                address.getStreet(), address.getWard(), address.getDistrict(), address.getCity());

        return AddressResponse.builder()
                .id(address.getId())
                .recipientName(address.getRecipientName())
                .phoneNumber(address.getPhoneNumber())
                .city(address.getCity())
                .district(address.getDistrict())
                .ward(address.getWard())
                .street(address.getStreet())
                .isDefault(address.getIsDefault())
                .fullAddress(fullAddr)
                .build();
    }
}
