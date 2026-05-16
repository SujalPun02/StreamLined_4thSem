package com.StreamLined.controllers;

import com.StreamLined.model.User;
import com.StreamLined.services.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/**
 * ProfileServlet
 * GET  /profile -> shows profile page
 * POST /profile -> updates profile or password
 */
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User loggedUser = (User) session.getAttribute("user");

        String action = req.getParameter("action");

        try {
            if ("updateProfile".equals(action)) {
                updateProfile(req, resp, session, loggedUser);
                return;
            }

            if ("changePassword".equals(action)) {
                changePassword(req, resp, loggedUser);
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/profile");

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Something went wrong. Please try again.");
            req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
        }
    }

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp,
                               HttpSession session, User loggedUser)
            throws ServletException, IOException, SQLException {

        String username = req.getParameter("username");
        String email = req.getParameter("email");

        if (isBlank(username) || isBlank(email)) {
            req.setAttribute("error", "Username and email are required.");
            req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
            return;
        }

        username = username.trim();
        email = email.trim().toLowerCase();

        if (username.length() < 3 || username.length() > 50) {
            req.setAttribute("error", "Username must be between 3 and 50 characters.");
            req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
            return;
        }

        if (!email.matches("^[\\w.+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$")) {
            req.setAttribute("error", "Please enter a valid email address.");
            req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
            return;
        }

        if (userService.usernameExistsForOtherUser(username, loggedUser.getUserId())) {
            req.setAttribute("error", "That username is already used by another account.");
            req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
            return;
        }

        if (userService.emailExistsForOtherUser(email, loggedUser.getUserId())) {
            req.setAttribute("error", "That email is already used by another account.");
            req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
            return;
        }

        boolean updated = userService.updateProfile(loggedUser.getUserId(), username, email);

        if (updated) {
            User updatedUser = userService.getUserById(loggedUser.getUserId());
            session.setAttribute("user", updatedUser);

            req.setAttribute("success", "Profile updated successfully.");
        } else {
            req.setAttribute("error", "Profile update failed.");
        }

        req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
    }

    private void changePassword(HttpServletRequest req, HttpServletResponse resp, User loggedUser)
            throws ServletException, IOException, SQLException {

        String oldPassword = req.getParameter("oldPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (isBlank(oldPassword) || isBlank(newPassword) || isBlank(confirmPassword)) {
            req.setAttribute("error", "All password fields are required.");
            req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
            return;
        }

        if (newPassword.length() < 6) {
            req.setAttribute("error", "New password must be at least 6 characters.");
            req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("error", "New password and confirm password do not match.");
            req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
            return;
        }

        boolean changed = userService.changePassword(
                loggedUser.getUserId(),
                oldPassword,
                newPassword
        );

        if (changed) {
            req.setAttribute("success", "Password changed successfully.");
        } else {
            req.setAttribute("error", "Old password is incorrect.");
        }

        req.getRequestDispatcher("/WEB-INF/pages/profile.jsp").forward(req, resp);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}