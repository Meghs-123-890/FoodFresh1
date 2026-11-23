
package com.foodfresh;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/foods")
public class FoodServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String search = request.getParameter("search");

        if (search == null) {
            search = "";
        }

        search = search.trim();

        List<Map<String, Object>> foods = new ArrayList<>();

        String sql;

        if (search.isEmpty()) {
            sql = "SELECT id, name, quantity, consume_by "
                + "FROM food_items ORDER BY id";
        } else {
            sql = "SELECT id, name, quantity, consume_by "
                + "FROM food_items WHERE name LIKE ? ORDER BY id";
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (!search.isEmpty()) {
                ps.setString(1, "%" + search + "%");
            }

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Map<String, Object> food = new HashMap<>();

                    food.put("id", rs.getInt("id"));
                    food.put("name", rs.getString("name"));
                    food.put("quantity", rs.getInt("quantity"));
                    food.put("consume_by", rs.getDate("consume_by"));

                    foods.add(food);
                }
            }

            request.setAttribute("foods", foods);
            request.setAttribute("searchTerm", search);

            request.getRequestDispatcher("/index.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to retrieve food items.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        try (Connection con = DBConnection.getConnection()) {

            if ("add".equals(action)) {

                String name = request.getParameter("name");
                String quantityText =
                    request.getParameter("quantity");
                String dateText =
                    request.getParameter("consume_by");

                if (name == null || name.trim().isEmpty()
                        || quantityText == null
                        || dateText == null
                        || dateText.trim().isEmpty()) {

                    response.sendError(400,
                        "Please enter all food details.");
                    return;
                }

                int quantity = Integer.parseInt(quantityText);

                if (quantity < 1) {
                    response.sendError(400,
                        "Quantity must be at least 1.");
                    return;
                }

                Date consumeBy = Date.valueOf(dateText);

                String sql =
                    "INSERT INTO food_items "
                    + "(name, quantity, consume_by) "
                    + "VALUES (?, ?, ?)";

                try (PreparedStatement ps =
                         con.prepareStatement(sql)) {

                    ps.setString(1, name.trim());
                    ps.setInt(2, quantity);
                    ps.setDate(3, consumeBy);
                    ps.executeUpdate();
                }

            } else if ("update".equals(action)) {

                String idText = request.getParameter("id");
                String name = request.getParameter("name");
                String quantityText =
                    request.getParameter("quantity");
                String dateText =
                    request.getParameter("consume_by");

                if (idText == null
                        || name == null
                        || name.trim().isEmpty()
                        || quantityText == null
                        || dateText == null
                        || dateText.trim().isEmpty()) {

                    response.sendError(400,
                        "Please enter all update details.");
                    return;
                }

                int id = Integer.parseInt(idText);
                int quantity = Integer.parseInt(quantityText);

                if (id < 1 || quantity < 1) {
                    response.sendError(400,
                        "Invalid ID or quantity.");
                    return;
                }

                Date consumeBy = Date.valueOf(dateText);

                String sql =
                    "UPDATE food_items "
                    + "SET name = ?, quantity = ?, consume_by = ? "
                    + "WHERE id = ?";

                try (PreparedStatement ps =
                         con.prepareStatement(sql)) {

                    ps.setString(1, name.trim());
                    ps.setInt(2, quantity);
                    ps.setDate(3, consumeBy);
                    ps.setInt(4, id);

                    int updated = ps.executeUpdate();

                    if (updated == 0) {
                        response.sendError(404,
                            "Food item not found.");
                        return;
                    }
                }

            } else if ("delete".equals(action)) {

                String idText = request.getParameter("id");

                if (idText == null) {
                    response.sendError(400,
                        "Food ID is required.");
                    return;
                }

                int id = Integer.parseInt(idText);

                if (id < 1) {
                    response.sendError(400,
                        "Invalid food ID.");
                    return;
                }

                String sql =
                    "DELETE FROM food_items WHERE id = ?";

                try (PreparedStatement ps =
                         con.prepareStatement(sql)) {

                    ps.setInt(1, id);
                    ps.executeUpdate();
                }

            } else {
                response.sendError(400, "Invalid action.");
                return;
            }

            response.sendRedirect(
                request.getContextPath() + "/foods");

        } catch (IllegalArgumentException e) {

            response.sendError(400,
                "Enter a valid ID, quantity and date.");

        } catch (SQLException e) {

            throw new ServletException(
                "Unable to save food item.", e);
        }
    }
}
