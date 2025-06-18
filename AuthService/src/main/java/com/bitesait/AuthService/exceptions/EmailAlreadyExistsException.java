package com.bitesait.AuthService.exceptions;

public class EmailAlreadyExistsException extends RuntimeException {
    public EmailAlreadyExistsException(String email) {
        super("E-mail już istnieje: " + email);
    }
}
