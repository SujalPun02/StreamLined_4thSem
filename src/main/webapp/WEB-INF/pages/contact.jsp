<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.StreamLined.model.User" %>

<%
    User user = (User) session.getAttribute("user");

    String errorMsg = (String) request.getAttribute("error");
    String successMsg = (String) request.getAttribute("success");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StreamLined – Contact</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">

    <style>
        .contact-wrapper {
            max-width: 1000px;
            margin: 50px auto;
            padding: 0 24px;
        }

        .contact-grid {
            display: grid;
            grid-template-columns: 1fr 1.4fr;
            gap: 24px;
            margin-top: 24px;
        }

        .contact-card {
            background: #151722;
            border: 1px solid #292c3a;
            border-radius: 18px;
            padding: 28px;
        }

        .contact-card h2 {
            margin-top: 0;
            color: #fff;
        }

        .contact-card p {
            color: #c4c6d4;
            line-height: 1.7;
        }

        @media (max-width: 768px) {
            .contact-grid {
                grid-template-columns: 1fr;
            }
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
    <div class="contact-wrapper">

        <h1 class="section-title">Contact Us</h1>
        <p class="auth-subtitle">Send us your questions, feedback, or support request.</p>

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

        <div class="contact-grid">

            <div class="contact-card">
                <h2>Support Details</h2>

                <p>
                    <strong>Email:</strong><br>
                    support@streamlined.com
                </p>

                <p>
                    <strong>Location:</strong><br>
                    Pokhara, Nepal
                </p>

                <p>
                    <strong>Purpose:</strong><br>
                    StreamLined provides a simple platform for movie discovery,
                    trailer viewing, reviews, and watchlist management.
                </p>
            </div>

            <div class="contact-card">
                <h2>Send Message</h2>

                <form action="<%= request.getContextPath() %>/contact" method="post">

                    <div class="form-group">
                        <label for="name">Full Name</label>
                        <input type="text"
                               id="name"
                               name="name"
                               placeholder="Enter your name"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email"
                               id="email"
                               name="email"
                               placeholder="Enter your email"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="subject">Subject</label>
                        <input type="text"
                               id="subject"
                               name="subject"
                               placeholder="Enter message subject"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="message">Message</label>
                        <textarea id="message"
                                  name="message"
                                  placeholder="Write your message"
                                  required></textarea>
                    </div>

                    <button type="submit" class="btn btn-primary">
                        Send Message
                    </button>

                </form>
            </div>

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