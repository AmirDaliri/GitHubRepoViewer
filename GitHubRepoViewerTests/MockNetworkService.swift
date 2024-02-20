//
//  MockNetworkService.swift
//  GitHubRepoViewerTests
//
//  Created by Amir Daliri on 20.02.2024.
//

import Combine
import Foundation
@testable import GitHubRepoViewer

/**
 A mock implementation of the `NetworkServiceProtocol` for testing purposes.
 
 This class provides a mock network service that can be used for testing network-related functionality in the application. It allows you to simulate different network responses and errors to ensure proper handling by other components.
 
 ## Usage Example:
 ```swift
 // Create an instance of the `MockNetworkService` with custom result values.
 let mockService = MockNetworkService(
 repositoriesResult: .success(Repositories(arrayLiteral: Repository(id: 222016060, name: "tealviewer", fullName: "algorand/tealviewer", owner: Owner(login: "algorand", avatarUrl: "https://avatars.githubusercontent.com/u/23182699?v=4"), htmlUrl: "https://github.com/algorand/tealviewer", description: nil, language: "JavaScript", stargazersCount: 11, forksCount: 7, openIssuesCount: 1, createdAt: "2019-11-15T22:52:45Z", updatedAt: "2023-05-31T05:49:41Z"))),
 errorResponse: nil
 )
 
 // Use the `mockService` for testing network-related functionality.
 */
class MockNetworkService: NetworkServiceProtocol {
    // Properties to customize the mock responses
    var repositoriesResult: Result<Repositories, NetworkError>
    var errorResponse: ErrorResponse?
    
    /**
     Initializes the `MockNetworkService` with custom result values.

     - Parameters:
        - repositoriesResult: The result for fetching a list of repositories.
        - errorResponse: An optional error response to simulate network errors.
     */
    init(
        repositoriesResult: Result<Repositories, NetworkError> = .success(Repositories.init()),
        errorResponse: ErrorResponse? = nil
    ) {
        self.repositoriesResult = repositoriesResult
        self.errorResponse = errorResponse
    }

    /**
     Simulates fetching a list of repositories.

     - Returns: A publisher that emits the result of fetching repositories.
     */
    func fetchRepositories(query: RepositoryQuery) -> AnyPublisher<Repositories, NetworkError> {
        // Implementation simulating the network request and response.
        return Future<Repositories, NetworkError> { promise in
            if let errorResponse = self.errorResponse {
                promise(.failure(errorResponse.toNetworkError()))
            } else {
                switch self.repositoriesResult {
                case .success(let repositories):
                    promise(.success(repositories))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /**
     Simulates searching for a repository.

     - Returns: A publisher that emits the result of searching for a repository.
     */
    func searchRepository(query: RepositoryQuery) -> AnyPublisher<Repositories, NetworkError> {
        // Implementation simulating the network request and response.
        // For simplicity, let's return the same result as fetchRepositories.
        return fetchRepositories(query: query)
    }

    /**
     Simulates fetching a single repository.

     - Returns: A publisher that emits the result of fetching a single repository.
     */
    func fetchRepository(ownerLogin: String, repoName: String) -> AnyPublisher<Repository, NetworkError> {
        // Implementation simulating the network request and response.
        // For simplicity, let's return a single repository wrapped in a success result.
        let repository = Repository.init()
            return Just(repository)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Init for test Methods
extension Repository {
    init(id: Int, name: String, fullName: String, owner: Owner, htmlUrl: String, description: String?, language: String?, stargazersCount: Int, forksCount: Int, openIssuesCount: Int, createdAt: Date, updatedAt: Date) {
        self.init()
        self.id = id
        self.name = name
        self.fullName = fullName
        self.owner = owner
        self.htmlURL = htmlUrl
        self.description = description
        self.language = language
        self.stargazersCount = stargazersCount
        self.forksCount = forksCount
        self.openIssuesCount = openIssuesCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Owner {
    init(login: String, avatarUrl: String) {
        self.init()
        self.login = login
        self.avatarURL = avatarUrl
    }
}
