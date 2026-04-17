<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StreamLined – Admin Panel</title>
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
            <a href="${pageContext.request.contextPath}/movies">Movies</a>
            <a href="${pageContext.request.contextPath}/admin" class="active">Admin</a>
        </nav>
        <div class="header-user">
            <span><strong>${sessionScope.user.username}</strong>
                <span class="badge badge-admin">Admin</span>
            </span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>
    </div>
</header>

<main class="main-content">
<div class="admin-wrapper">

    <div class="admin-header">
        <div>
            <h1 class="section-title" style="margin-bottom:4px">Admin Panel</h1>
            <p style="color:var(--text-secondary);font-size:14px">Manage the StreamLined movie catalog</p>
        </div>
        <a href="${pageContext.request.contextPath}/movies" class="btn btn-outline">← View Site</a>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty sessionScope.adminError}">
        <div class="alert alert-error">${sessionScope.adminError}</div>
        <c:remove var="adminError" scope="session"/>
    </c:if>
    <c:if test="${not empty requestScope.error}">
        <div class="alert alert-error">${requestScope.error}</div>
    </c:if>

    <div class="admin-grid">

        <!-- ═══════════ MOVIE TABLE ═══════════ -->
        <div>

            <div class="data-table-wrap">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Poster</th>
                            <th>Title</th>
                            <th>Genre</th>
                            <th>Year</th>
                            <th>Rating</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty requestScope.movies}">
                                <tr><td colspan="6" class="empty-state">No movies yet. Add one →</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="movie" items="${requestScope.movies}">
                                    <tr>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty movie.posterUrl}">
                                                    <img src="${movie.posterUrl}" alt="${movie.title}" class="movie-thumb">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="movie-thumb" style="display:flex;align-items:center;justify-content:center;color:var(--text-muted)">▶</div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="td-title">${movie.title}</td>
                                        <td>${movie.genre}</td>
                                        <td>${movie.releaseYear}</td>
                                        <td><span class="movie-rating">${movie.starRating}</span></td>
                                        <td>
                                            <div class="actions">
                                                <!-- Edit: GET to pre-populate form -->
                                                <a href="${pageContext.request.contextPath}/admin?edit=${movie.movieId}"
                                                   class="btn btn-ghost btn-sm">Edit</a>

                                                <!-- Delete: POST with confirmation -->
                                                <form action="${pageContext.request.contextPath}/admin" method="post"
                                                      onsubmit="return confirm('Delete \'${movie.title}\'? This cannot be undone.')">
                                                    <input type="hidden" name="action"  value="delete">
                                                    <input type="hidden" name="movieId" value="${movie.movieId}">
                                                    <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ═══════════ ADD / EDIT FORM ═══════════ -->
        <div class="admin-form-card">
            <h3>
                <c:choose>
                    <c:when test="${not empty requestScope.editMovie}">Edit Movie</c:when>
                    <c:otherwise>Add New Movie</c:otherwise>
                </c:choose>
            </h3>

            <form action="${pageContext.request.contextPath}/admin" method="post">

                <c:choose>
                    <c:when test="${not empty requestScope.editMovie}">
                        <input type="hidden" name="action"  value="update">
                        <input type="hidden" name="movieId" value="${requestScope.editMovie.movieId}">
                    </c:when>
                    <c:otherwise>
                        <input type="hidden" name="action" value="add">
                    </c:otherwise>
                </c:choose>

                <div class="form-group">
                    <label for="title">Title</label>
                    <input type="text" id="title" name="title" required maxlength="200"
                           value="${not empty requestScope.editMovie ? requestScope.editMovie.title : ''}">
                </div>

                <div class="form-group">
                    <label for="genre">Genre</label>
                    <input type="text" id="genre" name="genre" required maxlength="100"
                           placeholder="e.g. Action / Sci-Fi"
                           value="${not empty requestScope.editMovie ? requestScope.editMovie.genre : ''}">
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="releaseYear">Year</label>
                        <input type="number" id="releaseYear" name="releaseYear" required
                               min="1888" max="2099"
                               value="${not empty requestScope.editMovie ? requestScope.editMovie.releaseYear : ''}">
                    </div>
                    <div class="form-group">
                        <label for="rating">Rating (0–5)</label>
                        <input type="number" id="rating" name="rating" required
                               min="0" max="5" step="0.1"
                               value="${not empty requestScope.editMovie ? requestScope.editMovie.rating : '0.0'}">
                    </div>
                </div>

                <div class="form-group">
                    <label for="synopsis">Synopsis</label>
                    <textarea id="synopsis" name="synopsis" rows="3">${not empty requestScope.editMovie ? requestScope.editMovie.synopsis : ''}</textarea>
                </div>

                <div class="form-group">
                    <label for="posterUrl">Poster URL</label>
                    <input type="url" id="posterUrl" name="posterUrl" maxlength="500"
                           placeholder="https://…"
                           value="${not empty requestScope.editMovie ? requestScope.editMovie.posterUrl : ''}">
                    <p class="form-hint">Link to a JPG/PNG image (e.g. TMDB poster URL)</p>
                </div>

                <div class="form-group">
                    <label for="trailerUrl">Trailer URL</label>
                    <input type="url" id="trailerUrl" name="trailerUrl" maxlength="500"
                           placeholder="https://youtube.com/…"
                           value="${not empty requestScope.editMovie ? requestScope.editMovie.trailerUrl : ''}">
                </div>

                <div style="display:flex;gap:10px;margin-top:4px">
                    <button type="submit" class="btn btn-primary" style="flex:1">
                        <c:choose>
                            <c:when test="${not empty requestScope.editMovie}">Save Changes</c:when>
                            <c:otherwise>Add Movie</c:otherwise>
                        </c:choose>
                    </button>
                    <c:if test="${not empty requestScope.editMovie}">
                        <a href="${pageContext.request.contextPath}/admin"
                           class="btn btn-ghost">Cancel</a>
                    </c:if>
                </div>

            </form>
        </div>

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
