# B6-1 · 영화 평점 데이터베이스

SQLite를 사용해 **영화 평점 관리 도메인**을 관계형 데이터베이스로 설계하고, PK/FK/제약조건을 적용한 뒤 샘플 데이터를 입력하여 조회·조인·집계·서브쿼리·수정·삭제·인덱스까지 SQL로 실습한 프로젝트입니다.

백엔드 프레임워크는 사용하지 않았으며, macOS의 **VS Code + SQLite Extension** 환경에서 SQL을 작성하고 실행했습니다.

---

## 1. 프로젝트 목표

- 파일이나 엑셀에 단순히 데이터를 나열하는 방식과 달리, **PK/FK를 통해 데이터 간 관계와 무결성을 DB가 직접 관리**하도록 설계합니다.
- `member`, `genre`, `movie`, `review`를 역할별 테이블로 분리합니다.
- `SELECT / INSERT / UPDATE / DELETE`, `JOIN`, `GROUP BY`, 집계 함수, 서브쿼리, 인덱스를 직접 작성합니다.
- SQL 실행 결과와 FK 무결성 검증 결과를 산출물로 남깁니다.

### 엑셀과 관계형 DB의 차이

엑셀에서도 여러 시트에 데이터를 나눌 수 있지만, 일반적인 셀 입력만으로는 `member_id`가 실제 회원인지 같은 **참조 무결성 규칙을 자동으로 강제하지 않습니다.** 이 프로젝트의 SQLite DB는 FK 제약조건을 통해 존재하지 않는 회원이나 영화를 참조하는 리뷰 입력을 차단할 수 있습니다. 또한 SQL의 `JOIN`을 통해 분리된 테이블의 데이터를 관계 기준으로 다시 결합할 수 있습니다.

---

## 2. 개발 환경

| 항목 | 내용 |
| --- | --- |
| OS | macOS |
| DB | SQLite |
| SQL 실행 도구 | VS Code SQLite Extension |
| 백엔드 프레임워크 | 사용하지 않음 |
| SQL 작성 원칙 | 가급적 표준 SQL 사용, SQLite 전용 문법은 주석으로 명시 |

SQLite에서 사용한 주요 전용 문법은 `PRAGMA`입니다. `LIMIT`은 DBMS마다 행 제한 문법이 다르며, 이 과제에서 요구한 기능이므로 SQLite가 지원하는 `LIMIT`을 사용하고 쿼리에 주석으로 명시했습니다.

---

## 3. 프로젝트 구조

```text
B6-1/
├── 0.movie_rating.db3
├── 1.schema.sql
├── 2.sample_data.sql
├── 3.queries.sql
├── README.md
├── docs/
│   ├── ERD.png
│   └── bonus2-error.png
└── result/
    ├── q01.txt
    ├── q02.txt
    ├── ...
    ├── q15.txt
    └── fk_validation.txt
```

- `1.schema.sql`: 테이블, PK/FK, 제약조건 정의
- `2.sample_data.sql`: 테이블별 샘플 데이터 입력
- `3.queries.sql`: 핵심 SQL 15개와 보너스 SQL
- `docs/ERD.png`: ERD 다이어그램
- `docs/bonus2-error.png`: 보너스 2 FK 오류 검증 화면
- `result/q01.txt ~ q15.txt`: Q1~Q15 실제 실행 결과 텍스트
- `result/fk_validation.txt`: FK 정의와 활성화 상태 검증 결과

---

## 4. ERD

![영화 평점 데이터베이스 ERD](docs/ERD.png)

관계는 다음과 같습니다.

- `genre` 1 : N `movie`
- `member` 1 : N `review`
- `movie` 1 : N `review`

즉 과제의 **1:N 관계 최소 2개** 요구사항을 충족하며, 실제로는 3개의 1:N 관계를 구성했습니다.

FK 정의와 실제 PRAGMA 확인 결과는 [`result/fk_validation.txt`](result/fk_validation.txt)에 기록했습니다.

---

## 5. 테이블 설계

