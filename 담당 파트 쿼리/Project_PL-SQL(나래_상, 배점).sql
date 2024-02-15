-- Project_PL-SQL(나래_상, 배점).sql

/* C02-01. 배점 입출력 */
-- 1. 자신이 강의를 마친 과목의 목록 중에서 특정 과목을 선택하고 해당 배점 정보를 등록한다. 시험 날짜, 시험 문제를 추가한다. 특정 과목을 과목번호로 선택 시 출결 배점, 필기 배점, 실기 배점, 시험 날짜, 시험 문제를 입력할 수 있는 화면으로 연결되어야 한다.													
-- 2. 출결, 필기, 실기의 배점 비중은 담당 교사가 과목별로 결정한다.	
-- • 출결은 최소 20점 이상이어야 한다.
-- • 출결, 필기, 실기의 합은 100점이 되어야 한다.														
														
-- [배점 정보 등록 및 시험 날짜, 시험 문제 추가]
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procAddPoint(
	psubjectDetailNum NUMBER, --과목 상세번호
	paPoint NUMBER, --출석 배점
	pwPoint NUMBER, --필기 배점
	ppPoint NUMBER, --실기 배점
	ptestDate DATE, --시험일
	pisRegistration NUMBER --시험문제 등록 여부
)
IS
    vtotal number;
BEGIN
    
    vtotal := paPoint + pwPoint + ppPoint;

	IF fnCheckProgress(psubjectDetailNum) <> '강의종료' THEN
        dbms_output.put_line('강의를 마친 과목에 한해 배점 입력이 가능합니다.');
    ELSE
    
        IF vtotal <> 100 THEN
            dbms_output.put_line('출결, 필기, 실기의 합은 100점이 되어야 합니다.');
        ELSE
        
            IF paPoint < 20 THEN
                dbms_output.put_line('출결은 최소 20점 이상이어야 합니다.');
            ELSE
                INSERT INTO tblTest (testNum, subjectDetailNum, attendancePoint, writtenPoint, practicalPoint, testDate, isRegistration)
                    VALUES ((select nvl(max(lpad(testNum, 5, '0')), 0) + 1 from tblTest), psubjectDetailNum, paPoint, pwPoint, ppPoint, ptestDate, pisRegistration);
            END IF;
            
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  생성에 실패했습니다.');
END procAddPoint;

-- [프로시저용 저장함수 생성]
CREATE OR REPLACE FUNCTION fnCheckProgress(
	fnum NUMBER --subjectDetailNum
) RETURN varchar2
IS 
	vprogress varchar2(30);
BEGIN 
	SELECT progress INTO vprogress FROM tblLectureSchedule WHERE subjectDetailNum = fnum;
    return vprogress;
END fnCheckProgress;

-- [프로시저 실행]
BEGIN
    procAddPoint(1,20,40,40,'2023-09-14',1); --과목 상세 번호, 출석 배점, 필기 배점, 실기 배점, 시험일, 시험문제 등록 여부
END;

-- [실행 확인]
SELECT * FROM tblTest;

													
-- [시험 문제 등록(시험 문제 등록 안했을 경우)]
--> 아래 수정문에서 통합

-- [배점 수정, 시험일 및 시험문제 등록여부 수정]
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procUpdatePoint(
    pnum NUMBER, --과목 상세번호
    paPoint NUMBER, --출석 배점
	pwPoint NUMBER, --필기 배점
	ppPoint NUMBER, --실기 배점
	ptestDate DATE, --시험일
	pisRegistration NUMBER --시험문제 등록 여부
)
IS
    vtotal number;
BEGIN
    
    vtotal := paPoint + pwPoint + ppPoint;

	IF fnCheckProgress(pnum) <> '강의종료' THEN
        dbms_output.put_line('강의를 마친 과목에 한해 배점 수정이 가능합니다.');
    ELSE
--        IF EXISTS (SELECT 'Y' FROM tblTestScore ts INNER JOIN tblTest t ON t.testNum = ts.testNum WHERE t.testNum = ts.testNum) THEN
--            dbms_output.put_line('시험 점수가 입력된 과목의 배점 수정은 불가능합니다.');
--        ELSE
                
            IF vtotal <> 100 THEN
                dbms_output.put_line('출결, 필기, 실기의 합은 100점이 되어야 합니다.');
            ELSE
            
                IF paPoint < 20 THEN
                    dbms_output.put_line('출결은 최소 20점 이상이어야 합니다.');
                ELSE
                    UPDATE tblTest SET attendancePoint = paPoint, writtenPoint = pwPoint, practicalPoint = ppPoint, testDate = ptestDate, isRegistration = pisRegistration WHERE subjectDetailNum = pnum;
                END IF;
                
            END IF;
