//
//  Untitled.swift
//  SwiftWorkers
//
//  Created by USOV Vasily on 18.01.2025.
//

import Foundation

extension RestAPI {
    /// Расширение для тестирования
    protocol Testable {
        var testable_hookCheckingURLRequestBeforeSending: (@Sendable (URLRequest) async throws -> Void)? { get set }
    }
}

extension RestAPI.Testable {
    var testable_hookCheckingURLRequestBeforeSending: (@Sendable (URLRequest) async throws -> Void)? { nil }
}
