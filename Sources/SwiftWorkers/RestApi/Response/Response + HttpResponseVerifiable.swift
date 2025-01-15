//
//  Response + Verifiable.swift
//  DataLayer
//
//  Created by USOV Vasily on 13.01.2025.
//

import Foundation

public extension RestApi.Response {
    
    /// Расширение для обработки полученного статуса ответа от сервера
    protocol HttpResponseVerifiable {
        func handle(httpResponse: HTTPURLResponse, data: Data) throws
    }
}

public extension RestApi.Response.HttpResponseVerifiable {
    func handle(httpResponse: HTTPURLResponse, data: Data) throws {
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
            throw RestApi.WorkerError.failedHttpResponseStatusCode(code: httpResponse.statusCode)
        }
    }
    
}
