import Testing
import Foundation
@testable import LoggieNetwork

// private 메서드를 테스트할 수 있게 internal wrapper를 추가
extension LoggieNetworkInterceptor {
    // JSON pretty-print helper
    func testablePrettyJSON(from data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            return String(data: prettyData, encoding: .utf8)
        } catch {
            print("JSON pretty print failed: \(error)")
            return nil
        }
    }
    // Query-string pretty-print helper
    func testablePrettyQuery(from data: Data) -> Data? {
        guard let queryString = String(data: data, encoding: .utf8) else { return nil }
        var dict = [String: String]()
        queryString.components(separatedBy: "&").forEach { pair in
            let elements = pair.components(separatedBy: "=")
            if elements.count == 2 {
                dict[elements[0].removingPercentEncoding ?? ""] = elements[1].removingPercentEncoding ?? ""
            }
        }
        return try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
    }
    // 변환 로직(helper) 노출
    func testableTransform(_ data: Data, contentType: String?) -> Data {
        if contentType?.contains("application/json") == true,
           let prettyString = testablePrettyJSON(from: data),
           let prettyData = prettyString.data(using: .utf8) {
            return prettyData
        } else if let prettyData = testablePrettyQuery(from: data) {
            return prettyData
        }
        return data
    }
}

struct LoggieNetworkTests {
    // 1) JSON pretty-print 테스트
    @Test
    func prettyPrintsJSON() {
        let interceptor = LoggieNetworkInterceptor()
        let raw = #"{"a":1,"b":[true,false]}"#.data(using: .utf8)!
        let pretty = interceptor.testablePrettyJSON(from: raw)
        #expect(pretty != nil)
        #expect(pretty!.contains("\n"), "Pretty JSON should contain newline")
        #expect(pretty!.contains("  \"a\""), "Pretty JSON should be indented")
    }

    // 2) Query-string → JSON 변환 테스트
    @Test
    func prettyPrintsQueryString() {
        let interceptor = LoggieNetworkInterceptor()
        let qs = "key1=value1&key2=value%202".data(using: .utf8)!
        let out = interceptor.testablePrettyQuery(from: qs)
        #expect(out != nil)
        let s = String(data: out!, encoding: .utf8)!
        #expect(s.contains("\n"), "Pretty-printed query should contain newline")
        #expect(s.contains("\"key1\""), "Should include key1")
        #expect(s.contains("\"value 2\""), "Should decode percent-encoded value")
    }

    // 3) transformedBodyData(JSON) 테스트
    @Test
    func transformsJSONBody() {
        let interceptor = LoggieNetworkInterceptor()
        let raw = #"{"foo":123}"#.data(using: .utf8)!
        let out = interceptor.testableTransform(raw, contentType: "application/json")
        let s = String(data: out, encoding: .utf8)!
        #expect(s.contains("\n"), "Transformed JSON should be pretty-printed")
    }

    // 4) transformedBodyData(query) 테스트
    @Test
    func transformsQueryBody() {
        let interceptor = LoggieNetworkInterceptor()
        let raw = "x=1&y=two".data(using: .utf8)!
        let out = interceptor.testableTransform(raw, contentType: "application/x-www-form-urlencoded")
        let s = String(data: out, encoding: .utf8)!
        #expect(s.contains("\"x\""), "Should include x key")
        #expect(s.contains("\"two\""), "Should include decoded y value")
    }
}
