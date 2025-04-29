//
//  Created by Edison on 2025/4/25.
//

import Foundation
@testable import CleanArchitectureExample

class MockScheduleRepository: ScheduleRepositoryProtocol {
    var currentTimezone: TimeZone = .current
    var mockResponse: ScheduleResponse?
    var mockError: Error?
    var fetchCallCount = 0
    
    func fetchSchedules() async throws -> ScheduleResponse {
        fetchCallCount += 1
        if let error = mockError {
            throw error
        }
        return mockResponse ?? ScheduleResponse(available: [], booked: [])
    }
    
    func setTimezone(_ timezone: TimeZone) {
        currentTimezone = timezone
    }
}
