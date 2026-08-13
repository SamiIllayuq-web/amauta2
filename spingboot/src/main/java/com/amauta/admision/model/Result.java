package com.amauta.admision.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * Entidad que representa el resultado de un postulante en un simulacro.
 * Tabla: results
 */
@Entity
@Table(name = "results")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Result {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer resultId;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "mock_exam_id", nullable = false)
    private Integer mockExamId;

    @Column(name = "final_score")
    private Double finalScore = 0.0;

    @Column(name = "correct_answers")
    private Integer correctAnswers = 0;

    @Column(name = "incorrect_answers")
    private Integer incorrectAnswers = 0;

    @Column(name = "elapsed_time")
    private Integer elapsedTime = 0;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @PrePersist
    protected void onCreate() {
        if (completedAt == null) {
            completedAt = LocalDateTime.now();
        }
    }

}
