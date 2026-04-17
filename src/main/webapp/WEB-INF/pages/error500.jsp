<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StreamLined – Server Error</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
</head>
<body class="error-page">
    <div class="error-content">
        <div class="error-code">500</div>
        <h1 class="error-title">Something Went Wrong</h1>
        <p class="error-message">
            We ran into an unexpected problem on our end.
            Please try again in a moment.
        </p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary btn-lg">
            ▶ Back to Home
        </a>
    </div>
</body>
</html>
