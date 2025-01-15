import Testing
@testable import SwiftWorkers
import Foundation

//@Test func example() async throws {
//    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//}

struct RestApiTests {
    
    // Кейс 1. Запрос без параметров. Проверяется факт запроса
    @Test func simpleRequest() async throws {
        try await confirmation { confirm in
            let testedClient = MockRestApiWorker.Get()
            try await testedClient.makeRequest()
            confirm.confirm()
        }
    }
    
    // Кейс 2. Запрос с параметрами. Проверяется корректность кодирования параметров в URL и декодирования в тип String
    @Test func requestWithParametersAndResponse() async throws {
        let testedClient = MockRestApiWorker.GetOutIn<MockRestApiWorker.Out, String>()
        let result = try await testedClient.makeRequest(parameters: .init())
        print(result)
        #expect(result == "Hello my dier friend")
    }
    
    // Кейс 3. Запрос с параметрами. Проверяется корректность выброса ошибки при передаче неверного типа возвращаемого значения, когда возвращется строка
    @Test func requestWithParametersAndWrongResponse() async throws {
        try await confirmation { confirm in
            let testedClient = MockRestApiWorker.GetOutIn<MockRestApiWorker.Out, MockRestApiWorker.In>()
            do {
                let _ = try await testedClient.makeRequest(parameters: .init())
            } catch RestApi.WorkerError.failedResultDecoding(description: _) {
                confirm.confirm()
            }
        }
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
