<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StreamLined – Login</title>
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

        <h2 class="auth-title">Welcome back</h2>
        <p class="auth-subtitle">Sign in to continue watching</p>

        <!-- Success message from register redirect -->
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success">${sessionScope.successMsg}</div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>

        <!-- Error message -->
        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-error">${requestScope.error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post" novalidate>

            <div class="form-group">
                <label for="identifier">Username or Email</label>
                <input type="text" id="identifier" name="identifier"
                       placeholder="Enter your username or email"
                       value="${not empty param.identifier ? param.identifier : ''}"
                       required autofocus>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password"
                       placeholder="Enter your password" required>
            </div>

            <button type="submit" class="btn btn-primary btn-block">Sign In</button>
        </form>

        <p class="auth-switch">
            Don't have an account?
            <a href="${pageContext.request.contextPath}/register">Create one</a>
        </p>
    </div>
</div>

</body>
</html>
