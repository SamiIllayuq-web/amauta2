package com.amauta.admision.controller;

import com.amauta.admision.dto.MessageResponse;
import com.amauta.admision.dto.UserResponse;
import com.amauta.admision.service.AdminService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para operaciones de administrador.
 * Solo accesible para usuarios con rol ADMIN.
 * Ruta base: /api/admin/**
 */
@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    /**
     * Lista todos los postulantes.
     * GET /api/admin/postulants
     */
    @GetMapping("/postulants")
    public ResponseEntity<List<UserResponse>> getAllPostulants() {
        return ResponseEntity.ok(adminService.getAllPostulants());
    }

    /**
     * Obtiene un postulante por ID.
     * GET /api/admin/postulants/{id}
     */
    @GetMapping("/postulants/{id}")
    public ResponseEntity<?> getPostulant(@PathVariable Integer id) {
        try {
            return ResponseEntity.ok(adminService.getPostulantById(id));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Elimina un postulante.
     * DELETE /api/admin/postulants/{id}
     */
    @DeleteMapping("/postulants/{id}")
    public ResponseEntity<?> deletePostulant(@PathVariable Integer id) {
        try {
            adminService.deletePostulant(id);
            return ResponseEntity.ok(new MessageResponse("Postulante eliminado"));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Promueve un postulante a administrador.
     * PUT /api/admin/promote/{id}
     */
    @PutMapping("/promote/{id}")
    public ResponseEntity<?> promoteToAdmin(@PathVariable Integer id) {
        try {
            return ResponseEntity.ok(adminService.promoteToAdmin(id));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest()
                    .body(new MessageResponse(e.getMessage()));
        }
    }

}
