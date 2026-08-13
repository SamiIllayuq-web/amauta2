package com.amauta.admision.repository;

import com.amauta.admision.model.Alternative;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AlternativeRepository extends JpaRepository<Alternative, Integer> {

    List<Alternative> findByQuestionId(Integer questionId);

}
