//
//  Created by Edison on 2025/4/25.
//

import Foundation

struct DaySchedule {
    let date: Date
    let availableSlots: [TimeSlot]
    let bookedSlots: [TimeSlot]
    
    var sortedSlots: [(TimeSlot, Bool)] {
        (availableSlots.map { ($0, true) } +
         bookedSlots.map { ($0, false) })
        .sorted { $0.0.start < $1.0.start }
    }
    
    var hasAvailableSlots: Bool {
        return !availableSlots.isEmpty
    }
    
    var hasBookedSlots: Bool {
        return !bookedSlots.isEmpty
    }
    
    var isEmpty: Bool {
        return availableSlots.isEmpty && bookedSlots.isEmpty
    }
}
