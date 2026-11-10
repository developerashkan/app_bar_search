## [2.0.0]

### Added
- **Six designs** via `design:` — `classic`, `pill` (Material 3 search pill),
  `glass` (frosted liquid glass), `gradient` (vivid on-brand gradient),
  `floating` (detached capsule) and `spotlight` (command palette with a
  ⌘K / Ctrl K hint). All derive from the app's `ColorScheme`, light and dark.
- **Responsive layout** measured on the bar's own width: on wide bars the
  title stays and search opens beside it (`wideBreakpoint`, `maxSearchWidth`).
- **Keyboard shortcuts** for web/desktop: ⌘/Ctrl+K and `/` open, Esc closes
  (`keyboardShortcuts`).
- `AppBarSearchController` to open/close from code; `onOpen` / `onClose`.
- `debounce` for `onChanged` (submit flushes).
- Inline clear button (`showClearButton`), `initiallyOpen`, `titleWidget`,
  `bottom` (e.g. `TabBar`), `toolbarHeight`, `foregroundColor`, `gradient`,
  `searchIcon` / `closeIcon`, tooltip overrides, `textInputAction`,
  `keyboardType`, `automaticallyImplyLeading` (back/drawer like `AppBar`).
- Back gesture / button closes search before leaving the page (`closeOnBack`).
- Localized defaults (Search / Close / Clear text) from Material localizations.
- Reduced-motion support; status-bar icon brightness follows the bar.

### Fixed
- The search and close icons overlapped during the swap (the elastic curve
  kept the outgoing icon at full size; `rotate` and `flipVertical` never faded
  at all). The swap is now sequential — out, then in — for every style.
- The hidden search field stayed tappable and keyboard-focusable while closed
  (tapping the title could open the keyboard); the hidden title stayed
  tappable while searching. Both layers are now inert, unfocusable and
  excluded from semantics, and offstage once fully hidden.
- Opening then quickly closing could still pop the keyboard (delayed focus).
- Closing cleared the text without calling `onChanged('')`, leaving filters
  stale.
- Swapping `controller` / `focusNode` / duration at runtime was ignored.
- Animations and the reveal direction ignored right-to-left text.
- Typed text was not vertically centered in the field.
- Low-contrast hint text.
- Wrong `homepage` link; README said "5" animations next to a list of 10.

### Changed
- `hintText` defaults to the localized "Search" instead of `'Search...'`.

## [1.2.0]
### Added
- Updated minimum SDK constraints to Dart 3.8.0 and Flutter 3.32.0.

### Fixed
- Replaced deprecated `SizeTransition.axisAlignment` with `alignment`.
- Replaced deprecated `Color.withOpacity` with `Color.withValues`.
- Updated example app dependencies and fixed widget tests.

## [1.1.0]
### Added
- The New Animations:
  flipVertical: A 3D transformation where the title flips up like a shutter, and the search bar flips down into place.
- 
  revealRight: The search bar expands horizontally from the search icon (right to left), widely used in Material 3 and modern web headers.
- 
  slideUp: A clean motion where the title pushes up and out, while the search bar slides up from the bottom.
- 
  zoomOut: Creates depth. The title recedes into the background (fades & scales down), and the search bar fades in on top.
- 
  bounce: A playful but polished spring animation where the search bar slides in with a slight overshoot/settle effect.
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