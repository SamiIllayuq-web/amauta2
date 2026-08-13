package com.amauta.admision.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa una alternativa de respuesta.
 * Tabla: alternatives
 */
@Entity
@Table(name = "alternatives")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Alternative {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer alternativeId;

    @Column(name = "question_id", nullable = false)
    private Integer questionId;

    @Column(name = "alternative_text", nullable = false, length = 500)
    private String alternativeText;

    @Column(name = "is_correct")
    private Boolean isCorrect = false;

}
