-- 관리자_B02-02. 기간별 교육생 상담일지 관리

----------------------------------------------------- [전체 상담일지 조회] ------------------------------------------------------------------------------
-- [프로시저 생성]
/
CREATE OR REPLACE PROCEDURE procReadAllConsulting
IS
    vcnt NUMBER; --전체 상담일지의 데이터가 존재하는지 확인하는 변수
BEGIN
    
    SELECT COUNT(*) INTO vcnt FROM tblconsulting;
    
    DBMS_OUTPUT.PUT_LINE('──────────────────── 전체 상담일지 조회 ────────────────────');

    IF vcnt > 0 THEN --전체 상담일지의 데이터가 1건 이상 존재할 경우,
    
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
                            ORDER BY "상담 날짜" ASC, "교육생 번호" ASC
        )
        LOOP 
            DBMS_OUTPUT.PUT_LINE('  교육생 번호: ' || consulting."교육생 번호");
            DBMS_OUTPUT.PUT_LINE('  교육생 이름: ' || consulting."교육생 이름");
            DBMS_OUTPUT.PUT_LINE('  상담 날짜: ' || consulting."상담 날짜");
            DBMS_OUTPUT.PUT_LINE('  상담 교사: ' || consulting."상담 교사");
            DBMS_OUTPUT.PUT_LINE('  상담 내용: ' || consulting."상담 내용");
            DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────────────────────');
        END LOOP;
        
    ELSE --해당 tblConsulting 테이블에 데이터가 1건도 없을 경우
    DBMS_OUTPUT.PUT_LINE('  해당 내역이 존재하지 않습니다.');
        DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────────────────────');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('  전체 상담일지 조회에 실패했습니다.');    
END procReadAllConsulting;
/

-- [프로시저 실행]
/
BEGIN
    procReadAllConsulting;
END;
/


----------------------------------------------------- [특정 교육생의 상담일지 조회] ------------------------------------------------------------------------------
-- [프로시저 생성]
/
CREATE OR REPLACE PROCEDURE procReadOneConsulting(
    pnum IN NUMBER --교육생 번호    
)
IS
    vflag NUMBER := 0;

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
        IF (vflag = 0)
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
                DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────');
                vflag := 1;
        END IF;    
        -- 특정 상담번호의 일지 정보 및 해당 상담 교육생의 정보 출력
        DBMS_OUTPUT.PUT_LINE('  [상담 내역]');
        DBMS_OUTPUT.PUT_LINE('  상담 날짜: ' || consulting."상담 날짜");
        DBMS_OUTPUT.PUT_LINE('  상담 교사: ' || consulting."상담 교사");
        DBMS_OUTPUT.PUT_LINE('  상담 내용: ' || consulting."상담 내용");
        DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────────────');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE('  해당 교육생의 상담일지 조회에 실패했습니다.');
END procReadOneConsulting;
/

-- [프로시저 실행]
/
BEGIN
    procReadOneConsulting(54); --교육생 번호 54번
END;
/