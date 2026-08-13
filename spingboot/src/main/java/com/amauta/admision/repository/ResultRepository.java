package com.amauta.admision.repository;

import com.amauta.admision.model.Result;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ResultRepository extends JpaRepository<Result, Integer> {

    List<Result> findByUserIdOrderByCompletedAtDesc(Integer userId);

}
