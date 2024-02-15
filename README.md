# [Oracle Project(2023)] 교육센터 관리 시스템
교육센터를 이용하는 사용자(관리자, 교사, 교육생)를 대상으로 맞춤형 기능을 제공하는 데이터베이스를 구현한 프로젝트입니다.

<br>

## 🔖 목차
- [📄 프로젝트 개요](#프로젝트-개요)
- [✒️ 기획 배경](#%EF%B8%8F기획-배경)
- [📌 구현 목표](#구현-목표)
- [👨‍👩‍👧‍👦 업무 분담](#업무-분담)
- [💻 주요 구현 기능](#주요-구현-기능)
- [📚 산출물](#산출물)

<br>

### 📄프로젝트 개요
- **프로젝트명**: 교육센터 관리 시스템
- **분류**: Oracle Project
- **주제**: 관계형 데이터베이스 교육 내용을 바탕으로 교육센터 운영을 위한 각종 데이터 입력, 수정, 삭제 및 조회 기능을 가진 데이터베이스를 구현하고자 하였습니다.
- **개발 환경**: Oracle Database 11g, SQL Developer, DBeaver, eXERD, Draw.io, Google Drive
- **사용 기술**: ANSI-SQL, PL/SQL
- **주요 기능**: 관리자의 기초 정보 관리·교사 계정 관리·개설 과정 관리·개설 과목 관리·교육생 관리·시험 관리 및 조회·출결 관리 및 조회, 교사의 강의 스케줄 조회·배점 입출력·성적 입출력·출결 관리 및 출결 조회, 교육생의 성적 조회·출결 관리 및 출결 조회 등
- **담당 업무**: 쿼리문 작성(관리자의 교육생 관리 기능 및 상담일지 관리 기능, 관리자·교사·교육생의 우수 교육생 관련 기능, 교사의 배점 입출력 기능), 상기 항목의 더미 데이터 생성
- **획득 역량**: 관계형 데이터베이스 설계 및 운용
- **프로젝트 기간**: 2023.09.11 ~ 2023.09.18 (8일)

<br>

### ✒️기획 배경
: 주어진 요구 분석서를 바탕으로 교육센터 관리를 위한 데이터베이스 설계 및 운용

<br>

### 📌구현 목표
1. `관리자/교사/교육생별 기능을 위한 쿼리문 작성`
    1. 관리자
        - 기초 정보 관리
        - 교사 계정 관리
        - 개설 과정 관리
        - 개설 과목 관리
        - 교육생 관리
        - 시험 관리 및 조회
        - 출결 관리 및 조회
    2. 교사
        - 강의 스케줄 조회
        - 배점 입출력
        - 성적 입출력
        - 출결 관리 및 출결 조회
    3. 교육생
        - 성적 조회
        - 출결 관리 및 출결 조회
2. `기본 요구 분석 외 추가 요구 분석을 진행하여 추가 기능 구현`
    1. 관리자
        - 기간별 교육생 상담일지 관리
        - 과목별 교재 관리
        - 비품 등록 및 관리
        - 출입카드 등록 및 관리
        - 교육생 면접 및 선발 관리
        - 기관 연계 회사 관리
        - 교사 평가 항목 관리
        - 교사 추천 도서 관리
        - 질의 응답 관리
        - 우수 교육생 조회
        - 취업 명단 관리
        - 학생 생일 조회
    2. 교사
        - 추천 도서 입력 및 관리
        - 교사 평가 조회
        - 과제 등록 및 관리
        - 질의 응답
        - 비품 교체 신청
        - 우수 교육생 조회
    3. 교육생
        - 출입카드 조회 및 재신청
        - 교사 평가
        - 질의 응답 질의
        - 과제 제출 및 조회
        - 비품 교체 신청
        - 우수 교육생 수상
        - 교육생 지원금 수급
3. `절차형 SQL 활용`
    - 프로시저, 사용자 정의 함수, 트리거 등의 다양한 절차형 SQL을 활용하여 쿼리문 작성

<br>

### 👨‍👩‍👧‍👦업무 분담
- **박나래**: 교육생명단, 교육생수료명단, 교육생탈락명단, 교육생면접리스트, 교육생등록여부리스트, 상, 우수 교육생, 교육생 상담일지
- 이승원: 강의스케줄, 교육생수급내역, 과제리스트, 과제제출리스트
- 이연섭: 관리자, 교사명단, 취업명단, 질의/응답, 교사평가리스트, 평가리스트, 교재리스트, 교재상세리스트
- 차민재: 강의실리스트, 강의가능과목리스트, 교육생출결, 출결신청리스트, 과정리스트, 과정상세리스트, 과목리스트, 과목상세리스트
- 최진희: 도서리스트, 교사추천도서리스트, 시험리스트, 시험성적
- 허수경: 회사관리, 회사요구조건, 비품목록, 비품상세목록, 출입카드리스트, 출입카드재발급리스트

<br>

### 💻주요 구현 기능

<br>

### 📚산출물
- 요구분석서 (17장)
- 순서도
- 데이터베이스 설계(ERD)
- 테이블 정의서(DDL) (50장)
- 데이터 정의서(DML) (188장)
- ANSI-SQL Script (96장)
- PL/SQL Script (267장)
- PPT
- 요약본 (5장)

<details>
    <summary>산출물 미리보기 📷</summary>
        <div markdown="1">
            <img src="https://github.com/NaraeP/Oracle-Project_education-center-management-system/assets/140796673/402b08e8-3710-49d1-bde4-8c7fa34c8772" alt="요구분석서">
            <img src="https://github.com/NaraeP/Oracle-Project_education-center-management-system/assets/140796673/16e78f2a-3a63-4562-a026-afc2b8b96500" alt="순서도">
            <img src="https://github.com/NaraeP/Oracle-Project_education-center-management-system/assets/140796673/b88ac014-7be9-45bb-9853-6d9fc7efd5cd" alt="데이터베이스 설계(ERD)">
            <img src="https://github.com/NaraeP/Oracle-Project_education-center-management-system/assets/140796673/921f1413-3008-4271-ab7b-c165e0f85925" alt="테이블 정의서(DDL)">
            <img src="https://github.com/NaraeP/Oracle-Project_education-center-management-system/assets/140796673/57f51c31-0844-4220-9461-1d7b3ad612ba" alt="데이터 정의서(DML)">
            <img src="https://github.com/NaraeP/Oracle-Project_education-center-management-system/assets/140796673/8ba92c92-e480-4d39-a3e8-88ec37d7c120" alt="ANSI-SQL Script">
            <img src="https://github.com/NaraeP/Oracle-Project_education-center-management-system/assets/140796673/1b74115f-8a95-435e-bf61-9bfbeb7271bf" alt="PL/SQL Script">
            <img src="https://github.com/NaraeP/Oracle-Project_education-center-management-system/assets/140796673/9ae72130-79f2-4aa1-b2d2-399da3ee5449" alt="요약본">
        </div>
</details>
