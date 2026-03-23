package com.ice.pbl5.Service;

import com.ice.pbl5.Entity.User;
import com.ice.pbl5.Entity.UserPrincipal;
import com.ice.pbl5.Repository.UserRepo;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class MyUserDetailsService implements UserDetailsService {

    private final UserRepo userRepo;

    public MyUserDetailsService(UserRepo userRepo) {
        this.userRepo = userRepo;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepo.findByUsernameOrEmail(username, username).orElseThrow(() -> new UsernameNotFoundException("User not found"));


        return new UserPrincipal(user);
    }
}
