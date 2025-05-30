package com.blandev.create.service;

import com.blandev.create.dto.CreateBookDTO;
import com.blandev.create.entity.BookEntity;

public interface IBookService {

  BookEntity createBook(CreateBookDTO dto);

}
