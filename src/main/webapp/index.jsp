
<%@ page pageEncoding="UTF-8"
    contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, java.time.*, java.time.temporal.ChronoUnit" %>

<%!
    // Escape database text before displaying it in HTML.
    public String esc(Object value) {
        if (value == null) return "";

        String s = String.valueOf(value);

        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    List<Map<String, Object>> foods =
        (List<Map<String, Object>>) request.getAttribute("foods");

    if (foods == null) {
        foods = new ArrayList<>();
    }

    String searchTerm =
        (String) request.getAttribute("searchTerm");

    if (searchTerm == null) {
        searchTerm = "";
    }

    LocalDate today = LocalDate.now();
    int reminderCount = 0;

    for (Map<String, Object> food : foods) {
        java.sql.Date consumeDate =
            (java.sql.Date) food.get("consume_by");

        if (consumeDate != null) {
            long daysLeft = ChronoUnit.DAYS.between(
                today, consumeDate.toLocalDate());

            if (daysLeft >= 0 && daysLeft <= 3) {
                reminderCount++;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>FoodFresh - Food Freshness Monitor</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background: #f1f8f3;
            margin: 0;
            padding: 25px;
            color: #24352a;
        }

        .container {
            max-width: 1150px;
            margin: auto;
        }

        h1 {
            color: #218838;
            margin-bottom: 5px;
        }

        .subtitle {
            color: #617267;
            margin-bottom: 25px;
        }

        .panel {
            background: white;
            padding: 22px;
            margin-bottom: 22px;
            border-radius: 10px;
            box-shadow: 0 2px 8px #00000010;
        }

        .reminders {
            border-left: 6px solid #f0ad4e;
        }

        .reminder-item {
            padding: 12px 0;
            border-bottom: 1px solid #eeeeee;
        }

        .success {
            color: #218838;
            font-weight: bold;
        }

        .warning {
            color: #b86b00;
            font-weight: bold;
        }

        .danger {
            color: #c62828;
            font-weight: bold;
        }

        .count {
            display: inline-block;
            background: #fff0d5;
            color: #8a5100;
            padding: 5px 11px;
            border-radius: 15px;
            font-weight: bold;
        }

        .form-row {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        input {
            padding: 11px;
            border: 1px solid #cccccc;
            border-radius: 5px;
            font-size: 14px;
            max-width: 100%;
        }

        .form-row input[type="text"] {
            flex: 2;
            min-width: 140px;
        }

        .form-row input[type="number"],
        .form-row input[type="date"] {
            flex: 1;
            min-width: 140px;
        }

        button {
            padding: 10px 15px;
            background: #218838;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }

        button:hover {
            opacity: 0.85;
        }

        .delete {
            background: #c62828;
        }

        .search-form {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin: 15px 0;
        }

        .search-form input {
            flex: 1;
            min-width: 180px;
        }

        .reset-link {
            display: inline-flex;
            align-items: center;
            color: #218838;
            font-weight: bold;
            text-decoration: none;
            padding: 8px;
        }

        .search-result {
            color: #617267;
            font-size: 14px;
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }

        th, td {
            padding: 13px;
            text-align: left;
            border-bottom: 1px solid #dddddd;
        }

        th {
            background: #218838;
            color: white;
        }

        tbody tr:hover {
            background: #f7fbf8;
        }

        .edit-link {
            color: #1769aa;
            cursor: pointer;
            font-weight: bold;
            margin-bottom: 8px;
        }

        .update-form {
            display: flex;
            flex-direction: column;
            gap: 8px;
            min-width: 170px;
            margin: 10px 0;
        }

        .update-form label {
            font-size: 13px;
            font-weight: bold;
        }

        .update-form input {
            width: 100%;
            min-width: 0;
        }

        .empty {
            color: #777777;
            text-align: center;
            padding: 20px;
        }

        .note {
            font-size: 13px;
            color: #68756c;
            margin-top: 18px;
            line-height: 1.5;
        }

        .status-legend {
            line-height: 2;
            font-size: 14px;
        }

        @media (max-width: 700px) {
            body {
                padding: 10px;
            }

            .panel {
                padding: 14px;
            }

            th, td {
                padding: 9px;
                font-size: 13px;
            }
        }
    </style>
</head>

<body>

<div class="container">

    <h1>FoodFresh</h1>

    <p class="subtitle">
        Food Freshness Monitoring and Consume-By Date Reminder System
    </p>

    <!-- Consume-by reminders -->
    <div class="panel reminders">

        <h2>Consume-By Reminders</h2>

        <% if (reminderCount == 0) { %>

            <p>No food items are due within the next 3 days.</p>

        <% } else { %>

            <p>
                <span class="count"><%= reminderCount %></span>
                food item(s) need attention within the next 3 days.
            </p>

            <% for (Map<String, Object> food : foods) {

                java.sql.Date consumeDate =
                    (java.sql.Date) food.get("consume_by");

                if (consumeDate != null) {

                    long daysLeft = ChronoUnit.DAYS.between(
                        today, consumeDate.toLocalDate());

                    if (daysLeft >= 0 && daysLeft <= 3) {
            %>

                <div class="reminder-item">

                    <strong><%= esc(food.get("name")) %></strong>
                    &mdash;

                    <% if (daysLeft == 0) { %>

                        <span class="danger">Consume today!</span>

                    <% } else { %>

                        <span class="warning">
                            Consume within <%= daysLeft %> day(s)
                        </span>

                    <% } %>

                    (Date: <%= consumeDate %>)

                </div>

            <%
                    }
                }
            } %>

        <% } %>

    </div>

    <!-- Add food -->
    <div class="panel">

        <h2>Add Food Item</h2>

        <form action="foods" method="post">

            <input type="hidden" name="action" value="add">

            <div class="form-row">

                <input type="text"
                       name="name"
                       placeholder="Food name"
                       maxlength="100"
                       required>

                <input type="number"
                       name="quantity"
                       placeholder="Quantity"
                       min="1"
                       required>

                <input type="date"
                       name="consume_by"
                       min="<%= today %>"
                       required>

                <button type="submit">Add Food</button>

            </div>

        </form>

    </div>

    <!-- Inventory -->
    <div class="panel">

        <h2>Food Inventory</h2>

        <!-- Search -->
        <form action="foods" method="get" class="search-form">

            <input type="text"
                   name="search"
                   placeholder="Search food by name..."
                   value="<%= esc(searchTerm) %>">

            <button type="submit">Search</button>

            <a href="foods" class="reset-link">Show All</a>

        </form>

        <p class="search-result">
            <%= foods.size() %> matching food item(s) found.
        </p>

        <div class="table-wrapper">

            <table>

                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Food Name</th>
                        <th>Quantity</th>
                        <th>Consume-By Date</th>
                        <th>Freshness Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>

                <tbody>

                <% if (foods.isEmpty()) { %>

                    <tr>
                        <td colspan="6" class="empty">
                            No food items found.
                        </td>
                    </tr>

                <% } else {

                    for (Map<String, Object> food : foods) {

                        java.sql.Date consumeDate =
                            (java.sql.Date) food.get("consume_by");

                        long daysLeft = consumeDate == null
                            ? Long.MIN_VALUE
                            : ChronoUnit.DAYS.between(
                                today, consumeDate.toLocalDate());

                        String status;
                        String statusClass;

                        if (consumeDate == null) {
                            status = "Date unavailable";
                            statusClass = "";
                        } else if (daysLeft < 0) {
                            status = "Expired";
                            statusClass = "danger";
                        } else if (daysLeft == 0) {
                            status = "Consume Today";
                            statusClass = "danger";
                        } else if (daysLeft <= 3) {
                            status = "Consume Soon";
                            statusClass = "warning";
                        } else {
                            status = "Fresh";
                            statusClass = "success";
                        }
                %>

                    <tr>

                        <td><%= food.get("id") %></td>

                        <td><%= esc(food.get("name")) %></td>

                        <td><%= food.get("quantity") %></td>

                        <td>
                            <%= consumeDate == null
                                ? "N/A" : consumeDate %>
                        </td>

                        <td class="<%= statusClass %>">

                            <%= status %>

                            <% if (consumeDate != null
                                    && daysLeft > 0) { %>

                                <br>
                                <small>
                                    <%= daysLeft %> day(s) remaining
                                </small>

                            <% } %>

                        </td>

                        <td>

                            <!-- Update food -->
                            <details>

                                <summary class="edit-link">
                                    Edit / Update
                                </summary>

                                <form action="foods"
                                      method="post"
                                      class="update-form">

                                    <input type="hidden"
                                           name="action"
                                           value="update">

                                    <input type="hidden"
                                           name="id"
                                           value="<%= food.get("id") %>">

                                    <label>Food Name</label>

                                    <input type="text"
                                           name="name"
                                           value="<%= esc(food.get("name")) %>"
                                           maxlength="100"
                                           required>

                                    <label>Quantity</label>

                                    <input type="number"
                                           name="quantity"
                                           value="<%= food.get("quantity") %>"
                                           min="1"
                                           required>

                                    <label>Consume-By Date</label>

                                    <input type="date"
                                           name="consume_by"
                                           value="<%= consumeDate == null
                                               ? "" : consumeDate.toString() %>"
                                           required>

                                    <button type="submit">
                                        Save Update
                                    </button>

                                </form>

                            </details>

                            <!-- Delete food -->
                            <form action="foods"
                                  method="post"
                                  onsubmit="return confirm('Delete this food item?');">

                                <input type="hidden"
                                       name="action"
                                       value="delete">

                                <input type="hidden"
                                       name="id"
                                       value="<%= food.get("id") %>">

                                <button type="submit" class="delete">
                                    Delete
                                </button>

                            </form>

                        </td>

                    </tr>

                <%
                    }
                } %>

                </tbody>

            </table>

        </div>

        <h3>Freshness Status Guide</h3>

        <div class="status-legend">
            <span class="success">Fresh</span> —
            More than 3 days remaining<br>

            <span class="warning">Consume Soon</span> —
            1 to 3 days remaining<br>

            <span class="danger">Consume Today</span> —
            Consume-by date is today<br>

            <span class="danger">Expired</span> —
            Consume-by date has passed
        </div>

        <p class="note">
            Statuses are calculated using the consume-by date.
            These date-based reminders do not guarantee food safety.
            Always follow storage instructions and check food before eating.
        </p>

    </div>

</div>

</body>
</html>
