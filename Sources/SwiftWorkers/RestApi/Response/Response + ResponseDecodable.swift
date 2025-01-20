//
//  Response + ValueDecodable.swift
//  DataLayer
//
//  Created by USOV Vasily on 13.01.2025.
//

import Foundation

// MARK: - Interface

public extension RestAPI.Response {
    
    protocol ResponseDecodable: Sendable {
        associatedtype Response: Sendable, Decodable
        /// Способ кодирования параметров
        var decodingMethod: DecodingMethod { get }
        func makeRequest() async throws(RestAPI.WorkerError) -> Response
    }
    
}

// MARK: - Subtypes

public extension RestAPI.Response {
    /// Способ декодирования данных ответа
    enum DecodingMethod: Sendable {
        /// Данные поступают в формате JSON и декодируются в модель
        case asJson
        /// Данные поступают в виде строки и декодируются
        case asString
        
        internal func decode<T: Decodable>(data: Data) throws -> T {
            do {
                switch self {
                case .asJson:
                    return try JSONDecoder().decode(T.self, from: data)
                case .asString:
                    guard let result = String(data: data, encoding: .utf8) else {
                        throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Полученные данные имеют неверный формат"))
                    }
                    guard let stringResult = result as? T else {
                        throw DecodingError.typeMismatch(T.self, .init(codingPath: [], debugDescription: "Указан неверный тип для декодирования данных"))
                    }
                    return stringResult
                }
            } catch {
                throw RestAPI.WorkerError.failedResultDecoding(description: error.localizedDescription)
            }
        }
    }
}

// MARK: - Implementation

public extension RestAPI.Response.ResponseDecodable where Self: RestAPI.Worker  {
    func makeRequest() async throws(RestAPI.WorkerError) -> Response {
        try await wrappedIntoCancellableTask { [self] in
            let (session, request) = try await buildInitialParametersWithCommonHandlers()
            let data = try await runRequest(session: session, urlRequest: request)
            return try decodingMethod.decode(data: data)
        }
    }
}
