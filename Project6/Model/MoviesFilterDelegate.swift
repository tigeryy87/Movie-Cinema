//
//  MoviesFilterDelegate.swift
//  Project6
//
//  Created by Yin-Lin Chen on 2023/2/13.
//

import Foundation

protocol MoviesFilterDelegate: AnyObject {
    func changeFilter(price: Float, rating: String)
    func sortByDate()
}
