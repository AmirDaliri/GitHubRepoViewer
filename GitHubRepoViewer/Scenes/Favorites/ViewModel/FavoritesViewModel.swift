//
//  FavoritesViewModel.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 24.02.2024.
//

import UIKit
import CoreData
import Combine

/// View model responsible for managing favorite repositories.
class FavoritesViewModel: NSObject {
    
    /// Published property holding the array of favorite repositories.
    @Published var repositories: [RepositoryDB] = []
    
    /// Publisher for the array of favorite repositories.
    var repositoriesPublisher: Published<[RepositoryDB]>.Publisher { $repositories }
    
    /// PassthroughSubject used to publish whether the list of repositories is empty or not.
    private var isEmptySubject = PassthroughSubject<Bool, Never>()
    
    /// Publisher for determining if the list of repositories is empty.
    var isEmptyPublisher: AnyPublisher<Bool, Never> { isEmptySubject.eraseToAnyPublisher() }
 
    /// PassthroughSubject for notifying changes before content changes.
    @Published var contentWillChangePublisher = PassthroughSubject<Void, Never>()
    
    /// PassthroughSubject for notifying changes after content changes.
    @Published var contentDidChangePublisher = PassthroughSubject<Void, Never>()
    
    /// PassthroughSubject for notifying insertions in the list of repositories.
    @Published var insertPublisher = PassthroughSubject<IndexPath, Never>()
    
    /// PassthroughSubject for notifying deletions in the list of repositories.
    @Published var deletePublisher = PassthroughSubject<IndexPath, Never>()
    
    /// PassthroughSubject for notifying updates in the list of repositories.
    @Published var updatePublisher = PassthroughSubject<IndexPath, Never>()
    
    /// PassthroughSubject for notifying movements in the list of repositories.
    @Published var movePublisher = PassthroughSubject<(IndexPath, IndexPath), Never>()

    /// The managed object context for Core Data operations.
    private var context: NSManagedObjectContext
    
    /// The fetched results controller for managing the fetch request results.
    private var fetchResultsController: NSFetchedResultsController<RepositoryDB>!
    
    /// Set of cancellables to manage Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the view model with the given managed object context.
    /// - Parameter context: The managed object context to use.
    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
        super.init()
        setupFetchResultsController()
    }
    
    /// Updates the state indicating whether the list of repositories is empty.
    private func updateIsEmpty() {
        let isEmpty = repositories.isEmpty
        isEmptySubject.send(isEmpty)
    }
    
    /// Sets up the fetched results controller to fetch favorite repositories from Core Data.
    private func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<RepositoryDB> = RepositoryDB.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
            repositories = fetchResultsController.fetchedObjects ?? []
        } catch {
            print("Failed to fetch entities: \(error)")
        }
        updateIsEmpty()
    }
    
    /// Checks if the list of repositories is empty and updates the state accordingly.
    func checkEmptyState() {
        updateIsEmpty()
    }
    
    /// Deletes the repository at the specified index path from Core Data.
    /// - Parameter indexPath: The index path of the repository to delete.
    func deleteRepository(at indexPath: IndexPath) {
        guard repositories.indices.contains(indexPath.row) else { return }
        let objectToDelete = fetchResultsController.object(at: indexPath)
        context.delete(objectToDelete)
        
        do {
            try context.save()
            setupFetchResultsController()
        } catch {
            print("Failed to delete repository: \(error)")
        }
    }
    
    /// Fetches a repository object by its ID from Core Data.
    /// - Parameter id: The ID of the repository to fetch.
    /// - Returns: The fetched repository object, or nil if not found.
    private func fetchRepositoryObjectById(id: Int64) -> NSManagedObject? {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "RepositoryEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching repository with ID \(id): \(error)")
            return nil
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension FavoritesViewModel: NSFetchedResultsControllerDelegate {
    
    /// Notifies the delegate that the fetched results controller is about to start processing of one or more changes.
    /// - Parameter controller: The fetched results controller that will change its content.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        contentWillChangePublisher.send()
    }
    
    /// Notifies the delegate that the fetched results controller has completed processing of one or more changes.
    /// - Parameter controller: The fetched results controller that changed its content.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        contentDidChangePublisher.send()
    }
    
    /// Notifies the delegate of changes to the content or structure of the objects managed by the fetched results controller.
    /// - Parameters:
    ///   - controller: The fetched results controller that initiated the change.
    ///   - anObject: The object in the fetched results controller that changed.
    ///   - indexPath: The index path of the changed object (for insertions, deletions, and updates), or nil if not applicable.
    ///   - type: The type of change that occurred.
    ///   - newIndexPath: The destination index path for the object for move operations, or nil if not applicable.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                repositories.insert(anObject as! RepositoryDB, at: newIndexPath.row)
                insertPublisher.send(newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                repositories.remove(at: indexPath.row)
                deletePublisher.send(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                repositories[indexPath.row] = anObject as! RepositoryDB
                updatePublisher.send(indexPath)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                let movedObject = repositories.remove(at: indexPath.row)
                repositories.insert(movedObject, at: newIndexPath.row)
                movePublisher.send((indexPath, newIndexPath))
            }
        @unknown default:
            fatalError("Unknown NSFetchedResultsChangeType")
        }
        updateIsEmpty()
    }
}
