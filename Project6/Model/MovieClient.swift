//
//  MovieClient.swift
//  Project6
//
//  Created by Yin-Lin Chen on 2023/2/13.
//

import Foundation

import UIKit

   /// Creates a task that retrieves the contents of the an itunes URL, then calls a handler upon completion.
class MovieClient {
    
    /// Fetch movies from iTunes with completion block
    /// - Parameters:
    ///     - completion: A tuple with an `Array` of the movies and an error code
    /// - Throws:
    /// - Returns:
    static func fetchMovies(term: String, completion: @escaping (movielist?, Error?) -> Void) {
        print("DEBUG ---> Attempting to fetch movies")
        let url = URL(string: "https://itunes.apple.com/search?country=US&media=movie&limit=200&term=\(term)")!
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let issues = try decoder.decode(movielist.self, from: data)
                print("DEBUG ------> fetched new movies:", issues)
                DispatchQueue.main.async { completion(issues, nil) }
                
            } catch(let parsingError) {
                DispatchQueue.main.async { completion(nil, parsingError) }
            }
        }
        task.resume()
    }
    
    // FIXME: Change this to use the new Async Image method
    static func getImage(url: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let url=URL(string: url)!
        let session = URLSession.shared
        let task=session.dataTask(with:url as URL,completionHandler:{(data,response,error)->Void in
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
            // Do something with this
            // image on the main thread
                    completion(image, nil)
                }}else{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
        })
        task.resume()
    }
}
