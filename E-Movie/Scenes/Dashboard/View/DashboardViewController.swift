//
//  Dashboard.swift
//  E-Movie
//
//  Created by Sourav Basu Roy on 08/09/22.
//

import UIKit

/**
    DashboardViewController:  Contain UIcollectionView and Header. CollectionView load movie based on user scroll.
    Properties:
        IBOutlet: mainActivity - activity indicator. Link to storyboard.
        IBOutlet: movieGrid - collection view to display movies.
        IBOutlet: filter - filter button to filter movies between
        imgBaseUrl -  base image url from Configuration Api
        posterSizes - collection of image sizes.
        viewModel - viewModel object to call service methods and computing functions.
        createContextMenu() - create and display filer menu.
            
    Enum: Hold static values like collectionviewcell id and bundle id.
    Methods:
        viewConfiguration() - configure collection view.
        registerXib() - register collectionview cell.
*/
class DashboardViewController: UIViewController {
    
    private enum CellConstants {
        static let movieCell = "movieCell"
        static let bundleId = "MovieCell"
    }
    
    @IBOutlet weak var mainActivity: UIActivityIndicatorView!
    @IBOutlet weak var movieGrid: UICollectionView!
    @IBOutlet weak var filter: UIButton!
    
    var imgBaseUrl = ""
    var posterSizes: [String] = []
    var viewModel: DashboardViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure UI
        viewModel = DashboardViewModel(delegate: self)
        registerXib()
        viewConfiguration()
        createContextMenu()
        // Calling fetch all the popular movies by default
        mainActivity.startAnimating()
        viewModel.fetchMovies(with: viewModel.filter)
    }
    
}

extension DashboardViewController {
    
    fileprivate func viewConfiguration()  {
        movieGrid.dataSource = self
        movieGrid.delegate = self
        movieGrid.prefetchDataSource = self
        movieGrid.isHidden = true
        movieGrid.decelerationRate = .fast
    }
    
    fileprivate func registerXib()  {
        movieGrid.register(UINib(nibName: CellConstants.bundleId, bundle: nil), forCellWithReuseIdentifier: CellConstants.movieCell)
        if let layout = movieGrid.collectionViewLayout as? UICollectionViewFlowLayout  {
            layout.scrollDirection = .vertical
            layout.collectionView?.isPagingEnabled = false
        }
       
    }
    
    func createContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        filter.addInteraction(interaction)
    }
}

extension DashboardViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item >= viewModel.currentCount
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleItems = movieGrid.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleItems).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}
// Configure collectionview
extension DashboardViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConstants.movieCell, for: indexPath) as? MovieCell
        // Check if cell is require to reload or not.
        if isLoadingCell(for: indexPath) {
            cell?.cellConfiguration(with: .none)
        }
        else {
            let item = viewModel[indexPath.item]
            cell?.baseUrl = imgBaseUrl
            // passing poster size attribute to cell.
            if let size = posterSizes.first(where: { $0 == "w185"}) {
                cell?.posterSize = size
            }
            cell?.cellConfiguration(with: item)
        }
        return cell ?? UICollectionViewCell()
    }
    
}

// Navigate to Details view.

extension DashboardViewController: UICollectionViewDelegate, Navigation {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = viewModel[indexPath.item] {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailsVC = mainStoryboard.instantiateViewController(withIdentifier: "MovieDetailsViewController") as? MovieDetailsViewController {
                detailsVC.imgBaseUrl = imgBaseUrl
                detailsVC.posterSizes = posterSizes
                detailsVC.movieId = item.id ?? 0
                navigate(from: self, to: detailsVC)
            }
        }
    }
}

// As soon as the table view starts to prefetch a list of index paths, it checks if any of those are not loaded yet in the movie list.

extension DashboardViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            viewModel.fetchMovies(with: viewModel.filter)
        }
    }
}
// Resize cell to create grid design.

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width
        let widthMultipler = 0.5
        return CGSize(width: width * widthMultipler, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}
// Delegate methods to handle service calls.

extension DashboardViewController: DashboardViewModelDelegate, AlertDisplayer {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let _ = newIndexPathsToReload else {
            mainActivity.stopAnimating()
            movieGrid.isHidden = false
            movieGrid.reloadData()
            return
        }
        movieGrid.reloadData()
    }
    
    func onFetchFailed(with reason: String) {
        mainActivity.stopAnimating()
        print(reason)
        let title = "Warning"
        let action = UIAlertAction(title: "OK", style: .default)
        displayAlert(with: title , message: reason, actions: [action])
    }
}

// Delegate method to configure and show filter contextmenu.

extension DashboardViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: "filterImage" as NSCopying,
                                          previewProvider: makeImagePreview, //pass nil, if custom preview not needed
                                          actionProvider: { _ in
                                            let editMenu = self.makeEditMenu()
                                            return UIMenu(title: "Menu",
                                                          children: [editMenu])
        })
    }
    
    func makeEditMenu() -> UIMenu {
        let sortPopularAction = UIAction(title: "Popular",
                                         image: nil,
                                         identifier: nil
                                         ) { [weak self] _ in
            print("Popular Action")
            if let count = self?.movieGrid?.visibleCells.count, count > 0 {
                self?.mainActivity.startAnimating()
                self?.movieGrid?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                  at: .top,
                                            animated: true)
                self?.viewModel.reset()
                self?.viewModel.fetchMovies(with: .popular)
            }
            
        }
        
        let sortRatingction = UIAction(title: "Rating",
                                       image: nil,
                                       identifier: nil) { [weak self] _ in
            print("Rating Action")
            self?.mainActivity.startAnimating()
            self?.movieGrid?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                              at: .top,
                                        animated: true)
            self?.viewModel.reset()
            self?.viewModel.fetchMovies(with: .rating)
            
        }

        return UIMenu(title: "Edit",
                      image: nil,
                      options: [.displayInline], // [], .displayInline, .destructive
                      children: [sortPopularAction, sortRatingction])
    }
    
    func makeImagePreview() -> UIViewController {
        let viewController = UIViewController()
        
        let imageView = UIImageView(image:UIImage(named: "filter"))
        imageView.contentMode = .scaleAspectFit
        viewController.view = imageView
        
        imageView.frame = CGRect(x: 0, y: 0, width: filter.frame.size.width * 1.75, height: filter.frame.size.height * 1.75)
        
        viewController.preferredContentSize = imageView.frame.size
        viewController.view.backgroundColor = .clear
        
        return viewController
    }
}
