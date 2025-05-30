package com.blandev.create.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.blandev.create.dto.CreateBookDTO;
import com.blandev.create.entity.BookEntity;
import com.blandev.create.service.ICreateBookService;

@RestController
@RequestMapping("/books")
public class BookController {

  private final ICreateBookService createBookService;

  public BookController(ICreateBookService createBookService) {
    this.createBookService = createBookService;
  }

  @PostMapping
  public ResponseEntity<BookEntity> createBook(@RequestBody CreateBookDTO dto) {
    BookEntity createdBook = createBookService.createBook(dto);
    return ResponseEntity.status(HttpStatus.CREATED).body(createdBook);
  }

}
