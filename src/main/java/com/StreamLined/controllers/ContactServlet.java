package com.StreamLined.controllers;

import com.StreamLined.services.ContactService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

/**
 * ContactServlet
 * GET  /contact -> shows contact page
 * POST /contact -> saves message
 */
@WebServlet("/contact")
public class ContactServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final ContactService contactService = new ContactService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.getRequestDispatcher("/WEB-INF/pages/contact.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String subject = req.getParameter("subject");
        String message = req.getParameter("message");

        if (isBlank(name) || isBlank(email) || isBlank(subject) || isBlank(message)) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("/WEB-INF/pages/contact.jsp").forward(req, resp);
            return;
        }

        if (!email.trim().matches("^[\\w.+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$")) {
            req.setAttribute("error", "Please enter a valid email address.");
            req.getRequestDispatcher("/WEB-INF/pages/contact.jsp").forward(req, resp);
            return;
        }

        if (message.trim().length() < 10) {
            req.setAttribute("error", "Message must be at least 10 characters.");
            req.getRequestDispatcher("/WEB-INF/pages/contact.jsp").forward(req, resp);
            return;
        }

        try {
            boolean saved = contactService.saveMessage(name, email, subject, message);

            if (saved) {
                req.setAttribute("success", "Your message has been sent successfully.");
            } else {
                req.setAttribute("error", "Message could not be sent. Please try again.");
            }

            req.getRequestDispatcher("/WEB-INF/pages/contact.jsp").forward(req, resp);

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Something went wrong. Please try again later.");
            req.getRequestDispatcher("/WEB-INF/pages/contact.jsp").forward(req, resp);
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}