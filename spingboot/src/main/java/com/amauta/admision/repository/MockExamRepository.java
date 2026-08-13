package com.amauta.admision.repository;

import com.amauta.admision.model.MockExam;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MockExamRepository extends JpaRepository<MockExam, Integer> {
}
