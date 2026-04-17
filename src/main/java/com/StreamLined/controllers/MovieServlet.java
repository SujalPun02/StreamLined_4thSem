package com.StreamLined.controllers;

import com.StreamLined.model.Movie;
import com.StreamLined.model.Review;
import com.StreamLined.model.User;
import com.StreamLined.services.MovieService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * MovieServlet — handles the movie catalog, detail page, search,
 *               watchlist toggles, and review submissions.
 *
 * GET  /movies              → full movie catalog
 * GET  /movies?search=query → search results
 * GET  /movies?id=N         → movie detail page
 * POST /movies?action=addWatchlist    → add to watchlist
 * POST /movies?action=removeWatchlist → remove from watchlist
 * POST /movies?action=review          → submit a review
 */
@WebServlet("/movies")
public class MovieServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private final MovieService movieService = new MovieService();

    // ── GET ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Guard
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String idParam     = req.getParameter("id");
        String searchParam = req.getParameter("search");

        try {
            if (idParam != null) {
                // ── Detail page ──────────────────────────────────────────
                int movieId = Integer.parseInt(idParam);
                Movie movie = movieService.getMovieById(movieId);

                if (movie == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Movie not found");
                    return;
                }

                User user = (User) session.getAttribute("user");
                boolean inWatchlist = movieService.isInWatchlist(user.getUserId(), movieId);
                List<Review> reviews = movieService.getReviewsForMovie(movieId);

                req.setAttribute("movie",       movie);
                req.setAttribute("inWatchlist", inWatchlist);
                req.setAttribute("reviews",     reviews);
                req.getRequestDispatcher("/WEB-INF/pages/movieDetail.jsp").forward(req, resp);

            } else if (searchParam != null && !searchParam.isBlank()) {
                // ── Search ───────────────────────────────────────────────
                List<Movie> results = movieService.searchMovies(searchParam);
                req.setAttribute("movies",      results);
                req.setAttribute("searchQuery", searchParam);
                req.getRequestDispatcher("/WEB-INF/pages/home.jsp").forward(req, resp);

            } else {
                // ── Full catalog ─────────────────────────────────────────
                List<Movie> movies = movieService.getAllMovies();
                req.setAttribute("movies", movies);
                req.getRequestDispatcher("/WEB-INF/pages/home.jsp").forward(req, resp);
            }

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid movie ID");
        } catch (SQLException e) {
            req.setAttribute("error", "Something went wrong loading movies.");
            req.getRequestDispatcher("/WEB-INF/pages/home.jsp").forward(req, resp);
        }
    }

    // ── POST ────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User   user   = (User) session.getAttribute("user");
        String action = req.getParameter("action");
        String idParam = req.getParameter("movieId");

        if (idParam == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/movies");
            return;
        }

        int movieId;
        try {
            movieId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/movies");
            return;
        }

        try {
            switch (action) {

                case "addWatchlist":
                    movieService.addToWatchlist(user.getUserId(), movieId);
                    break;

                case "removeWatchlist":
                    movieService.removeFromWatchlist(user.getUserId(), movieId);
                    break;

                case "review":
                    String ratingStr = req.getParameter("rating");
                    String comment   = req.getParameter("comment");
                    if (ratingStr != null && !comment.isBlank()) {
                        Review review = new Review(user.getUserId(), movieId,
                                Integer.parseInt(ratingStr), comment.trim());
                        movieService.addReview(review);
                    }
                    break;

                default:
                    // Unknown action — ignore
                    break;
            }

        } catch (SQLException e) {
            // Log silently; redirect anyway to prevent error page exposure
        }

        resp.sendRedirect(req.getContextPath() + "/movies?id=" + movieId);
    }
}
