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
    
    static func getValueFromInt(int: Int) -> Self {
        switch int {
        case 0:
            return .algorand
        case 1:
            return .perawallet
        default:
            return .algorandFoundation
        }
    }
}

/// Struct representing a query for fetching repositories from a specific organization.
struct RepositoryQuery {
    let organization: Organization
    let page: Int
    let perPage: Int
    var searchTerm: String? = nil
    
    init(organization: Organization, page: Int, perPage: Int, searchTerm: String? = nil) {
        self.organization = organization
        self.page = page
        self.perPage = perPage
        self.searchTerm = searchTerm
    }
}

/// Enum representing the various network endpoints used within the app.
enum Router {
    // Enum cases for each type of network request, such as fetching a list of repositories for different organizations.
    case fetchRepositories(query: RepositoryQuery)
    case searchRepository(query: RepositoryQuery)
    case fetchRepository(ownerLogin: String, repoName: String)
    case fetchRedmeObject(ownerLogin: String, repoName: String)
    case fetchRedme(url: String)
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
        case .fetchRedmeObject(ownerLogin: let ownerLogin, repoName: let repoName):
            return "repos/\(ownerLogin)/\(repoName)/readme"
        case .fetchRedme:
            return ""
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
        case .fetchRedmeObject:
            return makeURLRequest(path: self.path)
        case .fetchRedme(let url):
            return makeReadmeURLRequest(urlSting: url)
        }
    }

    private func makeURLRequest(path: String, query: RepositoryQuery? = nil) -> URLRequest {
        var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        urlComponents.path += path
        
        if let query = query {
            var queryItems = [URLQueryItem]()
            if let searchTerm = query.searchTerm {
                queryItems.append(URLQueryItem(name: "q", value: "\(query.organization.rawValue)/\(searchTerm)"))
            }
            queryItems.append(URLQueryItem(name: "page", value: "\(query.page)"))
            queryItems.append(URLQueryItem(name: "per_page", value: "\(query.perPage)"))
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            fatalError("Failed to construct URL")
        }
        
        var request = URLRequest(url: url)
          // Add authentication header here
          // Replace "YOUR_TOKEN" with your actual GitHub personal access token
          request.addValue("token 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", forHTTPHeaderField: "Authorization")
//        ba6bb5cf79147243c2cdfb5f25c91b895f149671
        
        return request
    }

    
    private func makeReadmeURLRequest(urlSting: String) -> URLRequest {
        
        guard let url = URL(string: urlSting) else {
            fatalError("Failed to construct URL")
        }

        var request = URLRequest(url: url)
        // Add authentication header here
        // Replace "YOUR_TOKEN" with your actual GitHub personal access token and use `return request` instad of `return URLRequest(url: url)`
        request.addValue("token YOUR_TOKEN", forHTTPHeaderField: "Authorization")
        
        return URLRequest(url: url)
    }
}
