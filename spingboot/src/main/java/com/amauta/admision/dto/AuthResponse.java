package com.amauta.admision.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO que contiene el token JWT generado tras un login exitoso.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

    private String token;
    private String type = "Bearer";
    private UserResponse user;

    public AuthResponse(String token, UserResponse user) {
        this.token = token;
        this.user = user;
    }

}
