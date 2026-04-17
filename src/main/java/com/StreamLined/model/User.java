package com.StreamLined.model;
import java.sql.Timestamp;

/**
 * User model — mirrors the `users` table.
 */
public class User {

    private int       userId;
    private String    username;
    private String    email;
    private String    passwordHash;
    private String    role;           // "user" or "admin"
    private Timestamp createdAt;

    // ── Constructors ────────────────────────────────────────────────────────

    public User() {}

    public User(String username, String email, String passwordHash, String role) {
        this.username     = username;
        this.email        = email;
        this.passwordHash = passwordHash;
        this.role         = role;
    }

    // ── Getters & Setters ───────────────────────────────────────────────────

    public int       getUserId()      { return userId; }
    public void      setUserId(int v) { this.userId = v; }

    public String    getUsername()       { return username; }
    public void      setUsername(String v) { this.username = v; }

    public String    getEmail()          { return email; }
    public void      setEmail(String v)  { this.email = v; }

    public String    getPasswordHash()          { return passwordHash; }
    public void      setPasswordHash(String v)  { this.passwordHash = v; }

    public String    getRole()           { return role; }
    public void      setRole(String v)   { this.role = v; }

    public Timestamp getCreatedAt()          { return createdAt; }
    public void      setCreatedAt(Timestamp v) { this.createdAt = v; }

    public boolean   isAdmin() { return "admin".equalsIgnoreCase(role); }
}
