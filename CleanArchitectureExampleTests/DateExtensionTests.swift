//
//  Created by Edison on 2025/4/25.
//

import XCTest
@testable import CleanArchitectureExample

class DateExtensionTests: XCTestCase {
    
    func testStartOfDayInLocalTime() {
        let date = Date()
        let startOfDay = date.startOfDayInLocalTime()
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startOfDay)
        
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
    
    func testIsBeforeToday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        
        XCTAssertTrue(yesterday.isBeforeToday())
        XCTAssertFalse(tomorrow.isBeforeToday())
    }
    
    func testNext7Days() {
        let start = Date().startOfDayInLocalTime()
        let days = start.next7Days()
        
        XCTAssertEqual(days.count, 7)
        
        // 驗證每一天都是遞增的
        for i in 1..<days.count {
            XCTAssertTrue(days[i] > days[i-1])
            // 檢查相差一天
            let diff = Calendar.current.dateComponents([.day], from: days[i-1], to: days[i])
            XCTAssertEqual(diff.day, 1)
        }
    }
} 
