package com.blandev.update.service;

import org.springframework.stereotype.Service;

import com.blandev.update.entity.BookEntity;
import com.blandev.update.repository.BookRepository;

@Service
public class BookService implements IBookService {

  private final BookRepository bookRepository;

  public BookService(BookRepository bookRepository) {
    this.bookRepository = bookRepository;
  }

  @Override
  public BookEntity updateBook(Long id, BookEntity bookEntity) {
    BookEntity existingBook = bookRepository.findById(id).orElseThrow();

    existingBook.setTitle(bookEntity.getTitle());
    existingBook.setAuthor(bookEntity.getAuthor());
    existingBook.setPages(bookEntity.getPages());

    return bookRepository.save(existingBook);
  }

}
