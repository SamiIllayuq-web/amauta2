package com.amauta.admision.service;

import com.amauta.admision.dto.*;
import com.amauta.admision.model.User;
import com.amauta.admision.repository.UserRepository;
import com.amauta.admision.security.JwtUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Servicio encargado de la autenticacion:
 * registro, login, y recuperacion de contrasena.
 */
@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;

    // Almacenamiento en memoria de codigos de recuperacion.
    // En produccion esto deberia usar Redis o una tabla en BD.
    private final Map<String, String> recoveryCodes = new HashMap<>();

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtUtils jwtUtils) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtils = jwtUtils;
    }

    /**
     * Registra un nuevo postulante.
     * El rol por defecto es POSTULANTE.
     */
    public UserResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("El email ya esta registrado");
        }

        User user = new User();
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole("POSTULANTE");
        user.setCreatedAt(LocalDateTime.now());

        User saved = userRepository.save(user);
        return toUserResponse(saved);
    }

    /**
     * Inicia sesion y devuelve un JWT.
     */
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Credenciales invalidas"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Credenciales invalidas");
        }

        String token = jwtUtils.generateToken(user.getEmail(), user.getRole());
        return new AuthResponse(token, toUserResponse(user));
    }

    /**
     * Genera un codigo de recuperacion de contrasena.
     * En produccion esto envia un email.
     */
    public void forgotPassword(ForgotPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Genera un codigo de 6 digitos.
        String code = String.format("%06d", new Random().nextInt(999999));
        recoveryCodes.put(request.getEmail(), code);

        // En produccion aqui se envia el codigo por email.
        // Por ahora se imprime en consola para poder probarlo.
        System.out.println("=== CODIGO DE RECUPERACION PARA " + request.getEmail()
                + ": " + code + " ===");
    }

    /**
     * Resetea la contrasena usando el codigo de verificacion.
     */
    public void resetPassword(ResetPasswordRequest request) {
        String storedCode = recoveryCodes.get(request.getEmail());

        if (storedCode == null || !storedCode.equals(request.getCode())) {
            throw new RuntimeException("Codigo de verificacion invalido");
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        // Eliminar el codigo usado.
        recoveryCodes.remove(request.getEmail());
    }

    private UserResponse toUserResponse(User user) {
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
