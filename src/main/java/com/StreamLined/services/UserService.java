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
     * Also locks account for 5 minutes after 3 wrong attempts.
     */
    public User login(String usernameOrEmail, String plainPassword) throws SQLException {
        String sql = "SELECT * FROM users WHERE username = ? OR email = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String input = usernameOrEmail.trim();

            ps.setString(1, input);
            ps.setString(2, input.toLowerCase());

            try (ResultSet rs = ps.executeQuery()) {

                // No account found
                if (!rs.next()) {
                    return null;
                }

                int userId = rs.getInt("user_id");
                String storedHash = rs.getString("password_hash");
                int failedAttempts = rs.getInt("failed_attempts");
                Timestamp lockedUntil = rs.getTimestamp("locked_until");

                Timestamp now = new Timestamp(System.currentTimeMillis());

                // Account is still locked
                if (lockedUntil != null && lockedUntil.after(now)) {
                    return null;
                }

                String enteredHash = hashPassword(plainPassword);

                // Correct password
                if (storedHash.equals(enteredHash)) {
                    User user = mapUser(rs);
                    resetFailedAttempts(userId);
                    return user;
                }

                // Wrong password
                int newFailedAttempts = failedAttempts + 1;

                if (newFailedAttempts >= 3) {
                    lockAccount(userId);
                } else {
                    updateFailedAttempts(userId, newFailedAttempts);
                }

                return null;
            }
        }
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
 // ── Profile Management ─────────────────────────────────────────────────────

    /**
     * Gets user by user_id.
     */
    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }

        return null;
    }

    /**
     * Updates username and email for logged-in user.
     */
    public boolean updateProfile(int userId, String username, String email) throws SQLException {
        String sql = "UPDATE users SET username = ?, email = ? WHERE user_id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setInt(3, userId);

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Checks if username exists for another user.
     */
    public boolean usernameExistsForOtherUser(String username, int userId) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE username = ? AND user_id <> ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username.trim());
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Checks if email exists for another user.
     */
    public boolean emailExistsForOtherUser(String email, int userId) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ? AND user_id <> ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim().toLowerCase());
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Changes user password after checking old password.
     */
    public boolean changePassword(int userId, String oldPassword, String newPassword) throws SQLException {
        String checkSql = "SELECT password_hash FROM users WHERE user_id = ?";
        String updateSql = "UPDATE users SET password_hash = ? WHERE user_id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement checkPs = conn.prepareStatement(checkSql)) {

            checkPs.setInt(1, userId);

            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    String currentHash = rs.getString("password_hash");
                    String oldHash = hashPassword(oldPassword);

                    if (!currentHash.equals(oldHash)) {
                        return false;
                    }
                } else {
                    return false;
                }
            }

            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                updatePs.setString(1, hashPassword(newPassword));
                updatePs.setInt(2, userId);

                return updatePs.executeUpdate() > 0;
            }
        }
    }
 // ── Forgot Password / Reset Password ──────────────────────────────────────

    /**
     * Finds user by email.
     */
    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim().toLowerCase());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }

        return null;
    }

    /**
     * Saves password reset token and expiry time.
     */
    public boolean saveResetToken(String email, String token, Timestamp expiryTime) throws SQLException {
        String sql = "UPDATE users SET reset_token = ?, reset_token_expiry = ? WHERE email = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, token);
            ps.setTimestamp(2, expiryTime);
            ps.setString(3, email.trim().toLowerCase());

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Finds user using reset token.
     */
    public User findByResetToken(String token) throws SQLException {
        String sql = "SELECT * FROM users WHERE reset_token = ? AND reset_token_expiry > NOW()";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, token);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }

        return null;
    }

    /**
     * Updates password using reset token.
     */
    public boolean resetPassword(String token, String newPassword) throws SQLException {
        String sql = "UPDATE users SET password_hash = ?, reset_token = NULL, reset_token_expiry = NULL " +
                     "WHERE reset_token = ? AND reset_token_expiry > NOW()";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, hashPassword(newPassword));
            ps.setString(2, token);

            return ps.executeUpdate() > 0;
        }
    }
    /**
     * Updates failed login attempt count.
     */
    private void updateFailedAttempts(int userId, int attempts) throws SQLException {
        String sql = "UPDATE users SET failed_attempts = ? WHERE user_id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, attempts);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    /**
     * Locks account for 5 minutes.
     */
    private void lockAccount(int userId) throws SQLException {
        String sql = "UPDATE users SET failed_attempts = 3, locked_until = DATE_ADD(NOW(), INTERVAL 5 MINUTE) WHERE user_id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    /**
     * Resets failed attempts after successful login.
     */
    private void resetFailedAttempts(int userId) throws SQLException {
        String sql = "UPDATE users SET failed_attempts = 0, locked_until = NULL WHERE user_id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    /**
     * Checks if account is currently locked.
     */
    public boolean isAccountCurrentlyLocked(String usernameOrEmail) throws SQLException {
        String sql = "SELECT locked_until FROM users WHERE username = ? OR email = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String input = usernameOrEmail.trim();

            ps.setString(1, input);
            ps.setString(2, input.toLowerCase());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Timestamp lockedUntil = rs.getTimestamp("locked_until");
                    Timestamp now = new Timestamp(System.currentTimeMillis());

                    return lockedUntil != null && lockedUntil.after(now);
                }
            }
        }

        return false;
    }
}
