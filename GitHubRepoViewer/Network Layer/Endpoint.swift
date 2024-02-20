//
//  Endpoint.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 19.02.2024.
//

import Foundation

// Protocol defining the requirements for a network endpoint.
// Any type conforming to this protocol will provide the necessary components to construct a network request.
protocol Endpoint {
    // Base URL for the network requests.
    // This property should return the base URL common to all endpoints.
    var baseUrl: URL { get }

    // Path specific to the endpoint.
    // This string represents the path component that is appended to the base URL to form the full URL for a request.
    var path: String { get }

    // URLRequest for the endpoint.
    // This computed property should return a fully constructed URLRequest object, typically combining the base URL and path.
    // It can also include additional configurations like HTTP method, headers, and body, as required for the specific endpoint.
    var urlRequest: URLRequest { get }
}
