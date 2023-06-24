import Foundation
import Moya

protocol APIClientType<Target>: Sendable {
    associatedtype Target: APITarget

    @available(swift, deprecated: 1.2.0, renamed: "send")
    func request<Response: Decodable>(with target: Target) async throws -> Response
    @available(swift, deprecated: 1.2.0, renamed: "send")
    func request(with target: Target) async throws

    func send<Response: Decodable>(with target: Target) async throws -> Response
    func send(with target: Target) async throws
}

public enum APIClientError: Error, Sendable {
    case faildToDecodeCodable(DecodingError)
    case underlying(Error)
}

public actor APIClient<Target: APITarget> {
    private var provider: MoyaProvider<Target>

    public init(provider: MoyaProvider<Target> = .init()) {
        self.provider = provider
    }

    public static func stub() -> some APIClient {
        APIClient(
            provider: MoyaProvider<Target>(
                stubClosure: MoyaProvider.immediatelyStub
            )
        )
    }
}

extension APIClient: APIClientType {

    public func send<Response>(with target: Target) async throws -> Response where Response : Decodable {
        let response: Response = try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: APIClientError.underlying(error))
                case .success(let response):
                    do {
                        let codableResponse = try target.decoder.decode(Response.self, from: response.data)
                        continuation.resume(returning: codableResponse)
                    }
                    catch {
                        if let error = error as? DecodingError {
                            continuation.resume(throwing: APIClientError.faildToDecodeCodable(error))
                            return
                        }
                        continuation.resume(throwing: APIClientError.underlying(error))
                    }
                }
            }
        }
        return response
    }

    public func send(with target: Target) async throws {
        let _: Void = try await withCheckedThrowingContinuation({ continuation in
            provider.request(target) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: APIClientError.underlying(error))
                case .success:
                    continuation.resume(returning: ())
                }
            }
        })
    }

    @available(swift, deprecated: 1.2.0, renamed: "send")
    public func request<Response>(with target: Target) async throws -> Response where Response : Decodable {
        try await send(with: target)
    }

    @available(swift, deprecated: 1.2.0, renamed: "send")
    public func request(with target: Target) async throws {
        try await send(with: target)
    }
}
