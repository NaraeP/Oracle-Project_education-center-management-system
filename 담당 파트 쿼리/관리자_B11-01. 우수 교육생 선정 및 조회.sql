-- 로그인
INSERT INTO tblLogin Values (1, '박나래', '4444441'); -- 관리자

-- 로그아웃
DELETE FROM tblLogin;

-- 로그인한 사용자 확인
SELECT * FROM tblLogin;

--> 로그인 사용자별로 권한 제한 필요~~~~~~~~~~~~~~~~!!

----------------------------------------------------- [특정 과정의 성적 우수 학생 선정] ------------------------------------------------------------------------------
-- [프로시저 생성]
/
CREATE OR REPLACE PROCEDURE procAddToSPrize(
    pnum NUMBER --과정 상세 번호
)
IS
    vcursor sys_refcursor; --SELECT절에서 나온 1명 이상의 교육생 번호를 담을 커서
    vnum NUMBER; --커서에서 나온 성적 우수 교육생 번호를 담을 변수
    vcnt NUMBER; --기생성 내역을 확인할 카운트 변수
BEGIN
    OPEN vcursor
    FOR
    SELECT
        studentNum 
      FROM (SELECT 
                A.*, RANK() OVER(ORDER BY totalScore DESC) AS RK
              FROM (SELECT 
                        ts.studentNum,
                        SUM((ts.attendanceScore * (t.attendancePoint / 100)) + (ts.writtenScore * (t.writtenPoint / 100)) + (ts.practicalScore * (t.practicalPoint / 100))) AS totalScore,
                        COUNT(*) AS subjectCnt
                      FROM tblCourseDetail cd
                           INNER JOIN tblSubjectDetail sd 
                                   ON cd.courseDetailNum = sd.courseDetailNum
                           INNER JOIN tblTest t 
                                   ON sd.subjectDetailNum = t.subjectDetailNum
                           INNER JOIN tblTestScore ts 
                                   ON t.testNum = ts.testNum
                      WHERE cd.courseDetailNum = pnum
                        AND EXISTS (SELECT 'Y' FROM tblComplete c WHERE ts.studentNum = c.studentNum)
                        AND NOT EXISTS (SELECT 'Y' FROM tblFail f WHERE ts.studentNum = f.studentNum)
--                        AND NOT EXISTS (SELECT 'Y' FROM tblPrize p WHERE ts.studentNum = p.studentNum AND p.prizeCategory = '성적우수')
                    GROUP BY ts.studentNum)A)
    WHERE RK = 1
      AND subjectCnt = (SELECT subjectAmount FROM tblCourseDetail WHERE courseDetailNum = pnum);
     LOOP
        FETCH vcursor INTO vnum;
        EXIT WHEN vcursor%NOTFOUND;
        
        -- 이미 생성된 과정의 우수 교육생은 중복으로 들어가지 않도록 하는 장치 만들기
        SELECT COUNT(*) INTO vcnt FROM tblPrize WHERE studentNum = vnum AND prizeCategory = '성적우수';
        
        IF vcnt > 0 THEN
            DBMS_OUTPUT.PUT_LINE('  해당 과정의 우수 교육생 생성 내역이 이미 존재합니다.');
            
        ELSE
            INSERT INTO tblPrize (prizeNum, studentNum, prizeCategory)  VALUES ((select nvl(max(lpad(prizeNum, 5, '0')), 0) + 1 from tblPrize), vnum, '성적우수');
        END IF;
      END LOOP;
    CLOSE vcursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  생성에 실패했습니다.');
END procAddToSPrize; --과정 상세 번호
/

-- [프로시저 실행]
/
BEGIN
    procAddToSPrize(1);
END;
/


-- [프로시저 실행 확인]
SELECT * FROM tblPrize order by TO_NUMBER(prizeNum);
DELETE FROM tblPrize;
SET SERVEROUTPUT ON;
----------------------------------------------------- [특정 과정의 개근 학생 선정] ------------------------------------------------------------------------------
-- [프로시저 생성]
/
CREATE OR REPLACE PROCEDURE procAddToAPrize(
    pnum NUMBER --과정 상세 번호
)
IS
    vcursor sys_refcursor;
    vnum NUMBER;
    vcnt NUMBER; --기생성 내역을 확인할 카운트 변수
    vflag NUMBER := 0; --다수의 기생성 내역 에러 메세지를 1번만 출력하게끔 만드는 장치 역할 변수
BEGIN
    OPEN vcursor
    FOR
    SELECT studentNum
      FROM (SELECT s.studentNum
                  , COUNT(*) AS cnt
                  , RANK() OVER(ORDER BY COUNT(*) DESC) AS RK
              FROM tblStudent s
                   INNER JOIN tblStudentAttendance sa
                           ON s.studentNum = sa.studentNum
             WHERE s.courseDetailNum = pnum
               AND EXISTS (
                        SELECT 'Y'
                        FROM tblComplete c
                        WHERE s.studentNum = c.studentNum
                    )
                    AND NOT EXISTS (
                        SELECT 'Y'
                        FROM tblFail f
                        WHERE s.studentNum = f.studentNum
                    )
                    AND NOT EXISTS (
                        SELECT 'Y'
                        FROM tblAttendanceApply aa
                        WHERE s.studentNum = aa.STUDENTNUM
                        AND sa.attendanceDate = aa.applyDate
                    )
                    AND NOT EXISTS (
                        SELECT 'Y'
                        FROM tblHoliday h
                        WHERE h.holiday = sa.attendanceDate
                    )
        GROUP BY s.studentNum)
    WHERE RK = 1;
    
    LOOP
        FETCH vcursor INTO vnum;
        EXIT WHEN vcursor%NOTFOUND;
        
        -- 이미 생성된 과정의 우수 교육생은 중복으로 들어가지 않도록 하는 장치 만들기
        SELECT COUNT(*) INTO vcnt FROM tblPrize WHERE studentNum = vnum AND prizeCategory = '개근';
        
        IF vcnt > 0 THEN
            
            IF vflag = 0 THEN
                DBMS_OUTPUT.PUT_LINE('  해당 과정의 우수 교육생 생성 내역이 이미 존재합니다.');
                vflag := 1;
            END IF;
        ELSE
            INSERT INTO tblPrize (prizeNum, studentNum, prizeCategory)  VALUES ((select nvl(max(lpad(prizeNum, 5, '0')), 0) + 1 from tblPrize), vnum, '개근');
        END IF;

    END LOOP;
    CLOSE vcursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  생성에 실패했습니다.');
END procAddToAPrize;
/

-- [프로시저 실행]
/
BEGIN
    procAddToAPrize(1);
END;
/

-- [프로시저 실행 확인]
SELECT * FROM tblPrize order by TO_NUMBER(prizeNum);
DELETE FROM tblPrize;

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