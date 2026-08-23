//
//  AuthInterceptor.swift
//  SpiritualAllies
//
//  Alamofire RequestInterceptor that injects the Bearer access token into every
//  outgoing request. Requests made before login (e.g. the login call itself)
//  simply go out without an Authorization header.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    private let tokenProvider: TokenProviding

    init(tokenProvider: TokenProviding) {
        self.tokenProvider = tokenProvider
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        if let token = tokenProvider.accessToken, !token.isEmpty {
            request.headers.add(.authorization(bearerToken: token))
        }
        completion(.success(request))
    }
}
