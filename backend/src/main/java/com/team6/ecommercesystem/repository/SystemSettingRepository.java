package com.team6.ecommercesystem.repository;

import com.team6.ecommercesystem.model.SystemSetting;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SystemSettingRepository extends JpaRepository<SystemSetting, String> {
}
