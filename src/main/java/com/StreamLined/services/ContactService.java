package com.StreamLined.services;

import com.StreamLined.config.DBConfig;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * ContactService
 * Handles saving contact form messages.
 */
public class ContactService {

    public boolean saveMessage(String name, String email, String subject, String message)
            throws SQLException {

        String sql = "INSERT INTO contact_messages (name, email, subject, message) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, subject.trim());
            ps.setString(4, message.trim());

            return ps.executeUpdate() > 0;
        }
    }
}