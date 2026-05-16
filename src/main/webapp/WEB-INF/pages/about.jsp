<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.StreamLined.model.User" %>

<%
    User user = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StreamLined – About</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">

    <style>
        .info-wrapper {
            max-width: 1000px;
            margin: 50px auto;
            padding: 0 24px;
        }

        .info-card {
            background: #151722;
            border: 1px solid #292c3a;
            border-radius: 18px;
            padding: 32px;
            margin-bottom: 24px;
        }

        .info-card h2 {
            color: #fff;
            margin-top: 0;
        }

        .info-card p,
        .info-card li {
            color: #c4c6d4;
            line-height: 1.7;
        }

        .info-list {
            padding-left: 20px;
        }
    </style>
</head>

<body>

<header class="site-header">
    <div class="header-inner">

        <a href="<%= request.getContextPath() %>/dashboard" class="site-logo">
            <span class="logo-icon">▶</span> StreamLined
        </a>

        <nav class="site-nav">
            <% if (user != null) { %>
                <a href="<%= request.getContextPath() %>/dashboard">Home</a>
                <a href="<%= request.getContextPath() %>/movies">Movies</a>
                <a href="<%= request.getContextPath() %>/profile">Profile</a>
                <a href="<%= request.getContextPath() %>/about" class="active">About</a>
           	 	<a href="<%= request.getContextPath() %>/contact">Contact</a>

                <% if (user.isAdmin()) { %>
                    <a href="<%= request.getContextPath() %>/admin">Admin</a>
                <% } %>
            <% } %>

            
        </nav>

        <div class="header-user">
            <% if (user != null) { %>
                <span>Hi, <strong><%= user.getUsername() %></strong></span>
                <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline btn-sm">Logout</a>
            <% } else { %>
                <a href="<%= request.getContextPath() %>/login" class="btn btn-outline btn-sm">Login</a>
            <% } %>
        </div>

    </div>
</header>

<main class="main-content">
    <div class="info-wrapper">

        <h1 class="section-title">About StreamLined</h1>

        <div class="info-card">
            <h2>Project Purpose</h2>
            <p>
                StreamLined is a web-based movie streaming and discovery system developed using Java,
                JSP, Servlet, CSS, and MySQL. The purpose of this system is to allow users to browse movies,
                search for content, view movie details, watch trailers, manage watchlists, and submit reviews.
            </p>
        </div>

        <div class="info-card">
            <h2>Ethical Focus</h2>
            <p>
                The ethical aim of StreamLined is to promote safe and responsible movie browsing.
                Instead of providing illegal downloads, the system focuses on movie trailers, ratings,
                reviews, and user-managed watchlists. This supports legal content discovery and encourages
                users to make informed viewing choices.
            </p>
        </div>

        <div class="info-card">
            <h2>Main Features</h2>
            <ul class="info-list">
                <li>User registration and secure login</li>
                <li>Role-based access for admin and normal users</li>
                <li>Admin movie management with add, edit, delete, and view functions</li>
                <li>Movie search by title or genre</li>
                <li>Movie detail page with trailer background</li>
                <li>Watchlist and review management</li>
                <li>Profile and password management</li>
                <li>Forgot password and reset password feature</li>
            </ul>
        </div>

        <div class="info-card">
            <h2>Technology Used</h2>
            <p>
                This system follows the MVC architecture. Java Servlet is used as the controller,
                Java model and service classes handle data and business logic, JSP files display the view,
                and MySQL stores the data. CSS is used to create a responsive and user-friendly interface.
            </p>
        </div>

    </div>
</main>

<footer class="site-footer">
    <div class="container">
        <p>&copy; 2025 StreamLined. Built with Java MVC.</p>
    </div>
</footer>

</body>
</html>