package com.amauta.admision.controller;

import com.amauta.admision.model.Alternative;
import com.amauta.admision.model.MockExam;
import com.amauta.admision.model.Question;
import com.amauta.admision.service.ExamService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para examenes.
 * Accesible para usuarios autenticados.
 * Ruta base: /api/exams/**
 */
@RestController
@RequestMapping("/api/exams")
public class ExamController {

    private final ExamService examService;

    public ExamController(ExamService examService) {
        this.examService = examService;
    }

    /**
     * Lista todos los examenes disponibles.
     * GET /api/exams
     */
    @GetMapping
    public ResponseEntity<List<MockExam>> getAllExams() {
        return ResponseEntity.ok(examService.getAllMockExams());
    }

    /**
     * Obtiene un examen por ID.
     * GET /api/exams/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getExam(@PathVariable Integer id) {
        try {
            return ResponseEntity.ok(examService.getMockExamById(id));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Lista las preguntas de un examen.
     * GET /api/exams/{id}/questions
     */
    @GetMapping("/{id}/questions")
    public ResponseEntity<List<Question>> getQuestions(@PathVariable Integer id) {
        return ResponseEntity.ok(examService.getQuestionsByMockExam(id));
    }

    /**
     * Lista las alternativas de una pregunta.
     * GET /api/exams/questions/{questionId}/alternatives
     */
    @GetMapping("/questions/{questionId}/alternatives")
    public ResponseEntity<List<Alternative>> getAlternatives(
            @PathVariable Integer questionId) {
        return ResponseEntity.ok(
                examService.getAlternativesByQuestion(questionId));
    }

    /**
     * Crea una nueva pregunta en un examen.
     * POST /api/exams/questions
     */
    @PostMapping("/questions")
    public ResponseEntity<Question> createQuestion(@RequestBody Question question) {
        return ResponseEntity.ok(examService.saveQuestion(question));
    }

    /**
     * Elimina una pregunta.
     * DELETE /api/exams/questions/{id}
     */
    @DeleteMapping("/questions/{id}")
    public ResponseEntity<Void> deleteQuestion(@PathVariable Integer id) {
        examService.deleteQuestion(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Crea una alternativa para una pregunta.
     * POST /api/exams/alternatives
     */
    @PostMapping("/alternatives")
    public ResponseEntity<Alternative> createAlternative(
            @RequestBody Alternative alternative) {
        return ResponseEntity.ok(examService.saveAlternative(alternative));
    }

}
