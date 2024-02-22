//
//  RepositoriesViewModelTests.swift
//  GitHubRepoViewerTests
//
//  Created by Amir Daliri on 22.02.2024.
//

import XCTest
import Combine
@testable import GitHubRepoViewer

class RepositoriesViewModelTests: XCTestCase {
    
    var viewModel: RepositoriesViewModel!
    var mockNetworkService: MockNetworkService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        // Providing a default result for initialization
        
        let repo: Repository = .init(id: 2, name: "Repo 2", fullName: "Organization/Repo 2")        
        let defaultResult: Result<Repositories, NetworkError> = .success([repo])
        mockNetworkService = MockNetworkService(repositoriesResult: defaultResult)

        // Ensure that MockNetworkService conforms to NetworkServiceProtocol
        viewModel = RepositoriesViewModel(networkService: mockNetworkService)
        viewModel.repositories = [repo]
        
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        cancellables = nil
        super.tearDown()
    }

    
    func testLoadRepositories_Success() {
        // 1. Setup an expectation
        let loadExpectation = XCTestExpectation(description: "Load repositories")

        // 2. Observe the viewModel's repositories to fulfill the expectation
        viewModel.$repositories
            .dropFirst() // Skip the initial value if needed
            .sink { repositories in
                if !repositories.isEmpty { // Only proceed if repositories have been loaded
                    loadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Trigger the loading of repositories
        viewModel.loadRepositories(organization: .algorand)

        // 3. Wait for the expectation
        wait(for: [loadExpectation], timeout: 5.0)

        // Now, perform your assertions
        XCTAssertEqual(viewModel.repositories.count, 1, "Expected one repository to be loaded")
        XCTAssertEqual(viewModel.repositories.first?.id, 2)
        XCTAssertEqual(viewModel.repositories.first?.name, "Repo 2")
        XCTAssertEqual(viewModel.repositories.first?.fullName, "Organization/Repo 2")
    }

    
    
    func testLoadNextPage_AppendsRepositories() {
        let expectation = XCTestExpectation(description: "Load next page of repositories")
        
        // Setup repository for initial and next page load
        let repo1: Repository = .init(id: 1, name: "Repo 1", fullName: "Organization/Repo 1")
        let repo2: Repository = .init(id: 2, name: "Repo 2", fullName: "Organization/Repo 2")
        
        // Configure mock service to return the first repo, then change to return both repos to simulate a next page load
        let mockService = MockNetworkService(repositoriesResult: .success([repo1]))
        let viewModel = RepositoriesViewModel(networkService: mockService)
        
        var isFirstLoad = true
        
        viewModel.$repositories.sink { repositories in
            if isFirstLoad {
                isFirstLoad = false // After first load, prepare for next page simulation
                // Change mock response for next call to simulate loading next page
                mockService.repositoriesResult = .success([repo1, repo2])
                viewModel.loadNextPage(organization: .algorand)
            } else {
                // This block is expected to run after the next page is loaded
                XCTAssertEqual(repositories.count, 2, "Should have 2 repositories after loading next page.")
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        // Trigger the first load
        viewModel.loadRepositories(organization: .algorand)
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testNetworkError_UpdatesProperty() {
        let expectation = XCTestExpectation(description: "Network error updates property")
        let mockService = MockNetworkService()
        mockService.errorResponse = ErrorResponse(message: "Not Found")
        let viewModel = RepositoriesViewModel(networkService: mockService)

        viewModel.$networkError.dropFirst().sink { error in
            XCTAssertNotNil(error, "Network error should be updated.")
            expectation.fulfill()
        }.store(in: &cancellables)

        viewModel.loadRepositories(organization: .algorand)

        wait(for: [expectation], timeout: 5.0)
    }

    func testShowEmptyState_WhenNoRepositories() {
        let expectation = XCTestExpectation(description: "Show empty state when no repositories")
        let mockService = MockNetworkService()
        mockService.repositoriesResult = .success([]) // No repositories returned
        let viewModel = RepositoriesViewModel(networkService: mockService)

        // Listen for changes right away to catch the initial update
        viewModel.$showEmptyState.sink { showEmptyState in
            XCTAssertTrue(showEmptyState, "Should show empty state when no repositories are available.")
            expectation.fulfill()
        }.store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

    func testShowEmptyState_WhenNoRepositories2() {
        // 1. Setup expectation for the async operation to complete.
        let expectation = XCTestExpectation(description: "Show empty state when no repositories")

        // 2. Initialize your mock service and view model as before.
        let mockService = MockNetworkService()
        mockService.repositoriesResult = .success([]) // No repositories returned
        let viewModel = RepositoriesViewModel(networkService: mockService)

        // 3. Subscribe to the `showEmptyState` property updates.
        var didReceiveUpdate = false
        viewModel.$showEmptyState.sink { showEmptyState in
            // Ensure this block is only executed after loadRepositories is called
            if didReceiveUpdate {
                XCTAssertTrue(showEmptyState, "Should show empty state when no repositories are available.")
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        // 4. Trigger loading of repositories, which should update `showEmptyState`.
        viewModel.loadRepositories(organization: .algorand)
        didReceiveUpdate = true

        // 5. Wait for the expectation to be fulfilled.
        wait(for: [expectation], timeout: 5.0)
    }


    func testSearch_FilterRepositories() {
        let expectation = XCTestExpectation(description: "Search filters repositories")
        let mockService = MockNetworkService()
        var repo = Repository(id: 1, name: "Match", fullName: "Organization/Match")

        // Set up the mock service to return a specific repository for a search operation
        mockService.searchRepositoryResult = .success(SearchedRepositories(items: [repo]))

        let viewModel = RepositoriesViewModel(networkService: mockService)

        viewModel.$repositories.sink { repositories in
            if !repositories.isEmpty {
                XCTAssertEqual(repositories.count, 1, "Should only have repositories matching search criteria.")
                XCTAssertEqual(repositories.first?.name, "Match", "Repository should match search criteria.")
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        // Trigger the search
        viewModel.search(with: .algorand, searchTerm: "Match")

        wait(for: [expectation], timeout: 5.0)
    }


}
