package com.StreamLined.services;

import com.StreamLined.config.DBConfig;
import com.StreamLined.model.Movie;
import com.StreamLined.model.Review;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * MovieService
 * Handles all database operations for movies, watchlists, and reviews.
 */
public class MovieService {

    // ── Movies ──────────────────────────────────────────────────────────────

    /** Returns all movies, newest first. */
    public List<Movie> getAllMovies() throws SQLException {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM movies ORDER BY created_at DESC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapMovie(rs));
        }
        return list;
    }

    /** Returns movies whose title or genre contains the search term. */
    public List<Movie> searchMovies(String query) throws SQLException {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM movies WHERE title LIKE ? OR genre LIKE ? ORDER BY rating DESC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String term = "%" + query.trim() + "%";
            ps.setString(1, term);
            ps.setString(2, term);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapMovie(rs));
            }
        }
        return list;
    }

    /** Returns a single movie by ID, or null if not found. */
    public Movie getMovieById(int movieId) throws SQLException {
        String sql = "SELECT * FROM movies WHERE movie_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapMovie(rs);
            }
        }
        return null;
    }

    /** Returns the top-N movies by rating for the dashboard hero section. */
    public List<Movie> getTopMovies(int limit) throws SQLException {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT * FROM movies ORDER BY rating DESC LIMIT ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapMovie(rs));
            }
        }
        return list;
    }

    // ── Admin CRUD ──────────────────────────────────────────────────────────

    public void addMovie(Movie m) throws SQLException {
        String sql = "INSERT INTO movies (title, genre, synopsis, release_year, rating, trailer_url, poster_url) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getTitle());
            ps.setString(2, m.getGenre());
            ps.setString(3, m.getSynopsis());
            ps.setInt(4, m.getReleaseYear());
            ps.setDouble(5, m.getRating());
            ps.setString(6, m.getTrailerUrl());
            ps.setString(7, m.getPosterUrl());
            ps.executeUpdate();
        }
    }

    public void updateMovie(Movie m) throws SQLException {
        String sql = "UPDATE movies SET title=?, genre=?, synopsis=?, release_year=?, rating=?, trailer_url=?, poster_url=? WHERE movie_id=?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getTitle());
            ps.setString(2, m.getGenre());
            ps.setString(3, m.getSynopsis());
            ps.setInt(4, m.getReleaseYear());
            ps.setDouble(5, m.getRating());
            ps.setString(6, m.getTrailerUrl());
            ps.setString(7, m.getPosterUrl());
            ps.setInt(8, m.getMovieId());
            ps.executeUpdate();
        }
    }

    public void deleteMovie(int movieId) throws SQLException {
        String sql = "DELETE FROM movies WHERE movie_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            ps.executeUpdate();
        }
    }

    // ── Watchlist ───────────────────────────────────────────────────────────

    /** Adds a movie to a user's watchlist (silently ignores duplicates). */
    public void addToWatchlist(int userId, int movieId) throws SQLException {
        String sql = "INSERT IGNORE INTO watchlist (user_id, movie_id) VALUES (?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, movieId);
            ps.executeUpdate();
        }
    }

    public void removeFromWatchlist(int userId, int movieId) throws SQLException {
        String sql = "DELETE FROM watchlist WHERE user_id = ? AND movie_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, movieId);
            ps.executeUpdate();
        }
    }

    /** Returns all movies on a user's watchlist. */
    public List<Movie> getWatchlist(int userId) throws SQLException {
        List<Movie> list = new ArrayList<>();
        String sql = "SELECT m.* FROM movies m JOIN watchlist w ON m.movie_id = w.movie_id WHERE w.user_id = ? ORDER BY w.added_at DESC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapMovie(rs));
            }
        }
        return list;
    }

    /** Returns true if the movie is already in the user's watchlist. */
    public boolean isInWatchlist(int userId, int movieId) throws SQLException {
        String sql = "SELECT 1 FROM watchlist WHERE user_id = ? AND movie_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ── Reviews ─────────────────────────────────────────────────────────────

    public void addReview(Review r) throws SQLException {
        String sql = "INSERT INTO reviews (user_id, movie_id, rating, comment) VALUES (?,?,?,?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, r.getUserId());
            ps.setInt(2, r.getMovieId());
            ps.setInt(3, r.getRating());
            ps.setString(4, r.getComment());
            ps.executeUpdate();
        }
        recalcRating(r.getMovieId()); // update aggregate rating
    }

    /** Returns all reviews for a movie, newest first, with username joined. */
    public List<Review> getReviewsForMovie(int movieId) throws SQLException {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username FROM reviews r JOIN users u ON r.user_id = u.user_id WHERE r.movie_id = ? ORDER BY r.created_at DESC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review rev = new Review();
                    rev.setReviewId(rs.getInt("review_id"));
                    rev.setUserId(rs.getInt("user_id"));
                    rev.setMovieId(rs.getInt("movie_id"));
                    rev.setRating(rs.getInt("rating"));
                    rev.setComment(rs.getString("comment"));
                    rev.setUsername(rs.getString("username"));
                    rev.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(rev);
                }
            }
        }
        return list;
    }

    /** Recalculates and saves the average rating for a movie after a new review. */
    private void recalcRating(int movieId) throws SQLException {
        String sql = "UPDATE movies SET rating = (SELECT AVG(rating) FROM reviews WHERE movie_id = ?) WHERE movie_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            ps.setInt(2, movieId);
            ps.executeUpdate();
        }
    }

    // ── Mapper ──────────────────────────────────────────────────────────────

    private Movie mapMovie(ResultSet rs) throws SQLException {
        Movie m = new Movie();
        m.setMovieId(rs.getInt("movie_id"));
        m.setTitle(rs.getString("title"));
        m.setGenre(rs.getString("genre"));
        m.setSynopsis(rs.getString("synopsis"));
        m.setReleaseYear(rs.getInt("release_year"));
        m.setRating(rs.getDouble("rating"));
        m.setTrailerUrl(rs.getString("trailer_url"));
        m.setPosterUrl(rs.getString("poster_url"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        return m;
    }
}
