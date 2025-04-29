//
//  Created by Edison on 2025/4/25.
//

import Foundation

final class FetchScheduleUseCase: FetchScheduleUseCaseProtocol {
    private let repository: ScheduleRepositoryProtocol

    init(repository: ScheduleRepositoryProtocol) {
        self.repository = repository
    }
    
    var timezone: TimeZone {
        repository.currentTimezone
    }

    func execute() async throws -> ScheduleResponse {
        return try await repository.fetchSchedules()
    }
}
