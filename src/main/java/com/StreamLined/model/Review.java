package com.StreamLined.model;

import java.sql.Timestamp;

/**
 * Review model — mirrors the `reviews` table.
 */
public class Review {

    private int       reviewId;
    private int       userId;
    private int       movieId;
    private int       rating;      // 1–5
    private String    comment;
    private String    username;    // joined from users table for display
    private Timestamp createdAt;

    // ── Constructors ────────────────────────────────────────────────────────

    public Review() {}

    public Review(int userId, int movieId, int rating, String comment) {
        this.userId  = userId;
        this.movieId = movieId;
        this.rating  = rating;
        this.comment = comment;
    }

    // ── Getters & Setters ───────────────────────────────────────────────────

    public int    getReviewId()        { return reviewId; }
    public void   setReviewId(int v)   { this.reviewId = v; }

    public int    getUserId()          { return userId; }
    public void   setUserId(int v)     { this.userId = v; }

    public int    getMovieId()         { return movieId; }
    public void   setMovieId(int v)    { this.movieId = v; }

    public int    getRating()          { return rating; }
    public void   setRating(int v)     { this.rating = v; }

    public String getComment()         { return comment; }
    public void   setComment(String v) { this.comment = v; }

    public String getUsername()          { return username; }
    public void   setUsername(String v)  { this.username = v; }

    public Timestamp getCreatedAt()            { return createdAt; }
    public void      setCreatedAt(Timestamp v) { this.createdAt = v; }

    /** Returns a filled-star string like "★★★★☆" */
    public String getStars() {
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 5; i++) sb.append(i <= rating ? "★" : "☆");
        return sb.toString();
    }
}
