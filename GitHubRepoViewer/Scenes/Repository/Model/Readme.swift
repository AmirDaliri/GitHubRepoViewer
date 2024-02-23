//
//  Readme.swift
//  GitHubRepoViewer
//
//  Created by Amir Daliri on 23.02.2024.
//

import Foundation

// MARK: - Readme
struct Readme: Codable, Equatable {
    var downloadURL: String?

    enum CodingKeys: String, CodingKey {
        case downloadURL = "download_url"
    }
}

// MARK: Readme convenience initializers and mutators

extension Readme {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Readme.self, from: data)
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
        downloadURL: String?? = nil
    ) -> Readme {
        return Readme(
            downloadURL: downloadURL ?? self.downloadURL
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
