package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Request.UserCreateRequest;
import com.ice.pbl5.DTO.Request.UserLoginRequest;
import com.ice.pbl5.DTO.Response.LoginResponse;
import com.ice.pbl5.DTO.Response.UserResponse;
import com.ice.pbl5.Entity.User;
import com.ice.pbl5.Mapper.UserMapper;
import com.ice.pbl5.Repository.UserRepo;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;


@Service
public class UserServiceImpl implements UserService{
    private final UserRepo userRepo;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    private final AuthenticationManager authenticationManager;
    private final JWTService jwtService;

    public UserServiceImpl(UserRepo userRepo, UserMapper userMapper, PasswordEncoder passwordEncoder, AuthenticationManager authenticationManager, JWTService jwtService) {
        this.userRepo = userRepo;
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
    }

    @Override
    public UserResponse createUser(UserCreateRequest userCreateRequest) {
        if(userRepo.existsByUsername(userCreateRequest.getUsername()))
            throw new IllegalArgumentException("Username already exists");

        if(userRepo.existsByEmail(userCreateRequest.getEmail()))
            throw new IllegalArgumentException("Email already exists");

        // mapper
        User user = userMapper.toEntity(userCreateRequest, passwordEncoder.encode(userCreateRequest.getPassword()));
        User save = userRepo.save(user);
        return userMapper.toResponse(save);
    }

    @Override
    public UserResponse getUserById(long id) {
        User user = userRepo.findById(id).orElseThrow(() -> new IllegalArgumentException("User not found"));
        return userMapper.toResponse(user);
    }

    @Override
    public UserResponse getUserByUsername(String username) {
        User user = userRepo.findByUsername(username).orElseThrow(() -> new IllegalArgumentException("User not found"));
        return  userMapper.toResponse(user);
    }

    // nên thêm là username hay email đều được
    @Override
    public LoginResponse verity(UserLoginRequest userLoginRequest) {
         authenticationManager
                .authenticate(new UsernamePasswordAuthenticationToken(userLoginRequest.getIdentifier(), userLoginRequest.getPassword()));

        User user = userRepo.findByUsernameOrEmail(userLoginRequest.getIdentifier(), userLoginRequest.getIdentifier()).orElseThrow(() -> new UsernameNotFoundException("User not found"));

        String token = jwtService.generateToken(user.getUsername());
        return userMapper.toLoginResponse(
                user,
                token,
                "Bearer",
                jwtService.getExpiration()
        );
    }
}
