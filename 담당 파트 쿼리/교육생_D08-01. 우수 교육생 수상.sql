-- 로그인
INSERT INTO tblLogin Values (1, '최빈수', '1808966'); -- 우수 교육생 내역 있는 사용자
INSERT INTO tblLogin Values (1, '이우현', '1427956'); -- 우수 교육생 내역 없는 사용자

-- 로그아웃
DELETE FROM tblLogin;

-- 로그인한 사용자 확인
SELECT * FROM tblLogin;

-- 로그인한 사용자의 교육생 번호 뽑아내기
SELECT
    studentNum
  FROM vwStudent vs
        INNER JOIN tblLogin l
            ON l.pw = substr(vs.studentSsn,8,7)
 WHERE vs.studentName = l.id;

-- ****************************************************** 로그인 시, 사용자의 정보가 tblLogin에 들어간다는 가정 하 **************************************************************
-- ****************************************************** 매개변수 없이 tblLogin에 담긴 정보를 가지고 확인하는 쿼리 *************************************************************
----------------------------------------------------- [로그인한 사용자의 우수 교육생 내역 조회] ------------------------------------------------------------------------------
-- [매개변수 없는 Ver. 프로시저 생성]
/
CREATE OR REPLACE PROCEDURE procMyPrize
IS
    vnum NUMBER; --로그인한 사용자의 교육생 번호를 담는 변수
    vcnt NUMBER; --사용자의 교육생 번호가 '상' 테이블에 존재하는 개수를 담는 변수 
BEGIN
    -- 로그인한 상태(로그인 테이블에 id, pw가 들어가 있다는 가정 하에 해당 로그인한 학생의 우수 교육생 내역 조회)
    SELECT
        studentNum 
      INTO vnum
      FROM vwStudent vs
            INNER JOIN tblLogin l
                ON l.pw = substr(vs.studentSsn,8,7)
     WHERE vs.studentName = l.id;
     
     SELECT
        count(*) 
       INTO vcnt
       FROM tblPrize
      WHERE studentNum = vnum;
        
    DBMS_OUTPUT.PUT_LINE('──────────────────── 우수 교육생 수상 내역 조회 ────────────────────');
    
    IF vcnt > 0 THEN --로그인한 사용자의 교육생 번호와 일치하는 레코드가 '상' 테이블에 있을 경우 내역 출력
        
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
           WHERE p.studentNum = vnum
           ORDER BY 부문 DESC
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE('  ' || best."교육생 이름" || '님, ' || best.부문 || ' 학생 선정을 축하합니다!');
            DBMS_OUTPUT.PUT_LINE(' ');
            DBMS_OUTPUT.PUT_LINE('  부문: ' || best.부문);
            DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || best."교육생 번호");
            DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || best."교육생 이름");
            DBMS_OUTPUT.PUT_LINE('  과정명: ' || best.과정명);
            DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || best."과정 시작일");
            DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || best."과정 종료일");
            DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────────────────────────────');
        END LOOP;
    ELSE --'상' 테이블에 로그인한 사용자의 교육생 번호 레코드가 존재하지 않을 경우 하기 문구 출력
        DBMS_OUTPUT.PUT_LINE('  해당 내역이 존재하지 않습니다.');
        DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────────────────────────────');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('우수 교육생 수상 내역 조회에 실패했습니다.');
--    RAISE_APPLICATION_ERROR(-10001, '우수 교육생 수상 내역 조회에 실패했습니다.');
END procMyPrize;
/

-- [매개변수 없는 Ver. 프로시저 실행]
/
BEGIN
    procMyPrize;
END;
/

----------------------------------------------------- [본인이 수강한 과정의 우수 교육생 조회] ------------------------------------------------------------------------------
-- [매개변수 없는 Ver. 프로시저 생성]
/
CREATE OR REPLACE PROCEDURE proc_My_Cs_Prize
IS
    vnum NUMBER; --로그인한 사용자의 과정 상세 번호를 담는 변수
    vcnt NUMBER; --해당 개설 과정의 번호가 '상' 테이블에 존재하는 개수를 담는 변수
