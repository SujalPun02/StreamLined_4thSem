<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.StreamLined.model.User" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String errorMsg = (String) request.getAttribute("error");
    String successMsg = (String) request.getAttribute("success");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StreamLined – Profile</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">

    <style>
        .profile-wrapper {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 24px;
        }

        .profile-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-top: 24px;
        }

        .profile-card {
            background: #151722;
            border: 1px solid #292c3a;
            border-radius: 16px;
            padding: 24px;
        }

        .profile-card h2 {
            margin-top: 0;
            color: #fff;
        }

        .profile-info {
            color: #b9bbc8;
            margin-bottom: 18px;
        }

        .profile-info strong {
            color: #fff;
        }

        @media (max-width: 768px) {
            .profile-grid {
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
            <a href="<%= request.getContextPath() %>/dashboard">Home</a>
            <a href="<%= request.getContextPath() %>/movies">Movies</a>
            <a href="<%= request.getContextPath() %>/profile" class="active">Profile</a>

            <% if (user.isAdmin()) { %>
                <a href="<%= request.getContextPath() %>/admin">Admin</a>
            <% } %>
        </nav>

        <div class="header-user">
            <span>Hi, <strong><%= user.getUsername() %></strong></span>
            <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>

    </div>
</header>

<main class="main-content">
    <div class="profile-wrapper">

        <h1 class="section-title">My Profile</h1>
        <p class="auth-subtitle">Manage your account details and password.</p>

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

        <div class="profile-grid">

            <!-- Update Profile -->
            <div class="profile-card">
                <h2>Account Details</h2>

                <p class="profile-info">
                    Current role:
                    <strong><%= user.getRole() %></strong>
                </p>

                <form action="<%= request.getContextPath() %>/profile" method="post">
                    <input type="hidden" name="action" value="updateProfile">

                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text"
                               id="username"
                               name="username"
                               value="<%= user.getUsername() %>"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email"
                               id="email"
                               name="email"
                               value="<%= user.getEmail() %>"
                               required>
                    </div>

                    <button type="submit" class="btn btn-primary">
                        Update Profile
                    </button>
                </form>
            </div>

            <!-- Change Password -->
            <div class="profile-card">
                <h2>Change Password</h2>

                <form action="<%= request.getContextPath() %>/profile" method="post">
                    <input type="hidden" name="action" value="changePassword">

                    <div class="form-group">
                        <label for="oldPassword">Old Password</label>
                        <input type="password"
                               id="oldPassword"
                               name="oldPassword"
                               placeholder="Enter old password"
                               required>
                    </div>

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

                    <button type="submit" class="btn btn-primary">
                        Change Password
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