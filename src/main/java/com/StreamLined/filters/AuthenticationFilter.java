package com.StreamLined.filters;

import com.StreamLined.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * AuthenticationFilter
 * Checks whether user is logged in before accessing protected pages.
 */
@WebFilter(urlPatterns = {
        "/dashboard",
        "/movies",
        "/admin",
        "/profile"
})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Runs when filter starts
        System.out.println("AuthenticationFilter started.");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);

        boolean loggedIn = session != null && session.getAttribute("user") != null;

        String requestURI = req.getRequestURI();

        // If not logged in, send user to login page
        if (!loggedIn) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Admin protection
        if (requestURI.endsWith("/admin") && !user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Allow request to continue
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Runs when filter stops
        System.out.println("AuthenticationFilter stopped.");
    }
}