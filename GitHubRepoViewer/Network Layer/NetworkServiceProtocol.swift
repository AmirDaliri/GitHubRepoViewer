//
//  NetworkServiceProtocol.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 19.02.2024.
//

import Combine

/// Protocol defining the requirements for a network service in the application.
/// This protocol ensures that any network service class conforms to a standard interface for fetching repository data.
protocol NetworkServiceProtocol {
    /// Function to fetch a list of repositories.
    /// - Parameter query: The query parameters for fetching repositories.
    /// - Returns: A publisher that emits a `Repositories` object or a `NetworkError`. The use of `AnyPublisher` allows for flexibility in the underlying implementation, making the protocol adaptable to different networking strategies.
    func fetchRepositories(query: RepositoryQuery) -> AnyPublisher<Repositories, NetworkError>
    
    /// Function to search for repositories.
    /// - Parameter query: The query parameters for searching repositories.
    /// - Returns: A publisher that emits a `Repositories` object or a `NetworkError`. The use of `AnyPublisher` allows for flexibility in the underlying implementation, making the protocol adaptable to different networking strategies.
    func searchRepository(query: RepositoryQuery) -> AnyPublisher<Repositories, NetworkError>
    
    /// Function to fetch details of a specific repository.
    /// - Parameters:
    ///   - ownerLogin: The login name of the repository owner.
    ///   - repoName: The name of the repository.
    /// - Returns: A publisher that emits a `Repository` object or a `NetworkError`. The use of `AnyPublisher` allows for flexibility in the underlying implementation, making the protocol adaptable to different networking strategies.
    func fetchRepository(ownerLogin: String, repoName: String) -> AnyPublisher<Repository, NetworkError>
}
