//
//  MoviesCollectionViewController.swift
//  Project6
//
//  Created by Yin-Lin Chen on 2023/2/13.
//

import UIKit

private let reuseIdentifier = "Cell"

class MoviesCollectionViewController: UICollectionViewController {
    
    /// The collection view data source
    var dataSource: UICollectionViewDiffableDataSource<Int, Movie>!
    
    //
    // MARK: - Lifecycle
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Movie Cinema"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Set up a search controller to show in the `NavigationBar`
        // Note that we are not using the full `SearchResults` functionality, we
        // are really only using it to present a `UISearchBar`
        let srchCtr = UISearchController(searchResultsController: nil)
        srchCtr.searchBar.delegate = self
        srchCtr.searchBar.text = "Love"
        // https://stackoverflow.com/questions/56747186/how-to-hide-search-bar-on-scroll-without-uitableviewcontroller
        srchCtr.hidesNavigationBarDuringPresentation = true
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = srchCtr
        
        // Use the `MovieClient` to fetch a list of movies
        print("DEBUG-----> to fetch movies")
        MovieClient.fetchMovies(
            term: "love",
            completion: { [weak self] moviesData, error in
            guard let moviesData = moviesData, error == nil else {
                print(error ?? NSError())
                return
            }
            
            DataManager.sharedInstance.refreshMovieData(moviesData.results)
            /// Update the collection view based on the current state of the `data` property
            var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
            snapshot.appendSections([0])
            snapshot.appendItems(DataManager.sharedInstance.movies)
                
            self?.dataSource.apply(snapshot)
            }
        )
        
        // layout for the collection view
        collectionView.collectionViewLayout = makeLayout()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, state in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                          for: indexPath) as! MoviesCollectionViewCell
            cell.titleLabel.text = state.trackName
            cell.priceLabel.text = state.trackPrice_TOSTRING
            cell.ratingLabel.text = state.contentAdvisoryRating?.displayString
            cell.imageView.image = UIImage(systemName: "swift")
            
            // FIXME: Update the image download code in MovieClient to cache the images using NSCache
            // https://www.hackingwithswift.com/example-code/system/how-to-cache-data-using-nscache
            if let cachedImage = DataManager.sharedInstance.imageCache.object(forKey: (state.artworkUrl100 ?? "") as NSString) {
                print("DEBUG ---> for cached image")
                cell.imageView.image = cachedImage
                
                // https://stackoverflow.com/questions/51676691/get-average-color-of-uiimage
                let uiColor = cell.imageView.image?.averageColor
                cell.backgroundColor = uiColor
                
                // Test to make sure that your text is legible in both modes
                // https://www.appsloveworld.com/swift/100/26/determining-text-color-from-the-background-color-in-swift
                cell.titleLabel.textColor = cell.backgroundColor?.isDarkColor == true ? .white : .black
                cell.ratingLabel.textColor = cell.backgroundColor?.isDarkColor == true ? .white : .black
                cell.priceLabel.textColor = cell.backgroundColor?.isDarkColor == true ? .white : .black
                
            } else {
                // Handle error
                MovieClient.getImage ( url: state.artworkUrl100 ?? "", completion: { (image, error) in
                    guard let image = image, error == nil else {
                        print(error ?? "")
                        return
                    }
                    DataManager.sharedInstance.imageCache.setObject(image, forKey: (state.artworkUrl100 ?? "") as NSString)
                    cell.imageView.image = image
                    // https://stackoverflow.com/questions/51676691/get-average-color-of-uiimage
                    let uiColor = cell.imageView.image?.averageColor
                    cell.backgroundColor = uiColor
                    
                    // https://www.appsloveworld.com/swift/100/26/determining-text-color-from-the-background-color-in-swift
                    cell.titleLabel.textColor = cell.backgroundColor?.isDarkColor == true ? .white : .black
                    cell.ratingLabel.textColor = cell.backgroundColor?.isDarkColor == true ? .white : .black
                    cell.priceLabel.textColor = cell.backgroundColor?.isDarkColor == true ? .white : .black
                })
            }
            return cell
        }
    
        /// Update the collection view based on the current state of the `data` property
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(DataManager.sharedInstance.movies)
        
        dataSource.apply(snapshot)
    }
}

