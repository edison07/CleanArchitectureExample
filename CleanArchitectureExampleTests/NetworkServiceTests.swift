//
//  Created by Edison on 2025/4/25.
//

import XCTest
@testable import CleanArchitectureExample

final class NetworkServiceTests: XCTestCase {
    
    // MARK: - Helper: 模擬用 URL
    private func mockLocalURL() -> URL {
        // 建立一個臨時 JSON 檔案
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("mock_schedule.json")

        let json = """
        {
            "available": [
                { "start": "2025-04-25T08:00:00Z", "end": "2025-04-25T08:30:00Z" }
            ],
            "booked": []
        }
        """.data(using: .utf8)!

        try? json.write(to: fileURL)
        return fileURL
    }
    
    // MARK: - 測試成功解析 JSON
    func testFetchSchedulesSuccess() async throws {
        let jsonURL = mockLocalURL()
        let jsonData = try Data(contentsOf: jsonURL)
        
        let session = MockURLSession()
        session.mockData = jsonData
        
        let service = NetworkService(session: session)
        let result = try await service.fetchSchedules()
        
        XCTAssertEqual(result.available.count, 1)
        XCTAssertEqual(result.booked.count, 0)
    }
    
    // MARK: - 測試 JSON 解碼失敗
    func testFetchSchedulesDecodingFailure() async {
        let brokenJSON = "{ \"invalid\": true }".data(using: .utf8)!
        
        let session = MockURLSession()
        session.mockData = brokenJSON
        
        let service = NetworkService(session: session)
        
        do {
            _ = try await service.fetchSchedules()
            XCTFail("Should have thrown decodingError")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .decodingError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - 測試 session 發生錯誤
    func testFetchSchedulesNetworkError() async {
        let session = MockURLSession()
        session.mockError = URLError(.notConnectedToInternet)
        
        let service = NetworkService(session: session)
        
        do {
            _ = try await service.fetchSchedules()
            XCTFail("Should have thrown invalidResponse")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .invalidResponse)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - 測試檔案不存在（模擬 fileNotFound）
    func testFetchSchedulesFileNotFound() async {
        let mock = MockNetworkService()
        mock.mockError = NetworkError.fileNotFound

        do {
            _ = try await mock.fetchSchedules()
            XCTFail("Should throw fileNotFound")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .fileNotFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
