# app_bar_search

A lightweight Flutter widget that provides an AppBar with built-in search functionality and
smooth animated transitions.  
It is designed to be used directly as a replacement for the default AppBar.

## Demo

[▶ Watch demo video](https://github.com/user-attachments/assets/3166f618-32ac-44fd-bc9a-cfc1c92db2b3)

## Features

- Integrated search field inside AppBar
- Smooth title to search transition animations
- Implements PreferredSizeWidget for seamless Scaffold integration
- Search callbacks for filtering and submission
- External TextEditingController and FocusNode support
- Highly customizable appearance
- No external dependencies

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:app_bar_search/app_bar_search.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarSearch(
        title: const Text('My App'),
        hintText: 'Search...',
        onChanged: (query) {
          // Filter your data here
        },
        onSubmitted: (query) {
          // Handle search submit
        },
        onClosed: () {
          // Called when search is closed
        },
      ),
      body: Container(),
    );
  }
}