| 테이블 | 역할 | PK | FK |
| --- | --- | --- | --- |
| `member` | 회원 정보 | `member_id` | - |
| `genre` | 영화 장르 | `genre_id` | - |
| `movie` | 영화 정보 | `movie_id` | `genre_id` |
| `review` | 회원의 영화 리뷰 및 평점 | `review_id` | `member_id`, `movie_id` |

### PK 선정 이유

| 테이블 | PK | 선정 이유 |
| --- | --- | --- |
| `member` | `member_id` | 이름·이메일이 변경되더라도 회원을 안정적으로 식별하기 위한 숫자 식별자입니다. |
| `genre` | `genre_id` | 장르명을 직접 관계 키로 사용하지 않고 장르를 독립적으로 식별하기 위해 사용합니다. |
| `movie` | `movie_id` | 영화 제목은 중복될 수 있으므로 각 영화를 유일하게 식별하기 위해 사용합니다. |
| `review` | `review_id` | 한 회원이 여러 리뷰를 작성할 수 있으므로 각 리뷰를 독립적으로 식별하기 위해 사용합니다. |

### 컬럼 타입 선정 기준

| 주요 컬럼 | 타입 | 선정 이유 |
| --- | --- | --- |
| 각 `*_id` | `INTEGER` | PK/FK로 사용되는 숫자형 식별자이며 비교와 JOIN 기준으로 사용하기 적합합니다. |
| `name`, `email`, `genre_name`, `title` | `VARCHAR` | 길이가 고정되지 않은 문자열 데이터이므로 가변 길이 문자형으로 정의했습니다. |
| `release_year` | `INTEGER` | 연도는 숫자 비교와 정렬이 필요하므로 정수형을 사용했습니다. |
| `rating` | `INTEGER` | 평점을 1~5 정수로 관리하며 `CHECK` 제약조건으로 범위를 제한합니다. |
| `comment` | `VARCHAR(500)` | 리뷰 내용은 길이가 일정하지 않은 문자열이므로 가변 길이 문자형을 사용했습니다. |
| `created_at` | `DATE` | 리뷰 작성일이라는 컬럼의 의미를 명확하게 표현하기 위해 날짜형으로 선언했습니다. |

> SQLite는 동적 타입 시스템을 사용하므로 `VARCHAR(50)`의 길이나 `DATE` 저장 형식을 다른 일부 DBMS처럼 엄격하게 강제하지 않습니다. 이 프로젝트에서는 컬럼의 의미를 드러내고 표준 SQL에 가까운 스키마를 작성하기 위해 해당 타입명을 사용했습니다.

### 제약조건

- 모든 테이블에 `PRIMARY KEY` 적용
- 필수 값에 `NOT NULL` 적용
- `member.email`, `genre.genre_name`에 `UNIQUE` 적용
- `review.rating`에 `CHECK (rating BETWEEN 1 AND 5)` 적용
- `movie.genre_id`, `review.member_id`, `review.movie_id`에 FK 적용

### 부모 데이터 삭제 정책

FK에 별도의 `ON DELETE` 옵션을 지정하지 않았으므로 SQLite의 기본 동작인 `NO ACTION`을 사용합니다. FK 검사가 활성화된 연결에서는 자식 행이 참조 중인 부모 행을 바로 삭제할 수 없으므로, 회원·영화·장르를 삭제해야 할 경우 먼저 관련 자식 데이터의 존재 여부와 삭제 순서를 확인해야 합니다.

### 테이블 분리와 정규화

각 컬럼에는 하나의 원자값을 저장하고, 회원·장르·영화·리뷰 정보를 역할별로 분리했습니다. 모든 테이블은 단일 컬럼 PK를 사용하므로 부분 함수 종속을 두지 않았고, 장르명·회원명·영화 제목 같은 정보를 리뷰 테이블에 반복 저장하지 않도록 분리하여 **3NF 수준의 단순한 관계형 구조**를 목표로 설계했습니다. 과제 범위에 맞춰 정규화 이론 자체는 과도하게 확장하지 않았습니다.

---

## 6. 샘플 데이터

