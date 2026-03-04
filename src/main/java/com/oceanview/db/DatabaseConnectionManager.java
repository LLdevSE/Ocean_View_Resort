package com.oceanview.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DatabaseConnectionManager — Singleton Pattern
 * Ensures only one instance manages database connections throughout
 * the application lifecycle.
 *
 * Configuration: Edit DB_URL, DB_USER, DB_PASSWORD to match your MySQL setup.
 */
public class DatabaseConnectionManager {

    private static final Logger LOGGER = Logger.getLogger(DatabaseConnectionManager.class.getName());

    // ---- Database Configuration ----
    private static final String DB_DRIVER   = "com.mysql.cj.jdbc.Driver";
    private static final String DB_URL      = "jdbc:mysql://localhost:3306/ocean_view_resort?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_USER     = "root";
    private static final String DB_PASSWORD = "your_mysql_password"; // ← Change this

    // ---- Singleton instance (volatile for thread-safety) ----
    private static volatile DatabaseConnectionManager instance;

    /**
     * Private constructor — loads the JDBC driver once.
     */
    private DatabaseConnectionManager() {
        try {
            Class.forName(DB_DRIVER);
            LOGGER.info("MySQL JDBC Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Failed to load JDBC driver: " + e.getMessage(), e);
            throw new RuntimeException("JDBC Driver not found: " + DB_DRIVER, e);
        }
    }

    /**
     * Returns the single instance of this manager.
     * Uses double-checked locking for thread safety.
     */
    public static DatabaseConnectionManager getInstance() {
        if (instance == null) {
            synchronized (DatabaseConnectionManager.class) {
                if (instance == null) {
                    instance = new DatabaseConnectionManager();
                }
            }
        }
        return instance;
    }

    /**
     * Opens and returns a fresh database connection.
     * Callers are responsible for closing the connection (use try-with-resources).
     *
     * @return a new {@link Connection}
     * @throws SQLException if the connection cannot be established
     */
    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    /**
     * Safely closes a connection without throwing checked exceptions.
     */
    public void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing DB connection: " + e.getMessage(), e);
            }
        }
    }
}
