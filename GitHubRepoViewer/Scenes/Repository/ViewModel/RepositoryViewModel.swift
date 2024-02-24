//
//  RepositoryViewModel.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 23.02.2024.
//

import UIKit
import Combine
import CoreData

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

    @Published var isFavorite: Bool = false

    
    // MARK: - Private Properties
    private var searchSubject = PassthroughSubject<(organization: Organization, searchTerm: String), Never>()
    var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol
    private var currentPage = 0
    private let repositoriesPerPage = 15
    private let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
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
    
    /// Updates the favorite button image based on the favorite status of the repository.
    /// - Returns: A UIImage representing the favorite button image.
    func updateFavoriteButtonImage() -> UIImage? {
        let context =  appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<RepositoryDB> = RepositoryDB.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", repository.id ?? 0)

        do {
            let count = try context.count(for: fetchRequest)
            self.isFavorite = count > 0
            return UIImage(systemName: self.isFavorite ? "star.fill" : "star")
        } catch {
            print("Failed to fetch repository from Core Data: \(error)")
            return nil
        }
    }
    
    /// Adds or removes the repository from favorites and updates the favorite status.
    /// - Parameter tabbar: The UITabBar where the badge count needs to be updated.
    func addToFavorite(tabbar: UITabBar?) {
        UserDefaults.standard.saveRepository(repository)
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<RepositoryDB> = RepositoryDB.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", repository.id ?? 0)

        do {
            let results = try context.fetch(fetchRequest)
            if let existingRepository = results.first {
                // The repository is already a favorite, remove it from Core Data
                context.delete(existingRepository)
                appDelegate.saveContext()
                self.isFavorite = false
            } else {
                // The repository is not a favorite yet, add it to Core Data
                let newRepository = RepositoryDB(context: context)
                newRepository.populate(with: repository)
                appDelegate.saveContext()
                self.isFavorite = true
            }
            // Update the badge count
            RepositoryDB.updateFavoritesBadge(tabbar: tabbar)
        } catch {
            print("Could not fetch or delete the item. \(error)")
        }
    }
}
