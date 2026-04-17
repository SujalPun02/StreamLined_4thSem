<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StreamLined – Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/style.css">
</head>
<body>

<%-- ═══════════════════ HEADER ═══════════════════ --%>
<header class="site-header">
    <div class="header-inner">
        <a href="${pageContext.request.contextPath}/dashboard" class="site-logo">
            <span class="logo-icon">▶</span> StreamLined
        </a>
        <nav class="site-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="active">Home</a>
            <a href="${pageContext.request.contextPath}/movies">Movies</a>
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

    <%-- Error banner --%>
    <c:if test="${not empty requestScope.error}">
        <div class="alert alert-error container">${requestScope.error}</div>
    </c:if>

    <%-- ═══════════════════ HERO / TOP PICKS ═══════════════════ --%>
    <section class="hero-section">
        <div class="container">
            <h1 class="section-title">Top Picks for You</h1>
            <div class="movie-grid">
                <c:forEach var="movie" items="${requestScope.topMovies}">
                    <a href="${pageContext.request.contextPath}/movies?id=${movie.movieId}" class="movie-card">
                        <div class="movie-poster">
                            <c:choose>
                                <c:when test="${not empty movie.posterUrl}">
                                    <img src="${movie.posterUrl}" alt="${movie.title}" loading="lazy">
                                </c:when>
                                <c:otherwise>
                                    <div class="poster-placeholder">▶</div>
                                </c:otherwise>
                            </c:choose>
                            <div class="movie-overlay">
                                <span class="movie-rating">${movie.starRating}</span>
                            </div>
                        </div>
                        <div class="movie-info">
                            <h3 class="movie-title">${movie.title}</h3>
                            <p class="movie-meta">${movie.genre} · ${movie.releaseYear}</p>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </div>
    </section>

    <%-- ═══════════════════ WATCHLIST ═══════════════════ --%>
    <section class="watchlist-section">
        <div class="container">
            <h2 class="section-title">My Watchlist</h2>
            <c:choose>
                <c:when test="${empty requestScope.watchlist}">
                    <p class="empty-state">
                        Your watchlist is empty.
                        <a href="${pageContext.request.contextPath}/movies">Browse movies</a> to add some.
                    </p>
                </c:when>
                <c:otherwise>
                    <div class="movie-grid">
                        <c:forEach var="movie" items="${requestScope.watchlist}">
                            <a href="${pageContext.request.contextPath}/movies?id=${movie.movieId}" class="movie-card">
                                <div class="movie-poster">
                                    <c:choose>
                                        <c:when test="${not empty movie.posterUrl}">
                                            <img src="${movie.posterUrl}" alt="${movie.title}" loading="lazy">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="poster-placeholder">▶</div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="movie-overlay">
                                        <span class="movie-rating">${movie.starRating}</span>
                                    </div>
                                </div>
                                <div class="movie-info">
                                    <h3 class="movie-title">${movie.title}</h3>
                                    <p class="movie-meta">${movie.genre} · ${movie.releaseYear}</p>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <%-- ═══════════════════ ALL MOVIES ═══════════════════ --%>
    <section class="all-movies-section">
        <div class="container">
            <h2 class="section-title">All Movies</h2>
            <div class="movie-grid">
                <c:forEach var="movie" items="${requestScope.allMovies}">
                    <a href="${pageContext.request.contextPath}/movies?id=${movie.movieId}" class="movie-card">
                        <div class="movie-poster">
                            <c:choose>
                                <c:when test="${not empty movie.posterUrl}">
                                    <img src="${movie.posterUrl}" alt="${movie.title}" loading="lazy">
                                </c:when>
                                <c:otherwise>
                                    <div class="poster-placeholder">▶</div>
                                </c:otherwise>
                            </c:choose>
                            <div class="movie-overlay">
                                <span class="movie-rating">${movie.starRating}</span>
                            </div>
                        </div>
                        <div class="movie-info">
                            <h3 class="movie-title">${movie.title}</h3>
                            <p class="movie-meta">${movie.genre} · ${movie.releaseYear}</p>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </div>
    </section>

</main>

<%-- ═══════════════════ FOOTER ═══════════════════ --%>
<footer class="site-footer">
    <div class="container">
        <p>&copy; 2025 StreamLined. Built with Java MVC.</p>
    </div>
</footer>

</body>
</html>
