<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.StreamLined.model.Movie" %>
<%@ page import="com.StreamLined.model.User" %>
<%@ page import="com.StreamLined.model.Review" %>

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

    private String getYoutubeVideoId(String trailerUrl) {
        if (trailerUrl == null || trailerUrl.trim().isEmpty()) {
            return "";
        }

        trailerUrl = trailerUrl.trim();
        String videoId = "";

        if (trailerUrl.contains("watch?v=")) {
            videoId = trailerUrl.substring(trailerUrl.indexOf("watch?v=") + 8);
            if (videoId.contains("&")) {
                videoId = videoId.substring(0, videoId.indexOf("&"));
            }
        } else if (trailerUrl.contains("youtu.be/")) {
            videoId = trailerUrl.substring(trailerUrl.indexOf("youtu.be/") + 9);
            if (videoId.contains("?")) {
                videoId = videoId.substring(0, videoId.indexOf("?"));
            }
        } else if (trailerUrl.contains("/embed/")) {
            videoId = trailerUrl.substring(trailerUrl.indexOf("/embed/") + 7);
            if (videoId.contains("?")) {
                videoId = videoId.substring(0, videoId.indexOf("?"));
            }
        }

        return videoId;
    }

    private String getYoutubeEmbedUrl(String videoId, boolean muted) {
        if (videoId == null || videoId.trim().isEmpty()) {
            return "";
        }

        return "https://www.youtube.com/embed/" + videoId
                + "?autoplay=1"
                + "&mute=" + (muted ? "1" : "0")
                + "&loop=1"
                + "&playlist=" + videoId
                + "&controls=0"
                + "&showinfo=0"
                + "&modestbranding=1"
                + "&rel=0"
                + "&playsinline=1";
    }
