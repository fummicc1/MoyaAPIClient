import Foundation
import Moya

public protocol APITarget: TargetType, Sendable {
    var decoder: JSONDecoder { get }

    func send<Response: Decodable>(client: (APIClient<Self>)?) async throws -> Response
    func send(client: (APIClient<Self>)?) async throws
}

public extension APITarget {
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

public extension APITarget {
    func send<Response: Decodable & Sendable>(client: (APIClient<Self>)? = nil) async throws -> Response {
        if let client {
            return try await client.send(with: self)
        } else {
            return try await APIClient<Self>().send(with: self)
        }
    }
    func send(client: (APIClient<Self>)? = nil) async throws {
        if let client {
            try await client.send(with: self)
        } else {
            try await APIClient<Self>().send(with: self)
        }
    }


}
