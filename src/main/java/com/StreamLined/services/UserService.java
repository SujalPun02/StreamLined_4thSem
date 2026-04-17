package com.StreamLined.services;

import com.StreamLined.config.DBConfig;
import com.StreamLined.model.User;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;

/**
 * UserService
 * Handles all database operations related to users.
 * Uses PreparedStatement throughout to prevent SQL injection.
 */
public class UserService {

    // ── Password hashing ────────────────────────────────────────────────────

    /**
     * Produces a SHA-256 hex digest of the given plain-text password.
     * In a production app, replace this with BCrypt.
     */
    public static String hashPassword(String plainText) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plainText.getBytes());
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }

    // ── Registration ────────────────────────────────────────────────────────

    /**
     * Registers a new user. Returns true on success, false if the
     * username or email is already taken.
     */
    public boolean register(String username, String email, String plainPassword)
            throws SQLException {
        String sql = "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, hashPassword(plainPassword));
            ps.executeUpdate();
            return true;

        } catch (SQLIntegrityConstraintViolationException e) {
            // Duplicate username or email
            return false;
        }
    }

    // ── Login ───────────────────────────────────────────────────────────────

    /**
     * Validates credentials and returns the matching User, or null if invalid.
     */
    public User login(String usernameOrEmail, String plainPassword) throws SQLException {
        String sql = "SELECT * FROM users WHERE (username = ? OR email = ?) AND password_hash = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String input = usernameOrEmail.trim();
            ps.setString(1, input);
            ps.setString(2, input.toLowerCase());
            ps.setString(3, hashPassword(plainPassword));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapUser(rs);
            }
        }
        return null;
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    /** Checks whether a username already exists. */
    public boolean usernameExists(String username) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE username = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Checks whether an email already exists. */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Maps a ResultSet row → User object. */
    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setRole(rs.getString("role"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}
