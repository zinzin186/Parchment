# Changelog

`Parchment` adheres to [Semantic Versioning](http://semver.org/).

## [0.6.0](https://github.com/rechsteiner/Parchment/compare/v0.5.0...v0.6.0) - 2017-09-25

### Changes

- Upgrade to Swift 4.0 #54

### Fixes

- Fix bug where selecting items was not working #55

## [0.5.0](https://github.com/rechsteiner/Parchment/compare/v0.4.0...v0.5.0) - 2017-08-22

### Added

- Add support for scrolling in header #48

### Changes

- Require `PagingItem` to conform to `Hashable` and `Comparable`: [fbd7aff](https://github.com/rechsteiner/Parchment/pull/48/commits/fbd7aff8c1e3ac17dad8644961d073dc49da6a1e)
- Use custom collection view layout instead of using `UICollectionViewFlowLayout` [c6f78b4](https://github.com/rechsteiner/Parchment/pull/48/commits/c6f78b4521c4cae56050316ae3ec3ac72fe895ba)

## [0.4.0](https://github.com/rechsteiner/Parchment/compare/v0.3.0...v0.4.0) - 2017-05-04

### Added

- Add delegate for selected items in FixedPagingViewController #46

### Fixes

- Fix issue with delayed rendering #45

## [0.3.0](https://github.com/rechsteiner/Parchment/compare/v0.2.0...v0.3.0) - 2017-03-12

### Changes

- Allow selectPagingItem to be called before viewDidAppear #32
- Move collection view above paging view #31

### Fixes

- Fixes for EMPageViewController #36
- Fix calculation for transition distance #33
- Fix background color on header view #41

## [0.2.0](https://github.com/rechsteiner/Parchment/compare/v0.1.2...v0.2.0) - 2017-02-19

### Added

- Add progress value to menu items: #20
- Scroll menu items alongside content: #22
- Option to add spacing to indicator: #27
- Add new icons example project
- Add example for loading view controllers from storyboard

## [0.1.2](https://github.com/rechsteiner/Parchment/compare/v0.1.1...v0.1.2) - 2016-12-08

### Changes

- Update to Swift 3.0 #11
- Update public accessors [1f057a9](https://github.com/rechsteiner/Parchment/commit/1f057a94dc8e204343eeb78b9be6f516e1a6af15)

### Fixes

- Account for menuInsets when using sizeToFit #8
- Add support for centering fixed width menu items #10

## [0.1.1](https://github.com/rechsteiner/Parchment/compare/v0.1.0...v0.1.1) - 2016-05-22

### Changes

- Add MIT license #4

## [0.1.0](https://github.com/rechsteiner/Parchment/compare/0ad346e...v0.1.0) - 2016-05-22

- Inital release
