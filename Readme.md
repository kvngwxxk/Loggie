# Loggie

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkvngwxxk%2FLoggie%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kvngwxxk/Loggie)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkvngwxxk%2FLoggie%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kvngwxxk/Loggie)

**Loggie** is a lightweight, thread-safe logging and network debugging utility for iOS developers.  
It supports console logging, file logging, OSLog integration, and a floating UI for inspecting Alamofire requests.

## ✅ Minimum Requirements

- iOS 16.0 or later
- Swift 5.9 or later

> Although the package manifest specifies Swift 6.0 due to the use of `swift-testing` in test targets, the core library itself is fully compatible with Swift 5.9+ and iOS 16+.


## 📦 Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/kvngwxxk/Loggie.git", from: "1.0.2")
```

### CocoaPods

```ruby
pod 'Loggie'
pod 'Loggie/Network'
```



## 🚀 Basic Logging

```swift
log("A simple log message")
info("Informational event")
debug("Debugging details")
warning("Something looks wrong")
error("Something went wrong")
```



### Optional Configurations

```swift
Loggie.enabledLevels = [.debug, .info, .error]
Loggie.showEmojiInCommonLog = true
Loggie.showLevelInCommonLog = true
Loggie.useOSLog = true
```

### File Logging

```swift
Loggie.useFileLogging = true
```

> 🔍 Log files are saved in your app's sandbox under:
> `~/Library/Developer/CoreSimulator/Devices/.../Containers/Data/Application/.../Documents/Loggie/`

> Log files are stored in the app sandbox under `Loggie/`, with timestamped filenames.



## 🧪 Example Log Output

With the following configuration:

```swift
Loggie.showEmoji = true
Loggie.showEmojiInCommonLog = true
Loggie.showLevelInCommonLog = true
Loggie.useOSLog = true
Loggie.useFileLogging = true

log("A simple log message")
info("Informational event")
debug("Debugging details")
warning("Something looks wrong")
error("Something went wrong")
```

The output will be:

```text
🔍 [LOG] [Class Name:Function Name() @ Line Number] A simple log message
ℹ️ [INFO] [Class Name:Function Name() @ Line Number] Informational event
🐞 [DEBUG] [Class Name:Function Name() @ Line Number] Debugging details
⚠️ [WARNING] [Class Name:Function Name() @ Line Number] Something looks wrong
❌ [ERROR] [Class Name:Function Name() @ Line Number] Something went wrong
```

> Depending on your configuration, the above output may appear in the console, in a `.log` file, or in Console.app via OSLog.



## 🌐 Network Logging (LoggieNetwork)

**LoggieNetwork** makes it easy to track and inspect network activity in your app.  
It automatically logs your **Alamofire requests and responses**, and provides a **floating button UI** to browse the logs in real time.

No need to manually print or debug – just turn it on and you're ready to go.

<p float="left"> <img src="https://postfiles.pstatic.net/MjAyNTA2MTBfMTYg/MDAxNzQ5NTM0MDYxMjY1.0XJcEX4R9NtOb8zAEv46QsqYEK0Zmg2eE-cMic76MEAg.Y2GMhHMbsfSI40WkqNqp0nmgi6DVHQKgr8z5adhoE_8g.GIF/ezgif-302d48573bcaa4.gif?type=w3840" width="200" alt="video"/> <img src="https://postfiles.pstatic.net/MjAyNTA2MDlfMjM5/MDAxNzQ5NDU2MjMzMTEx.g_YRKc2wIDytk8EtvUYSvejTIzbvhPX9AKsXLC6v99Mg.bNYRo4-JwAPzd2q-07HyYMkg6erQKQYaGpehaO6rJgQg.PNG/IMG_0114.PNG?type=w966" width="200" alt="Initial Screen"/> <img src="https://postfiles.pstatic.net/MjAyNTA2MDlfMTEx/MDAxNzQ5NDU1NjgyMzI0.4byivA48sWQRK8cSxLiDOUYHXUA7fdHmOLbiks0JTcgg.ke7zKVgDdxWwpuxT_GOAzez5_kXInpNQuVjbah7IPjMg.PNG/IMG_0115.PNG?type=w966" width="200" alt="Log List Screen"/> <img src="https://postfiles.pstatic.net/MjAyNTA2MDlfMTMy/MDAxNzQ5NDU1NjgyMzM2.nweeqpH8PFSiPffUYeK9JlmwrSA3XmkvlFdma5OgqiEg.uQel5YgCacUOAMbdwP8xGek1XVpBpxT7hM7gV1DwciAg.PNG/IMG_0117.PNG?type=w966" width="200" alt="Log Detail Screen"/> </p>

> From left to right:
> 1. **Initial Button UI** – The floating Loggie button appears.
> 2. **Log List Screen** – View a scrollable list of recent network logs.
> 3. **Log Detail View** – Inspect headers, bodies, and status codes of selected logs.

### Basic Setup with Alamofire

If you're only using `LoggieNetwork`:

```swift
let LoggieInterceptor = LoggieNetwork.tracker.interceptor

let session = Session(
    configuration: .default,
    interceptor: LoggieInterceptor,
    eventMonitors: [LoggieInterceptor]
)
```

If you also use a custom interceptor (e.g., auth handling), combine them manually:

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

> LoggieNetwork works well with custom interceptors by simply including its interceptor in `eventMonitors` and `interceptors`.


### 2. Floating Tracker UI

```swift
LoggieNetwork.tracker.show()
```

> A floating button will appear. Tap it to view a list of recent network requests and responses.  
> To hide the button:

```swift
LoggieNetwork.tracker.hide()
```

#### 💡 When to Show

You should call `LoggieNetwork.tracker.show()` **after the main UI has been rendered**, otherwise the floating button may not attach correctly to the current window.

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

> ☝️ Wrapping `show()` inside `DispatchQueue.main.async` ensures it's called after the view has fully appeared.

### 🧯 Troubleshooting

- **LoggieNetwork does not capture requests?**  
  Ensure `LoggieNetwork.tracker.interceptor` is included both in `.interceptor` and `.eventMonitors`.

- **Floating button does not appear?**  
  Confirm `LoggieNetwork.tracker.show()` is called *after* the main window is active.

## 📄 License

Loggie is released under the [MIT License](LICENSE).

## 🤝 Contribution

Contributions, issues and feature requests are welcome!  
Feel free to open an issue or submit a pull request.

© 2025 Kangwook Lee
