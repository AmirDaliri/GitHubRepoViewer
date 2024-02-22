//
//  NetworkManager.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 19.02.2024.
//

import Foundation
import Combine

/// `NetworkManager` is responsible for managing network requests and data fetching.
class NetworkManager: NetworkServiceProtocol {
    
    /// Fetches a list of Repository from the server.
    /// - Returns: A publisher that emits a `Repositories` object or a `NetworkError`.
    func fetchRepositories(query: RepositoryQuery) -> AnyPublisher<Repositories, NetworkError> {
        let request = Router.fetchRepositories(query: query).urlRequest
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                // Check for HTTP status code 200, otherwise decode the error response.
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: output.data)
                    throw errorResponse.toNetworkError()
                }
                return output.data
            }
            .mapError { error in
                // Convert any thrown errors to `NetworkError`.
                (error as? NetworkError) ?? NetworkError.underlyingError(error)
            }
            .flatMap(maxPublishers: .max(1)) { data in
                // Decode the data into a `Repositories` object.
                self.decode(data)
            }
            .eraseToAnyPublisher()
    }
    
    func searchRepository(query: RepositoryQuery) -> AnyPublisher<SearchedRepositories, NetworkError> {
        let request = Router.searchRepository(query: query).urlRequest
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                // Check for HTTP status code 200, otherwise decode the error response.
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: output.data)
                    throw errorResponse.toNetworkError()
                }
                return output.data
            }
            .mapError { error in
                // Convert any thrown errors to `NetworkError`.
                (error as? NetworkError) ?? NetworkError.underlyingError(error)
            }
            .flatMap(maxPublishers: .max(1)) { data in
                // Decode the data into a `Repositories` object.
                self.decode(data)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRepository(ownerLogin: String, repoName: String) -> AnyPublisher<Repository, NetworkError> {
        let request = Router.fetchRepository(ownerLogin: ownerLogin, repoName: repoName).urlRequest

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                // Check for HTTP status code 200, otherwise decode the error response.
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: output.data)
                    throw errorResponse.toNetworkError()
                }
                return output.data
            }
            .mapError { error in
                // Convert any thrown errors to `NetworkError`.
                (error as? NetworkError) ?? NetworkError.underlyingError(error)
            }
            .flatMap(maxPublishers: .max(1)) { data in
                // Decode the data into a `Repositories` object.
                self.decode(data)
            }
            .eraseToAnyPublisher()
    }
    
    /// Decodes a JSON response into a specified `Decodable` type.
    /// - Parameter data: The data to decode.
    /// - Returns: A publisher that emits a decoded object or a `NetworkError`.
    private func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, NetworkError> {
        Just(data)
            .decode(type: T.self, decoder: newJSONDecoder())
            .mapError { error -> NetworkError in
                if let decodingError = error as? DecodingError {
                    return NetworkError.decodingError(decodingError)
                } else {
                    return NetworkError.underlyingError(error)
                }
            }
            .eraseToAnyPublisher()
    }

}
