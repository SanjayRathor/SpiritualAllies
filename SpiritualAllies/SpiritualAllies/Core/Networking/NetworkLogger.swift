//
//  NetworkLogger.swift
//  SpiritualAllies
//
//  Alamofire EventMonitor that prints full request/response details to the
//  console so network traffic can be tracked during development.
//

import Foundation
import Alamofire

final class NetworkLogger: EventMonitor, @unchecked Sendable {
    /// Dedicated queue so logging never blocks the networking queues.
    let queue = DispatchQueue(label: "com.spiritualallies.networklogger")

    private let enabled: Bool

    init(enabled: Bool = true) {
        self.enabled = enabled
    }

    // MARK: - Request

    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        guard enabled else { return }
        let method = urlRequest.httpMethod ?? "?"
        let url = urlRequest.url?.absoluteString ?? "?"
        var lines = ["", "⬆️ ───── REQUEST ─────", "\(method) \(url)"]

        if let headers = urlRequest.allHTTPHeaderFields, !headers.isEmpty {
            lines.append("Headers: \(redacted(headers))")
        }
        if let body = urlRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            lines.append("Body: \(bodyString)")
        }
        lines.append("────────────────────")
        print(lines.joined(separator: "\n"))
    }

    // MARK: - Response

    /// Generic variant — this is the one that fires for `.serializingDecodable`
    /// (and any typed serializer), so it covers all our API calls.
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        guard enabled else { return }
        let url = request.request?.url?.absoluteString ?? "?"
        let status = response.response?.statusCode ?? -1
        let symbol = (200..<300).contains(status) ? "✅" : "❌"
        var lines = ["", "\(symbol) ───── RESPONSE ─────", "[\(status)] \(url)"]

        if let duration = response.metrics?.taskInterval.duration {
            lines.append(String(format: "Duration: %.0f ms", duration * 1000))
        }
        if let data = response.data, let bodyString = String(data: data, encoding: .utf8) {
            lines.append("Body: \(truncate(bodyString))")
        }
        if let error = response.error {
            lines.append("AFError: \(error.localizedDescription)")
        }
        lines.append("─────────────────────")
        print(lines.joined(separator: "\n"))
    }

    /// Fires for every task completion, including transport failures/timeouts
    /// that never reach response parsing.
    func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: AFError?) {
        guard enabled, let error else { return }
        let url = request.request?.url?.absoluteString ?? "?"
        print("\n❌ ───── TASK FAILED ─────\n\(url)\nError: \(error.localizedDescription)\n─────────────────────")
    }

    // MARK: - Helpers

    /// Masks sensitive header values in logs.
    private func redacted(_ headers: [String: String]) -> [String: String] {
        var copy = headers
        for key in copy.keys where key.lowercased() == "authorization" {
            copy[key] = "Bearer ***redacted***"
        }
        return copy
    }

    private func truncate(_ string: String, limit: Int = 4000) -> String {
        guard string.count > limit else { return string }
        return String(string.prefix(limit)) + "… [truncated \(string.count - limit) chars]"
    }
}
