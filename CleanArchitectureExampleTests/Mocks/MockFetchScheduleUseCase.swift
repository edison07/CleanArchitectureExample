//
//  Created by Edison on 2025/4/25.
//

import Foundation
@testable import CleanArchitectureExample

final class MockFetchScheduleUseCase: FetchScheduleUseCaseProtocol {
    private var _timezone: TimeZone = .current
    var mockResponse: ScheduleResponse?
    var mockError: Error?
    var executeCallCount = 0
    
    var timezone: TimeZone {
        return _timezone
    }
    
    func setTimezone(_ timezone: TimeZone) {
        _timezone = timezone
    }
    
    func execute() async throws -> ScheduleResponse {
        executeCallCount += 1
        
        if let error = mockError {
            throw error
        }
        
        return mockResponse ?? ScheduleResponse(available: [], booked: [])
    }
}

