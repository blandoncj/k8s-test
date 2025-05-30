package com.blandev.delete.service;

import org.springframework.stereotype.Service;

import com.blandev.delete.repository.BookRepository;

@Service
public class BookService implements IBookService {

  private final BookRepository bookRepository;

  public BookService(BookRepository bookRepository) {
    this.bookRepository = bookRepository;
  }

  @Override
  public void deleteBook(Long id) {
    bookRepository.deleteById(id);
  }
}
