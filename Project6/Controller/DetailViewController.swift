//
//  DetailViewController.swift
//  Project6
//
//  Created by Yin-Lin Chen on 2023/2/13.
//

import UIKit

class DetailViewController: UIViewController {

    //
    // MARK: - IBOutlets
    //
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var ratingLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var descriptionView: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    var movie: Movie!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        
        // Title label
        titleLabel.text = "🎥" + movie.trackName!
        
        // Raitng label
        if let rating = movie.contentAdvisoryRating {
            ratingLabel.text = rating.displayString
        }
        ratingLabel.layer.cornerRadius = 10.0
        ratingLabel.layer.masksToBounds = true
        

        
        // Release date label
        releaseDateLabel.text = movie.releaseDate
        releaseDateLabel.textColor = UIColor.white
        if let date = movie.releaseDate {
            let endOfSentence = date.firstIndex(of: "T")!
            let substring = date[..<endOfSentence]
            releaseDateLabel.text = String(substring)
        }
        releaseDateLabel.backgroundColor = UIColor.darkGray
        releaseDateLabel.layer.cornerRadius = 10.0
        releaseDateLabel.layer.masksToBounds = true
        
        // Price label
        priceLabel.text = movie.trackPrice_TOSTRING
        priceLabel.textColor = UIColor.white
        priceLabel.backgroundColor = UIColor.darkGray
        priceLabel.layer.cornerRadius = 10.0
        priceLabel.layer.masksToBounds = true
        // Description text view
        descriptionView.text = movie.longDescription
        
        if let cachedImage = DataManager.sharedInstance.imageCache.object(forKey: (movie.artworkUrl100 ?? "") as NSString) {
            print("Detail vc: Used cached image")
            self.imageView.image = cachedImage
        } else {
            MovieClient.getImage ( url: movie.artworkUrl100 ?? "", completion: { (image, error) in
                guard let image = image, error == nil else {
                    print(error ?? "")
                    return
                }
                self.imageView.image = image
            })
        }
        
    }

    //
    // MARK: - IBActions
    //
    
    
    /// Open the current movie preview in Safari using system `UIApplication` method
    /// - Parameter sender: The button that was tapped
    
    @IBAction func openSafari(_ sender: Any) {
        //FIXME: Link to Safari to show preview
        // https://www.hackingwithswift.com/example-code/system/how-to-open-a-url-in-safari
        if let url = movie.previewUrl {
            UIApplication.shared.open(url)
        }
    }
}

