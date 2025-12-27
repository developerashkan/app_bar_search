# app_bar_search

A highly customizable Flutter AppBar with integrated search functionality and 5 beautiful animation styles.

## Features

✨ **5 Modern Animation Styles**
- Fade & Slide - Smooth vertical transition
- Scale - Zoom in/out effect
- Rotate - Spinning transition
- Elastic - Bouncy spring animation
- Slide Right - Horizontal slide transition

🎯 **Full Customization**
- Custom text styles and colors
- Search callbacks (onChanged, onSubmitted, onClear)
- Controller & FocusNode support
- Leading widget and action buttons
- Configurable animation duration

⚡ **Performance Optimized**
- Single AnimationController
- Efficient widget reuse
- Smooth 60fps animations

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_bar_search: ^1.0.8

## Basic Example

AppBarSearch(
  title: 'My App',
  hintText: 'Search...',
  onChanged: (value) => print('Searching: $value'),
);

// With Animation Style
AppBarSearch(
  title: 'My App',
  animationStyle: SearchAnimationStyle.elastic,
  animationDuration: Duration(milliseconds: 400),
  onSubmitted: (value) => performSearch(value),
);

// Advanced Example
final searchController = TextEditingController();

AppBarSearch(
  title: 'Products',
  controller: searchController,
  animationStyle: SearchAnimationStyle.scale,
  titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  searchTextStyle: TextStyle(fontSize: 16),
  backgroundColor: Colors.blue,
  iconColor: Colors.white,
  leading: IconButton(
    icon: Icon(Icons.menu),
    onPressed: () => openDrawer(),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () => showFilters(),
    ),
  ],
  onChanged: (value) => filterResults(value),
  onSubmitted: (value) => search(value),
  onClear: () => clearFilters(),
);
