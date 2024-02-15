-- Project_PL/SQL by Narae.sql

/* B8-01. 교육생 면접 및 선발 관리 */
-- 1. 면접에 지원한 지원생들의 이름, 주민등록번호, 전화번호, 면접 예정일을 등록한다.
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procAddInterviewer(
	pname varchar2,
	pssn varchar2,
	ptel varchar2,
	pdate DATE
)
IS
BEGIN
	INSERT INTO tblInterviewer (interviewerNum,interviewerName,interviewerSsn,interviewerTel,interviewerDate,isPass)
			VALUES ((select nvl(max(lpad(interviewerNum, 5, '0')), 0) + 1 from tblInterviewer), pname, pssn, ptel, pdate ,null);
EXCEPTION
	WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  생성에 실패했습니다.');
END procAddInterviewer;

-- [프로시저 실행]
BEGIN
	procAddInterviewer('테스트','201225-2030405','010-1234-5678','2023-09-13');
END;

-- [실행 확인]
SELECT * FROM tblinterviewer;

-- 2. 면접 진행 후, 지원생들의 면접 합격 여부를 입력하여 교육생을 선발한다.
-- • 면접에 합격한 학생에 한하여 교육생 등록 여부 리스트에 등록된다.
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procInterviewResult(
    pnum NUMBER, --교육생 면접번호
    pisPass NUMBER --합격여부
)
IS
BEGIN
	IF pisPass = 0 OR pisPass = 1 THEN 
        UPDATE tblInterviewer SET isPass = pisPass WHERE interviewerNum = pnum;
        
        IF pisPass = 1 THEN
            INSERT INTO tblInterviewRegister (interviewRegiNum,interviewerNum,isEnrollment)
                        VALUES ((select nvl(max(lpad(interviewRegiNum, 5, '0')), 0) + 1 from tblInterviewRegister),pnum,default);
        END IF;
	ELSE
		DBMS_OUTPUT.PUT_LINE('합불여부는 1(합격) 또는 0(불합격)으로만 입력 가능합니다.');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('  등록에 실패했습니다.');
END;

-- [프로시저 실행]
BEGIN
--	procInterviewResult(657,1); --657, 1
    procInterviewResult(655,0); --655, 0
END;

-- [실행 확인]
SELECT * FROM tblInterviewer; --657 면접번호(테스트), 655
SELECT * FROM tblInterviewRegister; --515 교육생등록여부번호

/* B02-01. 교육생 정보 등록 및 명단 조회 */
-- 1. 면접에 합격한 지원생은 과정 등록 여부에 따라 교육생 정보가 생성된다. 관리자가 교육생 등록일 및 과정 상세 번호를 입력한다. 주민등록번호 뒷자리는 교육생 본인이 로그인시 패스워드로 사용된다.
-- • 교육생 등록일은 등록한 날짜가 자동으로 입력되도록 한다.
-- • 교육생 등록 여부 리스트에서 교육생이 등록을 하지 않을 경우 교육생 정보가 생성되지 않는다.
-- • 교육생 정보 생성 시, 면접 지원 당시 입력한 정보를 사용한다.
-- • 교육생은 하나의 과정만 등록하여 수강이 가능하다.

-- [교육생 등록 및 등록 여부 리스트 '등록여부' 변경]
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procAddStudent(
	pnum NUMBER, --교육생 면접번호
	pcnum NUMBER --과정상세번호
)
IS
BEGIN
	UPDATE tblInterviewRegister set isEnrollment = 1 WHERE interviewerNum = pnum;
	INSERT INTO tblStudent (studentNum,interviewRegiNum,registrationDate,signUpCnt,courseDetailNum)
			VALUES (seqStudent.nextVal,fnGetInterviewRegiNum(pnum), sysdate, 1, pcnum);
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  등록에 실패했습니다.');
END;

-- [프로시저내에서 사용할 저장 함수 생성]
CREATE OR REPLACE FUNCTION fnGetInterviewRegiNum(
	pnum NUMBER --교육생 면접번호
) RETURN number --교육생 등록여부번호 반환
IS
	vnum NUMBER;
BEGIN
	SELECT interviewRegiNum INTO vnum FROM tblInterviewRegister WHERE interviewerNum = pnum;
	RETURN vnum;
END fnGetInterviewRegiNum;

