<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.StreamLined.model.Movie" %>
<%@ page import="com.StreamLined.model.User" %>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    if (!user.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }

    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
    Movie editMovie = (Movie) request.getAttribute("editMovie");

    String adminError = (String) session.getAttribute("adminError");
    String errorMsg = (String) request.getAttribute("error");

    boolean isEdit = editMovie != null;

    String title = "";
    String genre = "";
    String synopsis = "";
    String releaseYear = "";
    String rating = "";
    String posterUrl = "";
    String trailerUrl = "";

    if (isEdit) {
        title = editMovie.getTitle() == null ? "" : editMovie.getTitle();
        genre = editMovie.getGenre() == null ? "" : editMovie.getGenre();
        synopsis = editMovie.getSynopsis() == null ? "" : editMovie.getSynopsis();
        releaseYear = String.valueOf(editMovie.getReleaseYear());
        rating = String.valueOf(editMovie.getRating());
        posterUrl = editMovie.getPosterUrl() == null ? "" : editMovie.getPosterUrl();
        trailerUrl = editMovie.getTrailerUrl() == null ? "" : editMovie.getTrailerUrl();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StreamLined – Admin Panel</title>
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
            <a href="<%= request.getContextPath() %>/movies">Movies</a>
            <a href="<%= request.getContextPath() %>/admin" class="active">Admin</a>
        </nav>

        <div class="header-user">
            <span>Hi, <strong><%= user.getUsername() %></strong> Admin</span>
            <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>

    </div>
</header>

<main class="main-content">
    <div class="container">

        <h1 class="section-title">Admin Panel</h1>
        <p class="auth-subtitle">Manage the StreamLined movie catalog</p>

        <a href="<%= request.getContextPath() %>/movies" class="btn btn-ghost">
            ← View Site
        </a>

        <% if (adminError != null && !adminError.trim().isEmpty()) { %>
            <div class="alert alert-error">
                <%= adminError %>
            </div>
        <%
            session.removeAttribute("adminError");
        } %>

        <% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
            <div class="alert alert-error">
                <%= errorMsg %>
            </div>
        <% } %>

        <section class="catalog-section">

            <h2 class="section-title">Movie List</h2>

            <% if (movies == null || movies.isEmpty()) { %>

                <p class="empty-state">No movies yet. Add one below.</p>

            <% } else { %>

                <div class="admin-table-wrapper">
                    <table class="admin-table">
                        <thead>
                        <tr>
                            <th>Poster</th>
                            <th>Title</th>
                            <th>Genre</th>
                            <th>Year</th>
                            <th>Rating</th>
                            <th>Actions</th>
                        </tr>
                        </thead>

                        <tbody>
                        <% for (Movie movie : movies) { %>
                            <tr>

                                <!-- Poster Column -->
                                <td>
                                    <%
                                        String rowPosterUrl = movie.getPosterUrl();
                                        String rowPosterSrc = "";

                                        if (rowPosterUrl != null && !rowPosterUrl.trim().isEmpty()) {
                                            if (rowPosterUrl.startsWith("http://") || rowPosterUrl.startsWith("https://")) {
                                                rowPosterSrc = rowPosterUrl;
                                            } else {
                                                rowPosterSrc = request.getContextPath() + "/" + rowPosterUrl;
                                            }
                                        }
                                    %>

                                    <% if (rowPosterSrc != null && !rowPosterSrc.trim().isEmpty()) { %>
                                        <img src="<%= rowPosterSrc %>"
                                             alt="<%= movie.getTitle() %>"
                                             style="width:60px; height:80px; object-fit:cover; border-radius:8px;">
                                    <% } else { %>
                                        <span>▶</span>
                                    <% } %>
                                </td>

                                <td><%= movie.getTitle() %></td>
                                <td><%= movie.getGenre() %></td>
                                <td><%= movie.getReleaseYear() %></td>
                                <td><%= movie.getStarRating() %></td>

                                <td>
                                    <a href="<%= request.getContextPath() %>/admin?edit=<%= movie.getMovieId() %>"
                                       class="btn btn-outline btn-sm">
                                        Edit
                                    </a>

                                    <form action="<%= request.getContextPath() %>/admin"
                                          method="post"
                                          style="display:inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="movieId" value="<%= movie.getMovieId() %>">

                                        <button type="submit"
                                                class="btn btn-ghost btn-sm"
                                                onclick="return confirm('Are you sure you want to delete this movie?');">
                                            Delete
                                        </button>
                                    </form>
                                </td>

                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            <% } %>

        </section>

        <section class="catalog-section">

            <% if (isEdit) { %>
                <h2 class="section-title">Edit Movie</h2>
            <% } else { %>
                <h2 class="section-title">Add New Movie</h2>
            <% } %>

            <form action="<%= request.getContextPath() %>/admin" method="post" class="admin-form">

                <% if (isEdit) { %>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="movieId" value="<%= editMovie.getMovieId() %>">
                <% } else { %>
                    <input type="hidden" name="action" value="add">
                <% } %>

                <div class="form-group">
                    <label for="title">Title</label>
                    <input type="text"
                           id="title"
                           name="title"
                           value="<%= title %>"
                           required>
                </div>

                <div class="form-group">
                    <label for="genre">Genre</label>
                    <input type="text"
                           id="genre"
                           name="genre"
                           value="<%= genre %>"
                           required>
                </div>

                <div class="form-group">
                    <label for="releaseYear">Year</label>
                    <input type="number"
                           id="releaseYear"
                           name="releaseYear"
                           value="<%= releaseYear %>"
                           required>
                </div>

                <div class="form-group">
                    <label for="rating">Rating 0–5</label>
                    <input type="number"
                           step="0.1"
                           min="0"
                           max="5"
                           id="rating"
                           name="rating"
                           value="<%= rating %>"
                           required>
                </div>

                <div class="form-group">
                    <label for="synopsis">Synopsis</label>
                    <textarea id="synopsis"
                              name="synopsis"
                              required><%= synopsis %></textarea>
                </div>

                <div class="form-group">
                    <label for="posterUrl">Poster URL</label>
                    <input type="text"
                           id="posterUrl"
                           name="posterUrl"
                           value="<%= posterUrl %>"
                           placeholder="Paste real poster image URL">
                </div>

                <div class="form-group">
                    <label for="trailerUrl">Trailer URL</label>
                    <input type="text"
                           id="trailerUrl"
                           name="trailerUrl"
                           value="<%= trailerUrl %>"
                           placeholder="YouTube trailer link">
                </div>

                <% if (isEdit) { %>
                    <button type="submit" class="btn btn-primary">
                        Save Changes
                    </button>

                    <a href="<%= request.getContextPath() %>/admin" class="btn btn-ghost">
                        Cancel
                    </a>
                <% } else { %>
                    <button type="submit" class="btn btn-primary">
                        Add Movie
                    </button>
                <% } %>

            </form>

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