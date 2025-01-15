//
//  Untitled.swift
//  DataLayer
//
//  Created by USOV Vasily on 13.01.2025.
//

import Foundation

// MARK: - Interface

public extension RestApi.Authorization {
    
    /// Расширение для поддержка HTTP-авторизации в запросе
    protocol HttpAuthorizable {
        /// Провайдер токенов для авторизации
        var tokenProvider: TokenProvider { get }
        /// Способ HTTP-авторизации
        var httpAuthorizationMethod: HttpAuthorizationMethod { get }
        /// Метод, обеспечивающий добавление HTTP-заголовка для авторизации
        func addHttpAuthorizationHeader(session: inout URLSession, request: inout URLRequest) async throws
    }

}

// MARK: - Subtypes

public extension RestApi.Authorization {
    
    /// Тип авторизации для сетевого запроса
    enum HttpAuthorizationMethod: String, Sendable {
        case bearer = "Bearer"
        case basic = "Basic"
    }
    
}

// MARK: - Implementation

public extension RestApi.Authorization.HttpAuthorizable {
    func addHttpAuthorizationHeader(session _: inout URLSession, request: inout URLRequest) async throws {
        request.setValue("\(httpAuthorizationMethod.rawValue) \(try await tokenProvider.token)", forHTTPHeaderField: "Authorization")
    }
}
