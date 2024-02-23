//
//  RepositoryViewModel.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 23.02.2024.
//

import Combine
import Foundation

/// ViewModel for handling repositories data in the application.
class RepositoryViewModel {
    
    // MARK: - Published Properties
    
    /// Published property holding the repository.
    @Published var repository: Repository
    
    /// Published property representing network error if any occurs.
    @Published var networkError: NetworkError? = nil
    
    /// Published property indicating whether data is being loaded.
    @Published var isLoading: Bool = false
    
    /// Published property indicating whether data is being loaded.
    @Published var readme: String? = nil

    // MARK: - Private Properties
    private var searchSubject = PassthroughSubject<(organization: Organization, searchTerm: String), Never>()
    var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol
    private var currentPage = 0
    private let repositoriesPerPage = 15
    
    // MARK: - Initialization
    
    /// Initializes the RepositoriesViewModel with the given network service.
    /// - Parameter networkService: The network service to use for fetching repositories.
    init(networkService: NetworkServiceProtocol = NetworkManager(), repository: Repository) {
        self.networkService = networkService
        self.repository = repository        
        if let ownerLogin = repository.owner?.login, let repoName = repository.name {
            fetchReadmeObject(for: ownerLogin, repoName: repoName)
        }
    }
    
    /// Fetches the README object for a specific repository identified by its owner and name.
    /// This method initiates a network request to obtain the README object's metadata, including the download URL.
    /// - Parameters:
    ///   - ownerLogin: The login identifier of the repository's owner.
    ///   - repoName: The name of the repository.
    ///
    /// Upon successful retrieval of the README object, this method attempts to fetch the actual README content
    /// from the provided download URL. If an error occurs during the fetch, it updates the `networkError` property
    /// and sets `isLoading` to false to indicate that the loading process has ended.
    func fetchReadmeObject(for ownerLogin: String, repoName: String) {
        isLoading = true
        networkService.fetchReadmeObject(for: ownerLogin, repoName: repoName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.isLoading = false
                    self.networkError = error
                }
            }, receiveValue: { [weak self] readme in
                guard let self = self else { return }
                if let url = readme.downloadURL {
                    self.fetchReadme(from: url)
                }
            })
            .store(in: &cancellables)
    }

    /// Fetches the README content from a given URL as a string.
    /// This method makes a network request to download the content of the README file.
    /// - Parameter url: The URL string from which to fetch the README content.
    ///
    /// The result of this operation updates the `readme` property with the content of the README.
    /// If the operation fails, it updates the `networkError` property with the encountered error
    /// and sets `isLoading` to false. This indicates the loading process has ended and an error occurred.
    ///
    /// - Note: Ideally, this method should be marked as `private` to encapsulate the functionality within the ViewModel.
    /// However, it remains non-private to allow direct testing from the unit test target. Consider using `@testable`
    /// import in your test files and applying conditional compilation flags or dependency injection to maintain
    /// a balance between access control and testability.
    func fetchReadme(from url: String) {
        networkService.fetchReadme(from: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.networkError = error
                }
            }, receiveValue: { [weak self] stringReadme in
                guard let self = self else { return }
                self.readme = stringReadme
            })
            .store(in: &cancellables)
    }

    /// Determines the error message to display for the given network error.
    /// - Parameter error: The network error.
    /// - Returns: The error message.
    func determineErrorMessage(for error: NetworkError) -> String {
        switch error {
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
