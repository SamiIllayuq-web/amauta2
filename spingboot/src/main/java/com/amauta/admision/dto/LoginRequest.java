package com.amauta.admision.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para iniciar sesion.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {

    @NotBlank(message = "El email es obligatorio")
    @Email(message = "El email debe ser valido")
    private String email;

    @NotBlank(message = "La contrasena es obligatoria")
    private String password;

}
