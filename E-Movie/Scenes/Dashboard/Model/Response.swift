//
//  Response.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 09/09/22.
//

import Foundation

struct Response: Codable {
    let page: Int?
    let results: [Movie]?
    let totalPages, totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
