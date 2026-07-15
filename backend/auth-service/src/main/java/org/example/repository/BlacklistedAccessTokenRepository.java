package org.example.repository;

import org.example.model.BlackListedAccessToken;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BlacklistedAccessTokenRepository extends CrudRepository<BlackListedAccessToken, String> {
}

