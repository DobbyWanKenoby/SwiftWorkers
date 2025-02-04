//
//  Authorization + QueryItem.swift
//  DataLayer
//
//  Created by USOV Vasily on 14.01.2025.
//

import Foundation

// MARK: - Interface

public extension RestAPI.RequestConfigurable {
    
    /// Расширение, позволяющее добавлять в URL-запрос определенный набор параметров, к примеру данные для авторизации
    protocol QueryItemsAddable {
        var additionalQueryItems: [Parameter] { get }
        /// Метод, обеспечивающий добавление элемента в URL-запрос
        func addQueryItem(request: inout URLRequest) async throws
    }
}

// MARK: - Implementation

public extension RestAPI.RequestConfigurable.QueryItemsAddable {
    func addQueryItem(request: inout URLRequest) async throws {
        for p in additionalQueryItems {
            let item = URLQueryItem(name: p.name, value: try await p.value())
            request.url?.append(queryItems: [item])
        }
    }
}

// MARK: - Subtypes

public extension RestAPI.RequestConfigurable {
    struct Parameter: Sendable {
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
