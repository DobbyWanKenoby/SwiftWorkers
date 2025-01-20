import Testing
@testable import SwiftWorkers
import Foundation

struct RestApiTests {
    
    // Кейс 1. Запрос без параметров. Проверяется факт запроса
    @Test func simpleRequest() async throws {
        try await confirmation { confirm in
            let testedClient = MockRestApiWorker.Get()
            try await testedClient.launch()
            confirm.confirm()
        }
    }
    
    // Кейс 2. Запрос с параметрами. Проверяется корректность кодирования параметров в URL и декодирования в тип String
    @Test func requestWithParametersAndResponse() async throws {
        let testedClient = MockRestApiWorker.GetOutIn<MockRestApiWorker.Out, String>()
        let result = try await testedClient.launch(withParameters: .init())
        #expect(result == "Hello my dier friend")
    }
    
    // Кейс 3. Запрос с параметрами. Проверяется корректность выброса ошибки при передаче неверного типа возвращаемого значения, когда возвращется строка
    @Test func requestWithParametersAndWrongResponse() async throws {
        try await confirmation { confirm in
            let testedClient = MockRestApiWorker.GetOutIn<MockRestApiWorker.Out, MockRestApiWorker.In>()
            do {
                let _ = try await testedClient.launch(withParameters: .init())
            } catch RestApi.WorkerError.failedResultDecoding(description: _) {
                confirm.confirm()
            }
        }
    }
    
    // Кейс 4ю Запрос с дополнительными HTTP-заголовками
    @Test func requestWithAdditionalHttpHeaders() async throws {
        var client = MockRestApiWorker.GetAdditionalHeaders()
        client.testable_hookCheckingURLRequestBeforeSending = { @Sendable request in
            #expect(request.allHTTPHeaderFields?.count == 1)
            #expect(request.allHTTPHeaderFields?["AdditionalHeader"] == "AdditionalHeaderValue")
        }
        try await client.launch()
    }
}

enum MockRestApiWorker {

    // МОК GET без параметров
    struct Get: SwiftWorkers.RestApi.Worker {
        var baseUrlPath: String = "https://www.example.com/request"
        var urlEndpoint: String = ""
        var requestMethod: SwiftWorkers.RestApi.NetworkRequestMethod = .get
        var session: URLSession {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = [URLProtocolMock.self]
            return URLSession(configuration: configuration)
        }
    }
    
    struct GetOut<Request: Encodable & Sendable>: RestApi.Worker,
                                                  RestApi.Request.ParameterEncodable {
        typealias Parameters = Request
        var encodingMethod: SwiftWorkers.RestApi.Request.EncodingMethod = .asItemsToUrl
        
        var baseUrlPath: String = "https://www.example.com"
        var urlEndpoint: String = "/request"
        var requestMethod: SwiftWorkers.RestApi.NetworkRequestMethod = .get
        var session: URLSession {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = [URLProtocolMock.self]
            return URLSession(configuration: configuration)
        }
    }
    
    // МОК GET c передаваемым и получаемым параметрами
    struct GetOutIn<Request: Encodable & Sendable, Response: Decodable & Sendable>: RestApi.Worker,
                        RestApi.Request.ParameterEncodable,
                     RestApi.Response.ResponseDecodable {
        
        typealias Parameters = Request
        var encodingMethod: SwiftWorkers.RestApi.Request.EncodingMethod = .asItemsToUrl
        
        typealias Response = Response
        var decodingMethod: SwiftWorkers.RestApi.Response.DecodingMethod = .asString
        
        var baseUrlPath: String = "https://www.example.com/request"
        var urlEndpoint: String = ""
        var requestMethod: SwiftWorkers.RestApi.NetworkRequestMethod = .get
        var session: URLSession {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = [URLProtocolMock.self]
            return URLSession(configuration: configuration)
        }
    }
    
    // МОК без параметров со дополнительными HTTP Headers
    
    struct GetAdditionalHeaders: SwiftWorkers.RestApi.Worker,
                                 SwiftWorkers.RestApi.Request.HeaderFieldAddable,
                                 SwiftWorkers.RestApi.Testable {
        var baseUrlPath: String = "https://www.example.com"
        var urlEndpoint: String = "/request"
        var requestMethod: SwiftWorkers.RestApi.NetworkRequestMethod = .get
        var session: URLSession {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = [URLProtocolMock.self]
            return URLSession(configuration: configuration)
        }
        var additionalHeaderFields: [RestApi.Request.AdditionalHeaderField] = [
            .init(name: "AdditionalHeader", value: "AdditionalHeaderValue")
        ]
        var testable_hookCheckingURLRequestBeforeSending: (@Sendable (URLRequest) async throws -> Void)? = nil
    }
    
    // Структура для кодирования данных в запрос
    struct Out: Sendable, Encodable {
        var int = 1
        var string = "two"
    }
    
    // Структура для декодирования данных из ответа
    struct In: Sendable, Decodable {
        var string: String
    }
}

// Mock для URLSession, которая не ходит в сеть, а возвращает нужные нам данные дяля нужного нам запроса
final class URLProtocolMock: URLProtocol {
    static let testURLs: [URL?: Data] = [
        // Кейс 1
        URL(string: "https://www.example.com/request"): Data(),
        
        // Кейсы 2, 3
        URL(string: "https://www.example.com/request?int=1&string=two"): Data("Hello my dier friend".utf8)
    ]
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    override func startLoading() {
        if let url = request.url {
            if let data = URLProtocolMock.testURLs[url] {
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .allowed)
            }
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}