//
// MARK: - Navigation
//

extension MoviesCollectionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // the popover filter or the detail view controller
        if segue.identifier == "popover" {
            let filtersViewController = segue.destination as? FiltersViewController
            filtersViewController?.delegate = self
            segue.destination.preferredContentSize = CGSize(width: 300, height: 200)
            
            if let presentationController = segue.destination.popoverPresentationController { // 1
                presentationController.delegate = self // 2
            }
        } else {
            guard let detailViewController = segue.destination as? DetailViewController,
                  let selectedRow = collectionView.indexPathsForSelectedItems?.first?.row else {
                return
            }
            detailViewController.movie = DataManager.sharedInstance.filteredMovies[selectedRow]
        }
    }
}

//
// MARK: - Protocol Extensions
//

extension MoviesCollectionViewController: UIPopoverPresentationControllerDelegate {
    
    /// Delegate method to enforce the correct popover style
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension MoviesCollectionViewController: MoviesFilterDelegate {
    // FIXME: Update the collection view based on the popover filters (including the release date)
    /// Update the collection view based on the popover filter selections
    func changeFilter(price: Float, rating: String) {
        let filteredMovies = DataManager.sharedInstance.movies.filter { movie in
            let isBelowSelectedPriceLimit = movie.trackPrice ?? 0 < price
            let matchesSelectedRating = rating == "anyRating" || movie.contentAdvisoryRating?.displayString == rating.uppercased()
            
            return isBelowSelectedPriceLimit && matchesSelectedRating
        }
        
        DataManager.sharedInstance.update3(filteredMovies)
        
        /// Update the collection view based on the current state of the `data` property
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(DataManager.sharedInstance.filteredMovies)
        
        dataSource.apply(snapshot)
    }
    // Add an additional filter to sort the results by release date (releaseDate in the iTunes API JSON). This will allow the users to be able to easily identify new releases.
    func sortByDate() {
        DataManager.sharedInstance.sortByDate()
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(DataManager.sharedInstance.filteredMovies)
        
        dataSource.apply(snapshot)
    }
}

extension MoviesCollectionViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // FIXME: Search after enter
        print("Clicked")
        
        if let term = searchBar.text {
            MovieClient.fetchMovies(
                term: term,
                completion: { [weak self] moviesData, error in
                guard let moviesData = moviesData, error == nil else {
                    print(error ?? NSError())
                    return
                }
                
                DataManager.sharedInstance.refreshMovieData(moviesData.results)
                /// Update the collection view based on the current state of the `data` property
                var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
                snapshot.appendSections([0])
                snapshot.appendItems(DataManager.sharedInstance.movies)
                
                self?.dataSource.apply(snapshot)
                }
            )
        }
    }
}

//
// MARK: - Collection View Setup
//

private extension MoviesCollectionViewController {
    
    //FIXME: Update the layout as you see fit to make it look "good"
    func makeLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0),
                                                                                 heightDimension: NSCollectionLayoutDimension.absolute(200)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension: .absolute(200))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            return section
        }
    }

}

// Obtain average color of the image
// https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
extension UIImage {
    /// Average color of the image, nil if it cannot be found
    var averageColor: UIColor? {
        // Convert image to CIImage
        guard let inputImage = CIImage(image: self) else { return nil }

        // Creates a Core Image vector object called extentVector that describes the extent, or size and position, of an input image.
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        // Computes the average color of an image region specified by the kCIInputExtentKey parameter.
        guard let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        // Bitmap
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        // Renders a Core Image output image to a bitmap buffer.
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        // Convert our bitmap images of r, g, b, a to a UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}

extension UIColor
{
    var isDarkColor: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        // "luma" formula
        //  It is a weighted sum of the red, green, and blue color components, where each component is weighted according to its perceived brightness.
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50
    }
}
