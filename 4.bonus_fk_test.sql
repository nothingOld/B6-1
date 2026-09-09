-- BONUS 2. 데이터 정합성 깨뜨려 보기
-- 이 파일은 의도적으로 FK 오류를 발생시키는 검증용 파일입니다.
-- FOREIGN KEY constraint failed가 발생하면 정상적으로 검증된 것입니다.

-- SQLite 전용 문법: 현재 DB 연결에서 외래 키(FK) 제약조건을 활성화한다.
PRAGMA foreign_keys = ON;

-- FK 활성화 상태 확인: 1이어야 한다.
PRAGMA foreign_keys;

-- 존재하지 않는 member_id = 999를 참조하여 FK 오류를 발생시킨다.
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
