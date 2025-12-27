import 'package:flutter/material.dart';

enum SearchAnimationStyle {
  fadeSlide,
  scale,
  rotate,
  elastic,
  slideRight,
}

class AppBarSearch extends StatefulWidget implements PreferredSizeWidget {
  const AppBarSearch({
    super.key,
    required this.title,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.focusNode,
    this.leading,
    this.actions,
    this.titleTextStyle,
    this.searchTextStyle,
    this.inputDecoration,
    this.backgroundColor,
    this.iconColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.autoFocus = true,
    this.animationStyle = SearchAnimationStyle.fadeSlide,
  });

  final String title;
  final TextStyle? titleTextStyle;

  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextStyle? searchTextStyle;
  final InputDecoration? inputDecoration;

  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? iconColor;

  final Duration animationDuration;
  final bool autoFocus;
  final SearchAnimationStyle animationStyle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppBarSearch> createState() => _AppBarSearchState();
}

class _AppBarSearchState extends State<AppBarSearch>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;

  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searching = !_searching);

    if (_searching) {
      _animationController.forward();
      if (widget.autoFocus) {
        Future.delayed(
          const Duration(milliseconds: 100),
          _focusNode.requestFocus,
        );
      }
    } else {
      _animationController.reverse();
      _controller.clear();
      widget.onClear?.call();
      _focusNode.unfocus();
    }
  }

  Widget _buildTitleExit(Animation<double> animation, Widget child) {
    switch (widget.animationStyle) {
      case SearchAnimationStyle.fadeSlide:
        return FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0, -0.2),
            ).animate(animation),
            child: child,
          ),
        );

      case SearchAnimationStyle.scale:
        return FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1, end: 0.8).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          ),
        );

      case SearchAnimationStyle.rotate:
        return FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(animation),
          child: RotationTransition(
            turns: Tween<double>(begin: 0, end: 0.1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          ),
        );

      case SearchAnimationStyle.elastic:
        return FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1, end: 0.5).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInBack),
            ),
            child: child,
          ),
        );

      case SearchAnimationStyle.slideRight:
        return FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0.3, 0),
            ).animate(animation),
            child: child,
          ),
        );
    }
  }

  Widget _buildSearchEnter(Animation<double> animation, Widget child) {
    switch (widget.animationStyle) {
      case SearchAnimationStyle.fadeSlide:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );

      case SearchAnimationStyle.scale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );

      case SearchAnimationStyle.rotate:
        return FadeTransition(
          opacity: animation,
          child: RotationTransition(
            turns: Tween<double>(begin: -0.1, end: 0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );

      case SearchAnimationStyle.elastic:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            ),
            child: child,
          ),
        );

      case SearchAnimationStyle.slideRight:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.3, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
    }
  }

  Widget _buildIconTransition(Widget child, Animation<double> animation) {
    if (widget.animationStyle == SearchAnimationStyle.rotate) {
      return RotationTransition(turns: animation, child: child);
    }
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    final textField = TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      style: widget.searchTextStyle,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: widget.inputDecoration ??
          InputDecoration(
            hintText: widget.hintText,
            border: InputBorder.none,
          ),
    );

    return AppBar(
      backgroundColor: widget.backgroundColor,
      leading: widget.leading,
      title: Stack(
        alignment: Alignment.centerLeft,
        children: [
          _buildTitleExit(
            animation,
            Text(
              widget.title,
              style: widget.titleTextStyle,
            ),
          ),
          _buildSearchEnter(animation, textField),
        ],
      ),
      actions: [
        ...?widget.actions,
        IconButton(
          tooltip: _searching ? 'Clear' : 'Search',
          icon: AnimatedSwitcher(
            duration: widget.animationDuration,
            transitionBuilder: (child, animation) =>
                _buildIconTransition(child, animation),
            child: Icon(
              _searching ? Icons.close : Icons.search,
              key: ValueKey(_searching),
              color: widget.iconColor,
            ),
          ),
          onPressed: _toggleSearch,
        ),
      ],
    );
  }
}
