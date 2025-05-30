package com.blandev.read.service;

import java.util.List;

import com.blandev.read.entity.BookEntity;

public interface IBookService {

  List<BookEntity> getAllBooks();

  BookEntity getBookById(Long id);

}
