import UIKit
import Parchment

class ImagePagingDataSource {
  
  let items: [ImageItem] = [
    ImageItem(
      title: "Green",
      headerImage: UIImage(named: "green-1")!,
      images: [
        UIImage(named: "green-1")!,
        UIImage(named: "green-2")!,
        UIImage(named: "green-3")!,
        UIImage(named: "green-4")!,
      ]),
    ImageItem(
      title: "Food",
      headerImage: UIImage(named: "food-1")!,
      images: [
        UIImage(named: "food-1")!,
        UIImage(named: "food-2")!,
        UIImage(named: "food-3")!,
        UIImage(named: "food-4")!,
      ]),
    ImageItem(
      title: "Succulents",
      headerImage: UIImage(named: "succulents-1")!,
      images: [
        UIImage(named: "succulents-1")!,
        UIImage(named: "succulents-2")!,
        UIImage(named: "succulents-3")!,
        UIImage(named: "succulents-4")!,
      ]),
    ImageItem(
      title: "City",
      headerImage: UIImage(named: "city-1")!,
      images: [
        UIImage(named: "city-3")!,
        UIImage(named: "city-2")!,
        UIImage(named: "city-1")!,
        UIImage(named: "city-4")!,
      ]),
    ImageItem(
      title: "Scenic",
      headerImage: UIImage(named: "scenic-1")!,
      images: [
        UIImage(named: "scenic-1")!,
        UIImage(named: "scenic-2")!,
        UIImage(named: "scenic-3")!,
        UIImage(named: "scenic-4")!,
      ]),
    ImageItem(
      title: "Coffee",
      headerImage: UIImage(named: "coffee-1")!,
      images: [
        UIImage(named: "coffee-1")!,
        UIImage(named: "coffee-2")!,
        UIImage(named: "coffee-3")!,
        UIImage(named: "coffee-4")!,
      ]),
    ]
  
}

extension ImagePagingDataSource: PagingViewControllerDataSource {
  
  func viewControllerForPagingItem(pagingItem: PagingItem) -> UIViewController {
    let item = pagingItem as! ImageItem
    return ImagesViewController(images: item.images)
  }
  
  func pagingItemBeforePagingItem(pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.indexOf(pagingItem as! ImageItem) else { return nil }
    if index > 0 {
      return items[index - 1]
    }
    return nil
  }
  
  func pagingItemAfterPagingItem(pagingItem: PagingItem) -> PagingItem? {
    guard let index = items.indexOf(pagingItem as! ImageItem) else { return nil }
    if index < items.count - 1 {
      return items[index + 1]
    }
    return nil
  }
  
}
