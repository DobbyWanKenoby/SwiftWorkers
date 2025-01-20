#  SwiftWorkers

![my badge](https://badgen.net/static/Swift/6/orange) ![my badge](https://badgen.net/static/license/MIT/blue)

Используйте протокольно-ориентированный подход для создания различной функциональности для вашего iOS/macOS-приложения, включая разработку слоя работы с REST и (в будущем) gRPC, файлами, базами данных и т.д. 

В центре библиотеки стоит понятие "Работника" (Воркер, Worker), который предназначен для выполнения определенной задачи, например осуществления запроса к удаленному серверу. Все, что вам нужно - определить новый тип (нового работника), подписав его на необходимые протоколы. Вся базавоя функциональность определена в виде дефолтных реализаций протоколов и не требует от вас ее самостоятельно реализации. Ключевой особенность бибилиотеки являестя то, что благодаря протокольно-ориентированному подходу работник всегда обладает только присущей ему функциональностью и данными, больше никаких классов-комбайнов.

Это пример простейшего работника, осуществляющего REST-API запрос.

```swift
import SwiftWorkers

// Определение типа для нового работника
struct ExampleWorker: RestAPI.Worker {
    var baseUrlPath: String = "https://www.example.com"
    var urlEndpoint: String = "/request"
    var requestMethod: RestAPI.NetworkRequestMethod = .get
}

// Создание работника
let worker = ExampleWorker()
// Осуществление запроса
let worker.makeRequest()
``` 

При необходимости вы можете с легкостью расширить работника, наделив его дополнительной функциональностью. Для этого есть два подхода:

1. Переопределить доступные в протоколе свойства. К примеру, вы можете переопределить сессию, используемую для запроса:

```swift
// Переопределить свойство можно как в самом типе, так и в его расширении
// Конкретная реализация зависит от ваших требования
extension ExampleWorker {
    var session: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: configuration)
    }
}
```

2. Использовать дополнительные протоколы. К примеру, вы можете с легкостью добавить в тело запроса JSON с параметрами.

```swift
// Тип с параметрами
struct Options: Encodable {
    var name: String
    var description: String
}

// Использование протоколов доступно как в самом типе, так и в его расширении
// Конкретная реализация зависит от ваших требования
extension ExampleWorker: RestAPI.Request.ParameterEncodable {
    typealias Parameters = Options
    var encodingMethod: RestAPI.Request.EncodingMethod { .asJsonToBody }
}

// Теперь вам доступен новый метод для осуществления запроса с передачей параметров
let options = Options(name: "New item", description: "New item description")
let worker.makeRequest(withParameters: options)
```

SwiftWorkers обладает большим количеством встроенной логики, поставляемой через протоколы. 


## Использование RestAPI

