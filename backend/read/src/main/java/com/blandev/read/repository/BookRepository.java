package com.blandev.read.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.blandev.read.entity.BookEntity;

@Repository
public interface BookRepository extends JpaRepository<BookEntity, Long> {
}
