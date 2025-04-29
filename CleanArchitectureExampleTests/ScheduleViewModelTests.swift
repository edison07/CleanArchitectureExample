//
//  Created by Edison on 2025/4/25.
//

import XCTest
@testable import CleanArchitectureExample

@MainActor
final class ScheduleViewModelTests: XCTestCase {
    
    var viewModel: ScheduleViewModel!
    var mockService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockService = MockNetworkService()
        let repository = ScheduleRepository(networkService: mockService)
        let useCase = FetchScheduleUseCase(repository: repository)
        viewModel = ScheduleViewModel(fetchUseCase: useCase)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertTrue(viewModel.daySchedules.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testFetchSchedulesSuccess() async throws {
        // Given
        let today = Date().startOfDayInLocalTime()
        let slot = TimeSlot(start: today.addingTimeInterval(3600), end: today.addingTimeInterval(7200))
        mockService.mockResponse = ScheduleResponse(available: [slot], booked: [])

        // When
        await viewModel.fetchSchedules()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.daySchedules.count, 7)
        let hasAvailable = viewModel.daySchedules.contains { !$0.availableSlots.isEmpty }
        XCTAssertTrue(hasAvailable)
    }

    func testFetchSchedulesFailure() async {
        // Given
        mockService.mockError = NetworkError.fileNotFound

        // When
        await viewModel.fetchSchedules()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.daySchedules.isEmpty)
    }

    func testMoveToNextWeek() async {
        // Given
        let initial = viewModel.currentWeek
        mockService.mockResponse = ScheduleResponse(available: [], booked: [])

        // When
        viewModel.moveToNextWeek()
        try? await Task.sleep(nanoseconds: 500_000_000) // 等待 async 執行完

        // Then
        let expected = initial.movedBy(days: 7).startOfDayInLocalTime()
        XCTAssertEqual(viewModel.currentWeek, expected)
    }

    func testMoveToPreviousWeekWhenDisallowed() async {
        // Given
        let testWeek = Date().startOfDayInLocalTime()
        let repository = ScheduleRepository(networkService: mockService)
        let useCase = FetchScheduleUseCase(repository: repository)
        viewModel = ScheduleViewModel(fetchUseCase: useCase, currentWeek: testWeek)

        // When
        viewModel.moveToPreviousWeek()
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Then
        XCTAssertEqual(viewModel.currentWeek, testWeek) // 不該變
    }

    func testFetchSchedules_filtersOnlyThisWeekSlots() async {
        // Given
        let today = Date().startOfDayInLocalTime()
        
        // slot 在本週內
        let inRangeSlot = TimeSlot(
            start: today.addingTimeInterval(3600),
            end: today.addingTimeInterval(7200)
        )
        
        // slot 超出 7 天以外（模擬非本週）
        let outOfRangeSlot = TimeSlot(
            start: today.movedBy(days: 8),
            end: today.movedBy(days: 8).addingTimeInterval(3600)
        )
        
        mockService.mockResponse = ScheduleResponse(
            available: [inRangeSlot, outOfRangeSlot],
            booked: []
        )
        
        // When
        await viewModel.fetchSchedules()
        
        // Then
        XCTAssertEqual(viewModel.daySchedules.count, 7)
        let retainedStarts = viewModel.daySchedules
            .flatMap { $0.availableSlots }
            .map { $0.start }

        XCTAssertTrue(retainedStarts.contains(inRangeSlot.start))
        XCTAssertFalse(retainedStarts.contains(outOfRangeSlot.start))
    }

    @MainActor
    func testUpdateTimezone() async throws {
        // 設置
        let initialTimezone = TimeZone(identifier: "Europe/London")!
        let mockRepository = MockScheduleRepository()
        mockRepository.setTimezone(initialTimezone)
        let mockUseCase = MockFetchScheduleUseCase()
        mockUseCase.setTimezone(initialTimezone)
        
        viewModel = ScheduleViewModel(fetchUseCase: mockUseCase)
        
        // 驗證初始時區
        XCTAssertEqual(viewModel.timezone.identifier, "Europe/London")
        
        // 修改時區
        let newTimezone = TimeZone(identifier: "Asia/Tokyo")!
        mockUseCase.setTimezone(newTimezone)
        
        // 重新加載資料
        await viewModel.fetchSchedules()
        
        // 驗證時區已更新
        XCTAssertEqual(viewModel.timezone.identifier, "Asia/Tokyo")
    }

    @MainActor
    func testFetchSchedules_HandlesErrorCorrectly() async {
        // 設置
        let error = NetworkError.fileNotFound
        mockService.mockError = error
        
        // 執行
        await viewModel.fetchSchedules()
        
        // 驗證
        XCTAssertEqual(viewModel.error as? NetworkError, error)
        XCTAssertFalse(viewModel.isLoading)
    }

    @MainActor
    func testMoveToNextWeek_UpdatesCurrentWeek() async {
        // 設置
        let initialWeek = viewModel.currentWeek
        let expectedNextWeek = initialWeek.movedBy(days: 7).startOfDayInLocalTime()
        
        // 執行
        viewModel.moveToNextWeek()
        
        // 驗證
        XCTAssertEqual(viewModel.currentWeek, expectedNextWeek)
    }

    @MainActor
    func testUpdateTimezoneWithUseCase() async throws {
        // 設置
        let initialTimezone = TimeZone(identifier: "Europe/London")!
        let mockUseCase = MockFetchScheduleUseCase()
        mockUseCase.setTimezone(initialTimezone)
        
        let vmWithUseCase = ScheduleViewModel(fetchUseCase: mockUseCase)
        
        // 驗證初始時區
        XCTAssertEqual(vmWithUseCase.timezone.identifier, "Europe/London")
        
        // 修改時區
        let newTimezone = TimeZone(identifier: "Asia/Tokyo")!
        mockUseCase.setTimezone(newTimezone)
        
        // 重新加載資料
        await vmWithUseCase.fetchSchedules()
        
        // 驗證時區已更新
        XCTAssertEqual(vmWithUseCase.timezone.identifier, "Asia/Tokyo")
        
        // 驗證useCase.execute被調用
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }

    @MainActor
    func testFetchWithUseCase_HandlesErrorCorrectly() async {
        // 設置
        let mockUseCase = MockFetchScheduleUseCase()
        mockUseCase.mockError = NetworkError.fileNotFound
        
        let vmWithUseCase = ScheduleViewModel(fetchUseCase: mockUseCase)
        
        // 執行
        await vmWithUseCase.fetchSchedules()
        
        // 驗證
        XCTAssertEqual(vmWithUseCase.error as? NetworkError, .fileNotFound)
        XCTAssertFalse(vmWithUseCase.isLoading)
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
    }

}
