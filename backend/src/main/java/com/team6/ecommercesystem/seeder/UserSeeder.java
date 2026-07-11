package com.team6.ecommercesystem.seeder;

import com.team6.ecommercesystem.model.Role;
import com.team6.ecommercesystem.model.User;
import com.team6.ecommercesystem.repository.RoleRepository;
import com.team6.ecommercesystem.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class UserSeeder {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${seed.user.default-password}")
    private String defaultPassword;

    @Value("${seed.user.admin.full-name}")
    private String adminFullName;

    @Value("${seed.user.admin.email}")
    private String adminEmail;

    @Value("${seed.user.admin.phone}")
    private String adminPhone;

    @Value("${seed.user.shop-staff.full-name}")
    private String shopStaffFullName;

    @Value("${seed.user.shop-staff.email}")
    private String shopStaffEmail;

    @Value("${seed.user.shop-staff.phone}")
    private String shopStaffPhone;

    @Value("${seed.user.shipper.full-name}")
    private String shipperFullName;

    @Value("${seed.user.shipper.email}")
    private String shipperEmail;

    @Value("${seed.user.shipper.phone}")
    private String shipperPhone;

    @Value("${seed.user.member.full-name}")
    private String memberFullName;

    @Value("${seed.user.member.email}")
    private String memberEmail;

    @Value("${seed.user.member.phone}")
    private String memberPhone;

    public void seed() {
        createOrRepairUser(
                adminFullName,
                adminEmail,
                adminPhone,
                "ADMIN"
        );
        createOrRepairUser(
                shopStaffFullName,
                shopStaffEmail,
                shopStaffPhone,
                "SHOP_STAFF"
        );
        createOrRepairUser(
                shipperFullName,
                shipperEmail,
                shipperPhone,
                "SHIPPER"
        );
        createOrRepairUser(
                memberFullName,
                memberEmail,
                memberPhone,
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
                        .password(passwordEncoder.encode(defaultPassword))
                        .status(true)
                        .role(role)
                        .failedLoginAttempts(0)
                        .lastPasswordChangeDate(LocalDateTime.now())
                        .lastLoginDate(LocalDateTime.now())
                        .build()));
    }

    private User repairSeedUser(User user, String fullName, String phoneNumber, Role role) {
        boolean changed = false;

        if (!passwordEncoder.matches(defaultPassword, user.getPassword())) {
            user.setPassword(passwordEncoder.encode(defaultPassword));
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
