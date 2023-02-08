import XCTest
import Moya
@testable import MoyaAPIClient

final class APIClientTests: XCTestCase {
    enum SimpleRequest: APITarget {
        case index
        case failableIndex

        var baseURL: URL {
            URL(string: "example.com")!
        }

        var path: String {
            "/"
        }

        var method: Moya.Method {
            .get
        }

        var task: Moya.Task {
            .requestPlain
        }

        var sampleData: Data {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            switch self {
            case .index:
                let response = SimpleResponse(message: "This is stub message.")
                return try! encoder.encode(response)
            case .failableIndex:
                let json: [String: String] = [:]
                return try! encoder.encode(json)
            }
        }

        var headers: [String : String]? {
            nil
        }
    }

    struct SimpleResponse: Codable, Equatable {
        let message: String

        enum CodingKeys: String, CodingKey {
            case message
        }
    }

    func test() async throws {
        let client = APIClient<SimpleRequest>.stub()
        let expectedResponse = SimpleResponse(message: "This is stub message.")
        let response: SimpleResponse = try await client.send(with: .index)
        XCTAssertEqual(response, expectedResponse)
    }

    func test_decodingError() async throws {
        let client = APIClient<SimpleRequest>.stub()
        let expectedCodingKeyForError = SimpleResponse.CodingKeys.message
        do {
            let _: SimpleResponse = try await client.send(with: .failableIndex)
        } catch APIClientError.faildToDecodeCodable(let error) {
            if case let DecodingError.keyNotFound(codingKeys, _) = error {
                guard let codingKeys = codingKeys as? SimpleResponse.CodingKeys else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(codingKeys, expectedCodingKeyForError)
                return
            }
        }
        XCTFail()
    }

    func test_target_oriented_api() async throws {
        let expectedResponse = SimpleResponse(message: "This is stub message.")
        let request = SimpleRequest.index
        let response: SimpleResponse = try await request.send(client: .stub())
        XCTAssertEqual(response, expectedResponse)
    }
}
