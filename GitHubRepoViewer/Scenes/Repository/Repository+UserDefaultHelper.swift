//
//  Repository+UserDefaultHelper.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 24.02.2024.
//

import Foundation

extension UserDefaults {
    /// Key for storing repositories in UserDefaults.
    static let repositoriesKey = "repositoriesKey"
    
    /// Saves a repository to UserDefaults.
    /// - Parameter repository: The repository to save.
    func saveRepository(_ repository: Repository) {
        var repositories = loadRepositories()
        repositories.append(repository)
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(repositories)
            set(encodedData, forKey: UserDefaults.repositoriesKey)
        } catch {
            print("Error encoding repositories: \(error)")
        }
    }
    
    /// Deletes a repository by its ID from UserDefaults.
    /// - Parameter id: The ID of the repository to delete.
    func deleteRepositoryById(_ id: Int) {
        var repositories = loadRepositories()
        repositories.removeAll { $0.id == id }
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(repositories)
            set(encodedData, forKey: UserDefaults.repositoriesKey)
        } catch {
            print("Error encoding repositories: \(error)")
        }
    }
    
    /// Loads repositories from UserDefaults.
    /// - Returns: An array of repositories.
    func loadRepositories() -> [Repository] {
        guard let encodedData = data(forKey: UserDefaults.repositoriesKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let repositories = try decoder.decode([Repository].self, from: encodedData)
            return repositories
        } catch {
            print("Error decoding repositories: \(error)")
            return []
        }
    }
}
