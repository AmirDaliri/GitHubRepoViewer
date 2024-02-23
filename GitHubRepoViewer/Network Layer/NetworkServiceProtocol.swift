//
//  NetworkServiceProtocol.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 19.02.2024.
//

import Combine
import Foundation

/// Protocol defining the requirements for a network service in the application.
/// This protocol ensures that any network service class conforms to a standard interface for fetching repository data.
protocol NetworkServiceProtocol {
    /// Function to fetch a list of repositories.
    /// - Parameter query: The query parameters for fetching repositories.
    /// - Returns: A publisher that emits a `Repositories` object or a `NetworkError`. The use of `AnyPublisher` allows for flexibility in the underlying implementation, making the protocol adaptable to different networking strategies.
    func fetchRepositories(query: RepositoryQuery) -> AnyPublisher<Repositories, NetworkError>
    
    /// Function to search for repositories.
    /// - Parameter query: The query parameters for searching repositories.
    /// - Returns: A publisher that emits a `Repositories` object or a `NetworkError`. The use of `AnyPublisher` allows for flexibility in the underlying implementation, making the protocol adaptable to different networking strategies.
    func searchRepository(query: RepositoryQuery) -> AnyPublisher<SearchedRepositories, NetworkError>
    
    /// Function to fetch details of a specific repository.
    /// - Parameters:
    ///   - ownerLogin: The login name of the repository owner.
    ///   - repoName: The name of the repository.
    /// - Returns: A publisher that emits a `Repository` object or a `NetworkError`. The use of `AnyPublisher` allows for flexibility in the underlying implementation, making the protocol adaptable to different networking strategies.
    func fetchRepository(ownerLogin: String, repoName: String) -> AnyPublisher<Repository, NetworkError>
    
    /// Function to fetch the raw README object for a given repository.
    /// - Parameters:
    ///   - owner: The owner of the repository.
    ///   - repository: The repository name.
    /// - Returns: A publisher that emits the raw README content as a `String` or a `NetworkError`.
    func fetchReadmeObject(for ownerLogin: String, repoName: String) -> AnyPublisher<Readme, NetworkError>
    
    /// Function to fetch raw Markdown from a download URL.
    /// - Parameter url: The URL to fetch the content from.
    /// - Returns: A publisher that emits a `String` object (raw content) or a `NetworkError`.
    func fetchReadme(from urlString: String) -> AnyPublisher<String, NetworkError>
}


/// Protocol defining the requirements for a network service in the application.
/// Utilizing Swift's async/await pattern, this protocol ensures a more straightforward, readable, and maintainable way to handle network operations.
///
/// Usage:
/// 1. Define a Query: Use `RepositoryQuery` for operations like fetching or searching repositories.
/// 2. Call the Function: Invoke the desired async function on an object conforming to `NetworkServiceProtocol`. Use `await` within an async context.
/// 3. Handle Errors: Since these functions can throw `NetworkError`, use a do-catch block for error handling.
/// 4. Access the Data: Directly use the returned data (e.g., `Repositories`, `Repository`, `String` for README content) upon a successful call.
///
/// Benefits:
/// - Simplified Syntax: Async/await offers a cleaner syntax compared to Combine's publishers and subscribers.
/// - Built-in Error Handling: Integrates with Swift's error handling, simplifying error management.
/// - Improved Readability: The async/await pattern makes asynchronous code easier to read and maintain.
/// - Better Performance and Safety: Adheres to Swift's concurrency model, preventing common concurrency issues.
/// - Seamless Integration with Swift Concurrency: Enhances resource use and app performance with Swift's concurrency features.
/*
 protocol NetworkServiceProtocol {
     /// Async/Await Version:
     /// - This version of `fetchRepositories` uses Swift's async/await pattern. It's designed to fetch a list of repositories based on the provided query parameters asynchronously.
     /// - Usage involves calling this function within an async context and awaiting its result, which simplifies reading and writing asynchronous code.
     /// - Error handling is integrated into the function signature, allowing for the use of `throw` to indicate errors. This makes it straightforward to use try-catch blocks for error handling.
     /// - The function directly returns the `Repositories` object upon success, or throws a `NetworkError` in case of failure.
     /// - This approach is recommended for new projects or when working within Swift's concurrency model, as it provides cleaner syntax and better integration with Swift's error handling.
     func fetchRepositories(query: RepositoryQuery) async throws -> Repositories
     
     /// Combine Version:
     /// - This version of `fetchRepositories` uses the Combine framework. It returns a publisher that emits a `Repositories` object or a `NetworkError`.
     /// - Subscribers subscribe to the publisher to receive updates. This model is based on the reactive programming paradigm, which can handle complex asynchronous workflows and multiple data streams.
     /// - Error handling is managed through the publisher's output, which can emit a `NetworkError`. Subscribers need to implement error handling as part of their subscription logic.
     /// - The use of `AnyPublisher` ensures flexibility in the underlying implementation and allows for the composition of multiple publishers.
     /// - This approach is well-suited for apps that already use Combine extensively or require complex data processing and asynchronous operations management.
     func fetchRepositories(query: RepositoryQuery) -> AnyPublisher<Repositories, NetworkError>
 }
 
 These comments explain the key differences between using the async/await pattern and the Combine framework for network requests in Swift:
 
 * Syntax and Readability: The async/await pattern tends to have a more straightforward and readable syntax, making the code easier to understand at a glance.
 * Error Handling: Async/await integrates seamlessly with Swift's try-catch error handling, whereas Combine requires handling errors through the subscription to publishers.
 * Return Type: The async/await function directly returns the result or throws an error, while the Combine version returns a publisher, which subscribers must observe to receive updates or errors.
 * Use Cases: Async/await is generally simpler for straightforward asynchronous tasks, especially when working within Swift's concurrency model. In contrast, Combine is powerful for more complex, reactive programming scenarios, where handling multiple asynchronous data streams and their transformations is required.
 */

protocol NetworkServiceProtocol_Async {
    /// Function to fetch a list of repositories.
    /// - Parameter query: The query parameters for fetching repositories.
    /// - Returns: The `Repositories` object.
    /// - Throws: `NetworkError` on failure.
    func fetchRepositories(query: RepositoryQuery) async throws -> Repositories
    
    /// Function to search for repositories.
    /// - Parameter query: The query parameters for searching repositories.
    /// - Returns: The `SearchedRepositories` object.
    /// - Throws: `NetworkError` on failure.
    func searchRepository(query: RepositoryQuery) async throws -> SearchedRepositories
    
    /// Function to fetch details of a specific repository.
    /// - Parameters:
    ///   - ownerLogin: The login name of the repository owner.
    ///   - repoName: The name of the repository.
    /// - Returns: The `Repository` object.
    /// - Throws: `NetworkError` on failure.
    func fetchRepository(ownerLogin: String, repoName: String) async throws -> Repository
    
    /// Function to fetch the raw README object for a given repository.
    /// - Parameters:
    ///   - owner: The owner of the repository.
    ///   - repository: The repository name.
    /// - Returns: The raw README content as a `String`.
    /// - Throws: `NetworkError` on failure.
    func fetchReadmeObject(for owner: String, repository: String) async throws -> Readme
    
    /// Function to fetch raw Markdown from a download URL.
    /// - Parameter url: The URL to fetch the content from.
    /// - Returns: The raw content as a `String`.
    /// - Throws: `NetworkError` on failure.
    func fetchReadme(from url: String) async throws -> String
}
