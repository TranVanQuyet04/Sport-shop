package org.example.service;

import org.example.dto.request.AddressRequest;
import org.example.dto.response.AddressResponse;
import org.example.model.User;

import java.util.List;

public interface AddressService {
    User getCurrentUser();
    List<AddressResponse> getMyAddresses();
    AddressResponse createAddress(AddressRequest request);
    AddressResponse updateAddress(Long id, AddressRequest request);
    void deleteAddress(Long id);
    void setDefault(Long id);
}
