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
 * MovieServlet
 * GET  /movies              -> full movie catalog
 * GET  /movies?search=query -> search results
 * GET  /movies?id=N         -> movie detail page
 * POST /movies              -> watchlist and review actions
 */
@WebServlet("/movies")
public class MovieServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final MovieService movieService = new MovieService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String idParam = req.getParameter("id");
        String searchParam = req.getParameter("search");

        try {

            // Movie detail page
            if (idParam != null && !idParam.trim().isEmpty()) {

                int movieId = Integer.parseInt(idParam.trim());

                System.out.println("Clicked movie id: " + movieId);

                Movie movie = movieService.getMovieById(movieId);

                // Fallback: if getMovieById fails, search from all movies
                if (movie == null) {
                    List<Movie> allMovies = movieService.getAllMovies();

                    for (Movie m : allMovies) {
                        if (m.getMovieId() == movieId) {
                            movie = m;
                            break;
                        }
                    }
                }

                if (movie == null) {
                    List<Movie> movies = movieService.getAllMovies();

                    req.setAttribute("movies", movies);
                    req.setAttribute("error", "Movie not found. Please check movie_id in database.");

                    req.getRequestDispatcher("/WEB-INF/pages/movies.jsp").forward(req, resp);
                    return;
                }

                User user = (User) session.getAttribute("user");

                boolean inWatchlist = movieService.isInWatchlist(user.getUserId(), movieId);
                List<Review> reviews = movieService.getReviewsForMovie(movieId);

                req.setAttribute("movie", movie);
                req.setAttribute("inWatchlist", inWatchlist);
                req.setAttribute("reviews", reviews);

                req.getRequestDispatcher("/WEB-INF/pages/movieDetails.jsp").forward(req, resp);
                return;
            }

            // Search movies
            if (searchParam != null && !searchParam.trim().isEmpty()) {

                List<Movie> results = movieService.searchMovies(searchParam.trim());

                req.setAttribute("movies", results);
                req.setAttribute("searchQuery", searchParam.trim());

                req.getRequestDispatcher("/WEB-INF/pages/movies.jsp").forward(req, resp);
                return;
            }

            // Full movie catalog
            List<Movie> movies = movieService.getAllMovies();

            req.setAttribute("movies", movies);

            req.getRequestDispatcher("/WEB-INF/pages/movies.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            e.printStackTrace();

            List<Movie> movies = null;

            try {
                movies = movieService.getAllMovies();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }

            req.setAttribute("movies", movies);
            req.setAttribute("error", "Invalid movie ID.");

            req.getRequestDispatcher("/WEB-INF/pages/movies.jsp").forward(req, resp);

        } catch (SQLException e) {
            e.printStackTrace();

            req.setAttribute("error", "Something went wrong loading movies. Please check database and console.");
            req.getRequestDispatcher("/WEB-INF/pages/movies.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();

            req.setAttribute("error", "Unexpected error occurred. Please check console.");
            req.getRequestDispatcher("/WEB-INF/pages/movies.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        String action = req.getParameter("action");
        String idParam = req.getParameter("movieId");

        if (action == null || action.trim().isEmpty()
                || idParam == null || idParam.trim().isEmpty()) {

            resp.sendRedirect(req.getContextPath() + "/movies");
            return;
        }

        int movieId;

        try {
            movieId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/movies");
            return;
        }

        try {

            if ("addWatchlist".equals(action)) {

                movieService.addToWatchlist(user.getUserId(), movieId);

            } else if ("removeWatchlist".equals(action)) {

                movieService.removeFromWatchlist(user.getUserId(), movieId);

            } else if ("review".equals(action)) {

                String ratingStr = req.getParameter("rating");
                String comment = req.getParameter("comment");

                if (ratingStr != null && !ratingStr.trim().isEmpty()
                        && comment != null && !comment.trim().isEmpty()) {

                    int rating = Integer.parseInt(ratingStr.trim());

                    Review review = new Review(
                            user.getUserId(),
                            movieId,
                            rating,
                            comment.trim()
                    );

                    movieService.addReview(review);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();

        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        resp.sendRedirect(req.getContextPath() + "/movies?id=" + movieId);
    }
}