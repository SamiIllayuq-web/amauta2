package com.amauta.admision.config;

import com.amauta.admision.model.User;
import com.amauta.admision.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Inicializa datos en la base de datos al arrancar la aplicacion.
 * Inserta el usuario administrador inicial si no existe.
 */
@Component
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public DataSeeder(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (!userRepository.existsByEmail("kuma@gmail.com")) {
            User admin = new User();
            admin.setFirstName("Admin");
            admin.setLastName("Sistema");
            admin.setEmail("kuma@gmail.com");
            admin.setPassword(passwordEncoder.encode("kuma"));
            admin.setRole("ADMIN");
            admin.setCreatedAt(java.time.LocalDateTime.now());
            userRepository.save(admin);
            System.out.println("=== ADMIN CREADO: kuma@gmail.com / kuma ===");
        }
    }

}
