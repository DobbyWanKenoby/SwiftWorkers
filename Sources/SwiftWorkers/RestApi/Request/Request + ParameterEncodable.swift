//
//  Coding + ParameterEncodable.swift
//  DataLayer
//
//  Created by USOV Vasily on 13.01.2025.
//

import Foundation

// MARK: - Interface

public extension RestApi.Request {
    
    /// Протокол для кодирования переданных в запрос параметров
    protocol ParameterEncodable where Self: RestApi.Worker {
        associatedtype Parameters: Sendable, Encodable
        /// Способ кодирования параметров
        var encodingMethod: EncodingMethod { get }
        /// Запуск запрос с передачей параметров без возвращаемого значения
        func launch(withParameters: Parameters) async throws(RestApi.WorkerError)
    }
    
}

// MARK: - Subtypes

public extension RestApi.Request {
    /// Способ встраивания переданных данных в запрос
    enum EncodingMethod: Sendable {
        /// Данные сериализуются в JSON и встраиваются в тело запроса
        case asJsonToBody
        /// Данные сериализуются в строку и встраиваются в адрес запроса (после ?)
        case asItemsToUrl
        /// Данные сериализуются в словарь и встраиваются в тело, как data-form
    //            case postForm
        
        func encode<Parameters: Encodable>(parameters: Parameters, intoRequest request: inout URLRequest) throws {
            switch self {
            case .asJsonToBody:
                let jsonData = try JSONEncoder().encode(parameters)
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.httpBody = jsonData
            case .asItemsToUrl:
                let queryItems = try QueryEncoder().encode(parameters)
                request.url?.append(queryItems: queryItems)
            }
        }
    }
}

// MARK: - Implementation

// Дефолтная реализация метода кодирования параметров в запрос
internal extension RestApi.Request.ParameterEncodable {
     func encode<T: Encodable>(parameters: T, intoRequest urlRequest: inout URLRequest) throws {
        do {
            try encodingMethod.encode(parameters: parameters, intoRequest: &urlRequest)
        } catch {
            throw RestApi.WorkerError.failedParametersEncoding(description: error.localizedDescription)
        }
    }
}

// Дефолтная реализация метода, выполняющего запрос с параметрами без возвращаемого значения
public extension RestApi.Request.ParameterEncodable {
    func launch(withParameters: Parameters) async throws(RestApi.WorkerError) {
        try await wrappedIntoCancellableTask { [self] in
            var (session, request) = try await self.buildInitialParametersWithCommonHandlers()
            try encode(parameters: withParameters, intoRequest: &request)
            try await runRequest(session: session, urlRequest: request)
        }
    }
}

// Дефолтная реализация метода, выполняющего запрос с параметрами с вовзращаемым значением
// Данный метод доступен только когда воркер подписан сразу на ParameterEncodable и ResponseDecodable
public extension RestApi.Request.ParameterEncodable where Self: RestApi.Response.ResponseDecodable {
    func launch(withParameters: Parameters) async throws(RestApi.WorkerError) -> Response {
        try await wrappedIntoCancellableTask { [self] in
            var (session, request) = try await buildInitialParametersWithCommonHandlers()
            try encode(parameters: withParameters, intoRequest: &request)
            let data = try await runRequest(session: session, urlRequest: request)
            return try decodingMethod.decode(data: data)
        }
    }
}
