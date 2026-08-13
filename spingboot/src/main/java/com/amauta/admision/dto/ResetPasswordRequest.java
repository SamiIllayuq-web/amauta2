package com.amauta.admision.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para cambiar la contrasena con el codigo de verificacion.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ResetPasswordRequest {

    @NotBlank(message = "El email es obligatorio")
    private String email;

    @NotBlank(message = "El codigo es obligatorio")
    private String code;

    @NotBlank(message = "La nueva contrasena es obligatoria")
    private String newPassword;

}
