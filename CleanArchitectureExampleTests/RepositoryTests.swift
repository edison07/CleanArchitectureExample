//
//  Created by Edison on 2025/4/25.
//

import XCTest
@testable import CleanArchitectureExample

class RepositoryTests: XCTestCase {
    
    func testRepositoryTimezoneManagement() {
        let mockNetwork = MockNetworkService()
        let repository = ScheduleRepository(networkService: mockNetwork)
        
        // 檢查默認時區
        XCTAssertEqual(repository.currentTimezone, TimeZone.current)
        
        // 設置新時區
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        repository.setTimezone(tokyo)
        XCTAssertEqual(repository.currentTimezone, tokyo)
        
        // 設置另一個時區
        let london = TimeZone(identifier: "Europe/London")!
        repository.setTimezone(london)
        XCTAssertEqual(repository.currentTimezone, london)
    }
    
    func testRepositoryFetchCallsNetworkService() async throws {
        let mockNetwork = MockNetworkService()
        let slot = TimeSlot(start: Date(), end: Date().addingTimeInterval(1800))
        let response = ScheduleResponse(available: [slot], booked: [])
        mockNetwork.mockResponse = response
        
        let repository = ScheduleRepository(networkService: mockNetwork)
        
        // 第一次調用
        let result1 = try await repository.fetchSchedules()
        XCTAssertEqual(mockNetwork.fetchCallCount, 1)
        XCTAssertEqual(result1.available.count, 1)
        
        // 第二次調用
        let result2 = try await repository.fetchSchedules()
        XCTAssertEqual(mockNetwork.fetchCallCount, 2)
        XCTAssertEqual(result2.available.count, 1)
    }
    
    func testRepositoryErrorPropagation() async {
        let mockNetwork = MockNetworkService()
        mockNetwork.mockError = NetworkError.fileNotFound
        
        let repository = ScheduleRepository(networkService: mockNetwork)
        
        do {
            _ = try await repository.fetchSchedules()
            XCTFail("Should have thrown an error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .fileNotFound)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
} 
