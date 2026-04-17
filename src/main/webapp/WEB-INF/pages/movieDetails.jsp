<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StreamLined – ${requestScope.movie.title}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
</head>
<body>

<header class="site-header">
    <div class="header-inner">
        <a href="${pageContext.request.contextPath}/dashboard" class="site-logo">
            <span class="logo-icon">▶</span> StreamLined
        </a>
        <nav class="site-nav">
            <a href="${pageContext.request.contextPath}/dashboard">Home</a>
            <a href="${pageContext.request.contextPath}/movies" class="active">Movies</a>
            <c:if test="${sessionScope.user.admin}">
                <a href="${pageContext.request.contextPath}/admin">Admin</a>
            </c:if>
        </nav>
        <div class="header-user">
            <span>Hi, <strong>${sessionScope.user.username}</strong></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>
    </div>
</header>

<main class="main-content">
<div class="detail-wrapper">

    <!-- Breadcrumb -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/movies">Movies</a>
        <span>›</span>
        <span>${requestScope.movie.title}</span>
    </div>

    <!-- Hero -->
    <div class="detail-hero">

        <!-- Poster -->
        <div class="detail-poster">
            <c:choose>
                <c:when test="${not empty requestScope.movie.posterUrl}">
                    <img src="${requestScope.movie.posterUrl}" alt="${requestScope.movie.title}">
                </c:when>
                <c:otherwise>
                    <div class="poster-placeholder">▶</div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Info -->
        <div class="detail-meta">
            <span class="detail-genre">${requestScope.movie.genre}</span>
            <h1 class="detail-title">${requestScope.movie.title}</h1>

            <div class="detail-stats">
                <span class="rating-badge">${requestScope.movie.starRating}</span>
                <span>${requestScope.movie.releaseYear}</span>
            </div>

            <p class="detail-synopsis">${requestScope.movie.synopsis}</p>

            <!-- Action buttons -->
            <div class="detail-actions">

                <!-- Trailer link -->
                <c:if test="${not empty requestScope.movie.trailerUrl}">
                    <a href="${requestScope.movie.trailerUrl}" target="_blank" rel="noopener"
                       class="btn btn-primary btn-lg">▶ Watch Trailer</a>
                </c:if>

                <!-- Watchlist toggle -->
                <form action="${pageContext.request.contextPath}/movies" method="post">
                    <input type="hidden" name="movieId" value="${requestScope.movie.movieId}">
                    <c:choose>
                        <c:when test="${requestScope.inWatchlist}">
                            <input type="hidden" name="action" value="removeWatchlist">
                            <button type="submit" class="btn btn-ghost btn-lg">✓ In Watchlist</button>
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="addWatchlist">
                            <button type="submit" class="btn btn-outline btn-lg">+ Add to Watchlist</button>
                        </c:otherwise>
                    </c:choose>
                </form>

            </div>
        </div>
    </div>

    <hr class="divider">

    <!-- Reviews Section -->
    <div class="reviews-section">
        <h2 class="section-title">Reviews</h2>

        <!-- Submit a review -->
        <div class="review-form-card">
            <h3>Leave a Review</h3>
            <form action="${pageContext.request.contextPath}/movies" method="post">
                <input type="hidden" name="movieId" value="${requestScope.movie.movieId}">
                <input type="hidden" name="action"  value="review">

                <div class="form-group">
                    <label>Your Rating</label>
                    <!-- Reversed flex for CSS-only hover trick -->
                    <div class="star-select">
                        <input type="radio" id="s5" name="rating" value="5"><label for="s5">★</label>
                        <input type="radio" id="s4" name="rating" value="4"><label for="s4">★</label>
                        <input type="radio" id="s3" name="rating" value="3" checked><label for="s3">★</label>
                        <input type="radio" id="s2" name="rating" value="2"><label for="s2">★</label>
                        <input type="radio" id="s1" name="rating" value="1"><label for="s1">★</label>
                    </div>
                </div>

                <div class="form-group">
                    <label for="comment">Comment</label>
                    <textarea id="comment" name="comment" placeholder="Share your thoughts…" required></textarea>
                </div>

                <button type="submit" class="btn btn-primary">Submit Review</button>
            </form>
        </div>

        <!-- Existing reviews -->
        <c:choose>
            <c:when test="${empty requestScope.reviews}">
                <p class="empty-state">No reviews yet. Be the first to review this movie!</p>
            </c:when>
            <c:otherwise>
                <div class="reviews-list">
                    <c:forEach var="review" items="${requestScope.reviews}">
                        <div class="review-card">
                            <div class="review-header">
                                <div>
                                    <span class="review-user">${review.username}</span>
                                    <span class="review-stars">${review.stars}</span>
                                </div>
                                <span class="review-date">${review.createdAt}</span>
                            </div>
                            <p class="review-comment">${review.comment}</p>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

</div>
</main>

<footer class="site-footer">
    <div class="container">
        <p>&copy; 2025 StreamLined. Built with Java MVC.</p>
    </div>
</footer>

</body>
</html>
