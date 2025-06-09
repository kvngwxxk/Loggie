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

![initial page](https://postfiles.pstatic.net/MjAyNTA2MDlfMjM5/MDAxNzQ5NDU2MjMzMTEx.g_YRKc2wIDytk8EtvUYSvejTIzbvhPX9AKsXLC6v99Mg.bNYRo4-JwAPzd2q-07HyYMkg6erQKQYaGpehaO6rJgQg.PNG/IMG_0114.PNG?type=w466)
![loggie log list](https://postfiles.pstatic.net/MjAyNTA2MDlfMjkg/MDAxNzQ5NDU2MjMzMTUx.LlgMhbVkRhnkYT-0HMP9aQzocOFCuDJzKYbI1_FiInsg.tfLygOaz_Xk8krTi628j88ayVitCBgatlHM268yK3h0g.PNG/IMG_0115.PNG?type=w466)
![loggie log detail](https://postfiles.pstatic.net/MjAyNTA2MDlfMTg5/MDAxNzQ5NDU2MjMzMTYx.kP3ab48BUvGAEWVcdr5ROmeBra2jhnTO978KcI0YNS8g.o0YKFgFpNo0CmF0braIh29ZzGMtf7n23ylnv9rS38pcg.PNG/IMG_0117.PNG?type=w466)
![clear](https://postfiles.pstatic.net/MjAyNTA2MDlfMjY0/MDAxNzQ5NDU2MjMzMTYw.Pw7JCYnLUesSABMxI6Wo70nQLC6Xzgpsz20ScQVYeYQg.J12pcftms3FL9n80DAE8mVeY5WJzQ0rGLdNVNS7n65Ug.PNG/IMG_0116.PNG?type=w466)

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
