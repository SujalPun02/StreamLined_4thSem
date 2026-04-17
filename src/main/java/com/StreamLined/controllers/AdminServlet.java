package com.StreamLined.controllers;

import com.StreamLined.model.Movie;
import com.StreamLined.model.User;
import com.StreamLined.services.MovieService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * AdminServlet
 * Restricted to users with role="admin".
 *
 * GET  /admin           → list all movies
 * GET  /admin?edit=N    → pre-fill form to edit movie N
 * POST /admin?action=add    → add new movie
 * POST /admin?action=update → update existing movie
 * POST /admin?action=delete → delete movie
 */
@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private final MovieService movieService = new MovieService();

    // ── GET ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) return;

        String editParam = req.getParameter("edit");

        try {
            List<Movie> movies = movieService.getAllMovies();
            req.setAttribute("movies", movies);

            if (editParam != null) {
                Movie toEdit = movieService.getMovieById(Integer.parseInt(editParam));
                req.setAttribute("editMovie", toEdit);
            }

        } catch (SQLException e) {
            req.setAttribute("error", "Could not load movies.");
        }

        req.getRequestDispatcher("/WEB-INF/pages/adminPanel.jsp").forward(req, resp);
    }

    // ── POST ────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isAdmin(req, resp)) return;

        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {

                case "add": {
                    Movie m = buildMovieFromParams(req);
                    movieService.addMovie(m);
                    break;
                }

                case "update": {
                    Movie m = buildMovieFromParams(req);
                    m.setMovieId(Integer.parseInt(req.getParameter("movieId")));
                    movieService.updateMovie(m);
                    break;
                }

                case "delete": {
                    int id = Integer.parseInt(req.getParameter("movieId"));
                    movieService.deleteMovie(id);
                    break;
                }

                default:
                    break;
            }

        } catch (SQLException | NumberFormatException e) {
            req.getSession().setAttribute("adminError", "Operation failed. Please check your input.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin");
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    /** Returns true if the current session belongs to an admin; otherwise redirects. */
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

    private Movie buildMovieFromParams(HttpServletRequest req) {
        Movie m = new Movie();
        m.setTitle(req.getParameter("title"));
        m.setGenre(req.getParameter("genre"));
        m.setSynopsis(req.getParameter("synopsis"));
        m.setReleaseYear(Integer.parseInt(req.getParameter("releaseYear")));
        m.setRating(Double.parseDouble(req.getParameter("rating")));
        m.setTrailerUrl(req.getParameter("trailerUrl"));
        m.setPosterUrl(req.getParameter("posterUrl"));
        return m;
    }
}
