package com.StreamLined.controllers;

import com.StreamLined.model.User;
import com.StreamLined.services.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/**
 * RegisterServlet
 * GET  /register -> shows the registration page
 * POST /register -> validates input, creates account, redirects to login
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserService userService = new UserService();

    // GET method: opens register page
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // If already logged in, redirect user
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

        req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
    }

    // POST method: runs after clicking register button
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // Keep previous values if error happens
        req.setAttribute("prevUsername", username);
        req.setAttribute("prevEmail", email);

        // Empty field validation
        if (isBlank(username) || isBlank(email) || isBlank(password) || isBlank(confirmPassword)) {
            forwardWithError(req, resp, "All fields are required.");
            return;
        }

        username = username.trim();
        email = email.trim();

        // Username validation
        if (username.length() < 3 || username.length() > 50) {
            forwardWithError(req, resp, "Username must be between 3 and 50 characters.");
            return;
        }

        // Email validation
        if (!email.matches("^[\\w.+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$")) {
            forwardWithError(req, resp, "Please enter a valid email address.");
            return;
        }

        // Password validation
        if (password.length() < 6) {
            forwardWithError(req, resp, "Password must be at least 6 characters.");
            return;
        }

        // Confirm password validation
        if (!password.equals(confirmPassword)) {
            forwardWithError(req, resp, "Passwords do not match.");
            return;
        }

        try {
            // Check duplicate username
            if (userService.usernameExists(username)) {
                forwardWithError(req, resp, "That username is already taken. Please choose another.");
                return;
            }

            // Check duplicate email
            if (userService.emailExists(email)) {
                forwardWithError(req, resp, "An account with that email already exists.");
                return;
            }

            // Register user
            boolean success = userService.register(username, email, password);

            if (success) {
                // Green success message for login page
                req.getSession().setAttribute("successMsg", "Account created successfully. Please login.");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            forwardWithError(req, resp, "Registration failed. Please try again.");

        } catch (SQLException e) {
            e.printStackTrace();
            forwardWithError(req, resp, "Something went wrong. Please try again later.");
        }
    }

    // Helper method to check blank values
    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    // Helper method to send error back to register.jsp
    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp, String error)
            throws ServletException, IOException {

        req.setAttribute("error", error);

        // Keep typed values after error
        req.setAttribute("prevUsername", req.getParameter("username"));
        req.setAttribute("prevEmail", req.getParameter("email"));

        req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
    }
}