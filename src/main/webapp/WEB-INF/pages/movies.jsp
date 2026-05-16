<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.StreamLined.model.Movie" %>
<%@ page import="com.StreamLined.model.User" %>

<%!
    private String getPosterSrc(jakarta.servlet.http.HttpServletRequest request, Movie movie) {
        if (movie == null || movie.getPosterUrl() == null || movie.getPosterUrl().trim().isEmpty()) {
            return "";
        }

        String posterUrl = movie.getPosterUrl().trim();

        if (posterUrl.startsWith("http://") || posterUrl.startsWith("https://")) {
            return posterUrl;
        }

        return request.getContextPath() + "/" + posterUrl;
    }
%>

<%
    User loggedUser = (User) session.getAttribute("user");

    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
    String searchQuery = (String) request.getAttribute("searchQuery");
    String errorMsg = (String) request.getAttribute("error");

    if (searchQuery == null) {
        searchQuery = "";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StreamLined – Movies</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
</head>

<body>

<header class="site-header">
    <div class="header-inner">

        <a href="<%= request.getContextPath() %>/dashboard" class="site-logo">
            <span class="logo-icon">▶</span> StreamLined
        </a>

        <nav class="site-nav">
            <a href="<%= request.getContextPath() %>/dashboard">Home</a>
            <a href="<%= request.getContextPath() %>/movies" class="active">Movies</a>
            <a href="<%= request.getContextPath() %>/profile">Profile</a>
            <a href="<%= request.getContextPath() %>/about">About</a>
			<a href="<%= request.getContextPath() %>/contact">Contact</a>

            <% if (loggedUser.isAdmin()) { %>
                <a href="<%= request.getContextPath() %>/admin">Admin</a>
            <% } %>
        </nav>

        <div class="header-user">
            <span>Hi, <strong><%= loggedUser.getUsername() %></strong></span>
            <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>

    </div>
</header>

<main class="main-content">
    <section class="catalog-section">
        <div class="container">

            <!-- Search Bar -->
            <form action="<%= request.getContextPath() %>/movies" method="get" class="search-bar">
                <input type="text"
                       name="search"
                       placeholder="Search by title or genre..."
                       value="<%= searchQuery %>">

                <button type="submit" class="btn btn-primary">
                    Search
                </button>

                <% if (!searchQuery.trim().isEmpty()) { %>
                    <a href="<%= request.getContextPath() %>/movies" class="btn btn-ghost">
                        Clear
                    </a>
                <% } %>
            </form>

            <!-- Page Title -->
            <% if (!searchQuery.trim().isEmpty()) { %>
                <h1 class="section-title">
                    Results for <span>"<%= searchQuery %>"</span>
                </h1>
            <% } else { %>
                <h1 class="section-title">All Movies</h1>
            <% } %>

            <!-- Error Message -->
            <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
                <div class="alert alert-error">
                    <%= errorMsg %>
                </div>
            <% } %>

            <!-- Movies Grid -->
            <% if (movies == null || movies.isEmpty()) { %>

                <p class="empty-state">
                    No movies found. Try a different search term.
                </p>

            <% } else { %>

                <div class="movie-grid">

                    <% for (Movie movie : movies) { %>

                        <a href="<%= request.getContextPath() %>/movies?id=<%= movie.getMovieId() %>"
                           class="movie-card">

                            <div class="movie-poster">

                                <%
                                    String posterSrc = getPosterSrc(request, movie);
                                %>

                                <% if (posterSrc != null && !posterSrc.trim().isEmpty()) { %>
                                    <img src="<%= posterSrc %>"
                                         alt="<%= movie.getTitle() %>"
                                         loading="lazy">
                                <% } else { %>
                                    <div class="poster-placeholder">▶</div>
                                <% } %>

                                <div class="movie-overlay">
                                    <span class="movie-rating">
                                        <%= movie.getStarRating() %>
                                    </span>
                                </div>

                            </div>

                            <div class="movie-info">
                                <h3 class="movie-title">
                                    <%= movie.getTitle() %>
                                </h3>

                                <p class="movie-meta">
                                    <%= movie.getGenre() %> · <%= movie.getReleaseYear() %>
                                </p>
                            </div>

                        </a>

                    <% } %>

                </div>

            <% } %>

        </div>
    </section>
</main>

<footer class="site-footer">
    <div class="container">
        <p>&copy; 2025 StreamLined. Built with Java MVC.</p>
    </div>
</footer>

</body>
</html>