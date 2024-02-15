-- Project_ANSI-SQL by Narae.sql

/* B8-01. 교육생 면접 및 선발 관리 */
-- 1. 면접에 지원한 지원생들의 이름, 주민등록번호, 전화번호, 면접 예정일을 등록한다.

/*
INSERT INTO tblInterviewer (interviewerNum,interviewerName,interviewerSsn,interviewerTel,interviewerDate,isPass)
			VALUES (seqInterviewer.nextVal, <이름>, <주민등록번호>, <전화번호>, <면접일>, <합격여부>);
*/
INSERT INTO tblInterviewer (interviewerNum,interviewerName,interviewerSsn,interviewerTel,interviewerDate,isPass)
			VALUES (seqInterviewer.nextVal, '테스트', '201225-2030405', '010-1234-5678', '2023-09-13' ,null);

-- 2. 면접 진행 후, 지원생들의 면접 합격 여부를 입력하여 교육생을 선발한다.
-- • 면접에 합격한 학생에 한하여 교육생 등록 여부 리스트에 등록된다.

-- [합격 처리]
/*
UPDATE tblInterviewer SET isPass = 1 WHERE interviewerNum = <교육생 면접번호>;
INSERT INTO tblInterviewRegister (interviewRegiNum,interviewerNum,isEnrollment) VALUES (seqInterviewRegister.nextVal,<교육생면접번호>,<교육생등록여부>);
*/
UPDATE tblInterviewer SET isPass = 1 WHERE interviewerNum = 656;
INSERT INTO tblInterviewRegister (interviewRegiNum,interviewerNum,isEnrollment)
			VALUES (seqInterviewRegister.nextVal,656,default);	
		
-- [불합격 처리]		
/*
UPDATE tblInterviewer SET isPass = 0 WHERE interviewerNum = <교육생 면접번호>;
*/
UPDATE tblInterviewer SET isPass = 0 WHERE interviewerNum = 657;

/* B02-01. 교육생 정보 등록 및 명단 조회 */
-- 1. 면접에 합격한 지원생은 과정 등록 여부에 따라 교육생 정보가 생성된다. 관리자가 교육생 등록일 및 과정 상세 번호를 입력한다. 주민등록번호 뒷자리는 교육생 본인이 로그인시 패스워드로 사용된다.
-- • 교육생 등록일은 등록한 날짜가 자동으로 입력되도록 한다.
-- ﻿• 교육생 등록 여부 리스트에서 교육생이 등록을 하지 않을 경우 교육생 정보가 생성되지 않는다.
-- • 교육생 정보 생성 시, 면접 지원 당시 입력한 정보를 사용한다.
-- • 교육생은 하나의 과정만 등록하여 수강이 가능하다.

-- [교육생 등록 및 등록 여부 리스트 '등록여부' 변경]
/*
UPDATE tblInterviewRegister SET isEnrollment = 1 WHERE interviewerNum = <교육생 면접번호>;
INSERT INTO tblStudent (studentNum,interviewRegiNum,registrationDate,signUpCnt,courseDetailNum)
			VALUES (seqStudent.nextVal, <교육생 등록여부 번호>, sysdate, 1, <과정 상세 번호>);
*/
UPDATE tblInterviewRegister SET isEnrollment = 1 WHERE interviewerNum = 656;
INSERT INTO tblStudent (studentNum,interviewRegiNum,registrationDate,signUpCnt,courseDetailNum)
			VALUES (seqStudent.nextVal, 524, sysdate, 1, '16');

-- [교육생 미등록]
-- > 교육생 등록 여부 리스트에 DEFAULT값으로 '0'이 입력되므로 추가 업무 불요.

-- 2. 교육생 정보에 대한 입력, 출력, 수정, 삭제 기능을 사용할 수 있어야 한다.
-- [입력]
-- > 위 1번에서 구현

-- [출력]
-- > 아래 3번에서 구현

-- [수정]
/*
UPDATE tblInterviewer SET interviewerName = <교육생 이름>, interviewerSsn = <주민등록번호>, interviewerTel = <전화번호> WHERE interviewerNum = <교육생 면접 번호>;
*/
UPDATE tblInterviewer SET interviewerName = '박쿼리', interviewerSsn = '200101-1020304', interviewerTel = '010-5555-6666' WHERE interviewerNum = 664;

