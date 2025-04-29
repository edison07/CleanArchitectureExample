//
//  Created by Edison on 2025/4/25.
//

import XCTest
@testable import CleanArchitectureExample

@MainActor
class ErrorHandlingTests: XCTestCase {
    
    var mockRepository: MockScheduleRepository!
    var mockUseCase: MockFetchScheduleUseCase!
    var viewModel: ScheduleViewModelProtocol!
    var errorHandler: MockErrorHandler!
    var controller: ScheduleViewController!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockRepository = MockScheduleRepository()
        mockUseCase = MockFetchScheduleUseCase()
        viewModel = ScheduleViewModel(fetchUseCase: mockUseCase)
        errorHandler = MockErrorHandler()
        controller = ScheduleViewController(viewModel: viewModel, errorHandler: errorHandler, autoFetch: false)
        _ = controller.view
    }
    
    override func tearDown() {
        controller = nil
        errorHandler = nil
        viewModel = nil
        mockUseCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    @MainActor
    func testErrorHandling_FileNotFound() async {
        errorHandler.reset()
                
        controller.setupObservations()
        
        // 設置錯誤
        mockUseCase.mockError = NetworkError.fileNotFound
        // 觸發錯誤
        await viewModel.fetchSchedules()
        
        // 驗證視圖模型有錯誤
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.error is NetworkError)
        
        // 須等待Task完成
        try? await Task.sleep(for: .milliseconds(100))
        
        // 驗證錯誤處理被調用
        XCTAssertEqual(errorHandler.handleCallCount, 1)
        XCTAssertEqual(errorHandler.lastError as? NetworkError, NetworkError.fileNotFound)
        XCTAssertTrue(errorHandler.lastViewController === controller)
    }
    
    @MainActor
    func testErrorHandling_DecodingError() async {
        // 設置錯誤
        mockUseCase.mockError = NetworkError.decodingError
        
        // 觸發錯誤
        await viewModel.fetchSchedules()
        
        // 驗證視圖模型有錯誤
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.error is NetworkError)
        
        // 須等待Task完成
        try? await Task.sleep(for: .milliseconds(100))
        
        // 驗證錯誤處理被調用
        XCTAssertEqual(errorHandler.handleCallCount, 1)
        XCTAssertEqual(errorHandler.lastError as? NetworkError, NetworkError.decodingError)
    }
    
    @MainActor
    func testErrorHandling_InvalidResponse() async {
        // 設置錯誤
        mockUseCase.mockError = NetworkError.invalidResponse
        
        // 觸發錯誤
        await viewModel.fetchSchedules()
        
        // 驗證視圖模型有錯誤
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.error is NetworkError)
        
        // 須等待Task完成
        try? await Task.sleep(for: .milliseconds(100))
        
        // 驗證錯誤處理被調用
        XCTAssertEqual(errorHandler.handleCallCount, 1)
        XCTAssertEqual(errorHandler.lastError as? NetworkError, NetworkError.invalidResponse)
    }
} 
