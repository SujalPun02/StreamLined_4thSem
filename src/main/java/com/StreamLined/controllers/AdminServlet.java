package com.StreamLined.controllers;

import com.StreamLined.model.Movie;
import com.StreamLined.model.User;
import com.StreamLined.services.MovieService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

/**
 * AdminServlet
 * GET  /admin -> shows admin panel
 * POST /admin -> add, update, delete movies
 */
@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final MovieService movieService = new MovieService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) {
            return;
        }

        try {
            List<Movie> movies = movieService.getAllMovies();
            req.setAttribute("movies", movies);

            String editId = req.getParameter("edit");

            if (editId != null && !editId.trim().isEmpty()) {
                int movieId = Integer.parseInt(editId.trim());
                Movie editMovie = movieService.getMovieById(movieId);

                if (editMovie != null) {
                    req.setAttribute("editMovie", editMovie);
                } else {
                    req.getSession().setAttribute("adminError", "Movie not found for editing.");
                    resp.sendRedirect(req.getContextPath() + "/admin");
                    return;
                }
            }

            req.getRequestDispatcher("/WEB-INF/pages/adminPanel.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            req.getSession().setAttribute("adminError", "Invalid movie ID.");
            resp.sendRedirect(req.getContextPath() + "/admin");

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Could not load admin panel. Please check database.");
            req.getRequestDispatcher("/WEB-INF/pages/adminPanel.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) {
            return;
        }

        String action = req.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            req.getSession().setAttribute("adminError", "Invalid admin action.");
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        try {
            if ("add".equals(action)) {
                addMovie(req, resp);
                return;
            }

            if ("update".equals(action)) {
                updateMovie(req, resp);
                return;
            }

            if ("delete".equals(action)) {
                deleteMovie(req, resp);
                return;
            }

            req.getSession().setAttribute("adminError", "Unknown admin action.");
            resp.sendRedirect(req.getContextPath() + "/admin");

        } catch (SQLException e) {
            e.printStackTrace();
            req.getSession().setAttribute("adminError", "Database error occurred. Please try again.");
            resp.sendRedirect(req.getContextPath() + "/admin");

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("adminError", "Unexpected error occurred. Please try again.");
            resp.sendRedirect(req.getContextPath() + "/admin");
        }
    }

    private void addMovie(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, SQLException {

        Movie movie = buildMovieFromRequest(req);

        String validationError = validateMovie(movie);

        if (validationError != null) {
            req.getSession().setAttribute("adminError", validationError);
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        boolean success = movieService.addMovie(movie);

        if (success) {
            req.getSession().setAttribute("adminSuccess", "Movie added successfully.");
        } else {
            req.getSession().setAttribute("adminError", "Movie could not be added.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin");
    }

    private void updateMovie(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, SQLException {

        String movieIdParam = req.getParameter("movieId");

        if (movieIdParam == null || movieIdParam.trim().isEmpty()) {
            req.getSession().setAttribute("adminError", "Movie ID is missing.");
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        int movieId = Integer.parseInt(movieIdParam.trim());

        Movie movie = buildMovieFromRequest(req);
        movie.setMovieId(movieId);

        String validationError = validateMovie(movie);

        if (validationError != null) {
            req.getSession().setAttribute("adminError", validationError);
            resp.sendRedirect(req.getContextPath() + "/admin?edit=" + movieId);
            return;
        }

        boolean success = movieService.updateMovie(movie);

        if (success) {
            req.getSession().setAttribute("adminSuccess", "Movie updated successfully.");
        } else {
            req.getSession().setAttribute("adminError", "Movie could not be updated.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin");
    }

    private void deleteMovie(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, SQLException {

        String movieIdParam = req.getParameter("movieId");

        if (movieIdParam == null || movieIdParam.trim().isEmpty()) {
            req.getSession().setAttribute("adminError", "Movie ID is missing.");
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        int movieId = Integer.parseInt(movieIdParam.trim());

        boolean success = movieService.deleteMovie(movieId);

        if (success) {
            req.getSession().setAttribute("adminSuccess", "Movie deleted successfully.");
        } else {
            req.getSession().setAttribute("adminError", "Movie could not be deleted.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin");
    }

    private Movie buildMovieFromRequest(HttpServletRequest req) {

        String title = req.getParameter("title");
        String genre = req.getParameter("genre");
        String synopsis = req.getParameter("synopsis");
        String releaseYear = req.getParameter("releaseYear");
        String rating = req.getParameter("rating");
        String posterUrl = req.getParameter("posterUrl");
        String trailerUrl = req.getParameter("trailerUrl");

        Movie movie = new Movie();

        movie.setTitle(title == null ? "" : title.trim());
        movie.setGenre(genre == null ? "" : genre.trim());
        movie.setSynopsis(synopsis == null ? "" : synopsis.trim());
        movie.setPosterUrl(posterUrl == null ? "" : posterUrl.trim());
        movie.setTrailerUrl(trailerUrl == null ? "" : trailerUrl.trim());

        try {
            movie.setReleaseYear(Integer.parseInt(releaseYear.trim()));
        } catch (Exception e) {
            movie.setReleaseYear(0);
        }

        try {
            movie.setRating(Double.parseDouble(rating.trim()));
        } catch (Exception e) {
            movie.setRating(-1);
        }

        return movie;
    }

    private String validateMovie(Movie movie) {

        int currentYear = LocalDate.now().getYear();

        if (isBlank(movie.getTitle())) {
            return "Movie title is required.";
        }

        if (movie.getTitle().length() < 2 || movie.getTitle().length() > 150) {
            return "Movie title must be between 2 and 150 characters.";
        }

        if (isBlank(movie.getGenre())) {
            return "Movie genre is required.";
        }

        if (movie.getGenre().length() < 2 || movie.getGenre().length() > 50) {
            return "Genre must be between 2 and 50 characters.";
        }

        if (isBlank(movie.getSynopsis())) {
            return "Synopsis is required.";
        }

        if (movie.getSynopsis().length() < 10) {
            return "Synopsis must be at least 10 characters.";
        }

        if (movie.getReleaseYear() < 1888 || movie.getReleaseYear() > currentYear + 1) {
            return "Please enter a valid release year.";
        }

        if (movie.getRating() < 0 || movie.getRating() > 5) {
            return "Rating must be between 0 and 5.";
        }

        if (!isBlank(movie.getPosterUrl()) && !isValidUrlOrLocalPath(movie.getPosterUrl())) {
            return "Poster URL must be a valid online URL or local path like images/poster.jpg.";
        }

        if (!isBlank(movie.getTrailerUrl()) && !isValidUrl(movie.getTrailerUrl())) {
            return "Trailer URL must be a valid online URL.";
        }

        return null;
    }

    private boolean isValidUrl(String value) {
        return value.startsWith("http://") || value.startsWith("https://");
    }

    private boolean isValidUrlOrLocalPath(String value) {
        return value.startsWith("http://")
                || value.startsWith("https://")
                || value.startsWith("images/");
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private boolean isAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }

        User user = (User) session.getAttribute("user");

        if (!user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return false;
        }

        return true;
    }
}