BEGIN
    -- 로그인한 상태(로그인 테이블에 id, pw가 들어가 있다는 가정 하에 해당 로그인한 학생이 수강중인 과정의 우수 교육생 내역 조회)
    SELECT
        s.courseDetailNum
      INTO vnum
      FROM vwStudent vs
           INNER JOIN tblStudent s
                   ON s.studentNum = vs.studentNum
           INNER JOIN tblLogin l
                   ON l.pw = substr(vs.studentSsn,8,7)
     WHERE vs.studentName = l.id;
     
     SELECT
        count(*) 
       INTO vcnt
       FROM tblPrize p
            INNER JOIN tblStudent s
                    ON s.studentNum = p.studentNum
      WHERE s.courseDetailNum = vnum;
        
    DBMS_OUTPUT.PUT_LINE('──────────────────── 우수 교육생 조회 ─────────────────────');
    
    IF vcnt > 0 THEN --로그인한 사용자의 과정 상세 번호와 일치하는 레코드가 '상' 테이블에 있을 경우 내역 출력
        
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
           WHERE cs.courseDetailNum = vnum
           ORDER BY 부문 DESC, TO_NUMBER("교육생 번호") ASC
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
    ELSE --'상' 테이블에 로그인한 사용자의 과정 상세 번호와 일치하는 레코드가 존재하지 않을 경우 하기 문구 출력
        DBMS_OUTPUT.PUT_LINE('  해당 내역이 존재하지 않습니다.');
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('우수 교육생 조회에 실패했습니다.');
--        RAISE_APPLICATION_ERROR(-10001, '우수 교육생 조회에 실패했습니다.');
END proc_My_Cs_Prize;
/

-- [매개변수 없는 Ver. 프로시저 실행]
/
BEGIN
    proc_My_Cs_Prize;
END;
/






-- ****************************************************** tblLogin 테이블 사용 없이 ID, PW를 입력받는다는 가정 하 *************************************************************
-- ****************************************************** 매개변수가 있는, 입력받은 값을 기준으로 확인하는 쿼리    *************************************************************
----------------------------------------------------- [로그인한 사용자의 우수 교육생 내역 조회] ------------------------------------------------------------------------------
-- [매개변수 있는 Ver. 프로시저 생성]
/
CREATE OR REPLACE PROCEDURE procMyPrize(
    pid VARCHAR2, --로그인 id
    ppw VARCHAR2 --로그인 pw
)
IS
    vnum NUMBER; --로그인한 사용자의 교육생 번호를 담는 변수
    vcnt NUMBER; --사용자의 교육생 번호가 '상' 테이블에 존재하는 개수를 담는 변수 
BEGIN
    -- 로그인한 상태(프로시저 파라미터로 id, pw를 받아서 해당 로그인한 학생의 우수 교육생 내역 조회)
    SELECT
        studentNum 
      INTO vnum
      FROM vwStudent
     WHERE studentName = pid
       AND substr(studentSsn,8,7) = ppw;
     
     SELECT
        count(*) 
       INTO vcnt
       FROM tblPrize
      WHERE studentNum = vnum;
        
    DBMS_OUTPUT.PUT_LINE('──────────────────── 우수 교육생 수상 내역 조회 ────────────────────');
    
    IF vcnt > 0 THEN --로그인한 사용자의 교육생 번호와 일치하는 레코드가 '상' 테이블에 있을 경우 내역 출력
        
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
           WHERE p.studentNum = vnum
           ORDER BY 부문 DESC
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE('  ' || best."교육생 이름" || '님, ' || best.부문 || ' 학생 선정을 축하합니다!');
            DBMS_OUTPUT.PUT_LINE(' ');
            DBMS_OUTPUT.PUT_LINE('  부문: ' || best.부문);
            DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || best."교육생 번호");
            DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || best."교육생 이름");
            DBMS_OUTPUT.PUT_LINE('  과정명: ' || best.과정명);
            DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || best."과정 시작일");
            DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || best."과정 종료일");
            DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────────────────────────────');
        END LOOP;
    ELSE --'상' 테이블에 로그인한 사용자의 교육생 번호 레코드가 존재하지 않을 경우 하기 문구 출력
        DBMS_OUTPUT.PUT_LINE('  해당 내역이 존재하지 않습니다.');
        DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────────────────────────────');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('우수 교육생 수상 내역 조회에 실패했습니다.');
