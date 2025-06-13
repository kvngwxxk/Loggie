//
//  LoggieWebViewMessageHandler.swift
//  Loggie
//
//  Created by Kangwook Lee on 6/12/25.
//

import WebKit

final class LoggieWebViewMessageHandler: NSObject, WKScriptMessageHandler {
    static let shared = LoggieWebViewMessageHandler()
    private override init() {}

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard
            message.name == "loggie",
            let dict     = message.body as? [String: Any],
            let urlStr   = dict["url"]        as? String,
            let method   = dict["method"]     as? String,
            let duration = dict["duration"]   as? Double,
            let status   = dict["status"]     as? Int,
            let rawReq   = dict["requestBody"]  as? String,
            let rawRes   = dict["responseBody"] as? String
        else {
            return
        }

        // 1) 원본 String → Data
        let reqData = Data(rawReq.utf8)
        let resData = Data(rawRes.utf8)

        // 2) Data → pretty‐printed Data (JSON or QueryString)
        let prettyReqData = transformedBodyData(from: reqData, contentType: "application/json")
        let prettyResData = transformedBodyData(from: resData, contentType: "application/json")

        // 3) Data → String (fallback to raw)
        let prettyReq = String(data: prettyReqData, encoding: .utf8) ?? "There is no request body."
        let prettyRes = String(data: prettyResData, encoding: .utf8) ?? "There is no response data."

        // 4) Core Data에 기록
        Task {
            let ctx = CoreDataManager.shared.backgroundContext()
            try await ctx.performAsync {
                let log = LoggieNetworkLog(context: ctx)
                log.id                 = UUID()
                log.source             = "WebView"
                log.timestamp          = Date()
                log.duration           = duration
                log.requestURL         = urlStr
                log.endPoint           = URL(string: urlStr)?.path
                log.method             = method
                log.requestBody        = prettyReq
                log.responseData       = prettyRes
                log.responseStatusCode = Int16(status)
                try ctx.save()
            }
        }
    }

    // ─── 아래 세 헬퍼는 interceptor와 **똑같이** 가져온 것 ───

    private func prettyPrintedJSONString(from data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted]
            )
            return String(data: prettyData, encoding: .utf8)
        } catch {
            print("JSON pretty print failed: \(error)")
            return nil
        }
    }

    private func prettyPrintedQueryStringData(from data: Data) -> Data? {
        guard let queryString = String(data: data, encoding: .utf8) else { return nil }
        var dict = [String: String]()
        queryString
            .components(separatedBy: "&")
            .forEach { pair in
                let elements = pair.components(separatedBy: "=")
                if elements.count == 2 {
                    dict[elements[0].removingPercentEncoding ?? ""] =
                        elements[1].removingPercentEncoding ?? ""
                }
            }
        return try? JSONSerialization.data(
            withJSONObject: dict,
            options: [.prettyPrinted]
        )
    }

    private func transformedBodyData(from data: Data, contentType: String?) -> Data {
        // JSON 우선
        if contentType?.contains("application/json") == true,
           let prettyString = prettyPrintedJSONString(from: data),
           let prettyData = prettyString.data(using: .utf8) {
            return prettyData
        }
        // query-string 다음
        else if let prettyData = prettyPrintedQueryStringData(from: data) {
            return prettyData
        }
        // 그 외엔 원본
        return data
    }
}