--        END IF;        
    END IF;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  갱신에 실패했습니다.');
END procUpdatePoint;

-- [프로시저 실행]
BEGIN
    procUpdatePoint(1,25,35,40,'2023-09-14',1); --과목 상세 번호, 출석 배점, 필기 배점, 실기 배점, 시험일, 시험문제 등록 여부
END;

-- [실행 확인]
SELECT * FROM tblTest;

-- 3. 배점을 입력한 과목 목록 출력 시 과목상세번호, 과정명, 과정기간(시작 년월일, 끝 년월일), 강의실, 과목명, 과목기간(시작 년월일, 끝 년월일), 교재명, 출결, 필기, 실기 배점 등이 출력된다.
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procReadPoint
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('────────────────────── 과목별 배점 조회 ──────────────────────');
    FOR subject IN (
        SELECT
            sd.subjectDetailNum AS "과목 상세 번호",
            s.subjectName AS 과목명,
            sd.subjectStartDate AS "과목 시작일",
            sd.subjectEndDate AS "과목 종료일",
            c.courseName AS 과정명,
            cd.courseStartDate AS "과정 시작일",
            cd.courseEndDate AS "과정 종료일",
            cd.lectureRoomNum AS 강의실,
            tb.textBookName AS 교재명,
            t.attendancePoint AS "출결 배점",
            t.writtenPoint AS "필기 배점",
            t.practicalPoint AS "실기 배점"
          FROM tblSubjectDetail sd
              INNER JOIN tblSubject s
                     ON s.subjectNum = sd.subjectNum
              INNER JOIN tblTextBook tb
                     ON s.subjectNum = tb.subjectNum
              INNER JOIN tblCourseDetail cd
                     ON cd.courseDetailNum = sd.courseDetailNum
              INNER JOIN tblTest t
                     ON sd.subjectDetailNum = t.subjectDetailNum
              INNER JOIN tblCourse c
                     ON c.courseNum = cd.courseNum
          ORDER BY TO_NUMBER("과목 상세 번호")
    )
    LOOP
    DBMS_OUTPUT.PUT_LINE('  과목 상세 번호: ' || subject."과목 상세 번호");
    DBMS_OUTPUT.PUT_LINE('  과목명: ' || subject.과목명);
    DBMS_OUTPUT.PUT_LINE('  과목 시작일: ' || subject."과목 시작일");
    DBMS_OUTPUT.PUT_LINE('  과목 종료일: ' || subject."과목 종료일");
    DBMS_OUTPUT.PUT_LINE('  과정명: ' || subject.과정명);
    DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || subject."과정 시작일");
    DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || subject."과정 종료일");
    DBMS_OUTPUT.PUT_LINE('  강의실: ' || subject.강의실);
    DBMS_OUTPUT.PUT_LINE('  교재명: ' || subject.교재명);
    DBMS_OUTPUT.PUT_LINE('  출결 배점: ' || subject."출결 배점");
    DBMS_OUTPUT.PUT_LINE('  필기 배점: ' || subject."필기 배점");
    DBMS_OUTPUT.PUT_LINE('  실기 배점: ' || subject."실기 배점");
    DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  과목별 배점 조회에 실패했습니다.');
END procReadPoint;

-- [프로시저 실행]
BEGIN
	procReadPoint;
END;
                                 
/* B11-01. 우수 교육생 조회 */
-- 1. 성적이 우수한 학생은 성적 우수 학생으로 선정한다.
--﻿ • 우수 교육생 및 개근 학생의 선정은 과정의 모든 과목이 끝나고 수료 여부가 결정된 후 선정한다.
-- • 우수 교육생은 과정별로 선정한다.
-- • 성적이 우수한 학생은 과정에 속한 각 과목의 시험 점수 합계가 가장 높은 학생으로 정의한다.
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procAddBestStudent(
    pnum NUMBER --과정 상세 번호
)
IS
BEGIN
    INSERT INTO tblPrize (prizeNum, studentNum, prizeCategory)  VALUES ((select nvl(max(lpad(prizeNum, 5, '0')), 0) + 1 from tblPrize), fnGetBestStudentNum(pnum), '성적우수');
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  생성에 실패했습니다.');
END procAddBestStudent;
    
-- [프로시저용 저장 함수 생성]
CREATE OR REPLACE FUNCTION fnGetBestStudentNum(
    fnum NUMBER --과정 상세번호
) return NUMBER
IS
    vnum NUMBER; --반환할 1등 교육생 번호
