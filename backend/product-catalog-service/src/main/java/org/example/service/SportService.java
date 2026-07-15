package org.example.service;

import org.example.dto.request.SportRequest;
import org.example.dto.response.SportResponse;

import java.util.List;

public interface SportService {

    List<SportResponse> getAllSport();

    SportResponse createSport(SportRequest request);

    SportResponse updateSport(Long id, SportRequest request);

    SportResponse getSportById(Long id);

    void deleteSport(Long id);
}
