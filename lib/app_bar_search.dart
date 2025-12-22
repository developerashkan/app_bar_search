import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    return AppBar(
      backgroundColor: widget.backgroundColor,
      leading: widget.leading,
      title: Stack(
        alignment: Alignment.centerLeft,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(fade),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0, -0.2),
              ).animate(fade),
              child: Text(
                widget.title,
                style: widget.titleTextStyle,
              ),
            ),
          ),

          FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(fade),
              child: TextField(
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
              ),
            ),
          ),
        ],
      ),
      actions: [
        ...?widget.actions,
        IconButton(
          tooltip: _searching ? 'Clear' : 'Search',
          icon: AnimatedSwitcher(
            duration: widget.animationDuration,
            transitionBuilder: (child, animation) =>
                RotationTransition(turns: animation, child: child),
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