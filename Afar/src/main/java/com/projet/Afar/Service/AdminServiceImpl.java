package com.projet.Afar.Service;

import com.projet.Afar.Entity.Admin;
import com.projet.Afar.Entity.Notification;
import com.projet.Afar.Repository.AdminRepository;
import org.hibernate.Hibernate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Service
public class AdminServiceImpl implements AdminService {
    @Autowired
    AdminRepository adminRepository;
    @Override
    public Admin AddAdmin(Admin admin) {
        return adminRepository.save(admin);
    }

    @Override
    public Admin ModifyAdmin(Admin admin) {
        return adminRepository.save(admin);
    }

    @Override
    public List<Admin> ShowAdmin() {
        return adminRepository.findAll();
    }

    @Override
    public Optional<Admin> ShowAdminById(Long id) {
        return adminRepository.findById(id);
    }

    @Override
    public void DeleteAdmin(Long id) {
        adminRepository.deleteById(id);
    }

    @Override
    public List<Notification> getNotificationsByAdminId(Long adminId) {
        return adminRepository.findById(adminId)
                .map(admin -> {
                    Hibernate.initialize(admin.getNotifications());
                    return admin.getNotifications().stream()
                            .filter(notification -> adminId.equals(notification.getReceiver().getId()))
                            .toList();
                })
                .orElse(Collections.emptyList());
    }
}
