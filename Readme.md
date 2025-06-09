# Loggie

**Loggie** is a lightweight, thread-safe logging and network debugging utility for iOS developers.  
It supports console logging, file logging, OSLog integration, and a floating UI for inspecting Alamofire requests.



## 📦 Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/kvngwxxk/Loggie.git", from: "1.0.0")
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

![initial page](https://postfiles.pstatic.net/MjAyNTA2MDlfODAg/MDAxNzQ5NDU1NjgyMzQx.wfL6lsqpe659q3ZNuC3yKMcQg875D6VyoLume4mh3lQg.taIY5TvQFO4WuGIbuYYBqVV3cxlZjC0_hNj2rC-5k24g.PNG/IMG_0114.PNG?type=w966)
![loggie log list](https://postfiles.pstatic.net/MjAyNTA2MDlfMTEx/MDAxNzQ5NDU1NjgyMzI0.4byivA48sWQRK8cSxLiDOUYHXUA7fdHmOLbiks0JTcgg.ke7zKVgDdxWwpuxT_GOAzez5_kXInpNQuVjbah7IPjMg.PNG/IMG_0115.PNG?type=w966)
![loggie log detail](https://postfiles.pstatic.net/MjAyNTA2MDlfMTMy/MDAxNzQ5NDU1NjgyMzM2.nweeqpH8PFSiPffUYeK9JlmwrSA3XmkvlFdma5OgqiEg.uQel5YgCacUOAMbdwP8xGek1XVpBpxT7hM7gV1DwciAg.PNG/IMG_0117.PNG?type=w966)
![clear](https://postfiles.pstatic.net/MjAyNTA2MDlfMjY3/MDAxNzQ5NDU1NjgyMzM0.ZUYIeZCa3l-cGrrBp2uh9Bo9KP5ZA6ODGb5tm2HOvj4g.Fw_UYfOaaPbK1iKo2X3W551dRxR2zz_oS91xsR56Rxsg.PNG/IMG_0116.PNG?type=w966)

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



## 📄 License

MIT License  
© 2025 Kangwook Lee