-- [삭제]
/*
UPDATE tblStudent SET registrationDate = '01-01-01', signUpCnt = -1 WHERE studentNum = <교육생 번호>;
*/
UPDATE tblStudent SET registrationDate = '01-01-01', signUpCnt = -1 WHERE studentNum = 526;

-- 3. 교육생 정보 출력시 교육생 번호, 이름, 주민등록번호, 전화번호, 등록일, 수강(신청) 횟수를 출력한다.
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
				ON r.interviewRegiNum = s.interviewRegiNum;
		

-- 4. 특정 교육생 선택시 교육생 번호, 교육생 이름, 교육생이 수강 신청한 또는 수강중인, 수강했던 개설 과정 정보(과정명, 과정기간(시작 년월일, 끝 년월일), 강의실, 수료 및 중도탈락 여부, 수료 및 중도탈락 날짜)를 출력한다.
-- ﻿• 교육생 정보를 쉽게 확인하기 위한 검색 기능을 사용할 수 있어야 한다.

-- [VIEW 생성]			
CREATE OR REPLACE VIEW vwCompletionStatus
AS
SELECT
    s.studentNum AS studentNum,
    vs.studentName AS studentName,
    cd.courseDetailNum AS courseDetailNum,
    cs.courseNum AS courseNum,
   cs.courseName AS courseName,
   TO_CHAR(cd.courseStartDate,'YYYY-MM-DD') AS courseStartDate,
   TO_CHAR(cd.courseEndDate,'YYYY-MM-DD') AS courseEndDate,
   cd.lectureRoomNum AS lectureRoomNum,
   CASE 
      WHEN c.studentNum IS NOT NULL THEN '수료'
      WHEN f.studentNum IS NOT NULL THEN '중도 탈락'
      WHEN TO_CHAR(cd.courseStartDate,'YYYY-MM-DD') > TO_CHAR(sysdate,'YYYY-MM-DD') THEN '진행 예정'
      ELSE '진행중'
   END AS completionStatus,
   CASE
      WHEN c.studentNum IS NOT NULL THEN TO_CHAR(c.completeDate,'YYYY-MM-DD')
      WHEN f.studentNum IS NOT NULL THEN TO_CHAR(f.failDate,'YYYY-MM-DD')
      ELSE NULL
   END AS completionDate
FROM tblStudent s
   INNER JOIN tblCourseDetail cd
      ON s.courseDetailNum = cd.courseDetailNum
         INNER JOIN tblCourse cs
            ON cs.courseNum = cd.courseNum
               FULL OUTER JOIN tblComplete c
                  ON s.studentNum = c.studentNum
                     FULL OUTER JOIN tblFail f
                        ON s.studentNum = f.studentNum
                                    INNER JOIN vwStudent vs
                                        ON s.studentNum = vs.studentNum;			

-- [VIEW 사용]
/*
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
	WHERE studentNum = <교육생 번호>;
*/
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
  WHERE studentNum = 514;
                                                            
-- 5. 교육생에 대한 수료 및 중도 탈락 처리를 할 수 있어야 한다. 수료 또는 중도탈락 날짜를 입력할 수 있어야 한다.

-- [수료 처리]
/*
INSERT INTO tblComplete (completeNum, studentNum, completeDate) VALUES (seqComplete.nextVal, <교육생번호>, <수료일>);
*/
INSERT INTO tblComplete (completeNum, studentNum, completeDate) VALUES (seqComplete.nextVal, 528, '2023-09-14');

-- [중도 탈락 처리]
/*
INSERT INTO tblFail (failNum, studentNum, failDate, failReason) VALUES (seqFail.nextVal, <교육생 번호>, <탈락일>, <탈락 사유>);
*/
INSERT INTO tblFail (failNum, studentNum, failDate, failReason) VALUES (seqFail.nextVal, 529, '2023-09-14', '개인 사정');

