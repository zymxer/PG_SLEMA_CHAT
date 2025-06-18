package com.bitesait.AuthService.exceptions;


public class UsernameAlreadyExistsException extends RuntimeException {
    public UsernameAlreadyExistsException(String username) {
        super("Nazwa użytkownika już istnieje: " + username);
    }
}