BEGIN
    SELECT A.studentNum INTO vnum
      FROM
        (SELECT 
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
        WHERE cd.courseDetailNum = fnum
        AND EXISTS (SELECT 'Y' FROM tblComplete c WHERE ts.studentNum = c.studentNum)
        AND NOT EXISTS (SELECT 'Y' FROM tblFail f WHERE ts.studentNum = f.studentNum)
        GROUP BY ts.studentNum
        HAVING COUNT(*) = 6
        ORDER BY totalScore DESC)A
        WHERE ROWNUM = 1;
        RETURN vnum;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  예외 처리');
END;

-- [프로시저 실행]
BEGIN
	procAddBestStudent(1); --과정 상세번호 입력
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  등록에 실패했습니다.');
END;

-- [실행 확인]
SELECT * FROM tblPrize;
DELETE FROM tblPrize WHERE studentNum = 24;

		
-- 2. 출결이 우수한 학생은 개근 학생으로 선정한다.
-- • 출결이 우수한 학생은 주말, 공휴일을 제외한 정상 수업일에 모두 출석하고, 지각, 조퇴, 외출 등의 이력이 없는 학생으로 정의한다.  
-- • 우수 교육생 및 개근 학생의 선정은 과정의 모든 과목이 끝나고 수료 여부가 결정된 후 선정한다.
-- • 우수 교육생은 과정별로 선정한다.
-- [프로시저용 저장 함수 생성]
CREATE OR REPLACE FUNCTION fnGetBestAttendanceStNum(
    fnum NUMBER --과정 상세번호
) RETURN sys_refcursor
IS
    vcursor sys_refcursor;
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
            WHERE s.courseDetailNum = fnum
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
    
    RETURN vcursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  예외 처리');
END;

-- [출결 우수!! 프로시저 생성]
CREATE OR REPLACE PROCEDURE procAddBestAttendance(
    pnum NUMBER --과정 상세 번호
)
IS
    vcursor sys_refcursor;
    vnum NUMBER; --커서에서 나온 학생번호를 담을 변수
BEGIN
    vcursor := fnGetBestAttendanceStNum(pnum);
    LOOP
        FETCH vcursor INTO vnum;
        EXIT WHEN vcursor%NOTFOUND;
        INSERT INTO tblPrize (prizeNum, studentNum, prizeCategory)  VALUES ((select nvl(max(lpad(prizeNum, 5, '0')), 0) + 1 from tblPrize), vnum, '개근');
    END LOOP;
    CLOSE vcursor;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  생성에 실패했습니다.');
END procAddBestAttendance;

-- [프로시저 실행]
BEGIN
	procAddBestAttendance(1); --과정 상세번호 입력
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  등록에 실패했습니다.');
END;

-- [실행 확인]
SELECT * FROM tblPrize WHERE prizeCategory = '개근';
DELETE FROM tblPrize WHERE prizeCategory = '개근';

-- 3. 성적 우수 학생, 개근 학생 각 항목별로 과정 상세 번호를 입력 시 우수 교육생 명단 및 해당 교육생의 정보(교육생 번호, 교육생 이름, 수강 과정) 조회가 가능하다.                                       
-- 관리자 기능
-- [특정 과정의 우수 교육생 조회]
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procBestStudent(
    pnum NUMBER --과정 상세 번호
)
IS 
BEGIN
    DBMS_OUTPUT.PUT_LINE('────────────────────── 우수 교육생 조회 ──────────────────────');
    FOR best IN (
        SELECT
            vs.studentNum AS "교육생 번호",
            vs.studentName AS "교육생 이름",
            cs.courseName AS 과정명,
            cs.courseStartDate AS "과정 시작일",
            cs.courseEndDate AS "과정 종료일"
        FROM tblPrize p
            INNER JOIN vwStudent vs
                ON vs.studentNum = p.studentNum
            INNER JOIN vwCompletionStatus cs
                ON cs.studentNum = vs.studentNum
        WHERE cs.courseDetailNum = pnum
        AND p.prizeCategory = '성적우수'
--        AND EXISTS (SELECT 'Y' FROM tblComplete C WHERE vs.studentNum = C.studentNum)
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('  부문: 성적 우수');
        DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || best."교육생 번호");
        DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || best."교육생 이름");
        DBMS_OUTPUT.PUT_LINE('  과정명: ' || best.과정명);
        DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || best."과정 시작일");
        DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || best."과정 종료일");
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  우수 교육생 조회에 실패했습니다.');
END procBestStudent;

-- [프로시저 실행]
BEGIN
	procBestStudent(2);
END;

