//
//  License.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 20.02.2024.
//

import Foundation

struct License: Codable, Equatable {
    var key, name, spdxID: String?
    var url: String?
    var nodeID: String?

    enum CodingKeys: String, CodingKey {
        case key, name
        case spdxID = "spdx_id"
        case url
        case nodeID = "node_id"
    }
}

// MARK: License convenience initializers and mutators

extension License {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(License.self, from: data)
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
        key: String?? = nil,
        name: String?? = nil,
        spdxID: String?? = nil,
        url: String?? = nil,
        nodeID: String?? = nil
    ) -> License {
        return License(
            key: key ?? self.key,
            name: name ?? self.name,
            spdxID: spdxID ?? self.spdxID,
            url: url ?? self.url,
            nodeID: nodeID ?? self.nodeID
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
