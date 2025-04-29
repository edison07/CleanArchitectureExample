//
//  Created by Edison on 2025/4/25.
//

import Foundation

struct ScheduleResponse: Codable {
    let available: [TimeSlot]
    let booked: [TimeSlot]
}
