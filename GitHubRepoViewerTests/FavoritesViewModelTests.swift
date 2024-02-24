//
//  FavoritesViewModelTests.swift
//  GitHubRepoViewerTests
//
//  Created by Amir Daliri on 24.02.2024.
//

import XCTest
import Combine
import CoreData
@testable import GitHubRepoViewer // Import app module

class FavoritesViewModelTests: XCTestCase {
    
    var viewModel: FavoritesViewModel!
    var context: NSManagedObjectContext!
    var cancellables: Set<AnyCancellable>! = []
    let appdelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func setUp() {
        super.setUp()
        
        // Create an in-memory Core Data stack for testing
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try! persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
        viewModel = FavoritesViewModel(context: context)
    }
    
    override func tearDown() {
        // Clean up after each test
        super.tearDown()
        viewModel = nil
        context = nil
    }
    
    func testAddRepository() {
        // Given
        let repository = RepositoryDB(context: context)
        
        // When
        viewModel.repositories.append(repository)
        
        // Then
        XCTAssertEqual(viewModel.repositories.count, 1)
    }
    
    func testDeleteRepository() {
        // Given
        let repository = RepositoryDB(context: context)
        repository.name = "test"
        appdelegate.saveContext()
        viewModel = FavoritesViewModel(context: context)
        // When
        viewModel.deleteRepository(at: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertNil(viewModel.repositories[safe: 0], "Repository should be deleted")
    }
}