| 테이블 | 초기 데이터 수 | 특징 |
| --- | ---: | --- |
| `member` | 10 | `member_id = 10` 임하늘은 리뷰가 없음 |
| `genre` | 10 | 10개 장르 구성 |
| `movie` | 10 | `movie_id = 10` 사라진 기록은 리뷰가 없음 |
| `review` | 11 | DELETE 실습 후에도 최소 10행 유지 가능 |

샘플 데이터는 JOIN·LEFT JOIN·집계·서브쿼리 결과를 확인할 수 있도록 의도적으로 관계를 구성했습니다. 예를 들어 임하늘 회원과 사라진 기록 영화에는 연결된 리뷰가 없어 `LEFT JOIN`의 비매칭 행을 확인할 수 있습니다.

---

## 7. 핵심 SQL 15개와 결과 파일 매핑

| 번호 | 유형 | 핵심 문법 | 확인 내용 | 결과 증빙 |
| ---: | --- | --- | --- | --- |
| Q01 | 기본 조회 | `WHERE` | 2023년 이후 영화 | [`q01.txt`](result/q01.txt) |
| Q02 | 기본 조회 | `ORDER BY` | 최신 개봉 연도 순 | [`q02.txt`](result/q02.txt) |
| Q03 | 기본 조회 | `ORDER BY`, `LIMIT` | 최신 영화 5개 | [`q03.txt`](result/q03.txt) |
| Q04 | 기본 조회 | `WHERE`, `ORDER BY` | 평점 4점 이상 리뷰 | [`q04.txt`](result/q04.txt) |
| Q05 | 조인 | `INNER JOIN` | 회원 + 리뷰 | [`q05.txt`](result/q05.txt) |
| Q06 | 조인 | `INNER JOIN` | 영화 + 리뷰 | [`q06.txt`](result/q06.txt) |
| Q07 | 조인 | `INNER JOIN` | 영화 + 장르 | [`q07.txt`](result/q07.txt) |
| Q08 | 조인 | `LEFT JOIN` | 리뷰가 없는 회원 | [`q08.txt`](result/q08.txt) |
| Q09 | 집계 | `COUNT`, `GROUP BY` | 영화별 리뷰 수 | [`q09.txt`](result/q09.txt) |
| Q10 | 집계 | `AVG`, `GROUP BY` | 영화별 평균 평점 | [`q10.txt`](result/q10.txt) |
| Q11 | 집계 | `COUNT`, `GROUP BY` | 회원별 리뷰 수 | [`q11.txt`](result/q11.txt) |
| Q12 | 서브쿼리 | `NOT EXISTS` | 리뷰가 없는 회원 | [`q12.txt`](result/q12.txt) |
| Q13 | 데이터 수정 | `UPDATE` | 리뷰 평점·내용 수정 | [`q13.txt`](result/q13.txt) |
| Q14 | 데이터 삭제 | `DELETE` | 리뷰 1건 삭제 | [`q14.txt`](result/q14.txt) |
| Q15 | 인덱스 | `CREATE INDEX` | `review.movie_id` 인덱스 | [`q15.txt`](result/q15.txt) |

> 결과 증빙은 초기 스키마와 샘플 데이터를 적용한 새 DB에서 Q01 → Q15 순서로 실행해 기록했습니다. 따라서 Q13과 Q14 이전의 조회 결과는 초기 11개 리뷰 상태를 기준으로 하며, Q13 이후 평점이 수정되고 Q14 이후 리뷰 수가 10개로 변경됩니다.

---

## 8. Q01~Q15 실행 결과

<details>
<summary><strong>Q01. 기본 조회 / WHERE — 2023년 이후 영화 5건 조회</strong></summary>

| movie_id | title | release_year |
| --- | --- | --- |
| 1 | 우주 여행 | 2024 |
| 3 | 도시의 추격자 | 2023 |
| 6 | 닫힌 방 | 2024 |
| 8 | 마법의 숲 | 2023 |
| 10 | 사라진 기록 | 2025 |

전체 증빙: [`result/q01.txt`](result/q01.txt)

</details>

<details>
<summary><strong>Q02. 기본 조회 / ORDER BY — 개봉 연도 내림차순으로 10건 조회</strong></summary>

