package com.blandev.update.service;

import com.blandev.update.entity.BookEntity;

public interface IBookService {
  BookEntity updateBook(Long id, BookEntity bookEntity);
}
