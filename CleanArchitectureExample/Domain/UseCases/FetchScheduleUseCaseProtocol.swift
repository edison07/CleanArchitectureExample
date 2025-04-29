//
//  Created by Edison on 2025/4/26.
//

import Foundation

protocol FetchScheduleUseCaseProtocol {
    var timezone: TimeZone { get }
    func execute() async throws -> ScheduleResponse
}
