//
//  Created by Edison on 2025/4/25.
//

import UIKit
@testable import CleanArchitectureExample

class MockErrorHandler: ErrorHandlerProtocol {
    var lastError: Error?
    var lastViewController: UIViewController?
    var handleCallCount = 0
    
    func handle(error: Error, in viewController: UIViewController?) {
        handleCallCount += 1
        lastError = error
        lastViewController = viewController
    }
    
    func reset() {
        handleCallCount = 0
        lastError = nil
        lastViewController = nil
    }
}
