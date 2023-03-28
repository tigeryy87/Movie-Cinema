//
//  Movie.swift
//  Project6
//
//  Created by Yin-Lin Chen on 2023/2/13.
//

import Foundation

struct movielist: Decodable {
    let results: [Movie]
}

/// A move type with data matching the iTunes API (note that the names have historically music-like names)
struct Movie : Decodable, Hashable {
    let trackName: String?
    let trackPrice: Float?
    let contentAdvisoryRating: Rating?
    let artworkUrl100: String?
    let longDescription: String?
    let previewUrl: URL?
    let releaseDate: String?

    var trackPrice_TOSTRING: String {
        if let trackPrice = trackPrice {
            return "$\(trackPrice)"
        } else {
            return "Unknown Price"
        }
    }
}