-- [프로시저 실행]
BEGIN
	procAddStudent(657, 20); --교육생 면접번호(657), 과정 상세번호(20)
END;

-- [실행 확인]
SELECT * FROM tblInterviewRegister; --515 교육생등록여부번호
SELECT * FROM tblStudent;

-- 2. 교육생 정보에 대한 입력, 출력, 수정, 삭제 기능을 사용할 수 있어야 한다.
-- [입력]
-- > 위 1번에서 구현

-- [출력]
-- > 아래 3번에서 구현

-- [수정]
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procUpdateStudent(
    pnum NUMBER, --교육생 번호
    pname VARCHAR2, --교육생 이름
    pssn VARCHAR2, --교육생 주민등록번호
    ptel VARCHAR2 --교육생 전화번호
)
IS
    vnum NUMBER; -- 교육생 번호를 받아서 반환할 면접번호를 담는 변수
BEGIN
    vnum := fnGetInterviewerNum(pnum);
    UPDATE tblInterviewer SET interviewerName = pname, interviewerSsn = pssn, interviewerTel = ptel WHERE interviewerNum = vnum;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  갱신에 실패했습니다.');
END procUpdateStudent;


-- [프로시저내에서 사용할 저장 함수 생성] > 교육생 번호 입력 시, 교육생 면접번호 반환
CREATE OR REPLACE FUNCTION fnGetInterviewerNum(
	pnum NUMBER --교육생 번호
) RETURN NUMBER --반환 자료형
IS
	vnum NUMBER; --교육생 면접 번호 반환
BEGIN
    SELECT interviewRegiNum INTO vnum FROM tblStudent WHERE studentNum = pnum; --vnum = 등록여부번호
    SELECT interviewerNum INTO vnum FROM tblInterviewRegister WHERE interviewRegiNum = vnum;
    RETURN vnum;
END fnGetInterviewerNum;

-- [프로시저 실행]
BEGIN
	procUpdateStudent(1, '김테스', '991212-1011111','010-1234-1234');
END;

-- [실행 확인]
SELECT * FROM tblStudent WHERE studentNum = 1; --면접번호 1
SELECT * FROM tblInterviewer WHERE interviewerNum = 1;

-- 3. 교육생 정보 출력시 교육생 번호, 이름, 주민등록번호, 전화번호, 등록일, 수강(신청) 횟수를 출력한다.
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procReadAllStudent
IS
BEGIN
--    DBMS_OUTPUT.PUT_LINE('────────────────────── 교육생 정보 ──────────────────────');
    FOR student IN (
    SELECT
    s.studentNum AS "교육생 번호",
	i.interviewerName AS "교육생 이름",
	i.interviewerSsn AS 주민등록번호,
	i.interviewerTel AS 전화번호,
	TO_CHAR(s.registrationDate,'YYYY-MM-DD') AS 등록일,
	s.signUpCnt AS "수강(신청) 횟수"
    FROM tblInterviewer i
        INNER JOIN tblInterviewRegister r
            ON i.interviewerNum = r.interviewerNum
                INNER JOIN tblStudent s
                    ON r.interviewRegiNum = s.interviewRegiNum
    )
    LOOP
    DBMS_OUTPUT.PUT_LINE('========================================================================================================================================');
    DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || student."교육생 번호" || ' | 교육생 이름: ' || student."교육생 이름" || ' | 주민등록번호: ' || student.주민등록번호 || ' | 전화번호: ' || student.전화번호 || ' | 등록일: ' || student.등록일 || ' | 수강(신청) 횟수: ' || student."수강(신청) 횟수");
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  교육생 정보 조회에 실패했습니다.');
END procReadAllStudent;

-- [프로시저 실행]
BEGIN
	procReadAllStudent;
END;

