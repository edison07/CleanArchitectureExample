//
//  Created by Edison on 2025/4/25.
//

import Foundation
@testable import CleanArchitectureExample

final class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockError: Error?
    var lastRequestedURL: URL?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        lastRequestedURL = url
        
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw URLError(.badServerResponse)
        }
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data, response)
    }
}