%>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Movie movie = (Movie) request.getAttribute("movie");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");

    Object watchlistObj = request.getAttribute("inWatchlist");
    boolean inWatchlist = false;

    if (watchlistObj instanceof Boolean) {
        inWatchlist = (Boolean) watchlistObj;
    }

    if (movie == null) {
        response.sendRedirect(request.getContextPath() + "/movies");
        return;
    }

    String posterSrc = getPosterSrc(request, movie);
    String videoId = getYoutubeVideoId(movie.getTrailerUrl());
    String trailerEmbedUrl = getYoutubeEmbedUrl(videoId, true);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>StreamLined – <%= movie.getTitle() %></title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">

    <style>
        * {
            box-sizing: border-box;
        }

        body.movie-detail-page {
            margin: 0;
            min-height: 100vh;
            background: #050505;
            color: #ffffff;
            font-family: Arial, Helvetica, sans-serif;
            overflow-x: hidden;
        }

        .cinema-bg,
        .cinema-bg-fallback {
            position: fixed;
            inset: 0;
            width: 100vw;
            height: 100vh;
            z-index: -4;
            overflow: hidden;
            background-size: cover;
            background-position: center;
        }

        .cinema-bg iframe {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 120vw;
            height: 120vh;
            transform: translate(-50%, -50%) scale(1.25);
            border: none;
            pointer-events: none;
        }

        .cinema-overlay {
            position: fixed;
            inset: 0;
            z-index: -3;
            background:
                linear-gradient(to right, rgba(0,0,0,0.95) 0%, rgba(0,0,0,0.78) 35%, rgba(0,0,0,0.30) 72%, rgba(0,0,0,0.85) 100%),
                linear-gradient(to top, #050505 0%, rgba(5,5,5,0.65) 36%, rgba(5,5,5,0.35) 100%);
        }

        .top-controls {
            position: fixed;
            top: 28px;
            left: 36px;
            right: 36px;
            z-index: 10;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .circle-btn {
            width: 52px;
            height: 52px;
            border-radius: 50%;
            border: 1px solid rgba(255,255,255,0.18);
            background: rgba(20,20,20,0.45);
            color: white;
            font-size: 26px;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            backdrop-filter: blur(10px);
        }

        .circle-btn:hover {
            background: rgba(255,255,255,0.12);
        }

        .cinema-hero {
            min-height: 100vh;
            display: flex;
            align-items: flex-end;
            padding: 0 72px 86px;
            position: relative;
            z-index: 2;
        }

        .cinema-content {
            max-width: 760px;
        }

        .genre-pill {
            display: inline-block;
            color: #ffb11a;
            border: 1px solid rgba(255,177,26,0.45);
            background: rgba(255,177,26,0.12);
            padding: 7px 16px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 18px;
        }

        .cinema-title {
            margin: 0 0 16px;
            font-size: clamp(48px, 7vw, 95px);
            line-height: 0.95;
            font-weight: 900;
            color: #ffffff;
            letter-spacing: -2px;
            text-shadow: 0 8px 30px rgba(0,0,0,0.75);
        }

        .cinema-meta {
            display: flex;
            gap: 16px;
            align-items: center;
            flex-wrap: wrap;
            color: #e4e4e4;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
        }

        .rating-text {
            color: #ffb11a;
            font-weight: 800;
        }

        .cinema-description {
            max-width: 680px;
            color: #f2f2f2;
            font-size: 19px;
            line-height: 1.7;
            margin: 0 0 30px;
            text-shadow: 0 3px 16px rgba(0,0,0,0.8);
        }

        .cinema-actions {
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
            align-items: center;
        }

        .inline-form {
            display: inline;
        }

        .hero-btn {
            min-height: 56px;
            padding: 0 26px;
            border-radius: 999px;
            border: 1px solid transparent;
            font-size: 17px;
            font-weight: 800;
            text-decoration: none;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .hero-btn-primary {
            background: #ffffff;
            color: #111111;
        }

        .hero-btn-secondary {
            background: rgba(40,40,40,0.65);
            color: #ffffff;
            border-color: rgba(255,255,255,0.16);
            backdrop-filter: blur(8px);
        }

        .hero-btn-primary:hover {
            background: #e6e6e6;
        }

        .hero-btn-secondary:hover {
            background: rgba(255,255,255,0.14);
        }

        .lower-section {
            position: relative;
            z-index: 2;
            max-width: 1150px;
            margin: 0 auto 70px;
            padding: 0 56px;
        }

        .reviews-panel {
            background: rgba(10,10,10,0.78);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 22px;
            padding: 30px;
            backdrop-filter: blur(10px);
        }

        .section-title {
            color: #ffffff;
            font-size: 32px;
            margin: 0 0 24px;
            text-transform: uppercase;
        }

        .review-form-card {
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 16px;
            padding: 22px;
            margin-bottom: 24px;
        }

        .review-form-card h3 {
            margin-top: 0;
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #d7d7d7;
            font-weight: 700;
        }

        textarea {
            width: 100%;
            min-height: 110px;
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.12);
            background: rgba(0,0,0,0.38);
            color: white;
            padding: 14px;
            resize: vertical;
        }

        .empty-state {
            color: #c7c7c7;
        }

        .review-card {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 14px;
            padding: 18px;
            margin-bottom: 14px;
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 10px;
            color: #eaeaea;
        }

        .review-user {
            font-weight: 800;
        }

        .review-stars {
            color: #ffb11a;
            margin-left: 10px;
        }

        .review-date {
            color: #aaa;
            font-size: 13px;
        }

        .review-comment {
            color: #dddddd;
            line-height: 1.6;
            margin: 0;
        }

        .star-select input {
            margin-right: 4px;
        }

        .star-select label {
            display: inline;
            color: #ffb11a;
            font-size: 22px;
            margin-right: 8px;
        }

        @media (max-width: 800px) {
            .cinema-hero {
                padding: 0 24px 60px;
            }

            .cinema-title {
                font-size: 44px;
            }

            .cinema-description {
                font-size: 16px;
            }

            .cinema-meta {
                font-size: 15px;
            }

            .lower-section {
                padding: 0 20px;
            }

            .top-controls {
                left: 20px;
                right: 20px;
            }
        }
    </style>
</head>

<body class="movie-detail-page">

<% if (trailerEmbedUrl != null && !trailerEmbedUrl.trim().isEmpty()) { %>
    <div class="cinema-bg">
        <iframe id="trailerFrame"
                data-video-id="<%= videoId %>"
                src="<%= trailerEmbedUrl %>"
                title="<%= movie.getTitle() %> trailer"
                allow="autoplay; encrypted-media"
                allowfullscreen>
        </iframe>
    </div>
<% } else if (posterSrc != null && !posterSrc.trim().isEmpty()) { %>
    <div class="cinema-bg-fallback" style="background-image: url('<%= posterSrc %>');"></div>
<% } %>

<div class="cinema-overlay"></div>

<div class="top-controls">
    <a href="<%= request.getContextPath() %>/movies" class="circle-btn">&#8249;</a>
    <button type="button" id="muteToggle" class="circle-btn">🔇</button>
</div>

<main>
    <section class="cinema-hero">
        <div class="cinema-content">

            <span class="genre-pill"><%= movie.getGenre() %></span>

            <h1 class="cinema-title"><%= movie.getTitle() %></h1>

            <div class="cinema-meta">
                <span class="rating-text">★ <%= movie.getStarRating() %></span>
                <span><%= movie.getReleaseYear() %></span>
                <span><%= movie.getGenre() %></span>
            </div>

            <p class="cinema-description">
                <%= movie.getSynopsis() %>
            </p>

            <div class="cinema-actions">

                <% if (movie.getTrailerUrl() != null && !movie.getTrailerUrl().trim().isEmpty()) { %>
                    <a href="<%= movie.getTrailerUrl() %>"
                       target="_blank"
                       rel="noopener"
                       class="hero-btn hero-btn-primary">
                        ▶ Play Trailer
                    </a>
                <% } %>

                <form action="<%= request.getContextPath() %>/movies" method="post" class="inline-form">
                    <input type="hidden" name="movieId" value="<%= movie.getMovieId() %>">

                    <% if (inWatchlist) { %>
                        <input type="hidden" name="action" value="removeWatchlist">
                        <button type="submit" class="hero-btn hero-btn-secondary">
                            ✓ In Watchlist
                        </button>
                    <% } else { %>
                        <input type="hidden" name="action" value="addWatchlist">
                        <button type="submit" class="hero-btn hero-btn-secondary">
                            + Watchlist
                        </button>
                    <% } %>
                </form>

                <a href="#reviews" class="hero-btn hero-btn-secondary">
                    Reviews
                </a>

            </div>

        </div>
    </section>

    <section id="reviews" class="lower-section">
        <div class="reviews-panel">

            <h2 class="section-title">Reviews</h2>

            <div class="review-form-card">
                <h3>Leave a Review</h3>

                <form action="<%= request.getContextPath() %>/movies" method="post">
                    <input type="hidden" name="movieId" value="<%= movie.getMovieId() %>">
                    <input type="hidden" name="action" value="review">

                    <div class="form-group">
                        <label>Your Rating</label>

                        <div class="star-select">
                            <input type="radio" id="s5" name="rating" value="5">
                            <label for="s5">★</label>

                            <input type="radio" id="s4" name="rating" value="4">
                            <label for="s4">★</label>

                            <input type="radio" id="s3" name="rating" value="3" checked>
                            <label for="s3">★</label>

                            <input type="radio" id="s2" name="rating" value="2">
                            <label for="s2">★</label>

                            <input type="radio" id="s1" name="rating" value="1">
                            <label for="s1">★</label>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="comment">Comment</label>
                        <textarea id="comment"
                                  name="comment"
                                  placeholder="Share your thoughts..."
                                  required></textarea>
                    </div>

                    <button type="submit" class="hero-btn hero-btn-primary">
                        Submit Review
                    </button>
                </form>
            </div>

            <% if (reviews == null || reviews.isEmpty()) { %>

                <p class="empty-state">
                    No reviews yet. Be the first to review this movie!
                </p>

            <% } else { %>

                <div class="reviews-list">

                    <% for (Review review : reviews) { %>

                        <div class="review-card">
                            <div class="review-header">
                                <div>
                                    <span class="review-user"><%= review.getUsername() %></span>
                                    <span class="review-stars"><%= review.getStars() %></span>
                                </div>

                                <span class="review-date"><%= review.getCreatedAt() %></span>
                            </div>

                            <p class="review-comment"><%= review.getComment() %></p>
                        </div>

                    <% } %>

                </div>

            <% } %>

        </div>
    </section>
</main>

<script>
    const trailerFrame = document.getElementById("trailerFrame");
    const muteToggle = document.getElementById("muteToggle");

    if (trailerFrame && muteToggle) {
        let muted = true;
        const videoId = trailerFrame.getAttribute("data-video-id");

        muteToggle.addEventListener("click", function () {
            muted = !muted;
            muteToggle.textContent = muted ? "🔇" : "🔊";

            trailerFrame.src =
                "https://www.youtube.com/embed/" + videoId +
                "?autoplay=1" +
                "&mute=" + (muted ? "1" : "0") +
                "&loop=1" +
                "&playlist=" + videoId +
                "&controls=0" +
                "&showinfo=0" +
                "&modestbranding=1" +
                "&rel=0" +
                "&playsinline=1";
        });
    }
</script>

</body>
</html>