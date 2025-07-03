# Dear Day

![디어데이 썸네일](https://github.com/user-attachments/assets/505df640-77ef-4d8f-9bd2-33b6de00668b)

### 기억하고 싶은 모든 날들을 간편하게 관리해보세요.

> 음양력 계산, 반복 계산, 알림 설정, 그리고 다양한 위젯과 공유 기능으로 중요한 날을 더욱 의미있게 만들어 주는 D-Day 관리 앱입니다.
> 

[Dear Day 앱스토어 다운로드](https://apps.apple.com/kr/app/dear-day-%EB%94%94%EB%8D%B0%EC%9D%B4-%EC%9C%84%EC%A0%AF/id6738981629)

---

# 📚 목차

1. [⭐️ 주요 기능](#features)
2. [📸 스크린샷](#screenshots)
3. [💻 개발 환경](#development-environment)
4. [📋 설계 패턴](#design-patterns)
   - [싱글턴 패턴](#singleton-pattern)
   - [프로토콜 기반 DI](#protocol-based-di)
5. [🛠️ 기술 스택](#tech-stack)
6. [🚀 트러블 슈팅](#troubleshooting)
   - [TaskGroup 기반 비동기 최적화 및 Instruments 분석](#troubleshooting1)
   - [네트워크 모니터링 기반의 안정적인 API 요청 설계](#troubleshooting2)
   - [DTO 패턴을 활용한 App Group 기반 위젯 최적화](#troubleshooting3)
   - [DTO 패턴을 활용한 Realm 객체의 스레드 안전성 문제 해결](#troubleshooting4)
7. [🗂️ 파일 디렉토리 구조](#file-structure)
8. [🛣️ 향후 계획](#future-plans)

---

<h1 id="features">⭐️ 주요 기능</h1>

**1. D-Day 등록**

- 특정 날짜를 기준으로 디데이를 등록할 수 있습니다.
- 날짜수 기반으로 디데이를 등록할 수도 있습니다.

**2. D-Day 수정 및 관리**

- 등록된 디데이를 언제든 수정할 수 있으며, 데이터는 안전하게 관리됩니다.

**3. 네트워크 기반 음력 날짜 지원**

- 음력을 기준으로 디데이를 등록하고, 양력으로 자동 변환할 수 있습니다.

**4. 반복 계산 기능**

- 연 단위 또는 월 단위로 반복되는 디데이를 자동으로 계산합니다.

**5. 다양한 정렬 및 그룹화**

- 디데이를 생성일, 제목, 디데이 등 다양한 기준으로 정렬할 수 있습니다.
- 디데이를 그룹화하여 더 효율적으로 관리할 수 있습니다.

**6. 기념일 관리**

- 중요한 기념일을 한눈에 확인하고, 디데이와 함께 관리할 수 있습니다.

**7. 로컬 알림 지원**

- D-Day와 기념일에 대해 알림을 설정하여 중요한 날을 놓치지 않습니다.

**8. 다양한 위젯 지원**

- 다양한 크기와 스타일의 위젯을 통해 디데이와 기념일을 홈 화면 및 잠금 화면에서 확인할 수 있습니다.

**9. 다크 모드 지원**

- 다크 모드 환경에서도 앱을 편안하게 사용할 수 있습니다.

**10. 인스타그램 스토리 공유 기능**

- 특별한 날을 인스타그램 스토리를 통해 간편하게 공유할 수 있습니다.
- 감성적인 스타일로 꾸며진 디데이를 스티커 형태로 만들어 친구들과 공유할 수 있습니다.

---

<h1 id="screenshots">📸 스크린샷</h1>

| 메인 | 타입 설정 | 디데이 타입 등록 | 날짜수 타입 등록 | 이미지 편집 |
|-------------|---------------|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/25ff1938-0052-42cc-8438-1ed2eecc93dc" width="200"> | <img src="https://github.com/user-attachments/assets/d7ba2936-ba7c-4cf8-8c08-7364ee3c3f73" width="200"> | <img src="https://github.com/user-attachments/assets/9c5db3c6-3e9f-4dcf-aeb0-6e4f074c6360" width="200"> | <img src="https://github.com/user-attachments/assets/213c75a2-0910-49b7-9aaa-1bdcde397b14" width="200"> | <img src="https://github.com/user-attachments/assets/3cc3f956-6eb0-47c3-805b-2c40304dd1d7" width="200"> |

| 정렬 및 그룹화 | 디데이 타입 디테일 | 날짜수 타입 디테일 | 날짜수 타입 기념일 | 인스타그램 스토리 |
|-------------|---------------|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/336e6eb8-0a85-418d-8593-e6bbc0776405" width="200"> | <img src="https://github.com/user-attachments/assets/e0107cfd-f8a0-4f99-92f1-6a402284dbd7" width="200"> | <img src="https://github.com/user-attachments/assets/3367c37a-a7e8-4a62-8380-974a48d2a1b1" width="200"> | <img src="https://github.com/user-attachments/assets/9886ce46-c4a4-43b2-b598-daa1c0e222dc" width="200"> | <img src="https://github.com/user-attachments/assets/e567d712-311a-4e8a-bbb1-2187640c29c8" width="200"> |

| 홈 화면 위젯 | 잠금 화면 위젯 | 위젯 편집 | 위젯 리스트 편집 | 알림 |
|-------------|---------------|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/508f428d-69f5-411a-abdf-a87df4b60d95" width="200"> | <img src="https://github.com/user-attachments/assets/c6c56299-b463-4487-a089-14852bf94fd5" width="200"> | <img src="https://github.com/user-attachments/assets/dd245f32-452c-4352-949c-bcd9670056d4" width="200"> | <img src="https://github.com/user-attachments/assets/ce70dd78-3caf-4451-9315-b090989b801c" width="200"> | <img src="https://github.com/user-attachments/assets/58c512d2-0479-4676-b092-0b5c8285cc95" width="200"> |

---

<h1 id="development-environment">💻 개발 환경</h1>

- **개발 기간**: 2024.10.14 ~ 2024.12.10
- **앱 지원 iOS SDK**: iOS 16.0 이상
- **위젯 지원 iOS SDK**: iOS 17.0 이상
- **Xcode**: 15.0 이상
- **Swift 버전**: 5.8 이상

---

<h1 id="design-patterns">📋 설계 패턴</h1>

- **MVVM**: UI와 비즈니스 로직 분리
- **싱글턴 패턴**: 전역적으로 관리가 필요한 객체를 재사용하기 위해 사용
- **프로토콜 기반 DI**: 테스트 가능성과 유연성을 위한 의존성 주입 구현

<h2 id="singleton-pattern">싱글턴 패턴</h2>

전역적으로 관리가 필요한 객체들에 대해 **싱글턴 패턴**을 적용하여 일관성과 성능 최적화를 도모했습니다.

### **적용 이유**

- **일관된 전역 관리**: 동일한 인스턴스를 재사용하여 코드 일관성 유지
- **성능 최적화**: `DateFormatter`와 같은 비용이 큰 객체의 재사용을 통해 성능 향상
- **중복 방지**: 반복적인 리소스 초기화 방지 및 전역 접근 보장

<h2 id="protocol-based-di">프로토콜 기반 DI</h2>

유연한 설계와 향후 테스트 가능성을 고려하여 **프로토콜 기반 DI** 방식을 적용했습니다.

### **적용 이유**

- **Service Layer**: API 호출과 데이터 처리를 위한 인터페이스 설계
- **유연한 설계**: 프로토콜을 사용하여 구현체를 쉽게 교체 가능
- **테스트 준비**: Mock 객체를 활용한 테스트 작성 가능성 확보
- **결합도 감소**: 클래스 간 의존성 최소화

### **적용된 주요 영역**

- **DDayRepositoryProtocol**
    - Realm 기반 데이터 저장소 관리
- **APIServiceProtocol**
    - 네트워크 통신 처리 추상화

### **향후 계획**

- Mock 객체를 사용한 단위 테스트 작성
- DI 확장을 위한 컨테이너 또는 팩토리 패턴 연구
    - 의존성 생성을 중앙화하여 코드 관리와 테스트 효율성 향상

---

<h1 id="tech-stack">🛠️ 기술 스택</h1>

### **기본 구성**
- **SwiftUI**: iOS 사용자 인터페이스 구성
  
### **비동기 처리 및 네트워크 통신**

- **Swift Concurrency**: 비동기 작업 관리 (`async/await`, `Task`, `Actor`)
- **XMLParser**: XML 데이터 파싱 및 처리

### **데이터 관리**

- **Realm**: 경량 데이터베이스로 로컬 데이터 관리

### **UI 개선 및 사용자 경험**

- **WidgetKit**: 위젯 제작 (iOS 17.0 이상)
- **LocalNotification**: 로컬 알림을 통한 사용자 리마인더 및 알림
- **DragGesture**: 드래그 제스처 기반의 사용자 인터랙션 처리
- **MagnificationGesture**: 확대/축소 제스처를 통한 뷰 조작 지원

### **앱 간 연동**

- **URL Scheme**: 딥 링크를 통한 외부 앱 연동 (예: Instagram 스토리 공유)
- **UIPasteboard**: 외부 앱과의 데이터 교환을 위한 Pasteboard 사용

---

<h1 id="troubleshooting">🚀 트러블 슈팅</h1>

<h2 id="troubleshooting1">TaskGroup 기반 비동기 최적화 및 Instruments 분석</h2>

### **1. 문제 정의**

- D-Day 리스트의 이미지 로드와 음양력 계산을 async/await 기반으로 구현했으나, for 루프 내에서 순차적으로 실행되면서 비동기 함수임에도 불구하고 동기적으로 작동하는 구조적 한계가 존재
- 이에 따라 UI 반영이 늦어지고, 사용자 경험이 크게 저하되는 문제가 나타남

### **2. 문제 해결**

- TaskGroup과 async let을 활용하여 이미지 로드와 음양력 계산을 동시 실행으로 처리되도록 구조 개선
- 각 D-Day 항목에 대해 이미지 로드와 음양력 계산을 동시에 수행하고, 결과는 MainActor에서 UI에 반영
- Instruments와 OSLog를 사용해 성능 측정 및 적용 전후 비교 분석 수행

### **3. 결과**

- 병렬 처리 적용으로 전체 평균 로딩 시간이 평균 1초로 단축됨
- 즉, 리스트 렌더링 속도가 안정적으로 유지되어, 초기 화면 진입 지연 문제 해소
- 이미지 로드와 음양력 계산이 동시에 진행되어 UI 반영 속도 향상 및 사용자 경험 개선
- Instruments와 OSLog를 통해 적용 전후 성능 데이터를 측정해 개선 효과를 수치로 검증

<h2 id="troubleshooting2">네트워크 모니터링 기반의 안정적인 API 요청 설계</h2>

### **1. 문제 정의**

- 네트워크 연결이 끊긴 상태에서도 API 요청이 실행되어 불필요한 서버 호출이 발생하는 문제가 존재
- 또한, 네트워크가 복구 후에도 자동으로 재시도되지 않아 데이터가 최신 상태로 동기화되지 않는 문제가 발생
- 사용자가 앱을 재실행해야만 정상적인 네트워크 요청이 가능했으며, 이는 불편한 사용자 경험을 초래

### **2. 문제 해결**

- NWPathMonitor를 활용해 네트워크 상태를 실시간 감지하는 로직을 구현
- 네트워크가 오프라인일 경우 요청을 시도하지 않고, 즉시 실패 메시지를 반환하여 불필요한 API 호출 차단
- onReceive를 통해 뷰에서 네트워크 상태 변화를 감지하고, 복구 시 자동으로 요청을 재시도하도록 흐름 개선

### **3. 결과**

- 불필요한 서버 호출 제거로 네트워크 리소스 사용 최소화
- 네트워크 복구 시 자동 동기화가 가능해져, 앱 재실행 없이도 최신 데이터 반영 가능
- 사용자 입장에서 장애 상황에서도 자연스러운 흐름 유지, 앱 신뢰도 및 사용성 향상

<h2 id="troubleshooting3">DTO 패턴을 활용한 App Group 기반 위젯 최적화</h2>

### **1. 문제 정의**

- 위젯에서 Realm을 직접 로드하면서 초기 메모리 사용량이 17.4MB에 도달
- iOS 위젯의 메모리 제한(30MB)에 근접하여, 이미지 렌더링이나 추가 연산 시 위젯이 강제 종료될 위험 존재
- Realm의 내부 메타데이터, 스레드 바인딩 등의 부가 메모리로 인해 위젯 환경과 부적합

### **2. 문제 해결**

- Realm 객체를 직접 사용하지 않고 DTO 값 타입인 DDayItem으로 변환하여 JSON 형태로 App Group에 저장
- 위젯에서는 DDayItem만 로드하고, 이를 DDayEntity로 매핑해 렌더링 및 D-Day 계산 수행
- Realm 접근 없이 경량화된 값 타입 기반 구조로 변경하여 위젯에서의 메모리 소비 최소화
- 모든 로직은 DTO 기반으로 처리되어 스레드 안전성과 구조적 명확성 확보

### **3. 결과**

- 초기 위젯 메모리 사용량이 6.1MB로 총 64.9% 감소, 위젯 안정성 향상
- Realm 제거로 스레드 충돌, 접근 제한, 동시성 오류 제거
- App ↔ Widget 간 명확한 데이터 흐름 구성으로 유지보수성 증가

<h2 id="troubleshooting4">DTO 패턴을 활용한 Realm 객체의 스레드 안전성 문제 해결</h2>

### **1. 문제 정의**

- D-Day 객체를 삭제할 때, 'Object has been deleted or invalidated.' 오류가 발생
- Realm에서 객체를 삭제하면 해당 객체는 무효화(invalidated) 되는데, 뷰에서는 삭제된 객체를 참조하고 있기 때문에 발생
- 또한 D-Day 객체의 네트워크 요청이 비동기로 실행되면서, 'Realm accessed from incorrect thread.' 오류가 발생
- Realm 객체는 생성된 스레드에서만 접근이 가능한데, 객체에 대한 네트워크 요청이 백그라운드 스레드에서 실행되면서 충돌

### **2. 문제 해결**

- Realm 객체를 직접 사용하지 않고 DTO (Data Transfer Object) 패턴을 도입하여 Struct로 데이터 관리
- Realm 객체가 삭제되더라도 뷰에서 직접 참조하지 않아, 데이터 무효화 문제를 방지하고 앱의 신뢰성을 향상
- 또한, DTO는 Realm과 독립적인 값 타입이므로 스레드 간 제약 없이 활용 가능
- 네트워크 요청 등 비동기 처리에서도 DTO를 사용해 스레드 충돌 없이 안정적인 데이터 처리 구현

### **3. 결과**

- Realm 객체 삭제 후에도 뷰와의 참조 충돌 없이 앱 크래시 없이 안정적인 동작 유지
- 백그라운드 스레드에서도 DTO를 통해 데이터 전달이 원활하게 처리, 스레드 충돌 문제 해결
- Realm 데이터 흐름의 스레드 안전성과 신뢰성 확보, 전반적인 구조 안정성 향상

---

<h1 id="file-structure">🗂️ 파일 디렉토리 구조</h1>

```
DearDay
 ┣ Assets.xcassets
 ┃ ┣ AccentColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ AppIcon.appiconset
 ┃ ┃ ┣ Contents.json
 ┃ ┃ ┗ Logo.png
 ┃ ┗ Contents.json
 ┣ Extension
 ┃ ┗ String+Extension.swift
 ┣ Manager
 ┃ ┣ DateFormatterManager.swift
 ┃ ┣ ImageDocumentManager.swift
 ┃ ┗ NotificationManager.swift
 ┣ Model
 ┃ ┗ DDay.swift
 ┣ Network
 ┃ ┣ APIKey.swift
 ┃ ┣ APIService.swift
 ┃ ┣ NetworkMonitor.swift
 ┃ ┣ SolarDataItem.swift
 ┃ ┗ SolarDateXMLParser.swift
 ┣ Preview Content
 ┃ ┗ Preview Assets.xcassets
 ┃ ┃ ┗ Contents.json
 ┣ Protocol
 ┃ ┣ APIServiceProtocol.swift
 ┃ ┗ DDayRepositoryProtocol.swift
 ┣ Realm
 ┃ ┣ AppGroupID.swift
 ┃ ┣ DDayRepository.swift
 ┃ ┗ RealmConfiguration.swift
 ┣ View
 ┃ ┣ AddDDayView.swift
 ┃ ┣ AnniversaryView.swift
 ┃ ┣ DDayCardView.swift
 ┃ ┣ DDayDetailView.swift
 ┃ ┣ DDayImageCardView.swift
 ┃ ┣ DDayView.swift
 ┃ ┣ EditDDayView.swift
 ┃ ┣ ImagePicker.swift
 ┃ ┗ SelectDDayTypeAlertView.swift
 ┣ ViewModel
 ┃ ┗ DDayViewModel.swift
 ┣ ViewModifier
 ┃ ┣ FormStyleViewModifier.swift
 ┃ ┣ MainStyleViewModifier.swift
 ┃ ┗ RowStyleViewModifier.swift
 ┣ ContentView.swift
 ┣ DearDay.entitlements
 ┣ DearDayApp.swift
 ┗ Info.plist
 
 DearDayAccessoryWidget
 ┣ Assets.xcassets
 ┃ ┣ AccentColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ AppIcon.appiconset
 ┃ ┃ ┣ Contents.json
 ┃ ┃ ┗ Logo.png
 ┃ ┣ WidgetBackground.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┗ Contents.json
 ┣ DearDayAccessoryWidget.swift
 ┣ DearDayAccessoryWidgetBundle.swift
 ┗ Info.plist
 
 DearDayWidget
 ┣ Assets.xcassets
 ┃ ┣ AccentColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ AppIcon.appiconset
 ┃ ┃ ┣ Contents.json
 ┃ ┃ ┗ Logo.png
 ┃ ┣ WidgetBackground.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┗ Contents.json
 ┣ AppIntent.swift
 ┣ DearDayWidget.swift
 ┣ DearDayWidgetBundle.swift
 ┗ Info.plist
 
 DearDayListWidget
 ┣ Assets.xcassets
 ┃ ┣ AccentColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ AppIcon.appiconset
 ┃ ┃ ┣ Contents.json
 ┃ ┃ ┗ Logo.png
 ┃ ┣ WidgetBackground.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┗ Contents.json
 ┣ AppIntent.swift
 ┣ DearDayListWidget.swift
 ┣ DearDayListWidgetBundle.swift
 ┗ Info.plist
```

---

<h1 id="future-plans">🛣️ 향후 계획</h1>

- 다국어 지원
- 사용자 맞춤 테마