-- [특정 과정의 개근 학생 조회]
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procBestAttendance(
    pnum NUMBER --과정 상세 번호
)
IS 
BEGIN
    DBMS_OUTPUT.PUT_LINE('────────────────────── 우수 교육생 조회 ──────────────────────');
    FOR best IN (
        SELECT
            vs.studentNum AS "교육생 번호",
            vs.studentName AS "교육생 이름",
            cs.courseName AS 과정명,
            cs.courseStartDate AS "과정 시작일",
            cs.courseEndDate AS "과정 종료일"
        FROM tblPrize p
            INNER JOIN vwStudent vs
                ON vs.studentNum = p.studentNum
            INNER JOIN vwCompletionStatus cs
                ON cs.studentNum = vs.studentNum
        WHERE cs.courseDetailNum = pnum
        AND p.prizeCategory = '개근'
--        AND EXISTS (SELECT 'Y' FROM tblComplete C WHERE vs.studentNum = C.studentNum)
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('  부문: 개근');
        DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || best."교육생 번호");
        DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || best."교육생 이름");
        DBMS_OUTPUT.PUT_LINE('  과정명: ' || best.과정명);
        DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || best."과정 시작일");
        DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || best."과정 종료일");
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  우수 교육생 조회에 실패했습니다.');
END procBestAttendance;

-- [프로시저 실행]
BEGIN
	procBestAttendance(1);
END;                                 

/* C10-01. 우수 교육생 조회 */                                       
-- 교사 기능 > 과정 선택 시 조회
-- > B의 관리자 조회 기능과 동일

/* D08-01. 우수 교육생 수상 */
-- 학생 기능 > 과정 선택 시 조회 > 관리자 & 교사 조회 화면과 문구 상이
-- [특정 과정의 우수 교육생 조회]
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procBestStudentForSt(
    pnum NUMBER --과정 상세 번호
)
IS 
BEGIN
    DBMS_OUTPUT.PUT_LINE('────────────────────── 우수 교육생 조회 ──────────────────────');
    FOR best IN (
        SELECT
            vs.studentNum AS "교육생 번호",
            vs.studentName AS "교육생 이름",
            cs.courseName AS 과정명,
            cs.courseStartDate AS "과정 시작일",
            cs.courseEndDate AS "과정 종료일"
        FROM tblPrize p
            INNER JOIN vwStudent vs
                ON vs.studentNum = p.studentNum
            INNER JOIN vwCompletionStatus cs
                ON cs.studentNum = vs.studentNum
        WHERE cs.courseDetailNum = pnum
        AND p.prizeCategory = '성적우수'
--        AND EXISTS (SELECT 'Y' FROM tblComplete C WHERE vs.studentNum = C.studentNum)
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || best."교육생 이름" || '님, 성적 우수생 선정을 축하합니다!');
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('  부문: 성적 우수');
        DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || best."교육생 번호");
        DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || best."교육생 이름");
        DBMS_OUTPUT.PUT_LINE('  과정명: ' || best.과정명);
        DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || best."과정 시작일");
        DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || best."과정 종료일");
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  우수 교육생 조회에 실패했습니다.');
END procBestStudentForSt;

-- [프로시저 실행]
BEGIN
	procBestStudentForSt(2);
END;

-- [특정 과정의 개근 학생 조회]
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procBestAttendanceForSt(
    pnum NUMBER --과정 상세 번호
)
IS 
BEGIN
    DBMS_OUTPUT.PUT_LINE('────────────────────── 우수 교육생 조회 ──────────────────────');
    FOR best IN (
        SELECT
            vs.studentNum AS "교육생 번호",
            vs.studentName AS "교육생 이름",
            cs.courseName AS 과정명,
            cs.courseStartDate AS "과정 시작일",
            cs.courseEndDate AS "과정 종료일"
        FROM tblPrize p
            INNER JOIN vwStudent vs
                ON vs.studentNum = p.studentNum
            INNER JOIN vwCompletionStatus cs
                ON cs.studentNum = vs.studentNum
        WHERE cs.courseDetailNum = pnum
        AND p.prizeCategory = '개근'
--        AND EXISTS (SELECT 'Y' FROM tblComplete C WHERE vs.studentNum = C.studentNum)
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || best."교육생 이름" || '님, 개근 학생 선정을 축하합니다!');
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('  부문: 개근');
        DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || best."교육생 번호");
        DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || best."교육생 이름");
        DBMS_OUTPUT.PUT_LINE('  과정명: ' || best.과정명);
        DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || best."과정 시작일");
        DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || best."과정 종료일");
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  우수 교육생 조회에 실패했습니다.');
END procBestAttendanceForSt;

-- [프로시저 실행]
BEGIN
	procBestAttendanceForSt(1);
END;  