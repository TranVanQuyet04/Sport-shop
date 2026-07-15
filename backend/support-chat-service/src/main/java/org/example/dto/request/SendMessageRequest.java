package org.example.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SendMessageRequest {
    private String content;
    private String sender;
}
