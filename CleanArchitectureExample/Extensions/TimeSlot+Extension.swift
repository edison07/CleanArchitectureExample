//
//  Created by Edison on 2025/4/25.
//

import Foundation

extension TimeSlot {
    func splitByHalfHour() -> [TimeSlot] {
        var slots: [TimeSlot] = []
        var current = start
        while current < end {
            let next = Calendar.current.date(byAdding: .minute, value: 30, to: current)!
            if next <= end {
                slots.append(TimeSlot(start: current, end: next))
            }
            current = next
        }
        return slots
    }
}
