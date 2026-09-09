-- SQLite 전용 문법:
-- 현재 DB 연결에서 외래 키(FK) 제약조건을 활성화한다.
PRAGMA foreign_keys = ON;

-- 외래 키 확인: 1이면 정상
PRAGMA foreign_keys;

-- 샘플 데이터 검증 포인트
-- member_id = 10(임하늘)은 review가 없어 LEFT JOIN/NOT EXISTS의 비매칭 케이스로 사용한다.
-- movie_id = 10(사라진 기록)은 review가 없어 LEFT JOIN 집계에서 review_count = 0 케이스로 사용한다.
-- rating은 CHECK (1~5) 범위 안의 값을 사용하며, FK 오류는 보너스 2에서 별도로 검증한다.

-- 추가 경계/예외 검증은 샘플 데이터를 변경하지 않도록 별도 검증으로 수행한다.
-- rating 1/5 정상, rating 0/6 CHECK 실패, comment NULL 허용 여부를 result/constraint_validation.txt에 기록한다.

-- 1. 회원 샘플 데이터 10건
INSERT INTO member (member_id, name, email)
VALUES (1, '김민수', 'minsu@example.com');

INSERT INTO member (member_id, name, email)
VALUES (2, '이지은', 'jieun@example.com');

INSERT INTO member (member_id, name, email)
VALUES (3, '박서준', 'seojun@example.com');

INSERT INTO member (member_id, name, email)
VALUES (4, '최유진', 'yujin@example.com');

INSERT INTO member (member_id, name, email)
VALUES (5, '정현우', 'hyunwoo@example.com');

INSERT INTO member (member_id, name, email)
VALUES (6, '한수빈', 'subin@example.com');

INSERT INTO member (member_id, name, email)
VALUES (7, '윤지호', 'jiho@example.com');

INSERT INTO member (member_id, name, email)
VALUES (8, '강서연', 'seoyeon@example.com');

INSERT INTO member (member_id, name, email)
VALUES (9, '오민재', 'minjae@example.com');

INSERT INTO member (member_id, name, email)
VALUES (10, '임하늘', 'haneul@example.com');


-- 2. 장르 샘플 데이터 10건
INSERT INTO genre (genre_id, genre_name)
VALUES (1, '액션');

INSERT INTO genre (genre_id, genre_name)
VALUES (2, '드라마');

INSERT INTO genre (genre_id, genre_name)
VALUES (3, 'SF');

INSERT INTO genre (genre_id, genre_name)
VALUES (4, '코미디');

INSERT INTO genre (genre_id, genre_name)
VALUES (5, '로맨스');

INSERT INTO genre (genre_id, genre_name)
VALUES (6, '스릴러');

INSERT INTO genre (genre_id, genre_name)
VALUES (7, '애니메이션');

INSERT INTO genre (genre_id, genre_name)
VALUES (8, '판타지');

INSERT INTO genre (genre_id, genre_name)
VALUES (9, '다큐멘터리');

INSERT INTO genre (genre_id, genre_name)
VALUES (10, '미스터리');


-- 3. 영화 샘플 데이터 10건
INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (1, 3, '우주 여행', 2024);

INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (2, 2, '마지막 봄', 2021);

INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (3, 1, '도시의 추격자', 2023);

INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (4, 4, '웃음 공장', 2020);

INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (5, 5, '우리의 여름', 2022);

INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (6, 6, '닫힌 방', 2024);

INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (7, 7, '별빛 친구들', 2019);

INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (8, 8, '마법의 숲', 2023);

INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (9, 9, '푸른 지구', 2021);

INSERT INTO movie (movie_id, genre_id, title, release_year)
VALUES (10, 10, '사라진 기록', 2025);


-- 4. 리뷰 샘플 데이터 11건
INSERT INTO review (review_id, member_id, movie_id, rating, comment, created_at)
VALUES (1, 1, 1, 5, '영상과 이야기가 인상적이었다.', '2026-08-01');

INSERT INTO review (review_id, member_id, movie_id, rating, comment, created_at)
VALUES (2, 2, 1,4,'재미있게 감상했다.', '2026-08-02');

INSERT INTO review (review_id, member_id, movie_id, rating, comment, created_at)
VALUES ( 3, 3, 2, 3, '잔잔한 분위기가 좋았다.', '2026-08-03');

INSERT INTO review ( review_id, member_id, movie_id, rating, comment, created_at)
VALUES ( 4, 4, 3, 5, '액션 장면이 훌륭했다.', '2026-08-04');

INSERT INTO review ( review_id, member_id, movie_id, rating, comment, created_at)
VALUES ( 5, 5, 4, 2, '기대보다 아쉬웠다.', '2026-08-05');

INSERT INTO review ( review_id, member_id, movie_id, rating, comment, created_at)
VALUES ( 6, 6, 5, 4, '배우들의 연기가 좋았다.', '2026-08-06');

INSERT INTO review ( review_id, member_id, movie_id, rating, comment, created_at)
VALUES ( 7, 7, 6, 5, '긴장감이 끝까지 유지됐다.', '2026-08-07');

INSERT INTO review ( review_id, member_id, movie_id, rating, comment, created_at)
VALUES ( 8, 8, 7, 4, '가볍게 보기 좋은 영화였다.', '2026-08-08');

INSERT INTO review ( review_id, member_id, movie_id, rating, comment, created_at)
VALUES ( 9, 9, 8, 3, '세계관은 흥미로웠다.', '2026-08-09');

INSERT INTO review ( review_id, member_id, movie_id, rating, comment, created_at)
VALUES ( 10, 1, 9, 4, '내용이 유익했다.', '2026-08-10');

INSERT INTO review ( review_id, member_id, movie_id, rating, comment, created_at)
VALUES ( 11, 2, 3, 5, '다시 보고 싶은 영화다.', '2026-08-11');


-- 확인용 쿼리
SELECT COUNT(*) AS member_count FROM member;
SELECT COUNT(*) AS genre_count FROM genre;
SELECT COUNT(*) AS movie_count FROM movie;
SELECT COUNT(*) AS review_count FROM review;

SELECT * FROM member;
SELECT * FROM genre;
SELECT * FROM movie;
SELECT * FROM review;