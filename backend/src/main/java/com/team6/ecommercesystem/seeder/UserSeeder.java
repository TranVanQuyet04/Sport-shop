package com.team6.ecommercesystem.seeder;

import com.team6.ecommercesystem.model.Role;
import com.team6.ecommercesystem.model.User;
import com.team6.ecommercesystem.repository.RoleRepository;
import com.team6.ecommercesystem.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class UserSeeder {
    private static final String DEFAULT_PASSWORD = "Password123";

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    public void seed() {
        createOrRepairUser(
                "Admin User",
                "admin@example.com",
                "0123456789",
                "ADMIN"
        );
        createOrRepairUser(
                "Shop Staff User",
                "shopstaff@example.com",
                "0323456789",
                "SHOP_STAFF"
        );
        createOrRepairUser(
                "Shipper User",
                "shipper@example.com",
                "0333456789",
                "SHIPPER"
        );
        createOrRepairUser(
                "Member User",
                "member@example.com",
                "0987654321",
                "MEMBER"
        );
    }

    private void createOrRepairUser(String fullName, String email, String phoneNumber, String roleCode) {
        Role role = roleRepository.findByRoleCode(roleCode)
                .orElseThrow(() -> new IllegalStateException("Missing role: " + roleCode));

        userRepository.findByEmail(email)
                .map(user -> repairSeedUser(user, fullName, phoneNumber, role))
                .orElseGet(() -> userRepository.save(User.builder()
                        .fullName(fullName)
                        .email(email)
                        .phoneNumber(phoneNumber)
                        .password(passwordEncoder.encode(DEFAULT_PASSWORD))
                        .status(true)
                        .role(role)
                        .failedLoginAttempts(0)
                        .lastPasswordChangeDate(LocalDateTime.now())
                        .lastLoginDate(LocalDateTime.now())
                        .build()));
    }

    private User repairSeedUser(User user, String fullName, String phoneNumber, Role role) {
        boolean changed = false;

        if (!passwordEncoder.matches(DEFAULT_PASSWORD, user.getPassword())) {
            user.setPassword(passwordEncoder.encode(DEFAULT_PASSWORD));
            user.setLastPasswordChangeDate(LocalDateTime.now());
            changed = true;
        }
        if (!Boolean.TRUE.equals(user.getStatus())) {
            user.setStatus(true);
            changed = true;
        }
        if (user.getLockTime() != null) {
            user.setLockTime(null);
            changed = true;
        }
        if (user.getFailedLoginAttempts() == null || user.getFailedLoginAttempts() != 0) {
            user.setFailedLoginAttempts(0);
            changed = true;
        }
        if (user.getRole() == null || !role.getRoleCode().equals(user.getRole().getRoleCode())) {
            user.setRole(role);
            changed = true;
        }
        if (user.getFullName() == null || user.getFullName().isBlank()) {
            user.setFullName(fullName);
            changed = true;
        }
        if (user.getPhoneNumber() == null || user.getPhoneNumber().isBlank()) {
            user.setPhoneNumber(phoneNumber);
            changed = true;
        }

        return changed ? userRepository.save(user) : user;
    }
}
