//
//  RepositoryViewModelTests.swift
//  GitHubRepoViewerTests
//
//  Created by Amir Daliri on 23.02.2024.
//

import XCTest
import Combine
@testable import GitHubRepoViewer

class RepositoryViewModelTests: XCTestCase {
    
    var viewModel: RepositoryViewModel!
    var mockNetworkService: MockNetworkService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        // Providing a default result for initialization
        let sampleRepository = Repository(id: 2, name: "Repo 2", fullName: "Organization/Repo 2", owner: Owner(login: "User", avatarUrl: ""), htmlUrl: "", description: nil, language: "Swift", stargazersCount: 0, forksCount: 0, openIssuesCount: 0, createdAt: Date(), updatedAt: Date())
        let readmeObjectResponse: Result<Readme, NetworkError> = .success(Readme(downloadURL: "https://github.com/README.md"))
        let readmeResult: Result<String, NetworkError> = .success("https://github.com/README.md")
        
        let defaultResult: Result<Repositories, NetworkError> = .success([sampleRepository])
        mockNetworkService = MockNetworkService(repositoriesResult: defaultResult, readmeObjectResponse: readmeObjectResponse, readmeResponse: readmeResult)

        // Ensure that MockNetworkService conforms to NetworkServiceProtocol
        viewModel = RepositoryViewModel(networkService: mockNetworkService, repository: sampleRepository)
        viewModel.repository = sampleRepository
        
        cancellables = []

    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchReadmeObjectSuccess() {
        // Setup the expectation for the asynchronous fetch operation
        let loadExpectation = XCTestExpectation(description: "Load repositories")

        // Observe changes to the viewModel's `readme` property to capture the fetch result
        viewModel.$readme
            .dropFirst() // Skip the initial value if needed
            .sink { readme in
                if (readme != nil) { // Fulfill the expectation when README content is received
                    loadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Trigger the fetching of the README content
        viewModel.fetchReadmeObject(for: "test", repoName: "test")

        // Wait for the expectation to be fulfilled
        wait(for: [loadExpectation], timeout: 5.0)

        // Assert that the fetched README content matches the expected value
        XCTAssertEqual(viewModel.readme, "https://github.com/README.md", "Expected readme")
    }
    
    func testFetchReadmeObjectFailureUpdatesNetworkError() {
        let expectation = XCTestExpectation(description: "Expecting networkError to be updated upon fetch failure")
        // Configure your mock network service to simulate a failure
        mockNetworkService.readmeObjectResponse = .failure(.notFound)

        viewModel.$networkError
            .dropFirst() // Ignore the initial value
            .sink { error in
                if let error = error {
                    XCTAssertEqual(error, .notFound, "Expected to receive a 'notFound' error")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Trigger the operation that should result in a network failure
        viewModel.fetchReadmeObject(for: "test", repoName: "test")

        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchReadmeSuccess() {
        // Setup the expectation for the asynchronous fetch operation
        let loadExpectation = XCTestExpectation(description: "Load repositories")

        // Observe changes to the viewModel's `readme` property to capture the fetch result
        viewModel.$readme
            .dropFirst() // Skip the initial value if needed
            .sink { repositories in
                if (repositories != nil) { // Fulfill the expectation when README content is received
                    loadExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Trigger the fetching of the README content
        viewModel.fetchReadme(from: "https://github.com/README.md")

        // Wait for the expectation to be fulfilled
        wait(for: [loadExpectation], timeout: 5.0)

        // Assert that the fetched README content matches the expected value
        XCTAssertEqual(viewModel.readme, "https://github.com/README.md", "Expected readme")
    }
    
    func testFetchReadmeFailureUpdatesNetworkError() {
        let expectation = XCTestExpectation(description: "Expecting networkError to be updated upon fetch failure")
        // Configure your mock network service to simulate a failure
        mockNetworkService.readmeResponse = .failure(.notFound)

        viewModel.$networkError
            .dropFirst() // Ignore the initial value
            .sink { error in
                if let error = error {
                    XCTAssertEqual(error, .notFound, "Expected to receive a 'notFound' error")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Trigger the operation that should result in a network failure
        viewModel.fetchReadme(from: "https://example.com/nonexistent")

        wait(for: [expectation], timeout: 5.0)
    }

    func testFetchReadmeFailure() {
        // Setup expectation for failure state, such as expecting readme to be nil
        let expectation = XCTestExpectation(description: "Fetch README fails and sets readme to nil/default state")
        
        // Setup ViewModel and mock service to simulate failure...
        
        viewModel.$readme
            .sink { readmeContent in
                if readmeContent == nil { // Or some default value indicating failure
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act: Trigger the fetch operation that is expected to fail
        
        wait(for: [expectation], timeout: 5.0)
        
        // Assert: Verify the readme content is nil or some default state
        XCTAssertNil(viewModel.readme, "Expected readme to be nil or default state after failure")
    }
}
