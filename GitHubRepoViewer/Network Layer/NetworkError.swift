//
//  NetworkError.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 19.02.2024.
//

import UIKit

// Enumeration defining various types of network errors.
// This enumeration provides a comprehensive list of errors that could occur during network operations, aiding in debugging and error handling.
enum NetworkError: Error, Equatable {
    // Indicates a scenario where the URL is invalid.
    case invalidURL
    
    // Represents an underlying system-level error, encapsulated within this enum.
    // This could represent various errors thrown by networking APIs.
    case underlyingError(Error)
    
    // Indicates that the server's response was invalid or unexpected.
    case invalidResponse
    
    // Indicates the absence of data in the server's response.
    case noData
    
    // Represents an error in decoding the data into the desired format or model.
    // For instance, when JSON decoding fails due to mismatched data types.
    case decodingError(DecodingError)
    
    // Indicates that the requested resource was not found on the server.
    case notFound
    
    // Represents a server error with a specific status code.
    case serverError(Int)
    
    // Represents unauthorized access to the GitHub API.
    case unauthorizedAccess
    
    // Represents rate limit exceeded error.
    case rateLimitExceeded
    
    // Represents other types of errors, allowing for flexibility and extensibility.
    // The associated String value can provide additional context or message for the error.
    case otherError(String)
    
    // Implementation of the Equatable protocol to allow for comparing network errors.
    static func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        // Simple cases where equality is straightforward.
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.notFound, .notFound),
             (.unauthorizedAccess, .unauthorizedAccess),
             (.rateLimitExceeded, .rateLimitExceeded):
            return true
        // Comparing underlying or decoding errors based on their localized descriptions.
        case (.underlyingError(let error1), .underlyingError(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        // Comparing server errors based on their status code.
        case (.serverError(let code1), .serverError(let code2)):
            return code1 == code2
        // Comparing other errors based on their associated message.
        case (.otherError(let message1), .otherError(let message2)):
            return message1 == message2
        // Comparing decoding errors based on their error descriptions.
        case (.decodingError(let decodingError1), .decodingError(let decodingError2)):
            return "\(decodingError1)" == "\(decodingError2)"
        // For all other cases, return false.
        default:
            return false
        }
    }
}

// MARK: - Alert Error Handler
extension NetworkError {
    // Documented error handling methods
    /// Handles the given network error.
    /// - Parameter error: The network error to handle.
    func handleNetworkError(on viewController: UIViewController) {
        // Handle the error, e.g., show an alert
        let message = determineErrorMessage()
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
    
    /// Determines the error message to display for the given network error.
    /// - Parameter error: The network error.
    /// - Returns: The error message.
    private func determineErrorMessage() -> String {
        switch self {
        case .invalidURL, .invalidResponse, .noData:
            return "A network error occurred. Please try again."
        case .underlyingError(let underlyingError):
            return underlyingError.localizedDescription
        case .decodingError(let decodingError):
            return decodingError.localizedDescription
        case .notFound:
            return "not Found"
        case .otherError(let message):
            return message
        case .serverError(let statusCode):
            return "server error with \(statusCode) status code."
        case .unauthorizedAccess:
            return "unauthorized access to the GitHub API."
        case .rateLimitExceeded:
            return "rate limit exceeded error."
        }
    }
}