| movie_id | title | release_year |
| --- | --- | --- |
| 10 | 사라진 기록 | 2025 |
| 1 | 우주 여행 | 2024 |
| 6 | 닫힌 방 | 2024 |
| 3 | 도시의 추격자 | 2023 |
| 8 | 마법의 숲 | 2023 |
| 5 | 우리의 여름 | 2022 |
| 2 | 마지막 봄 | 2021 |
| 9 | 푸른 지구 | 2021 |
| 4 | 웃음 공장 | 2020 |
| 7 | 별빛 친구들 | 2019 |

전체 증빙: [`result/q02.txt`](result/q02.txt)

</details>

<details>
<summary><strong>Q03. 기본 조회 / ORDER BY + LIMIT — 최신 영화 상위 5건 조회</strong></summary>

| movie_id | title | release_year |
| --- | --- | --- |
| 10 | 사라진 기록 | 2025 |
| 1 | 우주 여행 | 2024 |
| 6 | 닫힌 방 | 2024 |
| 3 | 도시의 추격자 | 2023 |
| 8 | 마법의 숲 | 2023 |

전체 증빙: [`result/q03.txt`](result/q03.txt)

</details>

<details>
<summary><strong>Q04. 기본 조회 / WHERE + ORDER BY — 평점 4점 이상 리뷰 8건 조회</strong></summary>

| review_id | movie_id | rating | comment |
| --- | --- | --- | --- |
| 1 | 1 | 5 | 영상과 이야기가 인상적이었다. |
| 4 | 3 | 5 | 액션 장면이 훌륭했다. |
| 7 | 6 | 5 | 긴장감이 끝까지 유지됐다. |
| 11 | 3 | 5 | 다시 보고 싶은 영화다. |
| 2 | 1 | 4 | 재미있게 감상했다. |
| 6 | 5 | 4 | 배우들의 연기가 좋았다. |
| 8 | 7 | 4 | 가볍게 보기 좋은 영화였다. |
| 10 | 9 | 4 | 내용이 유익했다. |

전체 증빙: [`result/q04.txt`](result/q04.txt)

</details>

<details>
<summary><strong>Q05. INNER JOIN — 회원-리뷰 INNER JOIN 11건</strong></summary>

| name | rating | comment |
| --- | --- | --- |
| 김민수 | 5 | 영상과 이야기가 인상적이었다. |
| 이지은 | 4 | 재미있게 감상했다. |
| 박서준 | 3 | 잔잔한 분위기가 좋았다. |
| 최유진 | 5 | 액션 장면이 훌륭했다. |
| 정현우 | 2 | 기대보다 아쉬웠다. |
| 한수빈 | 4 | 배우들의 연기가 좋았다. |
| 윤지호 | 5 | 긴장감이 끝까지 유지됐다. |
| 강서연 | 4 | 가볍게 보기 좋은 영화였다. |
| 오민재 | 3 | 세계관은 흥미로웠다. |
| 김민수 | 4 | 내용이 유익했다. |
| 이지은 | 5 | 다시 보고 싶은 영화다. |

전체 증빙: [`result/q05.txt`](result/q05.txt)

</details>

<details>
<summary><strong>Q06. INNER JOIN — 영화-리뷰 INNER JOIN 11건</strong></summary>

| title | rating | comment |
| --- | --- | --- |
| 우주 여행 | 5 | 영상과 이야기가 인상적이었다. |
| 우주 여행 | 4 | 재미있게 감상했다. |
| 마지막 봄 | 3 | 잔잔한 분위기가 좋았다. |
| 도시의 추격자 | 5 | 액션 장면이 훌륭했다. |
| 웃음 공장 | 2 | 기대보다 아쉬웠다. |
| 우리의 여름 | 4 | 배우들의 연기가 좋았다. |
| 닫힌 방 | 5 | 긴장감이 끝까지 유지됐다. |
| 별빛 친구들 | 4 | 가볍게 보기 좋은 영화였다. |
| 마법의 숲 | 3 | 세계관은 흥미로웠다. |
| 푸른 지구 | 4 | 내용이 유익했다. |
| 도시의 추격자 | 5 | 다시 보고 싶은 영화다. |