-- 6. 강의 예정인 과정, 강의 중인 과정, 강의 종료된 과정 중에서 선택한 과정을 신청한 교육생 정보를 확인할 수 있어야 한다.
--교육생 번호, 이름, 주민등록번호, 전화번호, 등록일, 수강(신청) 횟수
-- [강의 예정인 과정 > 교육생 정보 조회]
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
 ORDER BY TO_NUMBER("교육생 번호");

-- [강의 중인 과정 > 교육생 정보 조회]
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
  ORDER BY TO_NUMBER("교육생 번호");

/
-- [강의 종료된 과정 > 교육생 정보 조회]
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
  ORDER BY TO_NUMBER("교육생 번호");

/* B02-02. 기간별 교육생 상담일지 관리 */
-- 1. 교사가 교육생과 상담을 진행한 후 작성한 상담일지를 조회 및 관리한다.
-- 4. 상담일지에 관한 입력, 출력, 수정, 삭제할 수 있다.
-- • 상담일자는 상담일을 기준으로 자동으로 입력되도록 한다.

-- [입력]
/*
INSERT INTO tblConsulting (consultingNum, consultingDate, studentNum, teacherNum, consultingContent, isComplete)
			VALUES (seqConsulting.nextVal, <상담 날짜>, <교육생 번호>, <교사 번호>, <상담 내용>, <상담완료여부>);
*/
INSERT INTO tblConsulting (consultingNum, consultingDate, studentNum, teacherNum, consultingContent, isComplete)
			VALUES (seqConsulting.nextVal, sysdate, '100', '7', '진로상담', 1);
-- [출력]
--> 아래 2,3번에서 구현

-- [수정]
/*
UPDATE tblConsulting SET studentNum = <교육생 번호>, teacherNum = <교사 번호>, consultingContent = <상담 내용> WHERE consultingNum = <상담 번호>; 
*/
UPDATE tblConsulting SET studentNum = '1', teacherNum = '5', consultingContent = '기타 상담' WHERE consultingNum = 43; 
-- [삭제]
/*
DELETE FROM tblConsulting WHERE consultingNum = <상담 번호>;
*/
DELETE FROM tblConsulting WHERE consultingNum = 31;


-- 2. 전체 상담일지 출력 시 교육생 번호, 교육생 이름, 상담날짜, 상담 교사, 상담 내용을 출력한다.
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
  ORDER BY "상담 날짜";

-- 3. 특정 상담일지 선택 시 교육생이 수강 신청한 또는 수강중인, 수강했던 개설 과정 정보(과정명, 과정기간(시작 년월일, 끝 년월일), 강의실, 수료 및 중도탈락 여부, 수료 및 중도탈락 날짜)를 출력하고, 상담일지의 정보(교사명, 상담일자, 상담내용)를 출력한다.
/*
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
															WHERE cst.consultingNum = <상담 번호>;

*/
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
															WHERE cst.consultingNum = 6;

/* C02-01. 배점 입출력 */
-- 1. 자신이 강의를 마친 과목의 목록 중에서 특정 과목을 선택하고 해당 배점 정보를 등록한다. 시험 날짜, 시험 문제를 추가한다. 특정 과목을 과목번호로 선택 시 출결 배점, 필기 배점, 실기 배점, 시험 날짜, 시험 문제를 입력할 수 있는 화면으로 연결되어야 한다.													
-- 2. 출결, 필기, 실기의 배점 비중은 담당 교사가 과목별로 결정한다.	
-- • 출결은 최소 20점 이상이어야 한다.
-- • 출결, 필기, 실기의 합은 100점이 되어야 한다.														
														
-- [배점 정보 등록 및 시험 날짜, 시험 문제 추가]
-- > PL/SQL
														
-- [시험 문제 등록(시험 문제 등록 안했을 경우)]
/*
UPDATE tblTest SET isRegistration(시험문제파일등록여부) = 1(등록) WHERE subjectDetailNum = <과목 상세 번호>;
*/
UPDATE tblTest SET isRegistration = 1 WHERE subjectDetailNum = 5;

-- [배점 수정]
-- > PL/SQL

