package com.StreamLined.controllers;

import com.StreamLined.model.User;
import com.StreamLined.services.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/**
 * ResetPasswordServlet
 * GET  /reset-password?token=... -> shows reset password form
 * POST /reset-password -> updates password
 */
@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token = req.getParameter("token");

        if (token == null || token.trim().isEmpty()) {
            req.setAttribute("error", "Invalid reset link.");
            req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userService.findByResetToken(token);

            if (user == null) {
                req.setAttribute("error", "Reset link is invalid or expired.");
                req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);
                return;
            }

            req.setAttribute("token", token);
            req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Something went wrong. Please try again.");
            req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token = req.getParameter("token");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (token == null || token.trim().isEmpty()) {
            req.setAttribute("error", "Invalid reset request.");
            req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);
            return;
        }

        if (newPassword == null || newPassword.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()) {

            req.setAttribute("token", token);
            req.setAttribute("error", "All password fields are required.");
            req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);
            return;
        }

        if (newPassword.length() < 6) {
            req.setAttribute("token", token);
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("token", token);
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);
            return;
        }

        try {
            boolean updated = userService.resetPassword(token, newPassword);

            if (updated) {
                req.getSession().setAttribute("successMsg", "Password reset successfully. Please login.");
                resp.sendRedirect(req.getContextPath() + "/login");
            } else {
                req.setAttribute("error", "Reset link is invalid or expired.");
                req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Something went wrong. Please try again.");
            req.getRequestDispatcher("/WEB-INF/pages/resetPassword.jsp").forward(req, resp);
        }
    }
}