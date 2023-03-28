//
//  Rating.swift
//  Project6
//
//  Created by Yin-Lin Chen on 2023/2/13.
//

import Foundation

enum Rating: Int, Decodable {
    case g
    case pg
    case pg13
    case r
    case anyRating
    
    var displayString: String {
        switch self {
        case .g:
            return "G"
        case .pg:
            return "PG"
        case .pg13:
            return "PG-13"
        case .r:
            return "R"
        default:
            return "Unrated"
        }
    }
    
    init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        switch label {
        case "G": self = .g
        case "PG": self = .pg
        case "PG-13": self = .pg13
        case "R": self = .r
        default: self = .anyRating
        }
    }
}
