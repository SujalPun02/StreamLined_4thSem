package com.StreamLined.controllers;

import com.StreamLined.model.User;
import com.StreamLined.services.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/**
 * LoginServlet
 * GET  /login  -> shows login page
 * POST /login  -> checks username/email and password
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserService userService = new UserService();

    // GET method: opens login page
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // If user is already logged in, send to dashboard/admin
        HttpSession session = req.getSession(false);

        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");

            if (user.isAdmin()) {
                resp.sendRedirect(req.getContextPath() + "/admin");
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }
            return;
        }

        // Show login page
        req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
    }

    // POST method: runs after clicking Sign In button
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String identifier = req.getParameter("identifier");
        String password = req.getParameter("password");

        // Keep typed username/email after error
        req.setAttribute("identifier", identifier);

        // Empty field validation
        if (identifier == null || identifier.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {

            req.setAttribute("error", "Please enter username/email and password.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
            return;
        }

        try {
            // Check login from database/service
            User user = userService.login(identifier.trim(), password);

            // Wrong username/email or password
            if (user == null) {

                if (userService.isAccountCurrentlyLocked(identifier)) {
                    req.setAttribute("error",
                            "Your account is temporarily locked because of too many wrong login attempts. Please try again after 5 minutes.");
                } else {
                    req.setAttribute("error", "Invalid username/email or password.");
                }

                req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
                return;
            }

            // Remove old session if exists
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            // Create new session after successful login
            HttpSession newSession = req.getSession(true);
            newSession.setAttribute("user", user);
            newSession.setMaxInactiveInterval(30 * 60); // 30 minutes

            // Redirect based on user role
            if (user.isAdmin()) {
                resp.sendRedirect(req.getContextPath() + "/admin");
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }

        } catch (SQLException e) {
            e.printStackTrace();

            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
        }
    }
}