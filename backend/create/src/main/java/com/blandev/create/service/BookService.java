package com.blandev.create.service;

import org.springframework.stereotype.Service;

import com.blandev.create.dto.CreateBookDTO;
import com.blandev.create.entity.BookEntity;
import com.blandev.create.repository.BookRepository;

@Service
public class BookService implements IBookService {

  private final BookRepository bookRepository;

  public BookService(BookRepository bookRepository) {
    this.bookRepository = bookRepository;
  }

  @Override
  public BookEntity createBook(CreateBookDTO dto) {
    BookEntity book = new BookEntity(
        dto.title(),
        dto.author(),
        dto.pages());
    return bookRepository.save(book);
  }
}
