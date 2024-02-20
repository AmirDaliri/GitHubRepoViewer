//
//  RepositoriesViewModel.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 20.02.2024.
//

import Combine

// ViewModel for handling repositories data in the application.
class RepositoriesViewModel {
    
    // Published properties that will update the view when changed.
    @Published var repositories: Repositories = [] // Array of Repositories objects.
    @Published var networkError: NetworkError? = nil // Stores potential network errors.
    
    // Set of AnyCancellable objects for managing memory and life cycle of network requests.
    var cancellables = Set<AnyCancellable>()
    // The network service responsible for fetching repositories data.
    let networkService: NetworkServiceProtocol

    // Initializer for the view model. It defaults to using NetworkManager for network operations.
    // - Parameter networkService: The network service to use for fetching data. Defaults to NetworkManager.
    init(networkService: NetworkServiceProtocol = NetworkManager()) {
        self.networkService = networkService
    }

    // Function to load repositories from the network.
    func loadRepositories() {
        networkService.fetchRepositories(query: .init(organization: .algorand, page: 0, perPage: 10))
            .sink(receiveCompletion: { [weak self] completion in
                // Handle the completion of the network request.
                switch completion {
                case .failure(let error):
                    // If there's an error, store it in networkError.
                    self?.networkError = error
                case .finished:
                    // No action needed if the network request finishes successfully.
                    break
                }
            }, receiveValue: { [weak self] repositories in
                // Receive the repositories and store them in the repositories property.
                print(repositories)
                self?.repositories = repositories
            })
            // Store the cancellable instance in the set to manage its lifecycle.
            .store(in: &cancellables)
    }
}
