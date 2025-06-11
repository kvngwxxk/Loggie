# Loggie

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkvngwxxk%2FLoggie%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kvngwxxk/Loggie)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkvngwxxk%2FLoggie%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kvngwxxk/Loggie)

**Loggie**는 iOS 개발자를 위한 경량 스레드-안전 로그 및 네트워크 디버깅 유틸리티입니다.
콘솔 로그, 파일 로그, OSLog 연동, Alamofire 요청을 실시간으로 확인할 수 있는 플로팅 UI를 지원합니다.

## ✅ 최소 요구사항

- iOS 16.0 이상
- Swift 5.9 이상

> `swift-testing`이 테스트 타깃에 사용되므로 패키지 매니페스트 상 Swift 6.0을 명시하고 있지만,
> 실제 라이브러리는 Swift 5.9+ 및 iOS 16+에서 완전히 호환됩니다.

## 📦 설치 방법

### Swift Package Manager

```swift
.package(url: "https://github.com/kvngwxxk/Loggie.git", from: "1.0.2")
```

### CocoaPods

```ruby
pod 'Loggie'
pod 'Loggie/Network'
```

## 🚀 기본 로깅 사용법

```swift
log("간단한 로그 메시지")
info("정보성 이벤트")
debug("디버깅 상세")
warning("문제가 있어 보임")
error("오류 발생")
```

### 선택 설정

```swift
Loggie.enabledLevels = [.debug, .info, .error]
Loggie.showEmojiInCommonLog = true
Loggie.showLevelInCommonLog = true
Loggie.useOSLog = true
```

### 파일 로그 활성화

```swift
Loggie.useFileLogging = true
```

> 🔍 로그 파일은 앱 샌드박스 내 다음 경로에 저장됩니다:
> `.../Documents/Loggie/` 디렉토리 아래, 타임스탬프를 포함한 파일명으로 저장됩니다.

## 🧪 예시 로그 출력

다음 설정을 적용한 경우:

```swift
Loggie.showEmoji = true
Loggie.showEmojiInCommonLog = true
Loggie.showLevelInCommonLog = true
Loggie.useOSLog = true
Loggie.useFileLogging = true

log("간단한 로그 메시지")
info("정보성 이벤트")
debug("디버깅 상세")
warning("문제가 있어 보임")
error("오류 발생")
```

출력 결과는 다음과 같습니다:

```text
🔍 [LOG] [Class Name:Function Name() @ Line Number] 간단한 로그 메시지
ℹ️ [INFO] [Class Name:Function Name() @ Line Number] 정보성 이벤트
🐞 [DEBUG] [Class Name:Function Name() @ Line Number] 디버깅 상세
⚠️ [WARNING] [Class Name:Function Name() @ Line Number] 문제가 있어 보임
❌ [ERROR] [Class Name:Function Name() @ Line Number] 오류 발생
```

> 위 출력은 설정에 따라 콘솔, `.log` 파일, 또는 Console.app(OSLog)에서 확인할 수 있습니다.

## 🌐 네트워크 로깅 (LoggieNetwork)

**LoggieNetwork**는 앱의 네트워크 활동을 추적하고 시각화하는 데 특화되어 있습니다.
**Alamofire 요청 및 응답을 자동 기록**하고, **플로팅 버튼 UI**를 통해 실시간으로 확인할 수 있습니다.

더 이상 `print`나 수동 디버깅은 필요 없습니다.

<p float="left"> <img src="https://postfiles.pstatic.net/MjAyNTA2MTBfMTYg/MDAxNzQ5NTM0MDYxMjY1.0XJcEX4R9NtOb8zAEv46QsqYEK0Zmg2eE-cMic76MEAg.Y2GMhHMbsfSI40WkqNqp0nmgi6DVHQKgr8z5adhoE_8g.GIF/ezgif-302d48573bcaa4.gif?type=w3840" width="200" alt="video"/>  </p>

### Alamofire와 기본 연동

LoggieNetwork만 사용할 경우:

```swift
let LoggieInterceptor = LoggieNetwork.tracker.interceptor

let session = Session(
    configuration: .default,
    interceptor: LoggieInterceptor,
    eventMonitors: [LoggieInterceptor]
)
```

커스텀 인터셉터를 함께 사용하는 경우:

```swift
let tokenInterceptor = TokenInterceptor(authManager: authManager)
let loggieInterceptor = LoggieNetwork.tracker.interceptor

let composite = Interceptor(
    adapters: [tokenInterceptor],
    retriers: [tokenInterceptor],
    interceptors: [loggieInterceptor]
)

let session = Session(
    configuration: .default,
    interceptor: composite,
    eventMonitors: [loggieInterceptor]
)
```

> `eventMonitors`와 `interceptors` 양쪽에 LoggieInterceptor를 포함해야 제대로 작동합니다.

### 2. 플로팅 트래커 UI 표시

```swift
LoggieNetwork.tracker.show()
```

> 버튼이 화면에 표시되며, 터치 시 네트워크 로그 리스트를 확인할 수 있습니다.
> 버튼을 숨기려면:

```swift
LoggieNetwork.tracker.hide()
```

#### 💡 표시 타이밍 주의

UI 렌더링이 완료된 후에 `show()`를 호출해야 버튼이 정상적으로 표시됩니다.

##### UIKit (SceneDelegate)

```swift
func sceneDidBecomeActive(_ scene: UIScene) {
#if DEBUG
    LoggieNetwork.tracker.show()
#endif
}
```

##### UIKit (AppDelegate)

```swift
func applicationDidBecomeActive(_ application: UIApplication) {
#if DEBUG
    LoggieNetwork.tracker.show()
#endif
}
```

##### SwiftUI

```swift
struct ContentView: View {
    var body: some View {
        MainScreen()
            .onAppear {
#if DEBUG
                DispatchQueue.main.async {
                    LoggieNetwork.tracker.show()
                }
#endif
            }
    }
}
```

> ☝️ `DispatchQueue.main.async` 안에 감싸면 뷰 렌더링 이후 호출을 보장할 수 있습니다.

### 🧯 문제 해결

- **요청이 기록되지 않아요?**

  `LoggieNetwork.tracker.interceptor`가 `.interceptor`와 `.eventMonitors` 양쪽에 포함되어 있는지 확인하세요.

- **플로팅 버튼이 보이지 않아요?**

  `show()` 호출이 앱의 메인 윈도우가 활성화된 이후에 실행되었는지 확인하세요.

## 📄 라이선스

Loggie는 [MIT License](LICENSE)로 배포됩니다.

## 🤝 기여

기능 제안, 버그 제보, PR 모두 환영합니다!
이슈를 열거나 풀 리퀘스트를 보내주세요.
