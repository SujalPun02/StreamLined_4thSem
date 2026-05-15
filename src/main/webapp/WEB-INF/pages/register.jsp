<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String errorMsg = (String) request.getAttribute("error");

    String prevUsername = (String) request.getAttribute("prevUsername");
    String prevEmail = (String) request.getAttribute("prevEmail");

    if (prevUsername == null) {
        prevUsername = "";
    }

    if (prevEmail == null) {
        prevEmail = "";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StreamLined – Register</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
</head>

<body class="auth-page">

<div class="auth-wrapper">
    <div class="auth-card">

        <!-- Logo -->
        <div class="auth-logo">
            <span class="logo-icon">▶</span>
            <span class="logo-text">StreamLined</span>
        </div>

        <h2 class="auth-title">Create an account</h2>
        <p class="auth-subtitle">Join and start exploring movies</p>

        <!-- Red error message only after Create Account click -->
        <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
            <div class="alert alert-error">
                <%= errorMsg %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/register" method="post" novalidate>

            <div class="form-group">
                <label for="username">Username</label>
                <input type="text"
                       id="username"
                       name="username"
                       placeholder="Choose a username"
                       value="<%= prevUsername %>"
                       required>
            </div>

            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email"
                       id="email"
                       name="email"
                       placeholder="you@example.com"
                       value="<%= prevEmail %>"
                       required>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password"
                       id="password"
                       name="password"
                       placeholder="At least 6 characters"
                       required>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <input type="password"
                       id="confirmPassword"
                       name="confirmPassword"
                       placeholder="Repeat your password"
                       required>
            </div>

            <button type="submit" class="btn btn-primary btn-block">
                Create Account
            </button>
        </form>

        <p class="auth-switch">
            Already have an account?
            <a href="${pageContext.request.contextPath}/login">Sign in</a>
        </p>

    </div>
</div>

</body>
</html>