package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Request.UserCreateRequest;
import com.ice.pbl5.DTO.Request.UserLoginRequest;
import com.ice.pbl5.DTO.Response.LoginResponse;
import com.ice.pbl5.DTO.Response.UserResponse;

public interface UserService {
    UserResponse createUser(UserCreateRequest userCreateRequest);
    UserResponse getUserById(long id);
    UserResponse getUserByUsername(String username);
    LoginResponse verity(UserLoginRequest userLoginRequest);
}
