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
   - [효율적인 네트워크 활용을 위한 API 호출 제어 전략](#api-optimization)
   - [다운샘플링과 임시 파일 활용으로 메모리 사용량 개선](#downsampling-and-temp-files)
   - [Realm 객체 삭제 오류 해결: DTO 패턴을 활용한 안정적 데이터 처리](#realm-delete-error)
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

- **기본 구성**
- **SwiftUI**: iOS 사용자 인터페이스 구성
- **Codebase UI**: SwiftUI 기반으로 코드에서 뷰 설계, Storyboard 의존성 제거

### **비동기 처리 및 네트워크 통신**

- **Swift Concurrency**: 비동기 작업 관리 (`async/await`, `Task`, `Actor`)
- **Combine**: 네트워크 상태 모니터링 및 비동기 데이터 흐름 관리
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

<h2 id="api-optimization">효율적인 네트워크 활용을 위한 API 호출 제어 전략</h2>

### **1. 문제 요약**

- **이슈 제목:** 네트워크 연결이 없는 상태에서 API 호출이 진행되는 문제
- **발생 위치:** 음양력 계산 API 호출 (`fetchSolarDate`, `fetchSolarDateSync`)
- **관련 컴포넌트:** `NetworkMonitor`, `APIService`, 네트워크 상태 확인

### **2. 문제 상세**

- **현상 설명:**
네트워크 연결이 되어 있지 않은 상태에서도 음양력 계산 API 호출이 진행됨. 통신이 실패하기 때문에 데이터는 가져오지 못하지만, **불필요한 API 호출 시도**로 인해 콜 횟수가 증가함.

### **3. 기존 코드 및 원인 분석**

- **기존 코드:**
    
    ```swift
    func fetchSolarDate(lunarDate: Date) async -> ResponseWrapper<Date> {
        let year = calendar.component(.year, from: lunarDate)
        let month = calendar.component(.month, from: lunarDate)
        let day = calendar.component(.day, from: lunarDate)
    
        do {
            let solarDateItems = try await fetchSolarDateItems(lunYear: year, lunMonth: month, lunDay: day)
            if let solarItem = solarDateItems.first,
               let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay))) {
                return ResponseWrapper(data: convertedDate, error: nil)
            }
        } catch {
            return ResponseWrapper(data: nil, error: .unknownError)
        }
    }
    ```
    
- **원인 분석:**
    - 네트워크 연결 여부를 확인하지 않고 API 호출(`fetchSolarDateItems`)을 진행.

### **4. 해결 방법 및 수정된 코드**

- **해결 방법:**
    - **`NetworkMonitor`를 활용한 네트워크 상태 확인:**
        - `NetworkMonitor`를 사용해 네트워크 연결 상태를 실시간으로 확인.
        - API 호출 전 연결 상태를 확인하여, 연결이 끊긴 경우 호출을 차단.
    - **네트워크 연결 상태에 따른 API 호출 제어:**
        - 연결되지 않은 경우 즉시 반환하며, 적절한 에러 메시지 전달.
    - **통일된 에러 처리 구조:**
        - 연결 상태와 관련된 에러(`networkUnavailable`)를 추가하여 호출부에서 처리 로직 간소화.
- **수정된 코드:**
    - **NetworkMonitor**
    
    ```swift
    final class NetworkMonitor {
        static let shared = NetworkMonitor()
        private let monitor = NWPathMonitor()
        private let queue = DispatchQueue.global()
        @Published var isConnected: Bool = true
    
        private init() {
            monitor.start(queue: queue)
            monitor.pathUpdateHandler = { path in
                DispatchQueue.main.async {
                    self.isConnected = path.status == .satisfied
                }
            }
        }
    }
    ```
    
    - **APIService**
    
    ```swift
    final class APIService: APIServiceProtocol {
        private let calendar = Calendar.current
        private let serviceKey = APIKey.key
        private let baseURL = "http://apis.data.go.kr/B090041/openapi/service/LrsrCldInfoService/getSolCalInfo"
    
        func fetchSolarDate(lunarDate: Date) async -> ResponseWrapper<Date> {
            // 네트워크 상태 확인
            guard NetworkMonitor.shared.isConnected else {
                return ResponseWrapper(data: nil, error: .networkUnavailable)
            }
    
            let year = calendar.component(.year, from: lunarDate)
            let month = calendar.component(.month, from: lunarDate)
            let day = calendar.component(.day, from: lunarDate)
    
            do {
                let solarDateItems = try await fetchSolarDateItems(lunYear: year, lunMonth: month, lunDay: day)
                if let solarItem = solarDateItems.first,
                   let convertedDate = calendar.date(from: DateComponents(year: Int(solarItem.solYear), month: Int(solarItem.solMonth), day: Int(solarItem.solDay))) {
                    return ResponseWrapper(data: convertedDate, error: nil)
                }
            } catch let error as APIServiceError {
                return ResponseWrapper(data: nil, error: error)
            } catch {
                return ResponseWrapper(data: nil, error: .unknownError)
            }
    
            return ResponseWrapper(data: nil, error: .unknownError)
        }
    }
    ```

### **5. 결론**

- **`NetworkMonitor` 활용:**
    - 네트워크 연결 상태를 확인한 후, 연결되지 않은 경우 API 호출을 차단하여 불필요한 호출을 방지.
    - 네트워크가 재연결될 때만 API 호출이 진행되도록 수정.
- **통합된 에러 처리 구조:**
    - 통합된 에러 처리 구조(`ResponseWrapper`)로 네트워크 관련 문제를 명확히 구분하여 호출부에서 간소화된 로직으로 처리 가능.
- **최종 결과:**
    - 불필요한 API 호출이 제거되어 서버 호출 횟수와 자원 낭비를 줄였으며, 네트워크 상태에 따른 유연한 처리로 앱의 안정성을 높임.

<h2 id="downsampling-and-temp-files">다운샘플링과 임시 파일 활용으로 메모리 사용량 개선</h2>

### **1. 문제 요약**

- **이슈 제목:** 이미지 원본 사용으로 인한 메모리 사용량 급증 문제
- **발생 위치:** `ImagePicker`를 통한 이미지 선택 및 로드
- **관련 컴포넌트:** `PHPickerViewController`, `UIImage`, 메모리 최적화

### **2. 문제 상세**

- **현상 설명:**
    - `PHPickerViewController`를 통해 이미지를 선택하면 원본 이미지를 로드하여 사용하는 방식으로 구현.
    - 이미지 변경 시 메모리 사용량이 급격히 증가하며, 특히 고해상도 이미지를 다룰 때 메모리 사용량이 급증하여 메모리 부족 문제가 발생할 가능성이 존재.

### **3. 원인 분석 및 기존 코드**

- **기존 코드:**
    
    ```swift
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
    
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
    
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
    
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
    
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
    ```
    
- **원인 분석:**
    - `provider.loadObject(ofClass: UIImage.self)`를 통해 원본 이미지를 메모리에 로드.
    - 고해상도 이미지를 사용하는 경우 메모리 사용량이 비효율적으로 증가.

### **4. 해결 방법 및 수정된 코드**

- **해결 방법:**
    - **다운샘플링을 통한 메모리 최적화:**
        - `CGImageSource`를 활용하여 이미지를 화면 크기에 맞게 다운샘플링.
        - 필요 없는 메모리 사용을 줄이면서도, 화질 손상을 최소화.
    - **임시 파일 경로를 활용한 이미지 처리:**
        - `loadFileRepresentation`을 통해 이미지를 임시 파일로 저장.
        - 임시 파일을 활용해 메모리 내 이미지를 직접 다루지 않고 다운샘플링 처리.
    - **동적 크기 조정 및 UI 연동:**
        - 화면 크기에 따라 동적으로 이미지를 리사이징.
        - 선택된 이미지는 다운샘플링된 결과로 UI에 전달.
- **수정된 코드**
    
    ```swift
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        let targetSize: CGSize
        let scale: CGFloat
    
        init(_ parent: ImagePicker, targetSize: CGSize, scale: CGFloat) {
            self.parent = parent
            self.targetSize = targetSize
            self.scale = scale
        }
    
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
    
            guard let provider = results.first?.itemProvider, provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else { return }
    
            provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                guard let self = self, let url = url else { return }
    
                let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(url.lastPathComponent)
                do {
                    try FileManager.default.copyItem(at: url, to: tempURL)
    
                    // 다운샘플링
                    let downsampledImage = self.downsampleImage(at: tempURL, to: self.targetSize, scale: self.scale)
    
                    DispatchQueue.main.async {
                        self.parent.selectedImage = downsampledImage
                    }
    
                    // 임시 파일 삭제
                    try FileManager.default.removeItem(at: tempURL)
                } catch {
                    print("Error handling image file: \(error)")
                }
            }
        }
    
        private func downsampleImage(at imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
                return UIImage()
            }
    
            let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary
    
            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
                return UIImage()
            }
    
            return UIImage(cgImage: downsampledImage)
        }
    }
    ```

### 5. 메모리 사용량 비교

- **다운샘플링 적용 전**
- 

- **다운샘플링 적용 후**
- 

### **6. 결론**

- **다운샘플링 적용:**
    - 원본 이미지 사용으로 인한 메모리 급증 문제를 해결.
    - `CGImageSource`와 임시 파일 접근을 활용해 메모리 효율적인 이미지 처리가 가능해짐.
- **최적화된 메모리 사용:**
    - 다운샘플링된 이미지를 UI에 전달하여 메모리 사용량을 효과적으로 줄임.
    - 고해상도 이미지 사용 시에도 앱 성능 저하를 방지.
- **최종 결과:**
    - 이미지 변경 시 메모리 사용량이 안정적으로 관리되며, 사용자 경험이 개선됨.

<h2 id="realm-delete-error">Realm 객체 삭제 오류 해결: DTO 패턴을 활용한 안정적 데이터 처리</h2>

### **1. 문제 요약**

- **이슈 제목:** Realm 객체 삭제 시 `'Object has been deleted or invalidated'` 오류 발생
- **발생 위치:** `DDay` 객체 삭제 및 뷰 업데이트 시
- **관련 컴포넌트:** Realm, SwiftUI, `DDay` 모델

### **2. 문제 상세**

- **현상 설명:**
    - Realm에 저장된 `DDay` 객체를 Realm에서 삭제하려고 시도하면 런타임 오류가 발생.
    - Realm 객체인 DDay를 뷰에서 직접 참조하여 사용했기에, 삭제된 Realm 객체를 여전히 뷰가 접근하거나 뷰 모델이 참조를 유지하고 있었음
- **에러 메시지:**
    
    ```swift
    *** Terminating app due to uncaught exception 'RLMException', reason: 'Object has been deleted or invalidated.'
    ```
    
- **에러 분석:**
    - Realm 객체를 삭제하거나 무효화된 상태에서 다시 접근하려고 할 때 발생.

### **3. 기존 코드 및 원인 분석**

- **기존 코드:**
    - **DDayViewModel**
    
    ```swift
    @MainActor
    final class DDayViewModel: ObservableObject {
        @Published var dDays: [DDay] = []
    
        private let repository: DDayRepositoryProtocol
    
        init(repository: DDayRepositoryProtocol) {
            self.repository = repository
            fetchDDay()
        }
    
        func fetchDDay() {
            dDays = repository.fetchItem()
        }
    
        func deleteDDay(dDay: DDay) {
            repository.deleteItem(dDay)
            fetchDDay()
        }
    }
    ```
    
    - **DDayDetailView**
    
    ```swift
    struct DDayDetailView: View {
        var dDay: DDay
        @ObservedObject var viewModel: DDayViewModel
        
        @State private var isPresentedAnniversaryView: Bool = false
        @State private var isPresentedEditDDayView: Bool = false
        @State private var isPresentedDeleteAlert = false
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationStack {
                DDayImageCardView(
                    dDay: dDay,
                    dDayText: viewModel.dDayText[dDay.pk] ?? "Loading...",
                    dDayImage: viewModel.dDayImage[dDay.pk] ?? nil
                )
                .toolbar {
                    ToolbarContent()
                }
                .sheet(isPresented: $isPresentedAnniversaryView) {
                    AnniversaryView(dDay: dDay)
                        .presentationDetents([.medium])
                }
                .sheet(isPresented: $isPresentedEditDDayView) {
                    EditDDayView(dDay: dDay, viewModel: viewModel)
                }
                .alert("해당 디데이를 삭제하시겠습니까?", isPresented: $isPresentedDeleteAlert) {
                    Button("취소", role: .cancel) { }
                    Button("삭제", role: .destructive) {
                        viewModel.deleteDDay(dDay: dDay)
                        dismiss()
                    }
                }
            }
        }
    }
    ```
    
- **원인 분석:**
    - 뷰에서 Realm 객체를 직접 SwiftUI 뷰에 바인딩하거나 접근하면, 해당 객체가 삭제되었을 때에도 뷰나 다른 컴포넌트에서 접근하려고 시도하면서 예외가 발생.

### **4. 해결 방법 및 수정된 코드**

- **해결 방법:**
    - **Realm 객체를 뷰에서 직접 다루지 않음:**
        - Realm 객체와 동일한 형태의 **DTO (Data Transfer Object)**를 생성함. 
        `DDayItem`을 만들어 뷰에서는 이 객체를 사용하도록 수정.
    - **뷰 모델에서 Realm 객체를 DTO로 변환:**
        - `DDay` 객체를 DTO인 `DDayItem`으로 변환하여 뷰에 전달.
        - Realm 객체의 상태 변경과 무관하게 뷰에서 안전하게 데이터를 사용할 수 있도록 함.
- **수정된 코드:**
    - **DDay 모델 (Realm 객체)**
    
    ```swift
    final class DDay: Object, ObjectKeyIdentifiable {
        @Persisted(primaryKey: true) var pk: ObjectId
        @Persisted var type: DDayType
        @Persisted var title: String
        @Persisted var date: Date
        @Persisted var isLunarDate: Bool
        @Persisted var convertedSolarDateFromLunar: Date?
    }
    ```
    
    - **DTO 구조체 (Realm 객체와 분리된 데이터)**
    
    ```swift
    struct DDayItem {
        let pk: String
        let type: DDayType
        let title: String
        let date: Date
        let isLunarDate: Bool
        let convertedSolarDateFromLunar: Date?
    
        // Realm 객체에서 DTO 생성
        init(from dDay: DDay) {
            self.pk = dDay.pk.stringValue
            self.type = dDay.type
            self.title = dDay.title
            self.date = dDay.date
            self.isLunarDate = dDay.isLunarDate
            self.convertedSolarDateFromLunar = dDay.convertedSolarDateFromLunar
        }
    }
    ```
    
    - **뷰 모델 (Realm 객체를 DTO로 변환)**
    
    ```swift
    @MainActor
    final class DDayViewModel: ObservableObject {
        @Published var dDayItems: [DDayItem] = []
    
        private let repository: DDayRepositoryProtocol
    
        init(repository: DDayRepositoryProtocol) {
            self.repository = repository
            fetchDDay()
        }
    
        func fetchDDay() {
            let dDays = repository.fetchItem()
            dDayItems = dDays.map { DDayItem(from: $0) } // DTO로 변환
        }
    
        func deleteDDay(dDayItem: DDayItem) {
            guard let dDay = repository.fetchItem().first(where: { $0.pk.stringValue == dDayItem.pk }) else { return }
            repository.deleteItem(dDay) // Realm에서 삭제
            fetchDDay() // DTO 리스트 갱신
        }
    }
    ```
    
    - **SwiftUI 뷰에서 DTO 사용**
    
    ```swift
    struct DDayDetailView: View {
        var dDayItem: DDayItem
        @ObservedObject var viewModel: DDayViewModel
        
        @State private var isPresentedAnniversaryView: Bool = false
        @State private var isPresentedEditDDayView: Bool = false
        @State private var isPresentedDeleteAlert = false
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationStack {
                DDayImageCardView(
                    dDayItem: dDayItem,
                    dDayText: viewModel.dDayText[dDayItem.pk] ?? "Loading...",
                    dDayImage: viewModel.dDayImage[dDayItem.pk] ?? nil
                )
                .toolbar {
                    ToolbarContent()
                }
                .sheet(isPresented: $isPresentedAnniversaryView) {
                    AnniversaryView(dDayItem: dDayItem)
                        .presentationDetents([.medium])
                }
                .sheet(isPresented: $isPresentedEditDDayView) {
                    EditDDayView(dDayItem: dDayItem, viewModel: viewModel)
                }
                .alert("해당 디데이를 삭제하시겠습니까?", isPresented: $isPresentedDeleteAlert) {
                    Button("취소", role: .cancel) { }
                    Button("삭제", role: .destructive) {
                        viewModel.deleteDDay(dDayItem: dDayItem)
                        dismiss()
                    }
                }
            }
        }
    }
    ```

### **5. 결론**

- **Realm 객체 직접 참조 제거:**
    - 뷰에서 Realm 객체를 직접 참조하지 않고 DTO(`DDayItem`)로 변환하여 사용하도록 수정.
- **안정적인 데이터 처리:**
    - Realm 객체 삭제 시에도 뷰와 뷰 모델은 DTO를 사용하기 때문에 예외가 발생하지 않음.
- **최종 결과:**
    - 해당 오류가 해결되었으며, Realm 객체와 UI 컴포넌트 간의 강한 의존성을 제거하여 코드 안정성과 유지보수성을 높임.

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
