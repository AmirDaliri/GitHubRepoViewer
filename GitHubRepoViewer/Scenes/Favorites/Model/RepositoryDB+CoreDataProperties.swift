//
//  RepositoryDB+CoreDataProperties.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 24.02.2024.
//
//

import UIKit
import CoreData

extension RepositoryDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RepositoryDB> {
        return NSFetchRequest<RepositoryDB>(entityName: "RepositoryDB")
    }

    @NSManaged public var descriptionValue: String?
    @NSManaged public var forkCount: Int16
    @NSManaged public var id: Int64
    @NSManaged public var language: String?
    @NSManaged public var name: String?
    @NSManaged public var ownerAvatar: String?
    @NSManaged public var ownerName: String?
    @NSManaged public var starCount: Int16
    @NSManaged public var topics: String?
    @NSManaged public var watchCount: Int16
}

extension RepositoryDB : Identifiable {
    func toRepository() -> Repository {
        let owner = Owner(login: ownerName, avatarURL: ownerAvatar)
        let topicsValue = topics?.split(separator: ",").map(String.init)
        return Repository(
            id: Int(self.id),
            name: name,
            owner: owner,
            description: descriptionValue,
            stargazersCount: Int(starCount),
            watchersCount: Int(watchCount), 
            language: language,
            forksCount: Int(self.forkCount),
            topics: topicsValue
        )
    }
    
    func populate(with repository: Repository) {
        self.id = Int64(repository.id ?? 0)
        self.descriptionValue = repository.description
        self.forkCount = Int16(repository.forksCount ?? 0)
        self.language = repository.language
        self.name = repository.name
        self.ownerAvatar = repository.owner?.avatarURL
        self.ownerName = repository.owner?.login
        self.starCount = Int16(repository.stargazersCount ?? 0)
        self.topics = (repository.topics ?? []).joined(separator: ", ")
        self.watchCount = Int16(repository.watchersCount ?? 0)
    }
    
    static func updateFavoritesBadge(tabbar: UITabBar?) {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {return}
        
        let fetchRequest: NSFetchRequest<RepositoryDB> = RepositoryDB.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            
            // Assuming you have a reference to your tab bar controller
            if let tabBarItem = tabbar?.items?[1] {
                // Set the badge value
                tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
            }
        } catch {
            print("Error fetching favorite count: \(error)")
        }
    }

}
