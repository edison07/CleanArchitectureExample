//
//  Created by Edison on 2025/4/25.
//

import Foundation
@testable import CleanArchitectureExample

final class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: ScheduleResponse?
    var mockError: Error?
    private(set) var fetchCallCount = 0

    func fetchSchedules() async throws -> ScheduleResponse {
        fetchCallCount += 1

        if let error = mockError {
            throw error
        }

        guard let response = mockResponse else {
            throw NetworkError.invalidResponse
        }

        return response
    }
}