전체 증빙: [`result/q06.txt`](result/q06.txt)

</details>

<details>
<summary><strong>Q07. INNER JOIN — 영화-장르 INNER JOIN 10건</strong></summary>

| title | genre_name |
| --- | --- |
| 우주 여행 | SF |
| 마지막 봄 | 드라마 |
| 도시의 추격자 | 액션 |
| 웃음 공장 | 코미디 |
| 우리의 여름 | 로맨스 |
| 닫힌 방 | 스릴러 |
| 별빛 친구들 | 애니메이션 |
| 마법의 숲 | 판타지 |
| 푸른 지구 | 다큐멘터리 |
| 사라진 기록 | 미스터리 |

전체 증빙: [`result/q07.txt`](result/q07.txt)

</details>

<details>
<summary><strong>Q08. LEFT JOIN — 리뷰가 없는 회원 임하늘 1건</strong></summary>

| member_id | name |
| --- | --- |
| 10 | 임하늘 |

전체 증빙: [`result/q08.txt`](result/q08.txt)

</details>

<details>
<summary><strong>Q09. COUNT + GROUP BY — 영화별 리뷰 수 집계 10건</strong></summary>

| movie_id | title | review_count |
| --- | --- | --- |
| 1 | 우주 여행 | 2 |
| 3 | 도시의 추격자 | 2 |
| 2 | 마지막 봄 | 1 |
| 4 | 웃음 공장 | 1 |
| 5 | 우리의 여름 | 1 |
| 6 | 닫힌 방 | 1 |
| 7 | 별빛 친구들 | 1 |
| 8 | 마법의 숲 | 1 |
| 9 | 푸른 지구 | 1 |
| 10 | 사라진 기록 | 0 |

전체 증빙: [`result/q09.txt`](result/q09.txt)

</details>

<details>
<summary><strong>Q10. AVG + GROUP BY — 영화별 평균 평점 집계 9건</strong></summary>

| movie_id | title | average_rating |
| --- | --- | --- |
| 3 | 도시의 추격자 | 5 |
| 6 | 닫힌 방 | 5 |
| 1 | 우주 여행 | 4.5 |
| 5 | 우리의 여름 | 4 |
| 7 | 별빛 친구들 | 4 |
| 9 | 푸른 지구 | 4 |
| 2 | 마지막 봄 | 3 |
| 8 | 마법의 숲 | 3 |
| 4 | 웃음 공장 | 2 |

전체 증빙: [`result/q10.txt`](result/q10.txt)

</details>

<details>
<summary><strong>Q11. COUNT + GROUP BY — 회원별 리뷰 작성 수 집계 10건</strong></summary>

| member_id | name | review_count |
| --- | --- | --- |
| 1 | 김민수 | 2 |
| 2 | 이지은 | 2 |
| 3 | 박서준 | 1 |
| 4 | 최유진 | 1 |
| 5 | 정현우 | 1 |
| 6 | 한수빈 | 1 |
| 7 | 윤지호 | 1 |
| 8 | 강서연 | 1 |
| 9 | 오민재 | 1 |
| 10 | 임하늘 | 0 |

전체 증빙: [`result/q11.txt`](result/q11.txt)

</details>

<details>
<summary><strong>Q12. 상관 서브쿼리 / NOT EXISTS — NOT EXISTS로 임하늘 1건</strong></summary>

| member_id | name |
| --- | --- |
| 10 | 임하늘 |

전체 증빙: [`result/q12.txt`](result/q12.txt)

</details>

<details>
<summary><strong>Q13. UPDATE — review_id=5 평점 2→3, 리뷰 내용 수정</strong></summary>

**변경 전**

| review_id | rating | comment |
| --- | --- | --- |
| 5 | 2 | 기대보다 아쉬웠다. |

**변경 후**

| review_id | rating | comment |
| --- | --- | --- |
| 5 | 3 | 다시 보니 처음보다 재미있었다. |

