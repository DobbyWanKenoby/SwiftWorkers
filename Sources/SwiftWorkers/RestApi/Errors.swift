//
//  Errors.swift
//  DataLayer
//
//  Created by USOV Vasily on 14.01.2025.
//

import Foundation

public extension RestAPI {
    
    /// Ошибка воркера
    enum WorkerError: LocalizedError, Sendable {
        /// Попытка cоздать URL-адрес с неверными данными
        case tryingCreateURLWithWrongPath
        /// Ошибка в ходе кодирования отивета от сервера
        case failedParametersEncoding(description: String)
        /// Ошибка в ходе декодирования ответа от сервера
        case failedResultDecoding(description: String)
        /// Ошибка в ходе запроса
        case failedRequest(description: String)
        /// Неверный код ответа сервера
        case failedHttpResponseStatusCode(code: Int)
        /// Ошибка в процессе подготовки данных авторизации
        case failedRequestPreparation(error: Error)
        /// Другая ошибка, например CancellationError
        case other(error: Error)
    }
}
