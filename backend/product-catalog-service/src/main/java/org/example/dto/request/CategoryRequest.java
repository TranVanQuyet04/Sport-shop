package org.example.dto.request;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class CategoryRequest {

    private String categoryName;
    private String description;
    private Long parentId; // cÃ³ thá»ƒ null náº¿u lÃ  root
}