전체 증빙: [`result/q13.txt`](result/q13.txt)

</details>

<details>
<summary><strong>Q14. DELETE — review_id=11 삭제, 리뷰 11→10건</strong></summary>

- 삭제 전 리뷰 수: `11`
- 삭제 후 리뷰 수: `10`
- `review_id = 11` 조회 결과: `0건`

전체 증빙: [`result/q14.txt`](result/q14.txt)

</details>

<details>
<summary><strong>Q15. CREATE INDEX — idx_review_movie_id 생성 및 사용 계획 확인</strong></summary>

- 생성 인덱스: `idx_review_movie_id`
- 대상 컬럼: `review.movie_id`
- `EXPLAIN QUERY PLAN` 확인 결과: `SEARCH review USING INDEX idx_review_movie_id (movie_id=?)`

전체 증빙: [`result/q15.txt`](result/q15.txt)

</details>

---

## 9. INNER JOIN과 LEFT JOIN 비교

### INNER JOIN

`INNER JOIN`은 **두 테이블의 JOIN 조건이 일치하는 행만 반환**합니다. Q05에서는 `member.member_id = review.member_id`가 일치하는 회원만 결과에 포함됩니다. 따라서 리뷰가 없는 `임하늘`은 Q05 결과에 포함되지 않습니다.

### LEFT JOIN

`LEFT JOIN`은 **왼쪽 테이블의 모든 행을 유지**하고, 오른쪽 테이블에 일치하는 행이 없으면 오른쪽 컬럼을 `NULL`로 반환합니다. Q08에서는 `member`가 왼쪽 테이블이므로 리뷰가 없는 회원도 먼저 남고, `WHERE r.review_id IS NULL` 조건으로 그 회원만 추출합니다.

Q08 결과:

| member_id | name |
| ---: | --- |
| 10 | 임하늘 |

정리하면 다음과 같습니다.

| 구분 | INNER JOIN | LEFT JOIN |
| --- | --- | --- |
| 매칭된 행 | 반환 | 반환 |
| 왼쪽에만 존재하는 행 | 제외 | 반환 |
| 이 프로젝트의 예 | 리뷰가 있는 회원 조회 | 리뷰가 없는 회원 찾기 |

---

## 10. 복합 쿼리 단계별 로직

### Q12. 상관 서브쿼리 `NOT EXISTS`

```sql
SELECT m.member_id
     , m.name
  FROM member AS m
 WHERE NOT EXISTS (
       SELECT 1
         FROM review AS r
        WHERE r.member_id = m.member_id
       );
```

처리 과정은 다음과 같습니다.

1. 바깥 쿼리가 `member` 테이블의 회원을 한 명씩 확인합니다.
2. 내부 서브쿼리가 현재 회원의 `member_id`와 같은 리뷰가 존재하는지 조회합니다.
3. 리뷰가 존재하면 `EXISTS = TRUE`이므로 `NOT EXISTS = FALSE`가 되어 해당 회원을 제외합니다.
4. 리뷰가 존재하지 않으면 `NOT EXISTS = TRUE`가 되어 해당 회원을 최종 결과에 포함합니다.
5. 샘플 데이터에서는 리뷰가 없는 `member_id = 10`, `임하늘`만 반환됩니다.

처리 흐름을 단순화하면 **`member 조회 → 회원별 review 존재 여부 검사 → 리뷰가 없는 회원만 선택`**입니다.

### Q09. JOIN + GROUP BY + COUNT

Q09는 `movie`와 `review`를 `LEFT JOIN`한 뒤 영화별로 그룹을 만들고 각 그룹의 리뷰 개수를 계산합니다. `LEFT JOIN`을 사용했기 때문에 리뷰가 없는 `사라진 기록`도 그룹에 남으며 `COUNT(r.review_id)` 결과가 `0`이 됩니다.

처리 흐름은 **`movie와 review 연결 → movie별 GROUP BY → COUNT(review_id) → 리뷰 수 내림차순 정렬`**입니다.

---

## 11. 인덱스

영화별 리뷰 조회나 영화-리뷰 JOIN에서 자주 사용하는 `review.movie_id`에 인덱스를 생성했습니다.

