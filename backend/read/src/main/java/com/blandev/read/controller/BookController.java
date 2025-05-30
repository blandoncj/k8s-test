package com.blandev.read.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.blandev.read.entity.BookEntity;
import com.blandev.read.service.IBookService;

@RestController
@RequestMapping("/books")
public class BookController {

  private final IBookService bookService;

  public BookController(IBookService bookService) {
    this.bookService = bookService;
  }

  @GetMapping
  public ResponseEntity<List<BookEntity>> getAllBooks() {
    List<BookEntity> books = bookService.getAllBooks();
    return ResponseEntity.ok(books);
  }

  @GetMapping("/{id}")
  public ResponseEntity<BookEntity> getBookById(Long id) {
    return ResponseEntity.ok(bookService.getBookById(id));
  }

}
