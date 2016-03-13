# Parchment

[![Build Status](https://img.shields.io/circleci/project/rechsteiner/parchment.svg)](https://circleci.com/gh/rechsteiner/Parchment)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/Parchment.svg)](https://cocoapods.org/pods/Parchment)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)

Parchment can be used to page between view controllers and display menu items that scrolls along with the content. It's build to be very flexible, and you can customize everything to match your needs. It also comes with some very good default behavior, which makes it super easy to get started.

## Usage

The easiest way to use Parchment is to just pass in an array of view controllers:

```Swift
let firstViewController = UIViewController()
let secondViewController = UIViewController()

let pagingViewController = PagingViewController(viewControllers: [
  firstViewController,
  secondViewController
])
```

Then add the paging view controller to you view controller:

```Swift
addChildViewController(pagingViewController)
view.addSubview(pagingViewController.view)
pagingViewController.didMoveToParentViewController(self)
```

Parchment will then generate menu items for each view controller using their title property. You can customize how the menu items will look, or even create your completely custom subclass. See [Customization]().

Check out `ViewController.swift` in the Example target for more details.

## Custom Data Source

Parchment supports adding your own custom data sources. This allows you
to allocate view controllers only when they are needed, and can even be used to 
create infinitly scrolling data sources.

To add your own data source, simply conform to `PagingDataSource`:

```Swift
protocol PagingDataSource: class {
  func viewControllerForPagingItem(pagingItem: PagingItem) -> UIViewController
  func pagingItemBeforePagingItem(pagingItem: PagingItem) -> PagingItem?
  func pagingItemAfterPagingItem(pagingItem: PagingItem) -> PagingItem?
}
```

If you've ever used [UIPageViewController](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIPageViewControllerClassReferenceClassRef/) this should seem familiar. Instead of returning view controllers directly, you return a object conforming to `PagingItem`. `PagingItem` is used to generate menu items for all the view controllers, without having to actually allocate them before they are needed.

## Delegate

Respond to delegate events by conforming to `PagingViewControllerDelegate`:

```Swift
protocol PagingViewControllerDelegate: class {
  func pagingViewController(pagingViewController: PagingViewController, didMoveToViewController: UIViewController)
}
```

## Customization

Parchment is build to be very flexible. You can customize values by passing in a struct of options to the initializer.
Your struct has to conform to the `PagingOptions` protocol:

```Swift
protocol PagingOptions {
  var theme: PagingTheme { get }
  var menuItemSize: PagingMenuItemSize { get }
  var borderOptions: PagingBorderOptions { get }
  var indicatorOptions: PagingIndicatorOptions { get }
  var selectedScrollPosition: PagingSelectedScrollPosition { get }
}
```

If you have any requests for addional customizations, issues and pull-requests are very much welcome.

#### `PagingCellSize`

The size for each of the menu items.

```Swift
enum PagingMenuItemSize {
  case Fixed(width: CGFloat, height: CGFloat)
  
  // Tries to fit all menu items inside the bounds of the screen.
  // If the items can't fit, the items will scroll as normal and
  // set the menu items width to `minWidth`.
  case SizeToFit(minWidth: CGFloat, height: CGFloat)
}
```

_Default: `.SizeToFit(minWidth: 150)`_

#### `PagingSelectedScrollPosition`

The scroll position of the selected menu item:

```Swift
enum PagingSelectedScrollPosition {
  case Left
  case Right
  case AlwaysCentered
  
  // Centers the selected menu item where possible. If the item is
  // to the far left or right, it will not update the scroll position.
  // Effectivly the same as .CenteredHorizontally on UIScrollView.
  case PreferCentered
}
```

_Default: `.PreferCentered`_

#### `PagingTheme`

```Swift 

protocol PagingTheme {
  var font: UIFont { get }
  var textColor: UIColor { get }
  var selectedTextColor: UIColor { get }
  var backgroundColor: UIColor { get }
  var headerBackgroundColor: UIColor { get }
}
```

_Default:_

```Swift
extension PagingTheme {
  
  var font: UIFont {
    return UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
  }
  
  var textColor: UIColor {
    return UIColor.blackColor()
  }
  
  var selectedTextColor: UIColor {
    return UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
  }
  
  var backgroundColor: UIColor {
    return UIColor.whiteColor()
  }
  
  var headerBackgroundColor: UIColor {
    return UIColor.whiteColor()
  }
  
}
```

#### `PagingBorderOptions`

Add a border at the bottom of the menu items. The border will be as wide as all the menu items. Insets only apply horizontally.

```Swift

enum PagingBorderOptions {
  case Hidden
  case Visible(height: CGFloat, zIndex: Int, insets: UIEdgeInsets, backgroundColor: UIColor)
}
```

_Default:_ 
```Swift
.Visible(
  height: 1,
  zIndex: Int.max - 1,
  insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
  backgroundColor: UIColor(white: 0.9, alpha: 1)
```

#### `PagingIndicatorOptions`

Add a indicator view to the selected menu item. The indicator width will be equal to the selected menu items width. Insets only apply horizontally.

```Swift

enum PagingIndicatorOptions {
  case Hidden
  case Visible(height: CGFloat, zIndex: Int, insets: UIEdgeInsets, backgroundColor: UIColor)
}
```

_Default:_ 
```Swift
.Visible(
  height: 4,
  zIndex: Int.max,
  insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
  backgroundColor: UIColor(red: 3/255, green: 125/255, blue: 233/255, alpha: 1)
```

## Installation

Parchment will be compatible with the lastest public release of Swift. Older releases will be available, but bug fixes won’t be issued.

#### [Carthage](https://github.com/carthage/carthage)

1. Add `github "rechsteiner/Parchment"` to your `Cartfile`
2. Run `carthage update`
3. Link `Parchment.framework` with you target
4. Add `$(SRCROOT)/Carthage/Build/iOS/Parchment.framework` to your `copy-frameworks` script phase

#### [CocoaPods](https://cocoapods.org)

1. Add `pod "Parchment"` to your `Podfile`
2. Make sure `use_frameworks!` is included. Adding this means your dependencies will be included as a dynamic framework (this is necessary since Swift cannot be included as a static library).
3. Run `pod install`

## Licence

Parchment is released under the MIT license. See LICENSE for details.
