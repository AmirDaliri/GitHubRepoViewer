//
//  Router.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 19.02.2024.
//

import Foundation

/// Enum representing the organizations whose repositories can be fetched.
enum Organization: String {
    case algorand
    case perawallet
    case algorandFoundation
}

/// Struct representing a query for fetching repositories from a specific organization.
struct RepositoryQuery {
    let organization: Organization
    let page: Int
    let perPage: Int
    let searchTerm: String? = nil
}

/// Enum representing the various network endpoints used within the app.
enum Router {
    // Enum cases for each type of network request, such as fetching a list of repositories for different organizations.
    case fetchRepositories(query: RepositoryQuery)
    case searchRepository(query: RepositoryQuery)
    case fetchRepository(ownerLogin: String, repoName: String)
}


extension Router: Endpoint {
    /// Base URL for the network requests.
    /// Computed property returning the URL object for the base address of the network service.
    var baseUrl: URL {
        return URL(string: "https://api.github.com/")!
    }
    
    /// Path for the specific endpoint.
    /// Determined based on the enum case and appended to the base URL to form the full URL for a request.
    var path: String {
        switch self {
        case .fetchRepositories(let query):
            return "orgs/\(query.organization.rawValue)/repos"
        case .searchRepository:
            return "search/repositories"
        case .fetchRepository(let ownerLogin, let repoName):
            return "repos/\(ownerLogin)/\(repoName)"
        }
    }
    
    /// URLRequest construction for the specific network request.
    /// This computed property constructs and returns a URLRequest object for the given endpoint, combining the base URL with the specific path.
    var urlRequest: URLRequest {
        switch self {
        case .fetchRepositories(let query):
            return makeURLRequest(path: self.path, query: query)
        case .searchRepository(let query):
            return makeURLRequest(path: self.path, query: query)
        case .fetchRepository(let owner, let repoName):
            let path = "repos/\(owner)/\(repoName)"
            return makeURLRequest(path: path)
        }
    }

    private func makeURLRequest(path: String, query: RepositoryQuery? = nil) -> URLRequest {
        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        urlComponents.path += path
        
        if let query = query {
            var queryItems = [URLQueryItem]()
            if let searchTerm = query.searchTerm {
                queryItems.append(URLQueryItem(name: "q", value: searchTerm))
            }
            queryItems.append(URLQueryItem(name: "page", value: "\(query.page)"))
            queryItems.append(URLQueryItem(name: "per_page", value: "\(query.perPage)"))
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            fatalError("Failed to construct URL")
        }
        
        return URLRequest(url: url)
    }

}
