//
//  Request + HeaderFileldAddable.swift
//  SwiftWorkers
//
//  Created by USOV Vasily on 18.01.2025.
//

import Foundation

// MARK: - Interface

public extension RestApi.Request {
    
    // Расширение для включения в запрос дополнительных HTTP-заголовков
    protocol HeaderFieldAddable {
        var additionalHeaderFields: [AdditionalHeaderField] { get }
        /// Метод, обеспечивающий добавление элемента в URL-запрос
        func addHeaders(request: inout URLRequest) async throws
    }
}

// MARK: - Implementation

public extension RestApi.Request.HeaderFieldAddable {
    func addHeaders(request: inout URLRequest) async throws {
        for header in additionalHeaderFields {
            request.addValue(try await header.value(), forHTTPHeaderField: header.name)
        }
    }
}

// MARK: - Subtypes

public extension RestApi.Request {
    struct AdditionalHeaderField: Sendable {
        public let name: String
        public let value: @Sendable () async throws -> String
        
        public init(name: String, closure: @escaping @Sendable () async throws -> String) {
            self.name = name
            self.value = closure
        }
        
        public init(name: String, value: @autoclosure @escaping @Sendable () -> String) {
            self.name = name
            self.value = value
        }
    }
}
