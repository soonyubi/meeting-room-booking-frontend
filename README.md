# Meeting Room Booking Frontend

Flutter 웹 애플리케이션으로 구현된 회의실 예약 시스템 프론트엔드입니다.

## 개발 환경 설정

### 필수 요구사항

- Flutter SDK (^3.7.2)
- Dart SDK
- Node.js (Firebase CLI 사용 시)

### 설치 및 실행

1. 의존성 설치:

```bash
flutter pub get
```

2. 웹 빌드:

```bash
flutter build web
```

3. 로컬 개발 서버 실행:

```bash
# 방법 1: Flutter 개발 서버
flutter run -d web-server --web-port 8080

# 방법 2: Python HTTP 서버 (빌드 후)
cd build/web && python3 -m http.server 8080
```

## Firebase Hosting 배포

### 1. Firebase CLI 설치

```bash
npm install -g firebase-tools
```

### 2. Firebase 로그인 및 프로젝트 초기화

```bash
firebase login
firebase init hosting
```

### 3. 웹 빌드 및 배포

```bash
flutter build web
firebase deploy
```

## 프로젝트 구조

```
lib/
  ├── main.dart          # 애플리케이션 진입점
  └── ...

web/
  ├── index.html         # 웹 진입점
  └── ...

build/web/              # 빌드된 웹 파일들
```

## 현재 상태

- ✅ Flutter 웹 프로젝트 설정 완료
- ✅ 웹 빌드 및 로컬 서버 실행 가능
- ✅ Firebase Hosting 설정 파일 생성
- ⏳ Firebase 프로젝트 연결 및 배포 (Node.js 업그레이드 필요)

## 다음 단계

1. Node.js를 v20 이상으로 업그레이드
2. Firebase 프로젝트 생성 및 연결
3. Firebase Hosting 배포
4. 회의실 예약 기능 구현

## 접속 정보

- 로컬 개발 서버: http://localhost:8080
- Firebase Hosting: 배포 후 제공될 URL
