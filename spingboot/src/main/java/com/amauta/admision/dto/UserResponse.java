package com.amauta.admision.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO con los datos del usuario autenticado.
 * No incluye la contrasena.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {

    private Integer userId;
    private String firstName;
    private String lastName;
    private String email;
    private String role;
    private String createdAt;

}