-- 4. 특정 교육생 선택시 교육생 번호, 교육생 이름, 교육생이 수강 신청한 또는 수강중인, 수강했던 개설 과정 정보(과정명, 과정기간(시작 년월일, 끝 년월일), 강의실, 수료 및 중도탈락 여부, 수료 및 중도탈락 날짜)를 출력한다.
-- ﻿• 교육생 정보를 쉽게 확인하기 위한 검색 기능을 사용할 수 있어야 한다.
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procReadOneStudent(
    pnum NUMBER --교육생 번호
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('────────────────────── 교육생 정보 ──────────────────────');
    FOR student IN (
    SELECT 
        studentNum AS "교육생 번호",
        studentName AS "교육생 이름",
        courseDetailNum AS 과정명,
        courseStartDate AS "과정 시작일",
        courseEndDate AS "과정 종료일",
        lectureRoomNum AS 강의실,
        completionStatus AS "수료 상태",
        completionDate AS "수료(탈락)일"
    FROM vwCompletionStatus
        WHERE studentNum = pnum
    )
    LOOP
    DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || student."교육생 번호");
    DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || student."교육생 이름");
    DBMS_OUTPUT.PUT_LINE('  과정명: ' || student.과정명);
    DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || student."과정 시작일");
    DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || student."과정 종료일");
    DBMS_OUTPUT.PUT_LINE('  강의실: ' || student."강의실");
    DBMS_OUTPUT.PUT_LINE('  수료 상태: ' || student."수료 상태");
    DBMS_OUTPUT.PUT_LINE('  수료(탈락)일: ' || student."수료(탈락)일");
    DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  교육생 정보 조회에 실패했습니다.');
END procReadOneStudent;

-- [프로시저 실행]
BEGIN
	procReadOneStudent(514); --교육생 번호(514)
END;

-- 5. 교육생에 대한 수료 및 중도 탈락 처리를 할 수 있어야 한다. 수료 또는 중도탈락 날짜를 입력할 수 있어야 한다.
-- 수료처리
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procToComplete(
	pnum NUMBER, --교육생번호
	pdate DATE --수료일
)
IS 
BEGIN
	INSERT INTO tblComplete (completeNum, studentNum, completeDate) VALUES ((select nvl(max(lpad(completeNum, 5, '0')), 0) + 1 from tblComplete), pnum, TO_CHAR(pdate,'YYYY-MM-DD'));
EXCEPTION
	WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('  등록에 실패했습니다.');
END procToComplete;

-- [프로시저 실행]
BEGIN
	procToComplete(412, sysdate); --교육생 번호(412), 수료일
END;

-- [실행 확인]
SELECT * FROM tblStudent;
SELECT * FROM tblComplete;

--중도 탈락 처리
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procToFail(
	pnum NUMBER, --교육생번호
	pdate DATE, --탈락일
	preason VARCHAR2 --탈락사유
)
IS 
BEGIN
	INSERT INTO tblFail (failNum, studentNum, failDate, failReason) VALUES ((select nvl(max(lpad(failNum, 5, '0')), 0) + 1 from tblFail), pnum, pdate, preason);
EXCEPTION
	WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('  등록에 실패했습니다.');
END procToFail;

-- [프로시저 실행]
BEGIN
	procToFail(413, sysdate, '테스트'); --교육생 번호(413), 탈락일, 사유
END;

-- [실행 확인]
SELECT * FROM tblStudent;
SELECT * FROM tblFail;

-- 6. 강의 예정인 과정, 강의 중인 과정, 강의 종료된 과정 중에서 선택한 과정을 신청한 교육생 정보를 확인할 수 있어야 한다.
--교육생 번호, 이름, 주민등록번호, 전화번호, 등록일, 수강(신청) 횟수
-- [강의 예정인 과정 > 교육생 정보 조회]
CREATE OR REPLACE PROCEDURE procBeforeCourseSt
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('────────────────────── 강의 예정 과정 교육생 정보 ──────────────────────');
    FOR student IN (
        SELECT 
        s.studentNum AS "교육생 번호",
        vs.studentName AS "교육생 이름",
        vs.studentSsn AS 주민등록번호,
        vs.studentTel AS 전화번호,
        s.registrationDate AS 등록일,
        s.signUpCnt AS "수강(신청) 횟수",
        vc.courseName AS 과정명,
        vc.completionStatus AS "수료 상태"
      FROM tblStudent s
          INNER JOIN vwStudent vs
                ON s.studentNum = vs.studentNum
          INNER JOIN vwCompletionStatus vc
                ON s.studentNum = vc.studentNum
     WHERE vc.courseStartDate > sysdate -- 강의 예정인 과정
     ORDER BY TO_NUMBER("교육생 번호")
    )
    LOOP
     DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || student."교육생 번호");
    DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || student."교육생 이름");
    DBMS_OUTPUT.PUT_LINE('  주민등록번호: ' || student.주민등록번호);
    DBMS_OUTPUT.PUT_LINE('  전화번호: ' || student.전화번호);
    DBMS_OUTPUT.PUT_LINE('  등록일: ' || student.등록일);
    DBMS_OUTPUT.PUT_LINE('  수강(신청) 횟수: ' || student."수강(신청) 횟수");
    DBMS_OUTPUT.PUT_LINE('  과정명: ' || student.과정명);
    DBMS_OUTPUT.PUT_LINE('  수료 상태: ' || student."수료 상태");
    DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  교육생 정보 조회에 실패했습니다.');
