import Parchment
import UIKit

final class SelfSizingViewController: PagingViewController {
    private let movies = [
        "Pulp Fiction",
        "The Shawshank Redemption",
        "The Dark Knight",
        "Fight Club",
        "Se7en",
        "Saving Private Ryan",
        "Interstellar",
        "Harakiri",
        "Psycho",
        "The Intouchables",
        "Once Upon a Time in the West",
        "Alien",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        menuItemSize = .selfSizing(estimatedWidth: 100, height: 40)
        self.indicatorOptions = .visible(height: 10, zIndex: 0, spacing: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), position: .right(30))
    }
}

extension SelfSizingViewController: PagingViewControllerDataSource {
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return PagingIndexItem(index: index, title: movies[index])
    }

    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return ContentViewController(title: movies[index])
    }

    func numberOfViewControllers(in _: PagingViewController) -> Int {
        return movies.count
    }
}
