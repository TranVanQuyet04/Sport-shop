package org.example.service;

import org.example.dto.request.SportRequest;
import org.example.dto.response.SportResponse;
import org.example.model.Sport;
import org.example.repository.SportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Transactional
public class SportServiceImpl implements SportService {

    private final SportRepository sportRepository;

    @Override
    @Transactional(readOnly = true)
    public List<SportResponse> getAllSport() {
        return sportRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    public SportResponse createSport(SportRequest request) {

        if (sportRepository.existsBySportName(request.getSportName())) {
            throw new RuntimeException("Sport Ä‘Ã£ tá»“n táº¡i");
        }

        Sport sport = Sport.builder()
                .sportName(request.getSportName())
                .description(request.getDescription())
                .build();

        return toResponse(sportRepository.save(sport));
    }

    @Override
    public SportResponse updateSport(Long id, SportRequest request) {

        Sport sport = sportRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("KhÃ´ng tÃ¬m tháº¥y sport"));

        sport.setSportName(request.getSportName());
        sport.setDescription(request.getDescription());

        return toResponse(sportRepository.save(sport));
    }

    @Override
    public SportResponse getSportById(Long id){
        Sport sport = sportRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("KhÃ´ng tÃ¬m tháº¥y sport"));
        return toResponse(sport);
    }

    @Override
    public void deleteSport(Long id) {

        Sport sport = sportRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("KhÃ´ng tÃ¬m tháº¥y sport"));

        // Náº¿u sport Ä‘ang Ä‘Æ°á»£c product sá»­ dá»¥ng thÃ¬ khÃ´ng cho xoÃ¡
        if (sport.getProducts() != null && !sport.getProducts().isEmpty()) {
            throw new RuntimeException("KhÃ´ng thá»ƒ xoÃ¡ sport Ä‘ang Ä‘Æ°á»£c sá»­ dá»¥ng");
        }

        sportRepository.delete(sport);
    }

    private SportResponse toResponse(Sport sport) {
        return SportResponse.builder()
                .id(sport.getId())
                .sportName(sport.getSportName())
                .description(sport.getDescription())
                .build();
    }
}
