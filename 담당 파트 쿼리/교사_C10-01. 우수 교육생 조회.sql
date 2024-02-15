-- 로그인
INSERT INTO tblLogin Values (1, '채제투', '1234567'); -- 근무중인 교사
INSERT INTO tblLogin Values (1, '김머기', '1579983'); -- 대기중인 교사 > 이 파트에서는 조회 기능 권한 O로 가정
INSERT INTO tblLogin Values (1, '양현미', '2473554'); -- 퇴사한 교사

-- 로그아웃
DELETE FROM tblLogin;

-- 로그인한 사용자 확인
SELECT * FROM tblLogin;
select * from tblteacher;

--> 로그인 사용자별로 권한 제한 필요~~~~~~~~~~~~~~~~!!

----------------------------------------------------- [특정 과정의 성적 우수 학생 조회] ------------------------------------------------------------------------------
-- [프로시저 생성]
/
CREATE OR REPLACE PROCEDURE procReadBestS(
    pnum NUMBER --과정 상세 번호
)
IS
    vcnt NUMBER; --해당 개설 과정의 번호가 '상' 테이블에 존재하는 개수를 담는 변수
BEGIN

     SELECT
        count(*) 
       INTO vcnt
       FROM tblPrize p
            INNER JOIN tblStudent s
                    ON s.studentNum = p.studentNum
      WHERE s.courseDetailNum = pnum;
        
    DBMS_OUTPUT.PUT_LINE('──────────────────── 우수 교육생 조회 ─────────────────────');
    
    IF vcnt > 0 THEN --입력한 과정 상세 번호와 일치하는 레코드가 '상' 테이블에 있을 경우 내역 출력
        
        FOR best IN (
          SELECT
                vs.studentNum AS "교육생 번호",
                vs.studentName AS "교육생 이름",
                cs.courseName AS 과정명,
                cs.courseStartDate AS "과정 시작일",
                cs.courseEndDate AS "과정 종료일",
                p.prizeCategory AS 부문
            FROM tblPrize p
                INNER JOIN vwStudent vs
                    ON vs.studentNum = p.studentNum
                INNER JOIN vwCompletionStatus cs
                    ON cs.studentNum = vs.studentNum
           WHERE cs.courseDetailNum = pnum
             AND p.prizeCategory = '성적우수'
           ORDER BY TO_NUMBER("교육생 번호") ASC
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE('  부문: ' || best.부문);
            DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || best."교육생 번호");
            DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || best."교육생 이름");
            DBMS_OUTPUT.PUT_LINE('  과정명: ' || best.과정명);
            DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || best."과정 시작일");
            DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || best."과정 종료일");
            DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────');
        END LOOP;
    ELSE --'상' 테이블에 입력한 과정 상세 번호와 일치하는 레코드가 존재하지 않을 경우 하기 문구 출력
        DBMS_OUTPUT.PUT_LINE('  해당 내역이 존재하지 않습니다.');
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('우수 교육생 조회에 실패했습니다.');
--        RAISE_APPLICATION_ERROR(-10001, '우수 교육생 조회에 실패했습니다.');
END procReadBestS;
/

-- [프로시저 실행]
/
BEGIN
    procReadBestS(4); --과정 상세 번호
END;
/

----------------------------------------------------- [특정 과정의 개근 학생 조회] ------------------------------------------------------------------------------
-- [프로시저 생성]
/
CREATE OR REPLACE PROCEDURE procReadBestA(
    pnum NUMBER --과정 상세 번호
)
IS
    vcnt NUMBER; --해당 개설 과정의 번호가 '상' 테이블에 존재하는 개수를 담는 변수
BEGIN

     SELECT
        count(*) 
       INTO vcnt
       FROM tblPrize p
            INNER JOIN tblStudent s
                    ON s.studentNum = p.studentNum
      WHERE s.courseDetailNum = pnum;
        
    DBMS_OUTPUT.PUT_LINE('──────────────────── 우수 교육생 조회 ─────────────────────');
    
    IF vcnt > 0 THEN --입력한 과정 상세 번호와 일치하는 레코드가 '상' 테이블에 있을 경우 내역 출력
        
        FOR best IN (
          SELECT
                vs.studentNum AS "교육생 번호",
                vs.studentName AS "교육생 이름",
                cs.courseName AS 과정명,
                cs.courseStartDate AS "과정 시작일",
                cs.courseEndDate AS "과정 종료일",
                p.prizeCategory AS 부문
            FROM tblPrize p
                INNER JOIN vwStudent vs
                    ON vs.studentNum = p.studentNum
                INNER JOIN vwCompletionStatus cs
                    ON cs.studentNum = vs.studentNum
           WHERE cs.courseDetailNum = pnum
             AND p.prizeCategory = '개근'
           ORDER BY TO_NUMBER("교육생 번호") ASC
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE('  부문: ' || best.부문);
            DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || best."교육생 번호");
            DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || best."교육생 이름");
            DBMS_OUTPUT.PUT_LINE('  과정명: ' || best.과정명);
            DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || best."과정 시작일");
            DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || best."과정 종료일");
            DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────');
        END LOOP;
    ELSE --'상' 테이블에 입력한 과정 상세 번호와 일치하는 레코드가 존재하지 않을 경우 하기 문구 출력
        DBMS_OUTPUT.PUT_LINE('  해당 내역이 존재하지 않습니다.');
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('우수 교육생 조회에 실패했습니다.');
--        RAISE_APPLICATION_ERROR(-10001, '우수 교육생 조회에 실패했습니다.');
END procReadBestA;
/

-- [프로시저 실행]
/
BEGIN
    procReadBestA(1); --과정 상세 번호
END;
/