package com.amauta.admision.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa una pregunta dentro de un simulacro.
 * Tabla: questions
 */
@Entity
@Table(name = "questions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Question {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer questionId;

    @Column(name = "mock_exam_id", nullable = false)
    private Integer mockExamId;

    @Column(name = "question_text", nullable = false, length = 1000)
    private String questionText;

    @Column(length = 2000)
    private String explanation;

}