END;

-- [프로시저 실행]
BEGIN
	procBeforeCourseSt;
END;

-- [강의 중인 과정 > 교육생 정보 조회]
CREATE OR REPLACE PROCEDURE procIngCourseSt
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('────────────────────── 강의 중인 과정 교육생 정보 ──────────────────────');
    FOR student IN (
        SELECT 
        s.studentNum AS "교육생 번호",
        vs.studentName AS "교육생 이름",
        vs.studentSsn AS 주민등록번호,
        vs.studentTel AS 전화번호,
        s.registrationDate AS 등록일,
        s.signUpCnt AS "수강(신청) 횟수",
        vc.courseName AS 과정명,
        vc.completionStatus AS "수료 상태"
      FROM tblStudent s
          INNER JOIN vwStudent vs
                ON s.studentNum = vs.studentNum
          INNER JOIN vwCompletionStatus vc
                ON s.studentNum = vc.studentNum
     WHERE vc.courseStartDate <= sysdate AND vc.courseEndDate >= sysdate -- 강의 중인 과정
     ORDER BY TO_NUMBER("교육생 번호")
    )
    LOOP
     DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || student."교육생 번호");
    DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || student."교육생 이름");
    DBMS_OUTPUT.PUT_LINE('  주민등록번호: ' || student.주민등록번호);
    DBMS_OUTPUT.PUT_LINE('  전화번호: ' || student.전화번호);
    DBMS_OUTPUT.PUT_LINE('  등록일: ' || student.등록일);
    DBMS_OUTPUT.PUT_LINE('  수강(신청) 횟수: ' || student."수강(신청) 횟수");
    DBMS_OUTPUT.PUT_LINE('  과정명: ' || student.과정명);
    DBMS_OUTPUT.PUT_LINE('  수료 상태: ' || student."수료 상태");
    DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  교육생 정보 조회에 실패했습니다.');
END procIngCourseSt;

-- [프로시저 실행]
BEGIN
	procIngCourseSt;
END;

-- [강의 종료된 과정 > 교육생 정보 조회]
CREATE OR REPLACE PROCEDURE procAfterCourseSt
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('────────────────────── 강의 종료 과정 교육생 정보 ──────────────────────');
    FOR student IN (
        SELECT 
        s.studentNum AS "교육생 번호",
        vs.studentName AS "교육생 이름",
        vs.studentSsn AS 주민등록번호,
        vs.studentTel AS 전화번호,
        s.registrationDate AS 등록일,
        s.signUpCnt AS "수강(신청) 횟수",
        vc.courseName AS 과정명,
        vc.completionStatus AS "수료 상태"
      FROM tblStudent s
          INNER JOIN vwStudent vs
                ON s.studentNum = vs.studentNum
          INNER JOIN vwCompletionStatus vc
                ON s.studentNum = vc.studentNum
     WHERE vc.courseEndDate < sysdate -- 강의 종료된 과정
     ORDER BY TO_NUMBER("교육생 번호")
    )
    LOOP
     DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || student."교육생 번호");
    DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || student."교육생 이름");
    DBMS_OUTPUT.PUT_LINE('  주민등록번호: ' || student.주민등록번호);
    DBMS_OUTPUT.PUT_LINE('  전화번호: ' || student.전화번호);
    DBMS_OUTPUT.PUT_LINE('  등록일: ' || student.등록일);
    DBMS_OUTPUT.PUT_LINE('  수강(신청) 횟수: ' || student."수강(신청) 횟수");
    DBMS_OUTPUT.PUT_LINE('  과정명: ' || student.과정명);
    DBMS_OUTPUT.PUT_LINE('  수료 상태: ' || student."수료 상태");
    DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  교육생 정보 조회에 실패했습니다.');
END procAfterCourseSt;

-- [프로시저 실행]
BEGIN
	procAfterCourseSt;
