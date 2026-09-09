-- ============================================================
-- 핵심 쿼리 설명
-- ============================================================
-- Q01~Q04 : 기본 조회(WHERE, ORDER BY, LIMIT)
-- Q05~Q08 : JOIN 4개(INNER JOIN 3개, LEFT JOIN 1개)
-- Q09~Q11 : 집계 3개(COUNT/AVG + GROUP BY)
-- Q12     : 상관 서브쿼리(NOT EXISTS)
-- Q13     : UPDATE
-- Q14     : DELETE
-- Q15     : CREATE INDEX
-- 실행 결과는 result/q01.txt ~ result/q15.txt에 1:1로 대응한다.
-- ============================================================

-- JOIN 동작 차이
-- INNER JOIN : 양쪽 테이블에서 조인 조건이 일치하는 행만 반환한다.
-- LEFT JOIN  : 왼쪽 테이블의 모든 행을 유지하며, 오른쪽에 매칭이 없으면 NULL을 반환한다.
-- 이 프로젝트에서 Q05는 리뷰가 있는 회원만 반환하고, Q08은 NULL을 이용해 리뷰가 없는 임하늘을 찾는다.

-- 집계 동작 원리
-- GROUP BY : 지정한 컬럼 값이 같은 행을 하나의 그룹으로 묶는다.
-- COUNT    : 그룹별 행/값의 개수를 계산한다.
-- AVG      : 그룹별 숫자 값의 평균을 계산한다.
-- SUM      : 그룹별 숫자 값의 합계를 계산한다. 이번 과제는 COUNT와 AVG 두 종류로 필수 조건을 충족한다.

-- Q1. 2023년 이후 개봉한 영화를 조회한다.(WHERE)
-- 결과 증빙: result/q01.txt, result/screenshots/q01.png
SELECT movie_id
     , title
     , release_year
  FROM movie
 WHERE release_year >= 2023;


-- Q2. 영화를 최신 개봉 연도 순으로 조회한다.(ORDER BY)
-- 결과 증빙: result/q02.txt, result/screenshots/q02.png
SELECT movie_id
     , title
     , release_year
  FROM movie
 ORDER BY release_year DESC;


-- Q3. 최신 영화 중 상위 5개를 조회한다.
-- 결과 증빙: result/q03.txt, result/screenshots/q03.png
-- SQLite에서 지원하는 LIMIT 문법으로 조회 행 수를 제한한다.(ORDER BY + LIMIT)
SELECT movie_id
     , title
     , release_year
  FROM movie
 ORDER BY release_year DESC
 LIMIT 5;


-- Q4. 평점이 4점 이상인 리뷰를 높은 평점 순으로 조회한다.(WHERE + ORDER BY)
-- 결과 증빙: result/q04.txt, result/screenshots/q04.png
SELECT review_id
     , movie_id
     , rating
     , comment
  FROM review
 WHERE rating >= 4
 ORDER BY rating DESC;


-- Q5. 리뷰를 작성한 회원의 이름과 평점, 리뷰 내용을 조회한다.(INNER JOIN)
-- 결과 증빙: result/q05.txt, result/screenshots/q05.png
-- member 1: N review
SELECT m.name
     , r.rating
     , r.comment
  FROM member AS m
 INNER JOIN review AS r
    ON m.member_id = r.member_id;


/* JOIN 쿼리 4개 */

-- Q6. 영화 제목과 해당 영화의 평점 및 리뷰 내용을 조회한다.(INNER JOIN)
-- 결과 증빙: result/q06.txt, result/screenshots/q06.png
-- movie 1 : N review
SELECT mo.title
     , r.rating
     , r.comment
  FROM movie AS mo
 INNER JOIN review AS r
    ON mo.movie_id = r.movie_id;


-- Q7. 각 영화의 제목과 장르를 조회한다.(INNER JOIN)
-- 결과 증빙: result/q07.txt, result/screenshots/q07.png
-- movie N : 1 genre
SELECT mo.title
     , g.genre_name
  FROM movie AS mo
 INNER JOIN genre AS g
    ON mo.genre_id = g.genre_id;


