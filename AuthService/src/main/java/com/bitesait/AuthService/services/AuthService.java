package com.bitesait.AuthService.services;

import com.bitesait.AuthService.DTO.LoginRequest;
import com.bitesait.AuthService.DTO.LoginResponse;
import com.bitesait.AuthService.DTO.RegisterRequest;
import com.bitesait.AuthService.exceptions.EmailAlreadyExistsException;
import com.bitesait.AuthService.exceptions.UsernameAlreadyExistsException;
import com.bitesait.AuthService.models.User;
import com.bitesait.AuthService.repositories.UserRepository;
import com.bitesait.AuthService.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public void register(RegisterRequest request){

        if(userRepository.findByUsername(request.getUsername()).isPresent()){
            throw new UsernameAlreadyExistsException(request.getUsername());
        }
        if(userRepository.findByEmail(request.getEmail()).isPresent()){
            throw new EmailAlreadyExistsException(request.getEmail());
        }

       User user = User.builder()
               .username(request.getUsername())
               .password(passwordEncoder.encode(request.getPassword()))
               .email(request.getEmail())
               .created_at(LocalDateTime.now())
               .build();
        userRepository.save(user);
    }

    public LoginResponse login(LoginRequest request) {
        Optional<User> user = userRepository.findByUsername(request.getUsername());

        if(user.isEmpty())
            throw(new UsernameNotFoundException("User not found"));

        if(!passwordEncoder.matches(request.getPassword(), user.get().getPassword()))
            throw new BadCredentialsException("Invalid password");

        String token = jwtUtil.generateToken(user.get());
        return new LoginResponse(token);
    }

    public String verifyToken(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new BadCredentialsException("Invalid token. Either empty or without Bearer prefix");
        }
        String token = authHeader.substring(7); // Remove "Bearer " prefix

        return jwtUtil.extractUsername(token);
    }
}
