package com.blandev.read.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.blandev.read.entity.BookEntity;
import com.blandev.read.repository.BookRepository;

@Service
public class BookService implements IBookService {

  private final BookRepository bookRepository;

  public BookService(BookRepository bookRepository) {
    this.bookRepository = bookRepository;
  }

  @Override
  public List<BookEntity> getAllBooks() {
    return bookRepository.findAll();
  }

  @Override
  public BookEntity getBookById(Long id) {
    return bookRepository.findById(id).orElseThrow();
  }
}
