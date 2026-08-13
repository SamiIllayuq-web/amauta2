package com.amauta.admision.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO generico para respuestas exitosas con mensaje.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessageResponse {

    private String message;

}
