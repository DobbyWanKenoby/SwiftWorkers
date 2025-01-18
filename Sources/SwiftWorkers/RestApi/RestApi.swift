//
//  RestApi.swift
//  SwiftWorkers
//
//  Created by USOV Vasily on 15.01.2025.
//

import Foundation

// MARK: - Namespace

/// Пространство имен для воркера, обеспечивающего работу с REST
public enum RestApi {}

// MARK: - Base Worker

public extension RestApi {
    
    /// Базовый Воркер. Определяет всю основную дефолтную функциональность
    protocol Worker: Sendable {
        /// Базовый URL-адрес для запросов
        var baseUrlPath: String { get }
        /// Эндпоинт для URL-запроса.
        ///
        /// При вычислении итогового URL для запроса символы `/` и `?` между базовым URL и эндпоинтом автоматически не подcтавляются, поэтому эндпоинт должен начинаться с одного из них.
        ///
        /// При этом предпочтительным является эндпоинт формата `/endpoint`.
        /// Для передачи параметров в формате `?parameter=val1&another=val2` реомендовано использовать
        /// протокол `Request.ParameterEncodable` и свойство `encodingMethod` в значении `.asStringToQuery`
        var urlEndpoint: String { get }
        /// Тип HTTP-запрос
        var requestMethod: NetworkRequestMethod { get }
        /// Базовый объект URLSession, используемый для запроса
        var session: URLSession { get }
        /// Базовый объект URLRequest, используемый для запроса
        func request(forURL url: URL) -> URLRequest
        /// Запуск выполнения запроса без параметров и возвращаемого значения
        func makeRequest() async throws(RestApi.WorkerError)
    }
}

// MARK: - Default Implementations

// Базовая имплементация свойств и методов
// Использщуется по умолчанию для всех объектов, реализующих протокол
// При необходимости конкретная реализация типа (struct, class, actor, enum) может переопределить методы для измнения функциональности
public extension RestApi.Worker {
    
    var session: URLSession { .shared }
    
    func request(forURL url: URL) -> URLRequest {
        URLRequest(url: url)
    }
    
    internal func buildInitialParametersWithCommonHandlers() async throws -> (URLSession, URLRequest) {
        // Создаем URL
        guard let url = URL(string: baseUrlPath + urlEndpoint) else {
            throw RestApi.WorkerError.tryingCreateURLWithWrongPath
        }

        // Создаем URLRequest
        // Далее он будет необходимым образом модифицирован
        var urlRequest = request(forURL: url)
        urlRequest.httpMethod = requestMethod.rawValue
        
        var session = self.session
        
        // Подготовка запроса
        do {
            // Добавляем дополнительные HTTP-заголовки
            if let _self = self as? RestApi.Request.HeaderFieldAddable {
                try await _self.addHeaders(request: &urlRequest)
            }
            
            // Добавляем HTTP-авторизацию
            if let _self = self as? RestApi.Authorization.HttpAuthorizable {
                try await _self.addHttpAuthorizationHeader(session: &session, request: &urlRequest)
            }
            // Добавляем QueryItem-авторизацию
            if let _self = self as? RestApi.Request.QueryItemsAddable {
                try await _self.addQueryItem(request: &urlRequest)
            }
        } catch let error as CancellationError {
            throw error
        } catch {
            throw RestApi.WorkerError.failedRequestPreparation(error: error)
        }
        
        return (session, urlRequest)
    }
    
    @discardableResult
    internal func runRequest(session: URLSession, urlRequest: URLRequest) async throws -> Data {
        if let _self = self as? RestApi.Testable {
            try await _self.testable_hookCheckingURLRequestBeforeSending?(urlRequest)
        }
        // Запрос в сеть
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw RestApi.WorkerError.failedRequest(description: error.localizedDescription)
        }
        
        // Обработка HTTPResponse
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RestApi.WorkerError.failedRequest(description: "Response is not HTTPURLResponse")
        }
        if let _self = self as? RestApi.Response.HttpResponseVerifiable {
            try _self.handle(httpResponse: httpResponse, data: data)
        }
        
        return data
    }
    
    // Оборачивает асинхронную операцию в отменяемую Task
    // Task может быть отменена, если воркер подписан на протокол RestApi.Execution.TimeoutCancellable
    internal func wrappedIntoCancellableTask<Success: Sendable>(_ operation: @escaping @Sendable () async throws -> Success) async throws(RestApi.WorkerError) -> Success {
        let storage = RestApi.CancellingTaskStorage<Success>()
        do {
            return try await withTaskCancellationHandler {
                if let _self = self as? RestApi.Execution.TimeoutCancellable {
                    let cancelling = Task {
                        try await Task.sleep(for: _self.cancellationTimeout)
                        await storage.cancellableTask?.cancel()
                    }
                    await storage.set(cancellingTask: cancelling)
                }
                
                // Выполняем основную операцию
                let cancellable = Task {
                    try await operation()
                }
                await storage.set(cancellableTask: cancellable)
                return try await cancellable.value
            } onCancel: {
                Task {
                    await storage.cancellingTask?.cancel()
                    await storage.cancellableTask?.cancel()
                }
            }
        } catch let error as RestApi.WorkerError {
            throw error
        } catch {
            throw RestApi.WorkerError.other(error: error)
        }
    }
    
    func makeRequest() async throws(RestApi.WorkerError) {
        try await wrappedIntoCancellableTask {
            let (session, request) = try await self.buildInitialParametersWithCommonHandlers()
            try await self.runRequest(session: session, urlRequest: request)
        }
    }
}

// MARK: - Subtypes

public extension RestApi {
    
    /// Тип HTTP-запроса
    enum NetworkRequestMethod: String, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // Хранилище для задачи, которая отменяет текущую задачу
    // Используется в рамках протокола RestApi.Execution.TimeoutCancellable
    private actor CancellingTaskStorage<Success: Sendable> {
        var cancellingTask: Task<Void, any Error>? = nil
        var cancellableTask: Task<Success, any Error>? = nil
        
        func set(cancellingTask: Task<Void, any Error>?) {
            self.cancellingTask = cancellingTask
        }
        
        func set(cancellableTask: Task<Success, any Error>?) {
            self.cancellableTask = cancellableTask
        }
    }
}
