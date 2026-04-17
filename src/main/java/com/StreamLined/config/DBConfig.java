package com.StreamLined.config;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * DBConfig
 * Centralises all database connection logic.
 * Change the constants below to match your local MySQL setup.
 */
public class DBConfig {

    // ── Connection settings ────────────────────────────────────────────────
	private static final String DB_NAME = "streamlined";
	private static final String URL = "jdbc:mysql://127.0.0.1:3306/"+DB_NAME;
    private static final String USERNAME = "root";       // ← your MySQL username
    private static final String PASSWORD = "";           // ← your MySQL password

    // Static block: load the JDBC driver once when the class is first used
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC driver not found. "
                    + "Add mysql-connector-java to your /WEB-INF/lib folder.", e);
        }
    }

    /**
     * Returns a live Connection. The caller is responsible for closing it
     * (use try-with-resources or call conn.close() in a finally block).
     */
    public static Connection getConnection() {
        Connection conn = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("Database Connected!");
        } catch (Exception e) {
            e.printStackTrace();
        }

        return conn;
    }
}