END;


/* B02-02. 기간별 교육생 상담일지 관리 */
-- 1. 교사가 교육생과 상담을 진행한 후 작성한 상담일지를 조회 및 관리한다.
-- 4. 상담일지에 관한 입력, 출력, 수정, 삭제할 수 있다.
-- • 상담일자는 상담일을 기준으로 자동으로 입력되도록 한다.
------------------------- [입력]-----------------------------------------
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procAddConsulting(
	psnum NUMBER, --교육생 번호
	ptnum NUMBER, --교사 번호
	pcontent VARCHAR2 --상담 내용
)
IS
BEGIN
	INSERT INTO tblConsulting (consultingNum, consultingDate, studentNum, teacherNum, consultingContent, isComplete)
			VALUES ((select nvl(max(lpad(consultingNum, 5, '0')), 0) + 1 from tblConsulting), sysdate, psnum, ptnum, pcontent, 1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  생성에 실패했습니다.');
END procAddConsulting;

-- [프로시저 실행]
BEGIN
    procAddConsulting(5, 3, '테스트'); --교육생 번호, 교사 번호, 상담내용
END;

-- [실행 확인]
SELECT * FROM tblConsulting;

------------------------- [출력]-----------------------------------------
--> 아래 2,3번에서 구현

------------------------- [수정]-----------------------------------------
-- [프로시저 생성] (상담일, 상담완료여부 빼고 전체 수정)
CREATE OR REPLACE PROCEDURE procUpdateConsulting(
	pnum NUMBER, --상담 번호
	psNum NUMBER, --교육생 번호
	ptNum NUMBER, --교사 번호
	pcontent VARCHAR2 --상담 내용
)
IS
BEGIN
	UPDATE tblConsulting SET studentNum = psNum, teacherNum = ptNum, consultingContent = pcontent WHERE consultingNum = pnum;
EXCEPTION
	WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  갱신에 실패했습니다.');
END;

-- [프로시저 실행]
BEGIN
    procUpdateConsulting(31,6,4,'상담상담상담'); --상담번호, 교육생번호, 교사번호, 상담내용
END;

-- [실행 확인]
SELECT * FROM tblConsulting;

------------------------- [삭제]-----------------------------------------
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procDeleteConsulting(
	pnum NUMBER --상담 번호
)
IS
BEGIN
	DELETE FROM tblConsulting WHERE consultingNum = pnum;
EXCEPTION
	WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE('  삭제에 실패했습니다.');
END;

-- [프로시저 실행]
BEGIN
    procDeleteConsulting(31);
END;

-- [실행 확인]
SELECT * FROM tblConsulting;

-- 2. 전체 상담일지 출력 시 교육생 번호, 교육생 이름, 상담날짜, 상담 교사, 상담 내용을 출력한다.
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procReadAllConsulting
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('──────────────────── 전체 상담일지 조회 ────────────────────');
    FOR consulting IN (
    SELECT
        vs.studentNum AS "교육생 번호",
        vs.studentName AS "교육생 이름",
        TO_CHAR(cs.consultingDate,'YYYY-MM-DD') AS "상담 날짜",
        t.teacherName AS "상담 교사",
        cs.consultingContent AS "상담 내용"
    FROM vwStudent vs
        INNER JOIN tblConsulting cs
            ON vs.studentNum = cs.studentNum
                INNER JOIN tblTeacher t
                    ON t.teacherNum = cs.teacherNum
                        ORDER BY "상담 날짜"
    )
    LOOP 
        DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || consulting."교육생 번호");
        DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || consulting."교육생 이름");
        DBMS_OUTPUT.PUT_LINE('  상담 날짜: ' || consulting."상담 날짜");
        DBMS_OUTPUT.PUT_LINE('  상담 교사: ' || consulting."상담 교사");
        DBMS_OUTPUT.PUT_LINE('  상담 내용: ' || consulting."상담 내용");
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
--        DBMS_OUTPUT.PUT_LINE(' ');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  전체 상담일지 조회에 실패했습니다.');    
END procReadAllConsulting;

-- [프로시저 실행]
BEGIN
    procReadAllConsulting;
END;


