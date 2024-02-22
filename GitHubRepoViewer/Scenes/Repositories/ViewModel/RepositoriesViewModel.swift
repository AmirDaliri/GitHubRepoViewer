//
//  RepositoriesViewModel.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 20.02.2024.
//

import Combine
import Foundation

/// ViewModel for handling repositories data in the application.
class RepositoriesViewModel {
    
    // MARK: - Published Properties
    
    /// Published property holding the array of repositories.
    @Published var repositories: [Repository] = []
    
    /// Published property representing network error if any occurs.
    @Published var networkError: NetworkError? = nil
    
    /// Published property indicating whether data is being loaded.
    @Published var isLoading: Bool = false
    
    /// Published property indicating whether to show the empty state.
    @Published var showEmptyState: Bool = false

    // MARK: - Private Properties
    
    private var searchSubject = PassthroughSubject<(organization: Organization, searchTerm: String), Never>()
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol
    private var currentPage = 0
    private let repositoriesPerPage = 15
    
    // MARK: - Initialization
    
    /// Initializes the RepositoriesViewModel with the given network service.
    /// - Parameter networkService: The network service to use for fetching repositories.
    init(networkService: NetworkServiceProtocol = NetworkManager()) {
        self.networkService = networkService
        setupSearchSubscription()
        observeRepositoriesForEmptyState()
    }
    
    // MARK: - Private Methods
    
    /// Observes the repositories array to determine whether to show the empty state.
    private func observeRepositoriesForEmptyState() {
        $repositories
            .map { repositories in
                repositories.isEmpty
            }
            .combineLatest($isLoading)
            .map { isEmpty, isLoading in
                // Show empty state only if not loading and repositories are empty
                !isLoading && isEmpty
            }
            .assign(to: &$showEmptyState)
    }
    
    /// Fetches repositories for the specified organization.
    /// - Parameter organization: The organization whose repositories to fetch.
    func loadRepositories(organization: Organization) {
        guard !isLoading else { return }
        isLoading = true
        currentPage = 1
        repositories.removeAll() // Ensuring we start fresh for a new organization
        
        fetchRepositories(for: organization, page: currentPage)
    }
    
    /// Fetches the next page of repositories for the specified organization.
    /// - Parameter organization: The organization whose repositories to fetch.
    func loadNextPage(organization: Organization) {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1
        
        fetchRepositories(for: organization, page: currentPage)
    }
    
    /// Fetches repositories from the network for the specified organization and page.
    /// - Parameters:
    ///   - organization: The organization whose repositories to fetch.
    ///   - page: The page number to fetch.
    private func fetchRepositories(for organization: Organization, page: Int) {
        networkService.fetchRepositories(query: .init(organization: organization, page: page, perPage: repositoriesPerPage))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.networkError = error
                }
            }, receiveValue: { [weak self] newRepositories in
                Task { [weak self] in
                    guard let strongSelf = self else { return }
                    await strongSelf.processRepositories(newRepositories)
                }
            })
            .store(in: &cancellables)
    }
    
    /// Sets up the subscription for search requests.
    private func setupSearchSubscription() {
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates { prev, next in
                prev.searchTerm == next.searchTerm && prev.organization == next.organization
            }
            .sink { [weak self] (organization, searchTerm) in
                self?.performSearch(organization: organization, searchTerm: searchTerm)
            }
            .store(in: &cancellables)
    }
    
    /// Performs a search with the specified organization and search term.
    /// - Parameters:
    ///   - organization: The organization to search within.
    ///   - searchTerm: The term to search for.
    private func performSearch(organization: Organization, searchTerm: String) {
        guard !searchTerm.isEmpty else {
            self.networkError = .otherError("searchTerm is not exist")
            return
        }
        self.loadSearchRepositories(organization: organization, searchTerm: searchTerm)
    }
    
    /// Initiates a search with the specified organization and search term.
    /// - Parameters:
    ///   - organization: The organization to search within.
    ///   - searchTerm: The term to search for.
    func search(with organization: Organization, searchTerm: String) {
        searchSubject.send((organization, searchTerm))
    }
    
    /// Fetches repositories matching the search term for the specified organization and page.
    /// - Parameters:
    ///   - organization: The organization to search within.
    ///   - searchTerm: The term to search for.
    ///   - page: The page number to fetch.
    private func searchRepositories(for organization: Organization, searchTerm: String, page: Int) {
        networkService.searchRepository(query: .init(organization: organization, page: page, perPage: repositoriesPerPage, searchTerm: searchTerm))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.networkError = error
                }
            }, receiveValue: { [weak self] newRepositories in
                Task { [weak self] in
                    guard let strongSelf = self else { return }
                    await strongSelf.processRepositories(newRepositories.items ?? [])
                }
            })
            .store(in: &cancellables)
    }
    
    /// Loads the first page of search results for the specified organization and search term.
    /// - Parameters:
    ///   - organization: The organization to search within.
    ///   - searchTerm: The term to search for.
    private func loadSearchRepositories(organization: Organization, searchTerm: String) {
        guard !isLoading else { return }
        isLoading = true
        currentPage = 1
        repositories.removeAll() // Ensuring we start fresh for a new organization
        
        searchRepositories(for: organization, searchTerm: searchTerm, page: currentPage)
    }

    /// Loads the next page of search results for the specified organization and search term.
    /// - Parameters:
    ///   - organization: The organization to search within.
    ///   - searchTerm: The term to search for.
    func loadSearchRepositoriesNextPage(organization: Organization, searchTerm: String) {
        guard !isLoading else { return }
        isLoading = true
        currentPage += 1
        
        searchRepositories(for: organization, searchTerm: searchTerm, page: currentPage)
    }
    
    /// Processes the fetched repositories and appends them to the existing repositories array.
    /// - Parameter newRepositories: The repositories to be processed.
    private func processRepositories(_ newRepositories: [Repository]) async {
        // Assuming MainActor is required if you're updating any UI or published properties
        await MainActor.run {
            self.repositories.append(contentsOf: newRepositories)
        }
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
