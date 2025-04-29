//
//  Created by Edison on 2025/4/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case fileNotFound
    case invalidResponse
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Mock file not found"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
