package com.blandev.update.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.blandev.update.entity.BookEntity;
import com.blandev.update.service.IBookService;

@RestController
@RequestMapping("/books")
public class BookController {

  private final IBookService bookService;

  public BookController(IBookService bookService) {
    this.bookService = bookService;
  }

  @PutMapping("/{id}")
  public ResponseEntity<BookEntity> updateBook(@PathVariable Long id, @RequestBody BookEntity bookEntity) {
    BookEntity updatedBook = bookService.updateBook(id, bookEntity);
    return ResponseEntity.ok(updatedBook);
  }

}
