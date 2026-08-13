package com.amauta.admision.service;

import com.amauta.admision.model.*;
import com.amauta.admision.repository.*;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Servicio para gestionar examenes, preguntas y alternativas.
 */
@Service
public class ExamService {

    private final MockExamRepository mockExamRepository;
    private final QuestionRepository questionRepository;
    private final AlternativeRepository alternativeRepository;

    public ExamService(MockExamRepository mockExamRepository,
                       QuestionRepository questionRepository,
                       AlternativeRepository alternativeRepository) {
        this.mockExamRepository = mockExamRepository;
        this.questionRepository = questionRepository;
        this.alternativeRepository = alternativeRepository;
    }

    // ==================== Mock Exams ====================

    public List<MockExam> getAllMockExams() {
        return mockExamRepository.findAll();
    }

    public MockExam getMockExamById(Integer id) {
        return mockExamRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Examen no encontrado"));
    }

    // ==================== Questions ====================

    public List<Question> getQuestionsByMockExam(Integer mockExamId) {
        return questionRepository.findByMockExamId(mockExamId);
    }

    public Question saveQuestion(Question question) {
        return questionRepository.save(question);
    }

    public void deleteQuestion(Integer id) {
        questionRepository.deleteById(id);
    }

    // ==================== Alternatives ====================

    public List<Alternative> getAlternativesByQuestion(Integer questionId) {
        return alternativeRepository.findByQuestionId(questionId);
    }

    public Alternative saveAlternative(Alternative alternative) {
        return alternativeRepository.save(alternative);
    }

}
