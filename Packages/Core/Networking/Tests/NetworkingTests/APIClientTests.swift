import Dependencies
import XCTest
@testable import Networking

final class APIClientTests: XCTestCase {
    @Dependency(\.apiClient) private var apiClient

    func testPutSearchIndexItem_DefaultTestValue() async throws {
        var errorThrow = false
        do {
            try await apiClient.putSearchIndexItem("test", "test")
        } catch {
            errorThrow = true
        }
        XCTAssertFalse(errorThrow)

        errorThrow = false
        do {
            try await apiClient.putSearchIndexItem("", "")
        } catch {
            errorThrow = true
        }
        XCTAssertTrue(errorThrow)
    }

    func testPutSearchIndexItem_CustomTestValue() async throws {
        await withDependencies {
            $0.apiClient.putSearchIndexItem = { _, _ in }
        } operation: {
            var errorThrow = false
            do {
                try await apiClient.putSearchIndexItem("test", "test")
            } catch {
                errorThrow = true
            }
            XCTAssertFalse(errorThrow)

            errorThrow = false
            do {
                try await apiClient.putSearchIndexItem("", "")
            } catch {
                errorThrow = true
            }
            XCTAssertFalse(errorThrow)
        }
    }
}
