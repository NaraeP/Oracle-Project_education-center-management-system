
-- [학생정보, 과정내용, 수료여부 VIEW 생성]			
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
                                        
                                        
--[학생 VIEW]
CREATE OR REPLACE VIEW vwStudent
AS
SELECT
	s.studentNum AS studentNum,
	i.interviewerName AS studentName,
	i.interviewerSsn AS studentSsn,
	i.interviewerTel AS studentTel
FROM tblInterviewer i
	INNER JOIN tblInterviewRegister r
		ON i.interviewerNum = r.interviewerNum
			INNER JOIN tblStudent s
				ON r.interviewRegiNum = s.interviewRegiNum;