-- Q8. 리뷰를 한 번도 작성하지 않은 회원을 조회한다.(LEFT JOIN)
-- 결과 증빙: result/q08.txt, result/screenshots/q08.png
-- member 1 : N review
SELECT m.member_id
     , m.name
  FROM member AS m
  LEFT JOIN review AS r
    ON m.member_id = r.member_id
 WHERE r.review_id IS NULL;


/* 집계쿼리 3개 */

-- Q9. 영화별 리뷰 개수를 조회한다.(COUNT)
-- 결과 증빙: result/q09.txt, result/screenshots/q09.png
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
-- 결과 증빙: result/q10.txt, result/screenshots/q10.png
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
-- 결과 증빙: result/q11.txt, result/screenshots/q11.png
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
-- 결과 증빙: result/q12.txt, result/screenshots/q12.png
-- 단계 1: 바깥 쿼리에서 member를 한 명씩 확인한다.
-- 단계 2: 내부 서브쿼리에서 현재 member_id와 같은 review가 존재하는지 확인한다.
-- 단계 3: review가 있으면 NOT EXISTS가 FALSE가 되어 제외한다.
-- 단계 4: review가 없으면 NOT EXISTS가 TRUE가 되어 최종 결과에 포함한다.
-- 처리 흐름: member 조회 -> 회원별 review 존재 여부 검사 -> 리뷰 없는 회원 선택
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
-- 결과 증빙: result/q13.txt, result/screenshots/q13.png
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
-- 결과 증빙: result/q14.txt, result/screenshots/q14.png
DELETE
  FROM review
 WHERE review_id = 11;

-- 삭제 확인용 쿼리
SELECT COUNT(*) AS review_count
  FROM review;


/* 인덱스 생성 (CREATE INDEX) */

-- Q15. 영화별 리뷰 조회 및 JOIN 시 검색 성능 향상을 위해 review.movie_id 컬럼에 인덱스를 생성한다.
-- 결과 증빙: result/q15.txt, result/screenshots/q15.png
-- 선정 근거: review.movie_id는 Q6/Q9/Q10 등에서 영화-리뷰 JOIN 조건으로 반복 사용된다.
-- 비용 측면: 인덱스는 조회를 빠르게 할 수 있지만 INSERT/UPDATE/DELETE 시 인덱스 유지 비용과 저장 공간이 추가된다.
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


/* 보너스 2. 데이터 정합성 깨뜨려 보기
   의도적으로 FK 오류를 발생시키는 테스트이므로 메인 실행 파일과 분리했습니다.
   실행 파일: 4.bonus_fk_test.sql
   증빙: docs/bonus2-error.png, result/fk_validation.txt
*/


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


-- BONUS 3-1. 영화별 리뷰 수
-- 영화별로 작성된 리뷰의 개수를 집계한다.
SELECT mo.movie_id
     , mo.title
     , COUNT(r.review_id) AS review_count
  FROM movie AS mo
  LEFT JOIN review AS r
    ON mo.movie_id = r.movie_id
 GROUP BY mo.movie_id
        , mo.title
 ORDER BY review_count DESC;


-- BONUS 3-2. 영화별 평균 평점
-- 영화별 리뷰 평점의 평균을 집계한다.
SELECT mo.movie_id
     , mo.title
     , AVG(r.rating) AS average_rating
  FROM movie AS mo
 INNER JOIN review AS r
    ON mo.movie_id = r.movie_id
 GROUP BY mo.movie_id
        , mo.title
 ORDER BY average_rating DESC;


-- BONUS 3-3. 회원별 리뷰 작성 수
-- 회원별로 작성한 리뷰의 개수를 집계한다.
SELECT m.member_id
     , m.name
     , COUNT(r.review_id) AS review_count
  FROM member AS m
  LEFT JOIN review AS r
    ON m.member_id = r.member_id
 GROUP BY m.member_id
        , m.name
 ORDER BY review_count DESC;
