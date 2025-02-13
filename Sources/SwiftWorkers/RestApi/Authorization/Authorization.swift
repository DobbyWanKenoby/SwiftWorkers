//
//  HttpAuhorizable.swift
//  DataLayer
//
//  Created by USOV Vasily on 13.01.2025.
//

/// Расширение воркера, добавляющее HTTP-авторизацию в заголовок запроса

// MARK: - Namespace

public extension RestAPI {
    /// Пространство имен для добавления функционала авторизации
    enum Authorization {}
}

// MARK: - Subtypes

public extension RestAPI.Authorization {
    
    /// Провайдер токенов для авторизации
    protocol TokenProvider: Sendable {
        var token: String { get async throws }
    }
    
}
