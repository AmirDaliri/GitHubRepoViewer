//
//  SearchedRepositories.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 22.02.2024.
//

import Foundation

// MARK: - SearchedRepositories
struct SearchedRepositories: Codable, Equatable {
    var totalCount: Int?
    var incompleteResults: Bool?
    var items: [Repository]?

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

// MARK: SearchedRepositories convenience initializers and mutators

extension SearchedRepositories {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SearchedRepositories.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        totalCount: Int?? = nil,
        incompleteResults: Bool?? = nil,
        items: [Repository]?? = nil
    ) -> SearchedRepositories {
        return SearchedRepositories(
            totalCount: totalCount ?? self.totalCount,
            incompleteResults: incompleteResults ?? self.incompleteResults,
            items: items ?? self.items
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
