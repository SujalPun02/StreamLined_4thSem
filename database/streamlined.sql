DROP DATABASE IF EXISTS streamlined;

CREATE DATABASE streamlined;

USE streamlined;

-- =========================
-- USERS TABLE
-- =========================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',

    failed_attempts INT DEFAULT 0,
    locked_until DATETIME NULL,

    reset_token VARCHAR(100) NULL,
    reset_token_expiry DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- MOVIES TABLE
-- =========================
CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    genre VARCHAR(50) NOT NULL,
    synopsis TEXT,
    release_year INT,
    rating DOUBLE DEFAULT 0,
    trailer_url VARCHAR(500),
    poster_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- WATCHLIST TABLE
-- =========================
CREATE TABLE watchlist (
    watchlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY unique_watchlist (user_id, movie_id),

    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
        ON DELETE CASCADE
);

-- =========================
-- REVIEWS TABLE
-- =========================
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
        ON DELETE CASCADE
);

-- =========================
-- CONTACT MESSAGES TABLE
-- =========================
CREATE TABLE contact_messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    subject VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- SAMPLE ADMIN USER
-- username: admin
-- password: admin123
-- =========================
INSERT INTO users (username, email, password_hash, role)
VALUES (
    'admin',
    'admin@streamlined.com',
    SHA2('admin123', 256),
    'admin'
);

-- =========================
-- SAMPLE NORMAL USER
-- username: user
-- password: user123
-- =========================
INSERT INTO users (username, email, password_hash, role)
VALUES (
    'user',
    'user@streamlined.com',
    SHA2('user123', 256),
    'user'
);

-- =========================
-- SAMPLE MOVIES
-- =========================
INSERT INTO movies 
(title, genre, synopsis, release_year, rating, trailer_url, poster_url)
VALUES
(
    'Inception',
    'Sci-Fi',
    'A thief who steals secrets through dream-sharing technology is given a difficult mission to plant an idea into someone’s mind.',
    2010,
    4.8,
    'https://www.youtube.com/watch?v=YoHD9XEInc0',
    'https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg'
),

(
    'Interstellar',
    'Sci-Fi',
    'A team of explorers travels through a wormhole in space to find a new home for humanity.',
    2014,
    4.9,
    'https://www.youtube.com/watch?v=zSWdZVtXT7E',
    'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg'
),

(
    'The Dark Knight',
    'Action',
    'Batman faces the Joker, a criminal mastermind who brings chaos to Gotham City.',
    2008,
    4.9,
    'https://www.youtube.com/watch?v=EXeTwQWrcwY',
    'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg'
),

(
    'Avatar',
    'Adventure',
    'A marine on an alien planet becomes part of the Na’vi world and must choose between two lives.',
    2009,
    4.6,
    'https://www.youtube.com/watch?v=5PSNL1qE6VY',
    'https://image.tmdb.org/t/p/w500/kyeqWdyUXW608qlYkRqosgbbJyK.jpg'
),

(
    'The Matrix',
    'Sci-Fi',
    'A computer hacker discovers that the world he knows is a simulated reality controlled by machines.',
    1999,
    4.7,
    'https://www.youtube.com/watch?v=vKQi3bBA1y8',
    'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg'
),

(
    'Joker',
    'Drama',
    'A failed comedian slowly changes into a dangerous criminal figure in Gotham City.',
    2019,
    4.5,
    'https://www.youtube.com/watch?v=zAGVQLHvwOY',
    'https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg'
),

(
    'Spider-Man: Into the Spider-Verse',
    'Animation',
    'Miles Morales becomes Spider-Man and meets other Spider-People from different universes.',
    2018,
    4.8,
    'https://www.youtube.com/watch?v=g4Hbz2jLxvQ',
    'https://image.tmdb.org/t/p/w500/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg'
),

(
    'Tenet',
    'Action',
    'A secret agent uses time inversion to prevent a global disaster.',
    2020,
    4.2,
    'https://www.youtube.com/watch?v=LdOM0x0XDMo',
    'https://image.tmdb.org/t/p/w500/aCIFMriQh8rvhxpN1iwV4b8kRby.jpg'
);

-- =========================
-- SAMPLE REVIEWS
-- =========================
INSERT INTO reviews (user_id, movie_id, rating, comment)
VALUES
(2, 1, 5, 'Amazing movie with a very creative story.'),
(2, 2, 5, 'The visuals and emotional story are excellent.'),
(2, 3, 5, 'One of the best action movies.');