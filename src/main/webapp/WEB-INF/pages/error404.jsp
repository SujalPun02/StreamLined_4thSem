<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StreamLined – Page Not Found</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
</head>
<body class="error-page">
    <div class="error-content">
        <div class="error-code">404</div>
        <h1 class="error-title">Page Not Found</h1>
        <p class="error-message">
            The page you're looking for doesn't exist or may have been moved.
            Head back and keep streaming.
        </p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary btn-lg">
            ▶ Back to Home
        </a>
    </div>
</body>
</html>
