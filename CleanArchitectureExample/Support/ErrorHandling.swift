//
//  Created by Edison on 2025/4/25.
//

import Foundation
import UIKit
import Combine

protocol ErrorHandlerProtocol {
    func handle(error: Error, in viewController: UIViewController?)
}

final class ErrorHandler: ErrorHandlerProtocol {
    @MainActor static let shared = ErrorHandler()

    private init() {}

    func handle(error: Error, in viewController: UIViewController?) {
        Task { @MainActor in
            if let networkError = error as? NetworkError {
                handleNetworkError(networkError, in: viewController)
            } else {
                handleGenericError(error, in: viewController)
            }
        }
    }

    @MainActor
    private func handleNetworkError(_ error: NetworkError, in viewController: UIViewController?) {
        let message: String

        switch error {
        case .fileNotFound:
            message = "找不到文件"
        case .decodingError:
            message = "解析錯誤"
        case .invalidResponse:
            message = "伺服器無回應"
        }

        showAlert(title: "錯誤", message: message, in: viewController)
    }

    @MainActor
    private func handleGenericError(_ error: Error, in viewController: UIViewController?) {
        showAlert(title: "錯誤", message: error.localizedDescription, in: viewController)
    }

    @MainActor
    private func showAlert(title: String, message: String, in viewController: UIViewController?) {
        guard let viewController = viewController else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        viewController.present(alert, animated: true)
    }
}

