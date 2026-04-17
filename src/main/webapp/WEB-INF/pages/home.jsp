<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StreamLined – Movies</title>
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
    <section class="catalog-section">
        <div class="container">

            <!-- Search bar -->
            <form action="${pageContext.request.contextPath}/movies" method="get" class="search-bar">
                <input type="text" name="search"
                       placeholder="Search by title or genre…"
                       value="${not empty requestScope.searchQuery ? requestScope.searchQuery : ''}">
                <button type="submit" class="btn btn-primary">Search</button>
                <c:if test="${not empty requestScope.searchQuery}">
                    <a href="${pageContext.request.contextPath}/movies" class="btn btn-ghost">Clear</a>
                </c:if>
            </form>

            <!-- Title -->
            <c:choose>
                <c:when test="${not empty requestScope.searchQuery}">
                    <h1 class="section-title">
                        Results for <span>"${requestScope.searchQuery}"</span>
                    </h1>
                </c:when>
                <c:otherwise>
                    <h1 class="section-title">All Movies</h1>
                </c:otherwise>
            </c:choose>

            <!-- Error -->
            <c:if test="${not empty requestScope.error}">
                <div class="alert alert-error">${requestScope.error}</div>
            </c:if>

            <!-- Grid -->
            <c:choose>
                <c:when test="${empty requestScope.movies}">
                    <p class="empty-state">No movies found. Try a different search term.</p>
                </c:when>
                <c:otherwise>
                    <div class="movie-grid">
                        <c:forEach var="movie" items="${requestScope.movies}">
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
</main>

<footer class="site-footer">
    <div class="container">
        <p>&copy; 2025 StreamLined. Built with Java MVC.</p>
    </div>
</footer>

</body>
</html>
