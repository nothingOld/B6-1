-- SQLite 전용 문법:
-- SQLite에서 외래 키(FK) 제약조건을 활성화한다.
PRAGMA foreign_keys = ON;


-- 1. 회원 테이블
CREATE TABLE member (
    member_id INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);


-- 2. 장르 테이블
CREATE TABLE genre (
    genre_id INTEGER PRIMARY KEY,
    genre_name VARCHAR(30) NOT NULL UNIQUE
);


-- 3. 영화 테이블
CREATE TABLE movie (
    movie_id INTEGER PRIMARY KEY,
    genre_id INTEGER NOT NULL,
    title VARCHAR(100) NOT NULL,
    release_year INTEGER NOT NULL,

    FOREIGN KEY (genre_id)
        REFERENCES genre(genre_id)
);


-- 4. 리뷰 테이블
CREATE TABLE review (
    review_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment VARCHAR(500),
    created_at DATE NOT NULL,

    FOREIGN KEY (member_id)
        REFERENCES member(member_id),

    FOREIGN KEY (movie_id)
        REFERENCES movie(movie_id)
);



-- 확인용 쿼리
PRAGMA foreign_key_list(movie);
PRAGMA foreign_key_list(review);
PRAGMA foreign_keys;