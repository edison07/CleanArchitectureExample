//
//  Created by Edison on 2025/4/25.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchSchedules() async throws -> ScheduleResponse
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url, delegate: nil)
    }
}
