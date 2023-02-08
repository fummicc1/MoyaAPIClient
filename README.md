# MoyaAPIClient

This library is super simple APIClient based on [Moya](https://github.com/Moya/Moya).


# Installation

Add below line to your `Package.swift`.

```swift
.package(url: "https://github.com/fummicc1/MoyaAPIClient", .upToNextMajor(from: "1.1.0")),
```

and use `MoyaAPIClient` library.

```swift
.product(name: "MoyaAPIClient", package: "MoyaAPIClient"),
```

# Usage

1. Define your `APITarget` (`APITarget` conforms to `Moya.TargetType`)

```swift
import Moya

public enum APIRequest {
    case index(text: String)
}

extension APIRequest: APITarget {
    public var baseURL: URL {
        URL(string: "https://example.com")!
    }

    public var path: String {
        switch self {
        case .index:
            return "/"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .index:
            return .get
        }
    }

    public var task: Moya.Task {
        switch self {
        case let .index(text):
            return .requestParameters(
                parameters: [
                    "text": text
                ],
                encoding: URLEncoding.default
            )
        }
    }

    public var headers: [String : String]? {
        nil
    }
}
```

2. Call api request

```swift

public struct Response: Decodable {
    public let results: [Result]
}

public extension Response {
    struct Result: Decodable {
        // ...
    }
}

let request: APIRequest = .index(text: "message")
let resppnse: Response = try await request.send()
```


# Contributing

Pull requests, bug reports and feature requests are welcome 🚀

# License

[MIT LICENSE](https://github.com/fummicc1/MoyaAPIClient/blob/main/LICENSE)
