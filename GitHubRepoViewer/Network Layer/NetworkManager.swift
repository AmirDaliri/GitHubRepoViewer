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
    
    /// Fetches a list of repositories based on the provided query.
    /// - Parameter query: The query to search for repositories.
    /// - Returns: A publisher that emits a `Repositories` object or a `NetworkError`.
    func fetchRepositories(query: RepositoryQuery) -> AnyPublisher<Repositories, NetworkError> {
        let route = Router.fetchRepositories(query: query)
        return request(route)
    }
    
    /// Searches for repositories based on the provided query.
    /// - Parameter query: The query to search for repositories.
    /// - Returns: A publisher that emits a `SearchedRepositories` object or a `NetworkError`.
    func searchRepository(query: RepositoryQuery) -> AnyPublisher<SearchedRepositories, NetworkError> {
        let route = Router.searchRepository(query: query)
        return request(route)
    }
    
    /// Fetches detailed information about a specific repository.
    /// - Parameters:
    ///   - ownerLogin: The login of the owner of the repository.
    ///   - repoName: The name of the repository.
    /// - Returns: A publisher that emits a `Repository` object or a `NetworkError`.
    func fetchRepository(ownerLogin: String, repoName: String) -> AnyPublisher<Repository, NetworkError> {
        let route = Router.fetchRepository(ownerLogin: ownerLogin, repoName: repoName)
        return request(route)
    }
    
    /// Fetches the readme content for a repository owned by the given owner.
    /// - Parameters:
    ///   - owner: The owner of the repository.
    ///   - repository: The name of the repository.
    /// - Returns: A publisher that emits the readme content as a string or a `NetworkError`.
    func fetchReadmeObject(for ownerLogin: String, repoName: String) -> AnyPublisher<Readme, NetworkError> {
        let route = Router.fetchRedmeObject(ownerLogin: ownerLogin, repoName: repoName)
        return request(route)
    }
    
    /// Fetches the readme content from the given URL.
    /// - Parameter url: The URL of the readme content.
    /// - Returns: A publisher that emits the readme content as a string or a `NetworkError`.
    func fetchReadme(from urlString: String) -> AnyPublisher<String, NetworkError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                // Check for HTTP status code 200, otherwise decode the error response.
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: output.data)
                    throw errorResponse.toNetworkError()
                }
                guard let string = String(data: output.data, encoding: .utf8) else {
                    throw NetworkError.decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unable to decode README content as string")))
                }
                return string
            }
            .mapError { error in
                (error as? NetworkError) ?? NetworkError.underlyingError(error)
            }
            .eraseToAnyPublisher()
    }
}


extension NetworkManager {
    /// Performs a network request based on the provided route.
    /// - Parameter route: The route defining the URL request to be performed.
    /// - Returns: A publisher that emits a decoded object of type `T` or a `NetworkError`.
    private func request<T: Decodable>(_ route: Router) -> AnyPublisher<T, NetworkError> {
        // Construct URLRequest based on the provided route.
        let request = route.urlRequest
        
        // Perform the network request using URLSession dataTaskPublisher.
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
                // Decode the data into the specified type `T`.
                
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
