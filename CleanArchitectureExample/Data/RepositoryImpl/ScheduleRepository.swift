//
//  Created by Edison on 2025/4/25.
//

import Foundation

final class ScheduleRepository: ScheduleRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private var _timezone: TimeZone = .current
    
    var currentTimezone: TimeZone {
        return _timezone
    }
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchSchedules() async throws -> ScheduleResponse {
        let response = try await networkService.fetchSchedules()
        return response
    }
    
    func setTimezone(_ timezone: TimeZone) {
        self._timezone = timezone
    }
} 
