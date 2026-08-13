package com.amauta.admision.service;

import com.amauta.admision.dto.UserResponse;
import com.amauta.admision.model.User;
import com.amauta.admision.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Servicio para gestionar postulantes (solo admins).
 */
@Service
public class AdminService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Lista todos los postulantes (sin contrasenas).
     */
    public List<UserResponse> getAllPostulants() {
        return userRepository.findAllByRole("POSTULANTE")
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene un postulante por ID.
     */
    public UserResponse getPostulantById(Integer id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Postulante no encontrado"));
        return toResponse(user);
    }

    /**
     * Elimina un postulante por ID.
     */
    public void deletePostulant(Integer id) {
        userRepository.deleteById(id);
    }

    /**
     * Actualiza el rol de un usuario a ADMIN.
     * Usado para promover un postulante a administrador.
     */
    public UserResponse promoteToAdmin(Integer id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        user.setRole("ADMIN");
        User saved = userRepository.save(user);
        return toResponse(saved);
    }

    private UserResponse toResponse(User user) {
        return new UserResponse(
                user.getUserId(),
                user.getFirstName(),
                user.getLastName(),
                user.getEmail(),
                user.getRole(),
                user.getCreatedAt().toString()
        );
    }

}
