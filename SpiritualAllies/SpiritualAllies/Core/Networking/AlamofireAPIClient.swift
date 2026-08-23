//
//  AlamofireAPIClient.swift
//  SpiritualAllies
//
//  Concrete APIClient backed by Alamofire. This is the ONLY file in the app
//  that imports Alamofire, keeping the dependency isolated behind a protocol.
//

import Foundation
import Alamofire

final class AlamofireAPIClient: APIClient {
    private let baseURL: URL
    private let session: Session
    private let decoder: JSONDecoder

    init(
        baseURL: URL = AppEnvironment.current.apiBaseURL,
        interceptor: RequestInterceptor? = nil,
        eventMonitors: [EventMonitor] = [NetworkLogger()],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = Session(interceptor: interceptor, eventMonitors: eventMonitors)
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        guard let url = endpoint.url(relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        let method = Alamofire.HTTPMethod(rawValue: endpoint.method.rawValue)
        let headers = HTTPHeaders(endpoint.headers.map { HTTPHeader(name: $0.key, value: $0.value) })

        let dataTask = session.request(
            url,
            method: method,
            headers: headers
        ) { urlRequest in
            urlRequest.httpBody = endpoint.body
        }
        .validate()
        .serializingDecodable(T.self, decoder: decoder)

        let response = await dataTask.response

        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw Self.mapError(error, statusCode: response.response?.statusCode)
        }
    }

    private static func mapError(_ error: AFError, statusCode: Int?) -> APIError {
        if let statusCode, !(200..<300).contains(statusCode) {
            return .server(statusCode: statusCode)
        }
        switch error {
        case .responseSerializationFailed:
            return .decoding(message: error.localizedDescription)
        case .sessionTaskFailed(let underlying):
            return .transport(message: underlying.localizedDescription)
        default:
            return .transport(message: error.localizedDescription)
        }
    }
}
