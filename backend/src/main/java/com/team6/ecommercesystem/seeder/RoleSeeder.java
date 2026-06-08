package com.team6.ecommercesystem.seeder;

import com.team6.ecommercesystem.model.Role;
import com.team6.ecommercesystem.repository.RoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class RoleSeeder {
    private final RoleRepository roleRepository;

    public void seed() {
        createIfMissing("ADMIN", "Quan Tri Vien", "Toan quyen quan ly he thong");
        createIfMissing("SHIPPER", "Nguoi giao hang", "Giao hang va cap nhat trang thai don hang");
        createIfMissing("MEMBER", "Thanh Vien", "Nguoi dung thong thuong");
    }

    private void createIfMissing(String roleCode, String roleName, String roleDescription) {
        roleRepository.findByRoleCode(roleCode).orElseGet(() -> {
            Role role = new Role();
            role.setRoleCode(roleCode);
            role.setRoleName(roleName);
            role.setRoleDescription(roleDescription);
            return roleRepository.save(role);
        });
    }
}
