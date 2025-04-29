//
//  Created by Edison on 2025/4/25.
//

import XCTest
@testable import CleanArchitectureExample

class ModelTests: XCTestCase {
    
    func testTimeSlotEquality() {
        let date1 = Date()
        let date2 = date1.addingTimeInterval(1800)
        
        let slot1 = TimeSlot(start: date1, end: date2)
        let slot2 = TimeSlot(start: date1, end: date2)
        let slot3 = TimeSlot(start: date1, end: date1.addingTimeInterval(3600))
        
        XCTAssertEqual(slot1, slot2)
        XCTAssertNotEqual(slot1, slot3)
    }
    
    func testTimeSlotSplitting() {
        // 創建一個跨越3小時的時間槽
        let start = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let end = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        let longSlot = TimeSlot(start: start, end: end)
        let splitSlots = longSlot.splitByHalfHour()
        
        // 應該得到6個半小時的時段
        XCTAssertEqual(splitSlots.count, 6)
        
        // 檢查第一個和最後一個時段
        XCTAssertEqual(splitSlots.first?.start, start)
        XCTAssertEqual(splitSlots.last?.end, end)
    }
    
    func testDayScheduleProperties() {
        // 創建測試數據
        let date = Date()
        let availableSlot = TimeSlot(start: date, end: date.addingTimeInterval(1800))
        let bookedSlot = TimeSlot(start: date.addingTimeInterval(3600), end: date.addingTimeInterval(5400))
        
        // 創建DaySchedule
        let schedule = DaySchedule(
            date: date,
            availableSlots: [availableSlot],
            bookedSlots: [bookedSlot]
        )
        
        // 測試屬性
        XCTAssertTrue(schedule.hasAvailableSlots)
        XCTAssertTrue(schedule.hasBookedSlots)
        XCTAssertFalse(schedule.isEmpty)
        XCTAssertEqual(schedule.sortedSlots.count, 2)
        
        // 測試空的DaySchedule
        let emptySchedule = DaySchedule(date: date, availableSlots: [], bookedSlots: [])
        XCTAssertFalse(emptySchedule.hasAvailableSlots)
        XCTAssertFalse(emptySchedule.hasBookedSlots)
        XCTAssertTrue(emptySchedule.isEmpty)
    }
} 
