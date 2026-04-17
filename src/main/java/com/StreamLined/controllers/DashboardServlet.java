package com.StreamLined.controllers;

import com.StreamLined.model.Movie;
import com.StreamLined.model.User;
import com.StreamLined.services.MovieService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * DashboardServlet
 * GET /dashboard → loads top movies + watchlist and forwards to dashboard.jsp
 */
@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private final MovieService movieService = new MovieService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Guard: must be logged in
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            List<Movie> topMovies = movieService.getTopMovies(6);
            List<Movie> allMovies = movieService.getAllMovies();
            List<Movie> watchlist = movieService.getWatchlist(user.getUserId());

            req.setAttribute("topMovies", topMovies);
            req.setAttribute("allMovies", allMovies);
            req.setAttribute("watchlist", watchlist);

        } catch (SQLException e) {
            req.setAttribute("error", "Could not load movies. Please try again.");
        }

        req.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(req, resp);
    }
}
