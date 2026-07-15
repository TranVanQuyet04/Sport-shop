package org.example.repository;

import org.example.model.UserAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserAddressRepository extends JpaRepository<UserAddress, Long> {
    List<UserAddress> findAllByUserId(Long userId);
    UserAddress findByIdAndUserId(Long id, Long userId);
}
