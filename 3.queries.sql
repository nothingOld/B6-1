-- Q1. 2023년 이후 개봉한 영화를 조회한다.(WHERE)
SELECT movie_id
     , title
     , release_year
  FROM movie
 WHERE release_year >= 2023;


-- Q2. 영화를 최신 개봉 연도 순으로 조회한다.(ORDER BY)
SELECT movie_id
     , title
     , release_year
  FROM movie
 ORDER BY release_year DESC;


-- Q3. 최신 영화 중 상위 5개를 조회한다.
-- SQLite에서 지원하는 LIMIT 문법으로 조회 행 수를 제한한다.(ORDER BY + LIMIT)
SELECT movie_id
     , title
     , release_year
  FROM movie
 ORDER BY release_year DESC
 LIMIT 5;


-- Q4. 평점이 4점 이상인 리뷰를 높은 평점 순으로 조회한다.(WHERE + ORDEER BY)
SELECT review_id
     , movie_id
     , rating
     , comment
  FROM review
 WHERE rating >= 4
 ORDER BY rating DESC;


-- Q5. 리뷰를 작성한 회원의 이름과 평점, 리뷰 내용을 조회한다.(INNER JOIN)
-- member 1: N review
SELECT m.name
     , r.rating
     , r.comment
  FROM member AS m
 INNER JOIN review AS r
    ON m.member_id = r.member_id;


/* JOIN 쿼리 4개 */

-- Q6. 영화 제목과 해당 영화의 평점 및 리뷰 내용을 조회한다.(INNER JOIN)
-- movie 1 : N review
SELECT mo.title
     , r.rating
     , r.comment
  FROM movie AS mo
 INNER JOIN review AS r
    ON mo.movie_id = r.movie_id;


-- Q7. 각 영화의 제목과 장르를 조회한다.(INNER JOIN)
-- movie N : 1 genre
SELECT mo.title
     , g.genre_name
  FROM movie AS mo
 INNER JOIN genre AS g
    ON mo.genre_id = g.genre_id;


-- Q8. 리뷰를 한 번도 작성하지 않은 회원을 조회한다.(LEFT JOIN)
-- member 1 : N review
SELECT m.member_id
     , m.name
  FROM member AS m
  LEFT JOIN review AS r
    ON m.member_id = r.member_id
 WHERE r.review_id IS NULL;


/* 집계쿼리 3개 */

-- Q9. 영화별 리뷰 개수를 조회한다.(COUNT)
SELECT mo.movie_id
     , mo.title
     , COUNT(r.review_id) AS review_count
  FROM movie AS mo
  LEFT JOIN review AS r
    ON mo.movie_id = r.movie_id
 GROUP BY mo.movie_id
        , mo.title
 ORDER BY review_count DESC;


-- Q10. 리뷰가 존재하는 영화의 평균 평점을 조회한다.(AVG)
SELECT mo.movie_id
     , mo.title
     , AVG(r.rating) AS average_rating
  FROM movie AS mo
 INNER JOIN review AS r
    ON mo.movie_id = r.movie_id
 GROUP BY mo.movie_id
        , mo.title
 ORDER BY average_rating DESC;


-- Q11. 회원별 리뷰 작성 횟수를 조회한다. (COUNT)
SELECT m.member_id
     , m.name
     , COUNT(r.review_id) AS review_count
  FROM member AS m
  LEFT JOIN review AS r
    ON m.member_id = r.member_id
 GROUP BY m.member_id
        , m.name
 ORDER BY review_count DESC;


/* 서브쿼리 1개 */

-- Q12. 서브쿼리를 이용해 리뷰를 작성하지 않은 회원을 조회한다.(NOT EXISTS)
SELECT m.member_id
     , m.name
  FROM member AS m
 WHERE NOT EXISTS (
       SELECT 1
         FROM review AS r
        WHERE r.member_id = m.member_id
       );


/* 데이터 수정(UPDATE) 및 삭제(DELETE) */

-- Q13. review_id가 5인 리뷰의 평점과 내용을 수정한다.
UPDATE review
   SET rating = 3
     , comment = '다시 보니 처음보다 재미있었다.'
 WHERE review_id = 5;

-- 수정 확인용 쿼리
SELECT review_id
     , rating
     , comment
  FROM review
 WHERE review_id = 5;


-- Q14. review_id가 11인 리뷰를 삭제한다.
DELETE
  FROM review
 WHERE review_id = 11;

-- 삭제 확인용 쿼리
SELECT COUNT(*) AS review_count
  FROM review;


/* 인덱스 생성 (CREATE INDEX) */

-- Q15. 영화별 리뷰 조회 및 JOIN 시 검색 성능 향상을 위해 review.movie_id 컬럼에 인덱스를 생성한다.
CREATE INDEX idx_review_movie_id
    ON review(movie_id);


/* 보너스 1. 조인 1개를 두 방식으로 풀기 */

-- BONUS 1-1. LEFT JOIN 방식
-- 리뷰를 한 번도 작성하지 않은 회원을 조회한다.
SELECT m.member_id
     , m.name
  FROM member AS m
  LEFT JOIN review AS r
    ON m.member_id = r.member_id
 WHERE r.review_id IS NULL;


-- BONUS 1-2. NOT EXISTS 서브쿼리 방식
-- 리뷰를 한 번도 작성하지 않은 회원을 조회한다.
SELECT m.member_id
     , m.name
  FROM member AS m
 WHERE NOT EXISTS (
       SELECT 1
         FROM review AS r
        WHERE r.member_id = m.member_id
       );


/*  보너스 2. 데이터 정합성 깨뜨려 보기 */

-- SQLite 전용 문법:
-- 현재 DB 연결에서 외래 키(FK) 제약조건을 활성화한다.
-- FK 활성화 확인
PRAGMA foreign_keys = ON;
PRAGMA foreign_keys;

-- BONUS 2. FK 무결성 검증
-- 존재하지 않는 member_id 999를 참조하여 FK 오류가 발생하는지 확인한다.
INSERT INTO review (
       review_id
     , member_id
     , movie_id
     , rating
     , comment
     , created_at
) VALUES (
       100
     , 999
     , 1
     , 5
     , 'FK 오류 확인용 리뷰'
     , '2026-09-09'
);

-- FK 비활성화시 확인용
SELECT * FROM review;
DELETE FROM review WHERE review_id = 100;


/*
보너스 3. 미니 리포트 만들기
이 DB로 뽑을 수 있는 핵심 지표 3개를 정의하고 각각을 구하는 SQL을 최종본으로 정리한다.

(핵심 지표 3개)
| 지표   | 의미          |
| ---- | -----------   |
| 지표 1 | 영화별 리뷰 수    |
| 지표 2 | 영화별 평균 평점   |
| 지표 3 | 회원별 리뷰 작성 수 |
*/


