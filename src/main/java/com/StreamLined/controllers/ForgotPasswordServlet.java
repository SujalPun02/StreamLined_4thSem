package com.StreamLined.controllers;

import com.StreamLined.model.User;
import com.StreamLined.services.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * ForgotPasswordServlet
 * GET  /forgot-password -> shows forgot password page
 * POST /forgot-password -> creates reset token
 */
@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.getRequestDispatcher("/WEB-INF/pages/forgotPassword.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Please enter your email address.");
            req.getRequestDispatcher("/WEB-INF/pages/forgotPassword.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userService.findByEmail(email);

            if (user == null) {
                req.setAttribute("error", "No account found with this email address.");
                req.getRequestDispatcher("/WEB-INF/pages/forgotPassword.jsp").forward(req, resp);
                return;
            }

            String token = UUID.randomUUID().toString();

            LocalDateTime expiryDateTime = LocalDateTime.now().plusMinutes(15);
            Timestamp expiryTimestamp = Timestamp.valueOf(expiryDateTime);

            boolean saved = userService.saveResetToken(email, token, expiryTimestamp);

            if (saved) {
                String resetLink = req.getContextPath() + "/reset-password?token=" + token;

                req.setAttribute("success", "Reset link generated successfully. Use the link below.");
                req.setAttribute("resetLink", resetLink);
            } else {
                req.setAttribute("error", "Could not generate reset link. Please try again.");
            }

            req.getRequestDispatcher("/WEB-INF/pages/forgotPassword.jsp").forward(req, resp);

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/pages/forgotPassword.jsp").forward(req, resp);
        }
    }
}