```sql
CREATE INDEX idx_review_movie_id
    ON review(movie_id);
```

샘플 데이터가 10여 건뿐이므로 실행 시간을 전후로 비교하는 것은 의미가 작습니다. 대신 `EXPLAIN QUERY PLAN`으로 확인했을 때 다음과 같이 생성한 인덱스를 사용하는 실행 계획을 확인했습니다.

```text
SEARCH review USING INDEX idx_review_movie_id (movie_id=?)
```

상세 증빙은 [`result/q15.txt`](result/q15.txt)에 있습니다.

---

## 12. 보너스 과제

### Bonus 1. 같은 요구를 JOIN과 서브쿼리로 해결

**요구:** 리뷰를 한 번도 작성하지 않은 회원 찾기

- Q08: `LEFT JOIN` 후 `r.review_id IS NULL`로 비매칭 회원 조회
- Q12: 상관 서브쿼리의 `NOT EXISTS`로 리뷰 존재 여부 검사

두 방식 모두 동일하게 다음 결과를 반환합니다.

| member_id | name |
| ---: | --- |
| 10 | 임하늘 |

`LEFT JOIN`은 테이블을 결합한 뒤 연결되지 않은 행을 찾는 방식이고, `NOT EXISTS`는 각 회원에 대해 조건을 만족하는 리뷰의 존재 여부 자체를 검사하는 방식입니다.

### Bonus 2. FK 무결성 오류 검증

실제 오류 화면은 별도 이미지로 증빙했습니다.

![FK 무결성 오류 검증](docs/bonus2-error.png)

FK 정의와 활성화 상태 자체의 텍스트 검증은 [`result/fk_validation.txt`](result/fk_validation.txt)에 정리했습니다.

### Bonus 3. 미니 리포트

Q13 수정과 Q14 삭제까지 반영한 상태를 기준으로 다음 세 지표를 정의했습니다.

#### 1) 영화별 리뷰 수

| movie_id | title | review_count |
| --- | --- | --- |
| 1 | 우주 여행 | 2 |
| 2 | 마지막 봄 | 1 |
| 3 | 도시의 추격자 | 1 |
| 4 | 웃음 공장 | 1 |
| 5 | 우리의 여름 | 1 |
| 6 | 닫힌 방 | 1 |
| 7 | 별빛 친구들 | 1 |
| 8 | 마법의 숲 | 1 |
| 9 | 푸른 지구 | 1 |
| 10 | 사라진 기록 | 0 |

#### 2) 영화별 평균 평점

| movie_id | title | average_rating |
| --- | --- | --- |
| 3 | 도시의 추격자 | 5 |
| 6 | 닫힌 방 | 5 |
| 1 | 우주 여행 | 4.5 |
| 5 | 우리의 여름 | 4 |
| 7 | 별빛 친구들 | 4 |
| 9 | 푸른 지구 | 4 |
| 2 | 마지막 봄 | 3 |
| 4 | 웃음 공장 | 3 |
| 8 | 마법의 숲 | 3 |

#### 3) 회원별 리뷰 작성 수

| member_id | name | review_count |
| --- | --- | --- |
| 1 | 김민수 | 2 |
| 2 | 이지은 | 1 |
| 3 | 박서준 | 1 |
| 4 | 최유진 | 1 |
| 5 | 정현우 | 1 |
| 6 | 한수빈 | 1 |
| 7 | 윤지호 | 1 |
| 8 | 강서연 | 1 |
| 9 | 오민재 | 1 |
| 10 | 임하늘 | 0 |

---

## 13. FK 검증

실제 SQLite 메타데이터 확인 결과 다음 FK가 정의되어 있습니다.

```text
movie.genre_id   -> genre.genre_id
review.movie_id  -> movie.movie_id
review.member_id -> member.member_id
```

`PRAGMA foreign_keys;`가 `1`인 동일 연결에서 FK 검사가 활성화됩니다. 자세한 PRAGMA 출력은 [`result/fk_validation.txt`](result/fk_validation.txt)에 있습니다.

---

