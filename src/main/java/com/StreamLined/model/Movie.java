package com.StreamLined.model;

import java.sql.Timestamp;

/**
 * Movie model — mirrors the `movies` table.
 */
public class Movie {

    private int       movieId;
    private String    title;
    private String    genre;
    private String    synopsis;
    private int       releaseYear;
    private double    rating;
    private String    trailerUrl;
    private String    posterUrl;
    private Timestamp createdAt;

    // ── Constructors ────────────────────────────────────────────────────────

    public Movie() {}

    public Movie(String title, String genre, String synopsis,
                 int releaseYear, double rating, String trailerUrl, String posterUrl) {
        this.title       = title;
        this.genre       = genre;
        this.synopsis    = synopsis;
        this.releaseYear = releaseYear;
        this.rating      = rating;
        this.trailerUrl  = trailerUrl;
        this.posterUrl   = posterUrl;
    }

    // ── Getters & Setters ───────────────────────────────────────────────────

    public int    getMovieId()        { return movieId; }
    public void   setMovieId(int v)   { this.movieId = v; }

    public String getTitle()          { return title; }
    public void   setTitle(String v)  { this.title = v; }

    public String getGenre()          { return genre; }
    public void   setGenre(String v)  { this.genre = v; }

    public String getSynopsis()         { return synopsis; }
    public void   setSynopsis(String v) { this.synopsis = v; }

    public int    getReleaseYear()      { return releaseYear; }
    public void   setReleaseYear(int v) { this.releaseYear = v; }

    public double getRating()           { return rating; }
    public void   setRating(double v)   { this.rating = v; }

    public String getTrailerUrl()          { return trailerUrl; }
    public void   setTrailerUrl(String v)  { this.trailerUrl = v; }

    public String getPosterUrl()           { return posterUrl; }
    public void   setPosterUrl(String v)   { this.posterUrl = v; }

    public Timestamp getCreatedAt()            { return createdAt; }
    public void      setCreatedAt(Timestamp v) { this.createdAt = v; }

    /** Convenience: formatted star string, e.g. "4.8 ★" */
    public String getStarRating() {
        return String.format("%.1f ★", rating);
    }
}
