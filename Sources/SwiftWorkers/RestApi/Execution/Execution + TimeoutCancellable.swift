//
//  Execution + TimeoutCancellable.swift
//  SwiftWorkers
//
//  Created by USOV Vasily on 15.01.2025.
//



public extension RestApi.Execution {
    /// Протокол для управления временем досрочного завершения выполнения запрос
    protocol TimeoutCancellable {
        /// Количество секунд до завершения запроса, если к этому времени ответ не был получен или не была выброшена ошибка
        var cancellationTimeout: Duration { get }
    }
}
