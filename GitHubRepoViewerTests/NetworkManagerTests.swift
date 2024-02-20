//
//  NetworkManagerTests.swift
//  GitHubRepoViewerTests
//
//  Created by Amir Daliri on 20.02.2024.
//

import XCTest
import Combine
@testable import GitHubRepoViewer

class NetworkManagerTests: XCTestCase {
    
    var mockService: MockNetworkService!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockService = MockNetworkService()
    }
    
    override func tearDown() {
        mockService = nil
        super.tearDown()
    }
    
    func testFetchRepositoriesSuccess() {
        
        //        let errorResponse = ErrorResponse(message: "Not Found")
        //        mockService = MockNetworkService(repositoriesResult: .failure(.notFound), errorResponse: errorResponse)
        
        // Arrange
        let expectedResult = Repositories(/* Add your expected repositories */)
        mockService.repositoriesResult = .success(expectedResult)
        
        // Act
        let expectation = XCTestExpectation(description: "Fetch repositories")
        var receivedRepositories: Repositories?
        var receivedError: NetworkError?
        
        mockService.fetchRepositories(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    receivedError = error
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { repositories in
                receivedRepositories = repositories
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedRepositories, expectedResult)
    }
    
    func testFetchRepositorySuccess() {
        // Arrange
        let expectedRepository = Repository(/* Add your expected repository */)
        mockService.repositoriesResult = .success(Repositories(arrayLiteral: expectedRepository))
        
        // Act
        let expectation = XCTestExpectation(description: "Fetch repository")
        var receivedRepository: Repository?
        var receivedError: NetworkError?
        
        mockService.fetchRepository(ownerLogin: "owner", repoName: "repo")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    receivedError = error
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { repository in
                receivedRepository = repository
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedRepository, expectedRepository)
    }

    func testDecodingFetchRepositoriesSuccess() {
        let expectedResult = Repository(id: 1, name: "Repository1", fullName: "Organization1/Repository1", owner: Owner(login: "Owner1", avatarUrl: "https://example.com/avatar1.png"), htmlUrl: "https://example.com/Repository1", description: "Description1", language: "Swift", stargazersCount: 10, forksCount: 5, openIssuesCount: 2, createdAt: Date(), updatedAt: Date())
                
        mockService.repositoriesResult = .success(Repositories(arrayLiteral: expectedResult))
        
        // Act
        let expectation = XCTestExpectation(description: "Fetch repositories")
        var receivedRepositories: Repositories?
        var receivedError: NetworkError?
        
        mockService.fetchRepositories(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    receivedError = error
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { repositories in
                receivedRepositories = repositories
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedRepositories, Repositories(arrayLiteral: expectedResult))
    }
    
    func testSearchRepositorySuccess() {
        // Arrange
        let expectedRepositories = Repositories(/* Add your expected repositories */)
        mockService.repositoriesResult = .success(expectedRepositories)
        
        // Act
        let expectation = XCTestExpectation(description: "Search repository")
        var receivedRepositories: Repositories?
        var receivedError: NetworkError?
        
        mockService.searchRepository(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    receivedError = error
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { repositories in
                receivedRepositories = repositories
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertNil(receivedError)
        XCTAssertEqual(receivedRepositories, expectedRepositories)
    }

    func testFetchRepositoriesFailure() {
        // Arrange
        mockService.repositoriesResult = .failure(.notFound)
        
        // Act
        let expectation = XCTestExpectation(description: "Fetch repositories")
        var receivedRepositories: Repositories?
        var receivedError: NetworkError?
        
        mockService.fetchRepositories(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    receivedError = error
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { repositories in
                receivedRepositories = repositories
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertNotNil(receivedError)
        XCTAssertNil(receivedRepositories)
    }
    
    func testNetworkLayerHandles404Error() {
        // Arrange
        mockService.repositoriesResult = .failure(.notFound)
        
        // Act
        let expectation = XCTestExpectation(description: "Fetch repositories")
        var receivedError: NetworkError?
        
        mockService.fetchRepositories(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    receivedError = error
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
        
        // Assert
        XCTAssertEqual(receivedError, NetworkError.notFound)
    }

    func testNetworkErrorReturnsMessage() {
        // Arrange
        let notFoundErrorResponse = ErrorResponse(message: "Not Found")
        let otherErrorResponse = ErrorResponse(message: "Some other error message")
        
        // Act
        let notFoundNetworkError = notFoundErrorResponse.toNetworkError()
        let otherNetworkError = otherErrorResponse.toNetworkError()
        
        // Assert
        XCTAssertEqual(notFoundNetworkError, NetworkError.notFound)
        XCTAssertEqual(otherNetworkError, NetworkError.otherError("Some other error message"))
    }

    func testInvalidURLError() {
        // Given: A mock network service that returns an invalid URL error
        let mockNetworkService = MockNetworkService(repositoriesResult: .failure(.invalidURL))
        
        // When: Fetching repositories using the mock network service
        let expectation = XCTestExpectation(description: "Invalid URL error handling")
        var receivedError: NetworkError?
        
        mockNetworkService.fetchRepositories(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    receivedError = error
                    expectation.fulfill()
                default:
                    break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        
        // Then: Assert that the received error is .invalidURL
        XCTAssertEqual(receivedError, .invalidURL)
    }


    func testNetworkLayerErrorHandling() {
        // Given: Setup the mock network service to return a specific error
        let service = MockNetworkService(repositoriesResult: .failure(.invalidResponse))
        let expectation = XCTestExpectation(description: "Network error handling")

        // When: Making a request that should trigger the specified error
        service.fetchRepositories(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    // Then: Assert that the error is correctly identified and handled
                    if error == .invalidResponse {
                        expectation.fulfill()
                    }
                default:
                    break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        // Wait for the expectation to be fulfilled, or timeout
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchRepositoriesFailure2() {
        // Given: Setup the mock network service to return a specific error
        let service = MockNetworkService(repositoriesResult: .failure(.notFound))
        let expectation = XCTestExpectation(description: "Fetch repositories failure")

        // When: Making a request that should result in a failure
        service.fetchRepositories(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    // Then: Assert that the error is correctly identified and handled
                    if error == .notFound {
                        expectation.fulfill()
                    }
                default:
                    break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        // Wait for the expectation to be fulfilled, or timeout
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchRepositoriesSuccessEmptyList() {
        // Given: Setup the mock network service to return an empty list of repositories
        let service = MockNetworkService(repositoriesResult: .success(Repositories([])))
        let expectation = XCTestExpectation(description: "Fetch repositories success with empty list")

        // When: Making a request that should result in success but with an empty list
        service.fetchRepositories(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                default:
                    break
                }
            }, receiveValue: { repositories in
                // Then: Assert that the received list of repositories is empty
                XCTAssertTrue(repositories.isEmpty)
            })
            .store(in: &cancellables)

        // Wait for the expectation to be fulfilled, or timeout
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchRepositoriesNoDataError() {
        // Given: Setup the mock network service to return a no data error
        let service = MockNetworkService(repositoriesResult: .failure(.noData))
        let expectation = XCTestExpectation(description: "Fetch repositories no data error")

        // When: Making a request that should result in a no data error
        service.fetchRepositories(query: RepositoryQuery(organization: .algorand, page: 1, perPage: 10))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    // Then: Assert that the received error is a no data error
                    XCTAssertEqual(error, .noData)
                    expectation.fulfill()
                default:
                    break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        // Wait for the expectation to be fulfilled, or timeout
        wait(for: [expectation], timeout: 1.0)
    }
}
