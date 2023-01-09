import XCTest
import Moya
@testable import MoyaAPIClient

final class APIClientTests: XCTestCase {
    enum SimpleRequest: TargetType {
        case index

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
            let response = SimpleResponse(message: "This is stub message.")
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try! encoder.encode(response)
        }

        var headers: [String : String]? {
            nil
        }
    }

    struct SimpleResponse: Codable, Equatable {
        let message: String
    }

    func test() async throws {
        let client = APIClientImpl<SimpleRequest>.stub()
        let expectedResponse = SimpleResponse(message: "This is stub message.")
        let response: SimpleResponse = try await client.request(with: .index)
        XCTAssertEqual(response, expectedResponse)
    }
}
