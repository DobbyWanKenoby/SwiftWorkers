//
//  Untitled.swift
//  SwiftWorkers
//
//  Created by USOV Vasily on 18.01.2025.
//

import Foundation

extension RestApi {
    /// Расширение для тестирования
    protocol Testable {
        var testable_hookCheckingURLRequestBeforeSending: (@Sendable (URLRequest) async throws -> Void)? { get set }
    }
}

extension RestApi.Testable {
    var testable_hookCheckingURLRequestBeforeSending: (@Sendable (URLRequest) async throws -> Void)? { nil }
}
