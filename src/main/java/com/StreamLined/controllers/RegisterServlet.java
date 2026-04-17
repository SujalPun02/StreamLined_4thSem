package com.StreamLined.controllers;

import com.StreamLined.services.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

/**
 * RegisterServlet
 * GET  /register → shows the registration page
 * POST /register → validates input, creates account, redirects to login
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private final UserService userService = new UserService();

    // ── GET ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
    }

    // ── POST ────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username  = req.getParameter("username");
        String email     = req.getParameter("email");
        String password  = req.getParameter("password");
        String confirm   = req.getParameter("confirmPassword");

        // ── Input validation ─────────────────────────────────────────────

        if (isBlank(username) || isBlank(email) || isBlank(password) || isBlank(confirm)) {
            forward(req, resp, "All fields are required.");
            return;
        }

        if (username.trim().length() < 3 || username.trim().length() > 50) {
            forward(req, resp, "Username must be between 3 and 50 characters.");
            return;
        }

        if (!email.trim().matches("^[\\w.+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$")) {
            forward(req, resp, "Please enter a valid email address.");
            return;
        }

        if (password.length() < 6) {
            forward(req, resp, "Password must be at least 6 characters.");
            return;
        }

        if (!password.equals(confirm)) {
            forward(req, resp, "Passwords do not match.");
            return;
        }

        try {
            if (userService.usernameExists(username.trim())) {
                forward(req, resp, "That username is already taken. Please choose another.");
                return;
            }

            if (userService.emailExists(email.trim())) {
                forward(req, resp, "An account with that email already exists.");
                return;
            }

            boolean success = userService.register(username.trim(), email.trim(), password);

            if (success) {
                // Pass a success message to the login page
                req.getSession().setAttribute("successMsg", "Account created! Please log in.");
                resp.sendRedirect(req.getContextPath() + "/login");
            } else {
                forward(req, resp, "Registration failed. Please try again.");
            }

        } catch (SQLException e) {
            forward(req, resp, "Something went wrong. Please try again later.");
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    private void forward(HttpServletRequest req, HttpServletResponse resp, String error)
            throws ServletException, IOException {
        req.setAttribute("error", error);
        // Re-populate fields so the user doesn't have to retype everything
        req.setAttribute("prevUsername", req.getParameter("username"));
        req.setAttribute("prevEmail",    req.getParameter("email"));
        req.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(req, resp);
    }
}
