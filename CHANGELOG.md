## [1.0.9]
### Added
- Add Some Improvements

## [1.0.8]
### Added
- 5 distinct animation styles: fadeSlide, scale, rotate, elastic, slideRight
- SearchAnimationStyle enum for easy animation selection
- Performance optimizations with single AnimationController
- Different icon transitions based on selected animation style

### Changed
- Icon transition now uses scale for non-rotate styles
- Improved animation curves for better visual experience

### Fixed
- Removed unwanted rotation from all non-rotate animation styles
- Optimized widget rebuilds for better performance

## [1.0.7]
### Added
- Demo Added.

## [1.0.6]
### Added
- Smooth fade & slide animations for title and search field
- Animated search ↔ clear icon transition
- Full AppBar support using PreferredSizeWidget
- Search callbacks: onChanged, onSubmitted, onClear
- Controller & FocusNode support
- Accessibility improvements

### Changed
- AppBarSearch can now be used directly as Scaffold.appBar
- Improved customization options for text styles and decorations

### Fixed
- Focus handling during search toggle
- Clean state disposal for internal controllers