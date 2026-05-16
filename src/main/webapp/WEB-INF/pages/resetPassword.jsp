<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String errorMsg = (String) request.getAttribute("error");
    String token = (String) request.getAttribute("token");

    if (token == null) {
        token = request.getParameter("token");
    }

    if (token == null) {
        token = "";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StreamLined – Reset Password</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
</head>

<body class="auth-page">

<div class="auth-wrapper">
    <div class="auth-card">

        <div class="auth-logo">
            <span class="logo-icon">▶</span>
            <span class="logo-text">StreamLined</span>
        </div>

        <h2 class="auth-title">Reset Password</h2>
        <p class="auth-subtitle">Create a new password for your account</p>

        <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
            <div class="alert alert-error">
                <%= errorMsg %>
            </div>
        <% } %>

        <% if (token == null || token.trim().isEmpty()) { %>

            <p class="auth-switch">
                Invalid reset link.
                <a href="<%= request.getContextPath() %>/forgot-password">Try again</a>
            </p>

        <% } else { %>

            <form action="<%= request.getContextPath() %>/reset-password" method="post">

                <input type="hidden" name="token" value="<%= token %>">

                <div class="form-group">
                    <label for="newPassword">New Password</label>
                    <input type="password"
                           id="newPassword"
                           name="newPassword"
                           placeholder="Enter new password"
                           required>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password"
                           id="confirmPassword"
                           name="confirmPassword"
                           placeholder="Repeat new password"
                           required>
                </div>

                <button type="submit" class="btn btn-primary btn-block">
                    Reset Password
                </button>
            </form>

        <% } %>

        <p class="auth-switch">
            Back to
            <a href="<%= request.getContextPath() %>/login">Sign in</a>
        </p>

    </div>
</div>

</body>
</html>