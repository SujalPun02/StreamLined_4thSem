package com.StreamLined.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConfig
 * Handles database connection for StreamLined project.
 */
public class DBConfig {

    // Database name must match phpMyAdmin database name
    private static final String DB_NAME = "streamlined";

    private static final String URL =
            "jdbc:mysql://localhost:3306/" + DB_NAME + "?useSSL=false&serverTimezone=UTC";

    private static final String USERNAME = "root";
    private static final String PASSWORD = "";

    // Load MySQL driver once
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL JDBC Driver Loaded Successfully!");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found. Check your pom.xml dependency.", e);
        }
    }

    /**
     * Returns database connection.
     * Caller must close the connection using try-with-resources.
     */
    public static Connection getConnection() throws SQLException {
        Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        System.out.println("Database Connected Successfully!");
        return conn;
    }
}