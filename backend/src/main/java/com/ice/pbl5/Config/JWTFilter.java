package com.ice.pbl5.Config;

import com.ice.pbl5.Service.JWTService;
import com.ice.pbl5.Service.MyUserDetailsService;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.ApplicationContext;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JWTFilter extends OncePerRequestFilter {
    private final JWTService jwtService;

    private final ApplicationContext context;

    public JWTFilter(JWTService jwtService, ApplicationContext context) {
        this.jwtService = jwtService;
        this.context = context;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String authHeader = request.getHeader("Authorization");
        String token = null;
        String name = null;

        try {
            if(authHeader != null &&  authHeader.startsWith("Bearer "))
            {
                token = authHeader.substring(7);
                name = jwtService.extractUsername(token);
            }

            if(token != null && SecurityContextHolder.getContext().getAuthentication() == null)
            {
                UserDetails userDetails = context.getBean(MyUserDetailsService.class).loadUserByUsername(name);
                if(jwtService.validation(token, userDetails))
                {
                    UsernamePasswordAuthenticationToken authToken = new
                            UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
        } catch (JwtException ex) {
            SecurityContextHolder.clearContext();
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"Invalid or expired token\",\"errorCode\":\"INVALID_TOKEN\"}");
            return;
        }

        filterChain.doFilter(request, response);
    }
}
