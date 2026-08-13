package com.amauta.admision.service;

import com.amauta.admision.model.Result;
import com.amauta.admision.repository.ResultRepository;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Servicio para gestionar resultados de examenes.
 */
@Service
public class ResultService {

    private final ResultRepository resultRepository;

    public ResultService(ResultRepository resultRepository) {
        this.resultRepository = resultRepository;
    }

    public List<Result> getResultsByUser(Integer userId) {
        return resultRepository.findByUserIdOrderByCompletedAtDesc(userId);
    }

    public Result saveResult(Result result) {
        return resultRepository.save(result);
    }

}