## 14. 실행 순서

1. VS Code에서 `0.movie_rating.db3` 또는 새 SQLite DB를 엽니다.
2. `1.schema.sql`을 실행해 테이블과 제약조건을 생성합니다.
3. `2.sample_data.sql`을 실행해 샘플 데이터를 입력합니다.
4. `3.queries.sql`의 Q01~Q15를 순서대로 실행합니다.
5. 보너스 쿼리를 실행하고 결과를 확인합니다.
6. ERD, 결과 텍스트, FK 오류 이미지를 함께 확인합니다.

> `PRAGMA foreign_keys = ON;`은 DB 파일에 영구 저장되는 값이 아니라 **연결 단위 설정**입니다. VS Code SQLite Extension에서 새 연결/세션이 만들어진 경우 같은 연결에서 다시 활성화 여부를 확인해야 합니다.

---

## 15. 트러블슈팅

### `table member already exists`

이미 테이블이 생성된 DB에 `1.schema.sql`을 다시 실행하면 동일한 `CREATE TABLE`이 실행되어 `table member already exists` 오류가 발생할 수 있습니다. 초기 개발 단계에서는 테스트 DB를 초기화한 뒤 스키마를 다시 적용하여 해결했습니다.

### `PRAGMA foreign_keys`가 다른 SQL 파일에서 0으로 조회됨

SQLite의 FK 활성화 설정은 연결 단위입니다. 한 SQL 실행 연결에서 `PRAGMA foreign_keys = ON;`을 실행했더라도 다른 연결에서는 `0`일 수 있으므로 **FK 테스트를 수행하는 동일 연결에서 `PRAGMA foreign_keys = ON;`과 `PRAGMA foreign_keys;`를 확인**하도록 했습니다.

### 스크립트 재실행 시 중복 오류

`2.sample_data.sql`을 이미 데이터가 존재하는 DB에 다시 실행하면 PK/UNIQUE 중복 오류가 발생할 수 있고, Q15를 반복 실행하면 동일한 인덱스가 이미 존재한다는 오류가 발생할 수 있습니다. 따라서 검증 시에는 초기화된 DB에서 스키마 → 샘플 데이터 → Q01~Q15 순서로 실행합니다.

---

## 16. 요구사항 충족 현황

| 요구사항 | 구현 |
| --- | --- |
| 로컬 DB | SQLite |
| 테이블 최소 4개 | 4개 |
| 모든 테이블 PK | 완료 |
| FK 최소 2개 | 3개 |
| 1:N 관계 최소 2개 | 3개 |
| `NOT NULL` | 적용 |
| `UNIQUE` | 적용 |
| 테이블별 최소 10행 | 충족 |
| 기본 조회 4개 | Q01~Q04 |
| JOIN 4개 이상 | Q05~Q08 |
| INNER JOIN 2개 이상 | Q05~Q07 |
| LEFT JOIN 1개 이상 | Q08 |
| 집계 3개 이상 | Q09~Q11 |
| `COUNT`, `AVG` 2종 이상 | 충족 |
| 서브쿼리 | Q12 |
| UPDATE / DELETE | Q13 / Q14 |
| 인덱스 | Q15 |
| 실행 결과 텍스트 | `result/q01.txt ~ q15.txt` |
| FK 검증 | `result/fk_validation.txt`, `docs/bonus2-error.png` |
| ERD | `docs/ERD.png` |
| 보너스 1~3 | 완료 |

---

## 17. 학습 내용

이 프로젝트를 통해 다음 내용을 실습했습니다.

- PK와 FK를 이용한 테이블 간 관계 설계
- 1:N 관계와 참조 무결성
- `NOT NULL`, `UNIQUE`, `CHECK` 제약조건
- `SELECT`, `INSERT`, `UPDATE`, `DELETE`
- `INNER JOIN`, `LEFT JOIN`의 동작 차이
- `GROUP BY`, `COUNT`, `AVG`를 이용한 집계
- `NOT EXISTS` 상관 서브쿼리
- 인덱스 생성과 실행 계획 확인
- SQLite의 연결 단위 FK 활성화 특성
