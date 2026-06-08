package com.team6.ecommercesystem.seeder;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {
    private final RoleSeeder roleSeeder;
    private final UserSeeder userSeeder;

    @Override
    @Transactional
    public void run(String... args) {
        roleSeeder.seed();
        userSeeder.seed();
    }
}
