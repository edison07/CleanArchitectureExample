//
//  Created by Edison on 2025/4/25.
//

import Foundation

extension Date {
    /// 將日期對齊到當地時區的凌晨 00:00
    func startOfDayInLocalTime() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// 回傳當天是否是今天（以當地時區為準）
    func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }

    /// 判斷是否在今天之前（不含今天）
    func isBeforeToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let this = calendar.startOfDay(for: self)
        return this <= today
    }

    /// 往前或往後移動幾天（對齊當地起始）
    func movedBy(days: Int) -> Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        return calendar.date(byAdding: .day, value: days, to: start)!
    }

    /// 回傳從當天開始的一週（7 天）
    func next7Days() -> [Date] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
}
