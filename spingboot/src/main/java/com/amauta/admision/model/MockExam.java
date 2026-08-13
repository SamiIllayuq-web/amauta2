package com.amauta.admision.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa un simulacro de examen.
 * Tabla: mock_exams
 */
@Entity
@Table(name = "mock_exams")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MockExam {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer mockExamId;

    @Column(name = "university_id", nullable = false)
    private Integer universityId;

    @Column(name = "area_id", nullable = false)
    private Integer areaId;

    @Column(nullable = false)
    private String title;

    private String description;

    @Column(name = "exam_year")
    private Integer examYear;

    @Column(name = "duration_minutes")
    private Integer durationMinutes;

    @Column(name = "total_questions")
    private Integer totalQuestions;

}
