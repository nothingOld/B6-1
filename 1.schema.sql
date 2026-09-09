-- ============================================================
-- 데이터베이스 설계 요약
-- ============================================================
-- 테이블 목록 및 역할
-- 1) member : 회원 정보 관리
-- 2) genre  : 영화 장르 관리
-- 3) movie  : 영화 정보 관리
-- 4) review : 회원이 영화에 작성한 평점/리뷰 관리
--
-- 1:N 관계
-- genre  1 : N movie  - 하나의 장르에는 여러 영화가 속할 수 있다.
-- member 1 : N review - 한 회원은 여러 리뷰를 작성할 수 있다.
-- movie  1 : N review - 한 영화에는 여러 리뷰가 작성될 수 있다.
--
-- PK 선정 이유
-- member_id : 이름/이메일 변경과 무관하게 회원을 식별하기 위한 키
-- genre_id  : 장르명을 직접 관계키로 사용하지 않고 장르를 식별하기 위한 키
-- movie_id  : 영화 제목 중복 가능성과 무관하게 영화를 식별하기 위한 키
-- review_id : 동일 회원의 여러 리뷰를 각각 식별하기 위한 키
--
-- PK와 FK 역할
-- PK(Primary Key) : 테이블의 각 행을 유일하게 식별한다.
-- FK(Foreign Key) : 다른 테이블의 PK를 참조해 테이블 간 관계와 참조 무결성을 관리한다.
--
-- 주요 타입 선정 이유
-- INTEGER : ID, 연도, 평점처럼 숫자 비교/정렬이 필요한 값
-- VARCHAR : 이름, 이메일, 제목, 리뷰처럼 길이가 가변적인 문자열
-- DATE    : 리뷰 작성 '날짜'를 저장하며 시간 단위 정보가 필요하지 않아 DATETIME 대신 사용
--
-- 정규화/역할 분담
-- 회원/장르/영화/리뷰를 역할별로 분리하여 동일한 회원명, 영화명, 장르명을
-- review에 반복 저장하지 않는다. 각 비키 속성은 해당 테이블의 PK에 종속되도록 구성한다.
-- ============================================================

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