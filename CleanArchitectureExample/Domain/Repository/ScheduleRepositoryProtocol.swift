//
//  Created by Edison on 2025/4/25.
//

import Foundation

protocol ScheduleRepositoryProtocol {
    func fetchSchedules() async throws -> ScheduleResponse
    func setTimezone(_ timezone: TimeZone)
    var currentTimezone: TimeZone { get }
}
