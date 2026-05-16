<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String errorMsg = (String) request.getAttribute("error");
    String successMsg = (String) request.getAttribute("success");
    String resetLink = (String) request.getAttribute("resetLink");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StreamLined – Forgot Password</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
</head>

<body class="auth-page">

<div class="auth-wrapper">
    <div class="auth-card">

        <div class="auth-logo">
            <span class="logo-icon">▶</span>
            <span class="logo-text">StreamLined</span>
        </div>

        <h2 class="auth-title">Forgot Password</h2>
        <p class="auth-subtitle">Enter your email to generate a reset link</p>

        <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
            <div class="alert alert-error">
                <%= errorMsg %>
            </div>
        <% } %>

        <% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
            <div class="alert alert-success">
                <%= successMsg %>
            </div>
        <% } %>

        <% if (resetLink != null && !resetLink.trim().isEmpty()) { %>
            <div class="alert alert-success">
                <p>Demo reset link:</p>
                <a href="<%= request.getContextPath() %>/reset-password?token=<%= resetLink.substring(resetLink.indexOf("token=") + 6) %>">
                    Click here to reset password
                </a>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/forgot-password" method="post">

            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email"
                       id="email"
                       name="email"
                       placeholder="Enter your registered email"
                       required>
            </div>

            <button type="submit" class="btn btn-primary btn-block">
                Generate Reset Link
            </button>
        </form>

        <p class="auth-switch">
            Remembered your password?
            <a href="<%= request.getContextPath() %>/login">Sign in</a>
        </p>

    </div>
</div>

</body>
</html>