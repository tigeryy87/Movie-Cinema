//
//  DataManager.swift
//  Project6
//
//  Created by Yin-Lin Chen on 2023/2/13.
//

import Foundation

import UIKit
class DataManager {
    //
    // MARK: - Singleton
    //
    public static let sharedInstance = DataManager()
    /// List of movies retrieved from iTunes, does not mutate with filters, maintains original fetch data
    private(set) var movies: [Movie]
    /// List of movies retrieved from iTunes, and then filtered based on user input
    private(set) var filteredMovies: [Movie]
    private(set) var priceLimitFilter: Float
    
    private(set) var ratingFilter: String
    let imageCache = NSCache<NSString, UIImage>()
    
    var priceLimitDisplayString: String {
        return "$\(priceLimitFilter)"
    }
    // Init with default values
    private init() {
        priceLimitFilter = 20
        ratingFilter = "anyRating"
        movies = []
        filteredMovies = []
    }
    func refreshMovieData(_ movies: [Movie]) {
        self.movies = movies
        self.filteredMovies = movies
    }
    func update1(_ filteredMovies: [Movie]) {
        self.movies = filteredMovies
    }
    
    func update2(priceLimit: Float? = nil, rating: String? = nil) {
        if let priceLimit = priceLimit {
            self.priceLimitFilter = priceLimit
        }
        
        if let rating = rating {
            self.ratingFilter = rating
        }
    }
    func update3(_ filteredMovies: [Movie]) {
        self.filteredMovies = filteredMovies
    }
    
    // Add an additional filter to sort the results by release date (releaseDate in the iTunes API JSON). This will allow the users to be able to easily identify new releases.
    // https://stackoverflow.com/questions/51710636/swift-sort-list-object-by-property
    func sortByDate() {
        self.filteredMovies.sort {
            guard let releaseDate0 = $0.releaseDate, let releaseDate1 = $1.releaseDate else { return false }
            return releaseDate0.localizedStandardCompare(releaseDate1) == .orderedDescending
        }
    }
}
