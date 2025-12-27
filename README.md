# app_bar_search

A highly customizable Flutter AppBar with integrated search functionality and 5 beautiful animation styles.

## Features

✨ **5 Modern Animation Styles**

* **Fade & Slide** – Smooth vertical transition
* **Scale** – Zoom in/out effect
* **Rotate** – Spinning transition
* **Elastic** – Bouncy spring animation
* **Slide Right** – Horizontal slide transition

🎯 **Full Customization**

* Custom text styles and colors
* Search callbacks (`onChanged`, `onSubmitted`, `onClear`)
* Controller & FocusNode support
* Leading widget and action buttons
* Configurable animation duration

⚡ **Performance Optimized**

* Single `AnimationController`
* Efficient widget reuse
* Smooth 60fps animations

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  app_bar_search: ^1.0.8
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
// Basic Example
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
```

## Animation Styles

| Style      | Description              | Best For            |
| ---------- | ------------------------ | ------------------- |
| fadeSlide  | Vertical slide with fade | Default, clean look |
| scale      | Zoom effect              | Modern apps         |
| rotate     | Spinning transition      | Playful UI          |
| elastic    | Bouncy spring            | Eye-catching        |
| slideRight | Horizontal slide         | Material design     |

## Parameters

| Parameter         | Type                   | Default     | Description               |
| ----------------- | ---------------------- | ----------- | ------------------------- |
| title             | String                 | required    | AppBar title text         |
| animationStyle    | SearchAnimationStyle   | fadeSlide   | Animation type            |
| animationDuration | Duration               | 300ms       | Animation speed           |
| hintText          | String                 | 'Search...' | Search field placeholder  |
| autoFocus         | bool                   | true        | Auto-focus on search open |
| onChanged         | ValueChanged<String>?  | null        | Live search callback      |
| onSubmitted       | ValueChanged<String>?  | null        | Search submit callback    |
| onClear           | VoidCallback?          | null        | Clear button callback     |
| controller        | TextEditingController? | null        | Custom controller         |
| focusNode         | FocusNode?             | null        | Custom focus node         |

## License

MIT License

Copyright (c) 2022–2025 Ashkan Bahmani [ashkanbhmn@gmail.com](mailto:ashkanbhmn@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
