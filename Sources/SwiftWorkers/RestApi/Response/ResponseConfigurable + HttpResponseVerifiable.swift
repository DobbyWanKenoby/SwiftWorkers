//
//  Response + Verifiable.swift
//  DataLayer
//
//  Created by USOV Vasily on 13.01.2025.
//

import Foundation

public extension RestAPI.ResponseConfigurable {
    
    /// Расширение для обработки полученного статуса ответа от сервера
    protocol HttpStatusCodeVerifiable {
        func handle(httpResponse: HTTPURLResponse, data: Data) throws
    }
}

public extension RestAPI.ResponseConfigurable.HttpStatusCodeVerifiable {
    func handle(httpResponse: HTTPURLResponse, data: Data) throws {
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
            throw RestAPI.WorkerError.failedHttpResponseStatusCode(code: httpResponse.statusCode)
        }
    }
    
}
