//
//  Created by Edison on 2025/4/25.
//

import Foundation

@MainActor
final class AppDependencyContainer {
    static let shared = AppDependencyContainer()

    // MARK: - Private dependencies
    private lazy var networkService: NetworkServiceProtocol = NetworkService()
    private lazy var repository: ScheduleRepositoryProtocol = ScheduleRepository(networkService: networkService)
    private lazy var fetchScheduleUseCase: FetchScheduleUseCaseProtocol = FetchScheduleUseCase(repository: repository)
    private lazy var errorHandler: ErrorHandlerProtocol = ErrorHandler.shared

    private init() {}

    // MARK: - Factory Methods

    func makeScheduleViewModel() -> ScheduleViewModelProtocol {
        return ScheduleViewModel(
            fetchUseCase: fetchScheduleUseCase,
            calendar: .current
        )
    }

    func makeScheduleViewController() -> ScheduleViewController {
        let viewModel = makeScheduleViewModel()
        return ScheduleViewController(viewModel: viewModel, errorHandler: errorHandler)
    }
}
