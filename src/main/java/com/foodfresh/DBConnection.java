
package com.foodfresh;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/foodfresh";

    private static final String USER = "root";
    private static final String PASSWORD =
            System.getenv("FOODFRESH_DB_PASSWORD");

    public static Connection getConnection() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "MySQL JDBC driver not found. Check WEB-INF/lib.", e);
        }

        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
