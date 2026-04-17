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
 * GET  /login  → shows the login page
 * POST /login  → validates credentials, creates session, redirects to dashboard
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private final UserService userService = new UserService();

    // ── GET ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // If already logged in, go straight to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
    }

    // ── POST ────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String identifier = req.getParameter("identifier"); // username or email
        String password   = req.getParameter("password");

        // Basic null / empty guard
        if (identifier == null || identifier.isBlank() ||
            password   == null || password.isBlank()) {
            req.setAttribute("error", "Please fill in all fields.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userService.login(identifier, password);

            if (user == null) {
                req.setAttribute("error", "Invalid username/email or password.");
                req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
                return;
            }

            // Create a new session and store the user object
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            // Admins go to admin panel; regular users go to dashboard
            if (user.isAdmin()) {
                resp.sendRedirect(req.getContextPath() + "/admin");
            } else {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            }

        } catch (SQLException e) {
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
        }
    }
}