-- 3. 배점을 입력한 과목 목록 출력 시 과목상세번호, 과정명, 과정기간(시작 년월일, 끝 년월일), 강의실, 과목명, 과목기간(시작 년월일, 끝 년월일), 교재명, 출결, 필기, 실기 배점 등이 출력된다.
SELECT
    sd.subjectDetailNum AS "과목 상세 번호",
    c.courseName AS 과정명,
    cd.courseStartDate AS "과정 시작일",
    cd.courseEndDate AS "과정 종료일",
    cd.lectureRoomNum AS 강의실,
    s.subjectName AS 과목명,
    sd.subjectStartDate AS "과목 시작일",
    sd.subjectEndDate AS "과목 종료일",
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
  ORDER BY TO_NUMBER("과목 상세 번호");
                                       
/* B11-01. 우수 교육생 조회 */
-- 1. 성적이 우수한 학생은 성적 우수 학생으로 선정한다.
--﻿ • 우수 교육생 및 개근 학생의 선정은 과정의 모든 과목이 끝나고 수료 여부가 결정된 후 선정한다.
-- • 우수 교육생은 과정별로 선정한다.
-- • 성적이 우수한 학생은 과정에 속한 각 과목의 시험 점수 합계가 가장 높은 학생으로 정의한다.
-- > PL/SQL
		
-- 2. 출결이 우수한 학생은 개근 학생으로 선정한다.
-- • 출결이 우수한 학생은 주말, 공휴일을 제외한 정상 수업일에 모두 출석하고, 지각, 조퇴, 외출 등의 이력이 없는 학생으로 정의한다.  
-- • 우수 교육생 및 개근 학생의 선정은 과정의 모든 과목이 끝나고 수료 여부가 결정된 후 선정한다.
-- • 우수 교육생은 과정별로 선정한다.
-- > PL/SQL

-- 3. 성적 우수 학생, 개근 학생 각 항목별로 과정 상세 번호를 입력 시 우수 교육생 명단 및 해당 교육생의 정보(교육생 번호, 교육생 이름, 수강 과정) 조회가 가능하다.                                       
-- 관리자 기능
-- [특정 과정의 우수 교육생 조회]
/*
SELECT
    vs.studentName,
    p.prizeCategory,
    cs.courseName
FROM tblPrize p
    INNER JOIN vwStudent vs
        ON vs.studentNum = p.studentNum
    INNER JOIN vwCompletionStatus cs
        ON cs.studentNum = vs.studentNum
WHERE cs.courseDetailNum = <과정 상세 번호>
AND p.prizeCategory = '성적우수';
*/
SELECT
    vs.studentNum AS "교육생 번호",
    vs.studentName AS "교육생 이름",
    p.prizeCategory AS "수강 과정",
    cs.courseName AS "부문"
FROM tblPrize p
    INNER JOIN vwStudent vs
        ON vs.studentNum = p.studentNum
    INNER JOIN vwCompletionStatus cs
        ON cs.studentNum = vs.studentNum
WHERE cs.courseDetailNum = 1
AND p.prizeCategory = '성적우수';

-- [특정 과정의 개근 학생 조회]
/*
SELECT
    vs.studentNum AS "교육생 번호",
    vs.studentName AS "교육생 이름",
    p.prizeCategory AS "수강 과정",
    cs.courseName AS "부문"
FROM tblPrize p
    INNER JOIN vwStudent vs
        ON vs.studentNum = p.studentNum
    INNER JOIN vwCompletionStatus cs
        ON cs.studentNum = vs.studentNum
WHERE cs.courseDetailNum = <과정 상세 번호>
AND p.prizeCategory = '개근'; 
*/


SELECT
    vs.studentNum AS "교육생 번호",
    vs.studentName AS "교육생 이름",
    p.prizeCategory AS "수강 과정",
    cs.courseName AS "부문"
FROM tblPrize p
    INNER JOIN vwStudent vs
        ON vs.studentNum = p.studentNum
    INNER JOIN vwCompletionStatus cs
        ON cs.studentNum = vs.studentNum
WHERE cs.courseDetailNum = 1
AND p.prizeCategory = '개근';                                    

/* C10-01. 우수 교육생 조회 */                                       
-- 교사 기능 > 과정 선택 시 조회
-- > B의 조회 기능과 동일

/* D08-01. 우수 교육생 수상 */
-- 학생 기능 > 과정 선택 시 조회
-- > B의 조회 기능과 동일