package com.amauta.admision;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Punto de entrada de la aplicacion Spring Boot.
 * Inicia el servidor backend para Admision Amauta.
 */
@SpringBootApplication
public class AdmisionApplication {

    public static void main(String[] args) {
        SpringApplication.run(AdmisionApplication.class, args);
    }

}
