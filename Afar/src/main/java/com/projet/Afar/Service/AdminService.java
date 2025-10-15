package com.projet.Afar.Service;

import com.projet.Afar.Entity.Admin;

import java.util.List;
import java.util.Optional;

public interface AdminService {
    Admin AddAdmin(Admin admin);
    Admin ModifyAdmin(Admin admin);
    List<Admin> ShowAdmin();
    Optional<Admin> ShowAdminById(Long id);
    void DeleteAdmin(Long id);
}
