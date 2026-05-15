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
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    List<Movie> topMovies = (List<Movie>) request.getAttribute("topMovies");
    List<Movie> allMovies = (List<Movie>) request.getAttribute("allMovies");
    List<Movie> watchlist = (List<Movie>) request.getAttribute("watchlist");
    String errorMsg = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StreamLined – Dashboard</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
</head>

<body>

<header class="site-header">
    <div class="header-inner">

        <a href="<%= request.getContextPath() %>/dashboard" class="site-logo">
            <span class="logo-icon">▶</span> StreamLined
        </a>

        <nav class="site-nav">
            <a href="<%= request.getContextPath() %>/dashboard" class="active">Home</a>
            <a href="<%= request.getContextPath() %>/movies">Movies</a>

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
    <div class="container">

        <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
            <div class="alert alert-error">
                <%= errorMsg %>
            </div>
        <% } %>

        <!-- Top Movies Section -->
        <section class="catalog-section">
            <h1 class="section-title">Top Picks for You</h1>

            <% if (topMovies == null || topMovies.isEmpty()) { %>

                <p class="empty-state">No top movies available.</p>

            <% } else { %>

                <div class="movie-grid">

                    <% for (Movie movie : topMovies) { %>

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
                                <h3 class="movie-title"><%= movie.getTitle() %></h3>
                                <p class="movie-meta">
                                    <%= movie.getGenre() %> · <%= movie.getReleaseYear() %>
                                </p>
                            </div>

                        </a>

                    <% } %>

                </div>

            <% } %>
        </section>

        <!-- Watchlist Section -->
        <section class="catalog-section">
            <h2 class="section-title">My Watchlist</h2>

            <% if (watchlist == null || watchlist.isEmpty()) { %>

                <p class="empty-state">
                    Your watchlist is empty.
                    <a href="<%= request.getContextPath() %>/movies">Browse movies</a> to add some.
                </p>

            <% } else { %>

                <div class="movie-grid">

                    <% for (Movie movie : watchlist) { %>

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
                                <h3 class="movie-title"><%= movie.getTitle() %></h3>
                                <p class="movie-meta">
                                    <%= movie.getGenre() %> · <%= movie.getReleaseYear() %>
                                </p>
                            </div>

                        </a>

                    <% } %>

                </div>

            <% } %>
        </section>

        <!-- All Movies Section -->
        <section class="catalog-section">
            <h2 class="section-title">All Movies</h2>

            <% if (allMovies == null || allMovies.isEmpty()) { %>

                <p class="empty-state">No movies found.</p>

            <% } else { %>

                <div class="movie-grid">

                    <% for (Movie movie : allMovies) { %>

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
                                <h3 class="movie-title"><%= movie.getTitle() %></h3>
                                <p class="movie-meta">
                                    <%= movie.getGenre() %> · <%= movie.getReleaseYear() %>
                                </p>
                            </div>

                        </a>

                    <% } %>

                </div>

            <% } %>
        </section>

    </div>
</main>

<footer class="site-footer">
    <div class="container">
        <p>&copy; 2025 StreamLined. Built with Java MVC.</p>
    </div>
</footer>

</body>
</html>