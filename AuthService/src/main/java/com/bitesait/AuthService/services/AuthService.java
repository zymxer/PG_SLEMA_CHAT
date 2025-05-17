package com.bitesait.AuthService.services;

import com.bitesait.AuthService.DTO.RegisterRequest;
import com.bitesait.AuthService.exceptions.EmailAlreadyExistsException;
import com.bitesait.AuthService.exceptions.InvalidPasswordException;
import com.bitesait.AuthService.exceptions.UsernameAlreadyExistsException;
import com.bitesait.AuthService.models.User;
import com.bitesait.AuthService.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;


    public User register(RegisterRequest request){

        if(userRepository.findByUsername(request.getUsername()).isPresent()){
            throw new UsernameAlreadyExistsException(request.getUsername());
        }
        if(userRepository.findByEmail(request.getEmail()).isPresent()){
            throw new EmailAlreadyExistsException(request.getEmail());
        }
        if(request.getPassword() == null || request.getPassword().length() < 6){
            throw new InvalidPasswordException("Password must be at least 6 characters");
        }


       User user = User.builder()
                       .username(request.getUsername())
                               .password(passwordEncoder.encode(request.getPassword()))
                                       .email(request.getEmail())
                                            .created_at(LocalDateTime.now())
                                                       .build();
        return userRepository.save(user);
    }

    public Optional<User> findByUsername(String username){
        return userRepository.findByUsername(username);
    }

}
