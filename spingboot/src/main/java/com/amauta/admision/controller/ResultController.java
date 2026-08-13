package com.amauta.admision.controller;

import com.amauta.admision.model.Result;
import com.amauta.admision.service.ResultService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para resultados de examenes.
 * Cada postulante solo ve sus propios resultados.
 * Ruta base: /api/results/**
 */
@RestController
@RequestMapping("/api/results")
public class ResultController {

    private final ResultService resultService;

    public ResultController(ResultService resultService) {
        this.resultService = resultService;
    }

    /**
     * Obtiene los resultados del usuario autenticado.
     * GET /api/results
     */
    @GetMapping
    public ResponseEntity<List<Result>> getMyResults() {
        Integer userId = getCurrentUserId();
        return ResponseEntity.ok(resultService.getResultsByUser(userId));
    }

    /**
     * Guarda un resultado de examen.
     * POST /api/results
     */
    @PostMapping
    public ResponseEntity<Result> saveResult(@RequestBody Result result) {
        result.setUserId(getCurrentUserId());
        return ResponseEntity.ok(resultService.saveResult(result));
    }

    // =============================================
    // Obtiene el userId del usuario autenticado
    // desde el contexto de seguridad de Spring.
    // =============================================

    private Integer getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        var user = (com.amauta.admision.model.User) auth.getPrincipal();
        return user.getUserId();
    }

}