-- 3. 특정 상담일지 선택 시 교육생이 수강 신청한 또는 수강중인, 수강했던 개설 과정 정보(과정명, 과정기간(시작 년월일, 끝 년월일), 강의실, 수료 및 중도탈락 여부, 수료 및 중도탈락 날짜)를 출력하고, 상담일지의 정보(교사명, 상담일자, 상담내용)를 출력한다.
-- [프로시저 생성]
CREATE OR REPLACE PROCEDURE procReadOneConsulting(
    pnum IN NUMBER --교육생 번호    
)
IS
    flag NUMBER := 0;

BEGIN
    FOR consulting IN (
    SELECT 	
        s.studentNum AS "교육생 번호",
        vs.studentName AS "교육생 이름",
        TO_CHAR(cst.consultingDate,'YYYY-MM-DD') AS "상담 날짜",
        t.teacherName AS "상담 교사",
        cst.consultingContent AS "상담 내용",
        cs.courseName AS 과정명,
        TO_CHAR(cd.courseStartDate,'YYYY-MM-DD') AS "과정 시작일",
        TO_CHAR(cd.courseEndDate,'YYYY-MM-DD') AS "과정 종료일",
        cd.lectureRoomNum AS 강의실,
        CASE 
            WHEN c.studentNum IS NOT NULL THEN '수료'
            WHEN f.studentNum IS NOT NULL THEN '중도 탈락'
            WHEN TO_CHAR(cd.courseStartDate,'YYYY-MM-DD') > TO_CHAR(sysdate,'YYYY-MM-DD') THEN '진행 예정'
            ELSE '진행중'
        END AS "수료 상태",
        CASE
            WHEN c.studentNum IS NOT NULL THEN TO_CHAR(c.completeDate,'YYYY-MM-DD')
            WHEN f.studentNum IS NOT NULL THEN TO_CHAR(f.failDate,'YYYY-MM-DD')
            ELSE NULL
        END AS "수료(탈락)일"
    FROM tblStudent s
        INNER JOIN tblCourseDetail cd
            ON cd.courseDetailNum = s.courseDetailNum
                INNER JOIN tblCourse cs
                    ON cs.courseNum = cd.courseNum
                        FULL JOIN tblComplete c
                            ON s.studentNum = c.studentNum
                                FULL JOIN tblFail f
                                    ON s.studentNum = f.studentNum
                                        INNER JOIN tblConsulting cst
                                            ON s.studentNum = cst.studentNum
                                                INNER JOIN tblTeacher t
                                                    ON t.teacherNum = cst.teacherNum
                                                        INNER JOIN vwStudent vs
                                                            ON s.studentNum = vs.studentNum
        WHERE s.studentNum = pnum --교육생 번호
    )

    LOOP
        IF (flag = 0)
            THEN 
                DBMS_OUTPUT.PUT_LINE('──────────────────── 상담일지 조회 ────────────────────');
                DBMS_OUTPUT.PUT_LINE('  [교육생 정보]');
                DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || consulting."교육생 번호");
                DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || consulting."교육생 이름");
                DBMS_OUTPUT.PUT_LINE('  과정명: ' || consulting.과정명);
                DBMS_OUTPUT.PUT_LINE('  과정 시작일: ' || consulting."과정 시작일");
                DBMS_OUTPUT.PUT_LINE('  과정 종료일: ' || consulting."과정 종료일");
                DBMS_OUTPUT.PUT_LINE('  강의실: ' || consulting."강의실");
                DBMS_OUTPUT.PUT_LINE('  수료 상태: ' || consulting."수료 상태");
                DBMS_OUTPUT.PUT_LINE('  수료(탈락)일: ' || consulting."수료(탈락)일");
                DBMS_OUTPUT.PUT_LINE(' ');
                DBMS_OUTPUT.PUT_LINE('  [상담 내역]');
                flag := 1;
        END IF;    
        -- 특정 상담번호의 일지 정보 및 해당 상담 교육생의 정보 출력
        DBMS_OUTPUT.PUT_LINE('  상담 날짜: ' || consulting."상담 날짜");
        DBMS_OUTPUT.PUT_LINE('  상담 교사: ' || consulting."상담 교사");
        DBMS_OUTPUT.PUT_LINE('  상담 내용: ' || consulting."상담 내용");
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────────────');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE('  해당 교육생의 상담일지 조회에 실패했습니다.');
END procReadOneConsulting;

-- [프로시저 실행]
BEGIN
    procReadOneConsulting(54); --교육생 번호 54번
END;