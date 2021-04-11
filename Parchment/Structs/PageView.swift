import SwiftUI
import UIKit

/// Check if both SwiftUI and Combine is available. Without this
/// xcodebuild fails, saying it can't find the SwiftUI types used
/// inside PageView, even though it's wrapped with an @available
/// check. Found a possible fix here: https://stackoverflow.com/questions/58233454/how-to-use-swiftui-in-framework
/// This might be related to the issue discussed in this thread:
/// https://forums.swift.org/t/weak-linking-of-frameworks-with-greater-deployment-targets/26017/24
#if canImport(SwiftUI) && canImport(Combine)

    /// `PageView` provides a SwiftUI wrapper around `PagingViewController`.
    /// It can be used with any fixed array of `PagingItem`s. Use the
    /// `PagingOptions` struct to customize the properties.
    @available(iOS 13.0, *)
    public struct PageView<Item: PagingItem, Page: View>: View {
        let content: (Item) -> Page

        private let options: PagingOptions
        private var items = [Item]()
        private var onWillScroll: ((PagingItem) -> Void)?
        private var onDidScroll: ((PagingItem) -> Void)?
        private var onDidSelect: ((PagingItem) -> Void)?
        @Binding private var selectedIndex: Int

        /// Initialize a new `PageView`.
        ///
        /// - Parameters:
        ///   - options: The configuration parameters we want to customize.
        ///   - items: The array of `PagingItem`s to display in the menu.
        ///   - selectedIndex: The index of the currently selected page.
        ///   Updating this index will transition to the new index.
        ///   - content: A callback that returns the `View` for each item.
        public init(
            options: PagingOptions = PagingOptions(),
            items: [Item],
            selectedIndex: Binding<Int> = .constant(0),
            content: @escaping (Item) -> Page
        ) {
            _selectedIndex = selectedIndex
            self.options = options
            self.items = items
            self.content = content
        }

        public var body: some View {
            PagingController(
                items: items,
                options: options,
                content: content,
                onWillScroll: onWillScroll,
                onDidScroll: onDidScroll,
                onDidSelect: onDidSelect,
                selectedIndex: $selectedIndex
            )
        }

        /// Called when the user finished scrolling to a new view.
        ///
        /// - Parameter action: A closure that is called with the
        /// paging item that was scrolled to.
        /// - Returns: An instance of self
        public func didScroll(_ action: @escaping (PagingItem) -> Void) -> Self {
            var view = self
            view.onDidScroll = action
            return view
        }

        /// Called when the user is about to start scrolling to a new view.
        ///
        /// - Parameter action: A closure that is called with the
        /// paging item that is being scrolled to.
        /// - Returns: An instance of self
        public func willScroll(_ action: @escaping (PagingItem) -> Void) -> Self {
            var view = self
            view.onWillScroll = action
            return view
        }

        /// Called when an item was selected in the menu.
        ///
        /// - Parameter action: A closure that is called with the
        /// selected paging item.
        /// - Returns: An instance of self
        public func didSelect(_ action: @escaping (PagingItem) -> Void) -> Self {
            var view = self
            view.onDidSelect = action
            return view
        }

        /// Create a custom paging view controller subclass that we
        /// can use to store state to avoid reloading data unnecessary.
        final class CustomPagingViewController: PagingViewController {
            var items: [Item]?
        }

        struct PagingController: UIViewControllerRepresentable {
            let items: [Item]
            let options: PagingOptions
            let content: (Item) -> Page
            var onWillScroll: ((PagingItem) -> Void)?
            var onDidScroll: ((PagingItem) -> Void)?
            var onDidSelect: ((PagingItem) -> Void)?

            @Binding var selectedIndex: Int

            func makeCoordinator() -> Coordinator {
                Coordinator(self)
            }

            func makeUIViewController(context: UIViewControllerRepresentableContext<PagingController>) -> CustomPagingViewController {
                let pagingViewController = CustomPagingViewController(options: options)
                pagingViewController.dataSource = context.coordinator
                pagingViewController.delegate = context.coordinator
                return pagingViewController
            }

            func updateUIViewController(_ pagingViewController: CustomPagingViewController,
                                        context: UIViewControllerRepresentableContext<PagingController>) {
                context.coordinator.parent = self

                if pagingViewController.dataSource == nil {
                    pagingViewController.dataSource = context.coordinator
                }

                // If the menu items have changed we call reload data
                // to update both the menu and content views.
                if let previousItems = pagingViewController.items,
                    !previousItems.elementsEqual(items, by: { $0.isEqual(to: $1) }) {
                    pagingViewController.reloadData()
                }

                // Store the current items so we can compare it with
                // the new items the next time this method is called.
                pagingViewController.items = items

                let index = $selectedIndex.wrappedValue
                pagingViewController.select(index: index, animated: true)
            }
        }

        final class Coordinator: PagingViewControllerDataSource, PagingViewControllerDelegate {
            var parent: PagingController

            init(_ pagingController: PagingController) {
                parent = pagingController
            }

            func numberOfViewControllers(in _: PagingViewController) -> Int {
                return parent.items.count
            }

            func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
                let view = parent.content(parent.items[index])
                return UIHostingController(rootView: view)
            }

            func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
                parent.items[index]
            }

            func pagingViewController(_ controller: PagingViewController,
                                      didScrollToItem pagingItem: PagingItem,
                                      startingViewController _: UIViewController?,
                                      destinationViewController _: UIViewController,
                                      transitionSuccessful _: Bool) {
                parent.onDidScroll?(pagingItem)

                if let item = pagingItem as? Item,
                    let index = parent.items.firstIndex(where: { $0.isEqual(to: item) }) {
                    parent.selectedIndex = index
                }
            }

            func pagingViewController(_: PagingViewController,
                                      willScrollToItem pagingItem: PagingItem,
                                      startingViewController _: UIViewController,
                                      destinationViewController _: UIViewController) {
                parent.onWillScroll?(pagingItem)
            }

            func pagingViewController(_: PagingViewController, didSelectItem pagingItem: PagingItem) {
                parent.onDidSelect?(pagingItem)
            }
        }
    }
#endif
