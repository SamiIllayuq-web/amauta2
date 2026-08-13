package com.amauta.admision.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para solicitar recuperacion de contrasena.
 * El backend genera un codigo de verificacion.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ForgotPasswordRequest {

    @NotBlank(message = "El email es obligatorio")
    @Email(message = "El email debe ser valido")
    private String email;

}
