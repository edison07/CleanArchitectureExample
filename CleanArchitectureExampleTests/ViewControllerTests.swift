//
//  Created by Edison on 2025/4/25.
//

import XCTest
@testable import CleanArchitectureExample

@MainActor
class ViewControllerTests: XCTestCase {
    
    var mockRepository: MockScheduleRepository!
    var mockUseCase: MockFetchScheduleUseCase!
    var viewModel: ScheduleViewModelProtocol!
    var controller: ScheduleViewController!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockRepository = MockScheduleRepository()
        mockUseCase = MockFetchScheduleUseCase()
        viewModel = ScheduleViewModel(fetchUseCase: mockUseCase)
        controller = ScheduleViewController(viewModel: viewModel)
    }
    
    override func tearDown() {
        controller = nil
        viewModel = nil
        mockUseCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    @MainActor
    func testControllerInitialization() {
        // 加載視圖
        _ = controller.view
        
        // 基本測試視圖已加載
        XCTAssertNotNil(controller.view)
    }
    
    @MainActor
    func testControllerCallsFetchOnLoad() async {
        // 加載視圖
        _ = controller.view
        
        // 等待異步操作
        try? await Task.sleep(for: .milliseconds(100))
        
        // 應該調用了一次fetch
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }
    
    @MainActor
    func testWeekNavigation() async {
        // 加載視圖
        _ = controller.view
        
        // 記錄初始週
        let initialWeek = viewModel.currentWeek
        
        // 模擬WeekNavigationViewDelegate方法調用
        controller.didTapNextWeek()
        
        // 驗證週前進了
        XCTAssertEqual(viewModel.currentWeek, initialWeek.movedBy(days: 7).startOfDayInLocalTime())
        
        // 等待異步操作
        try? await Task.sleep(for: .milliseconds(100))
        
        // 應該有第二次fetch
        XCTAssertEqual(mockUseCase.executeCallCount, 2)
        
        // 模擬向後導航
        controller.didTapPreviousWeek()
        
        // 驗證週後退了
        XCTAssertEqual(viewModel.currentWeek, initialWeek)
        
        // 等待異步操作
        try? await Task.sleep(for: .milliseconds(100))
        
        // 應該有第三次fetch
        XCTAssertEqual(mockUseCase.executeCallCount, 3)
    }
} 
