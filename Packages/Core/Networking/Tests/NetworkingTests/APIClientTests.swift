import XCTest
@testable import Networking

final class APIClientTests: XCTestCase {
    private var apiClient = APIClient.testValue

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

    func testGetRSSFeed() async throws {
        do {
            let feed = try await apiClient.getRSSFeed(URL(string: "https://9to5mac.com"))
            XCTAssertEqual(feed?.title, "9to5mac")
            XCTAssertEqual(feed?.link, "https://9to5mac.com")
        } catch {
            XCTFail("Test failed")
        }
    }

    func testGetSearchIndex() async throws {
        do {
            let searchIndex = try await apiClient.getSearchIndex()
            XCTAssertEqual(searchIndex?.count, 1)
            let firstIndex = searchIndex?.first
            XCTAssertEqual(firstIndex?.id, "123")
            XCTAssertEqual(firstIndex?.item, SearchIndexItemResponse(title: "9to5mac", url: "https://9to5mac.com"))
        } catch {
            XCTFail("Test failed")
        }
    }
}
