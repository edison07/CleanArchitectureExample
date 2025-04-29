//
//  Created by Edison on 2025/4/25.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetchSchedules() async throws -> ScheduleResponse {
        guard let url = Bundle.main.url(forResource: "mock_schedule", withExtension: "json") else {
            throw NetworkError.fileNotFound
        }

        do {
            let (data, _) = try await session.data(from: url)
            return try decoder.decode(ScheduleResponse.self, from: data)
        } catch is DecodingError {
            throw NetworkError.decodingError
        } catch {
            throw NetworkError.invalidResponse
        }
    }
}