--    RAISE_APPLICATION_ERROR(-10001, '우수 교육생 수상 내역 조회에 실패했습니다.');
END procMyPrize;
/
-- [매개변수 있는 Ver. 프로시저 실행]
--- 1. 내역이 존재하는 Case
/
BEGIN
	procMyPrize('최빈수', '1808966'); -- 로그인 사용자 id, pw 입력
END; 
/
--- 2. 내역이 존재하지 않는 Case
/
BEGIN
	procMyPrize('이우현', '1427956'); -- 로그인 사용자 id, pw 입력
END; 
/

----------------------------------------------------- [본인이 수강한 과정의 우수 교육생 조회] ------------------------------------------------------------------------------
-- [매개 변수 있는 ver. 프로시저 생성]
/
CREATE OR REPLACE PROCEDURE proc_My_Cs_Prize(
    pid VARCHAR2, --로그인 id
    ppw VARCHAR2 --로그인 pw
)
IS
    vnum NUMBER; --로그인한 사용자의 과정 상세 번호를 담는 변수
    vcnt NUMBER; --해당 개설 과정의 번호가 '상' 테이블에 존재하는 개수를 담는 변수
BEGIN
    -- 로그인한 상태(프로시저 파라미터로 id, pw를 받아서 해당 로그인한 학생이 수강한 과정의 우수 교육생 조회)
    SELECT
        s.courseDetailNum
      INTO vnum
      FROM vwStudent vs
           INNER JOIN tblStudent s
                   ON s.studentNum = vs.studentNum
     WHERE vs.studentName = pid
       AND substr(vs.studentSsn,8,7) = ppw;
     
     SELECT
        count(*) 
       INTO vcnt
       FROM tblPrize p
            INNER JOIN tblStudent s
                    ON s.studentNum = p.studentNum
      WHERE s.courseDetailNum = vnum;
        
    DBMS_OUTPUT.PUT_LINE('──────────────────── 우수 교육생 조회 ─────────────────────');
    
    IF vcnt > 0 THEN --로그인한 사용자의 과정 상세 번호와 일치하는 레코드가 '상' 테이블에 있을 경우 내역 출력
        
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
           WHERE cs.courseDetailNum = vnum
           ORDER BY 부문 DESC, TO_NUMBER("교육생 번호") ASC
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
    ELSE --'상' 테이블에 로그인한 사용자의 과정 상세 번호와 일치하는 레코드가 존재하지 않을 경우 하기 문구 출력
        DBMS_OUTPUT.PUT_LINE('  해당 내역이 존재하지 않습니다.');
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('우수 교육생 조회에 실패했습니다.');
--        RAISE_APPLICATION_ERROR(-10001, '우수 교육생 조회에 실패했습니다.');
END proc_My_Cs_Prize;
/
-- [매개변수 있는 Ver. 프로시저 실행]
--- 1. 내역이 존재하는 Case
/
BEGIN
	proc_My_Cs_Prize('최빈수', '1808966'); -- 로그인 사용자 id, pw 입력
END; 
/
--- 2. 내역이 존재하지 않는 Case
/
BEGIN
	proc_My_Cs_Prize('최혜소', '2170817'); -- 로그인 사용자 id, pw 입력
END; 
/