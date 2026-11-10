import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'search_animations.dart';
import 'search_controller.dart';
import 'search_design.dart';

/// An app bar with integrated, animated search.
///
/// Use it directly as `Scaffold.appBar`. Pick a look with [design] and a
/// motion with [animationStyle]; everything else has sensible, localized,
/// accessible defaults.
///
/// ```dart
/// Scaffold(
///   appBar: AppBarSearch(
///     title: 'Inbox',
///     design: AppBarSearchDesign.pill,
///     onChanged: (q) => setState(() => query = q),
///   ),
/// )
/// ```
class AppBarSearch extends StatefulWidget implements PreferredSizeWidget {
  const AppBarSearch({
    super.key,
    required this.title,
    this.titleWidget,
    this.design = AppBarSearchDesign.classic,
    this.animationStyle = SearchAnimationStyle.fadeSlide,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onOpen,
    this.onClose,
    this.debounce,
    this.controller,
    this.focusNode,
    this.searchController,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.titleTextStyle,
    this.searchTextStyle,
    this.inputDecoration,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.gradient,
    this.animationDuration = const Duration(milliseconds: 350),
    this.autoFocus = true,
    this.initiallyOpen = false,
    this.showClearButton = true,
    this.closeOnBack = true,
    this.keyboardShortcuts,
    this.toolbarHeight,
    this.bottom,
    this.centerTitle = false,
    this.maxSearchWidth = 560,
    this.wideBreakpoint = 720,
    this.searchIcon,
    this.closeIcon,
    this.searchTooltip,
    this.closeTooltip,
    this.clearTooltip,
    this.textInputAction = TextInputAction.search,
    this.keyboardType,
  });

  /// Title text (also used for accessibility).
  final String title;

  /// Replaces the title text with any widget (logo, avatar + name…).
  final Widget? titleWidget;

  final AppBarSearchDesign design;
  final SearchAnimationStyle animationStyle;

  /// Placeholder; defaults to the localized "Search".
  final String? hintText;

  /// Called as the user types (debounced when [debounce] is set) and with
  /// `''` when the text is cleared or search closes.
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Called when the text is cleared (clear button or closing search).
  final VoidCallback? onClear;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  /// Waits this long after the last keystroke before calling [onChanged]
  /// (great for network search). Submitting flushes immediately.
  final Duration? debounce;

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Opens/closes the search programmatically.
  final AppBarSearchController? searchController;

  /// Leading widget; when null a back or drawer button is implied like
  /// [AppBar] does (see [automaticallyImplyLeading]).
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;

  final TextStyle? titleTextStyle;
  final TextStyle? searchTextStyle;

  /// Replaces the field decoration entirely.
  final InputDecoration? inputDecoration;

  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Color for icons (defaults to the foreground color).
  final Color? iconColor;

  /// Gradient for [AppBarSearchDesign.gradient] (defaults to primary → tertiary).
  final Gradient? gradient;

  final Duration animationDuration;

  /// Focus the field (show the keyboard) when search opens.
  final bool autoFocus;

  /// Start with search open.
  final bool initiallyOpen;

  /// Show an inline clear (×) button while the field has text.
  final bool showClearButton;

  /// The system back gesture / button closes search before leaving the page.
  final bool closeOnBack;

  /// ⌘/Ctrl+K and `/` open search, Esc closes it. Defaults to on for web and
  /// desktop, off on phones.
  final bool? keyboardShortcuts;

  final double? toolbarHeight;

  /// A widget below the toolbar, e.g. a [TabBar].
  final PreferredSizeWidget? bottom;

  final bool centerTitle;

  /// Upper bound for the search field on large screens.
  final double maxSearchWidth;

  /// From this screen width the title stays visible and search opens beside
  /// it (non-classic designs).
  final double wideBreakpoint;

  final Widget? searchIcon;
  final Widget? closeIcon;
  final String? searchTooltip;
  final String? closeTooltip;
  final String? clearTooltip;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? SearchDesignSpec.defaultToolbarHeight(design)) +
        SearchDesignSpec.verticalChrome(design) +
        (bottom?.preferredSize.height ?? 0),
  );

  @override
  State<AppBarSearch> createState() => _AppBarSearchState();
}

class _AppBarSearchState extends State<AppBarSearch> with SingleTickerProviderStateMixin {
  TextEditingController? _ownText;
  FocusNode? _ownFocus;
  AppBarSearchController? _ownSearch;

  TextEditingController get _text => widget.controller ?? _ownText!;
  FocusNode get _focus => widget.focusNode ?? _ownFocus!;
  AppBarSearchController get _search => widget.searchController ?? _ownSearch!;

  late final AnimationController _anim;
  late final CurvedAnimation _curve;
  Timer? _debounce;
  late bool _open;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _ownText = TextEditingController();
    if (widget.focusNode == null) _ownFocus = FocusNode(debugLabel: 'AppBarSearch');
    if (widget.searchController == null) _ownSearch = AppBarSearchController(isOpen: widget.initiallyOpen);
    _open = _search.isOpen;
    _anim = AnimationController(vsync: this, duration: widget.animationDuration, value: _open ? 1 : 0)
      ..addStatusListener(_onStatus);
    _curve = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    _search.addListener(_onSearchController);
    HardwareKeyboard.instance.addHandler(_onKey);
    if (_open && widget.autoFocus) _focusSoon();
  }

  @override
  void didUpdateWidget(AppBarSearch old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      if (widget.controller == null) {
        _ownText = TextEditingController(text: old.controller?.text);
      } else {
        _ownText?.dispose();
        _ownText = null;
      }
    }
    if (old.focusNode != widget.focusNode) {
      if (widget.focusNode == null) {
        _ownFocus = FocusNode(debugLabel: 'AppBarSearch');
      } else {
        _ownFocus?.dispose();
        _ownFocus = null;
      }
    }
    if (old.searchController != widget.searchController) {
      (old.searchController ?? _ownSearch)?.removeListener(_onSearchController);
      if (widget.searchController == null) {
        _ownSearch = AppBarSearchController(isOpen: _open);
      } else {
        _ownSearch?.dispose();
        _ownSearch = null;
      }
      _search.addListener(_onSearchController);
      if (_search.isOpen != _open) _setOpen(_search.isOpen, fromController: true);
    }
    if (old.animationDuration != widget.animationDuration) _anim.duration = widget.animationDuration;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _debounce?.cancel();
    _search.removeListener(_onSearchController);
    _curve.dispose();
    _anim.dispose();
    _ownText?.dispose();
    _ownFocus?.dispose();
    _ownSearch?.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus _) {
    if (mounted) setState(() {}); // toggles Offstage of the hidden layer
  }

  void _onSearchController() {
    if (_search.isOpen != _open) _setOpen(_search.isOpen, fromController: true);
  }

  void _focusSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only if still open: a quick open→close must not pop the keyboard.
      if (mounted && _open) _focus.requestFocus();
    });
  }

  void _setOpen(bool open, {bool fromController = false}) {
    if (_open == open) return;
    setState(() => _open = open);
    if (!fromController) open ? _search.open() : _search.close();
    if (open) {
      _anim.forward();
      widget.onOpen?.call();
      if (widget.autoFocus) _focusSoon();
    } else {
      _anim.reverse();
      _debounce?.cancel();
      final hadText = _text.text.isNotEmpty;
      _text.clear();
      if (hadText) widget.onChanged?.call('');
      widget.onClear?.call();
      _focus.unfocus();
      widget.onClose?.call();
    }
  }

  void _changed(String value) {
    final d = widget.debounce;
    if (d == null || d == Duration.zero) {
      widget.onChanged?.call(value);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(d, () {
      if (mounted) widget.onChanged?.call(value);
    });
  }

  void _submitted(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      widget.onChanged?.call(value);
    }
    widget.onSubmitted?.call(value);
  }

  void _clearText() {
    _debounce?.cancel();
    final had = _text.text.isNotEmpty;
    _text.clear();
    if (had) widget.onChanged?.call('');
    widget.onClear?.call();
    _focus.requestFocus();
  }

  bool get _shortcutsEnabled =>
      widget.keyboardShortcuts ??
      (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent || !mounted || !_shortcutsEnabled) return false;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return false;
    final key = e.logicalKey;
    if (key == LogicalKeyboardKey.escape && _open) {
      _setOpen(false);
      return true;
    }
    final hw = HardwareKeyboard.instance;
    if ((hw.isMetaPressed || hw.isControlPressed) && key == LogicalKeyboardKey.keyK) {
      _open ? _focus.requestFocus() : _setOpen(true);
      return true;
    }
    if (key == LogicalKeyboardKey.slash && !_open && !_typingElsewhere()) {
      _setOpen(true);
      return true;
    }
    return false;
  }

  bool _typingElsewhere() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    return ctx != null && ctx.findAncestorStateOfType<EditableTextState>() != null;
  }

  // -------------------------------------------------------------- building

  Widget _inert({required bool active, required Widget child}) => IgnorePointer(
    ignoring: !active,
    child: ExcludeSemantics(
      excluding: !active,
      child: ExcludeFocus(excluding: !active, child: child),
    ),
  );

  Widget? _impliedLeading(BuildContext context) {
    if (widget.leading != null) return widget.leading;
    if (!widget.automaticallyImplyLeading) return null;
    if (Scaffold.maybeOf(context)?.hasDrawer ?? false) return const DrawerButton();
    final route = ModalRoute.of(context);
    if (route?.impliesAppBarDismissal ?? false) {
      return route is PageRoute && route.fullscreenDialog ? const CloseButton() : const BackButton();
    }
    return null;
  }

  Widget _title(ThemeData theme, SearchDesignSpec spec) {
    final custom = widget.titleWidget;
    if (custom != null) return custom;
    final base =
        widget.titleTextStyle ?? theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge ?? const TextStyle();
    final style = base.copyWith(
      color: widget.titleTextStyle?.color ?? spec.foreground,
      fontWeight:
          widget.titleTextStyle?.fontWeight ?? (spec.design == AppBarSearchDesign.classic ? null : FontWeight.w700),
      letterSpacing: widget.titleTextStyle?.letterSpacing ?? (spec.design == AppBarSearchDesign.classic ? null : -0.3),
    );
    return Semantics(
      header: true,
      child: Text(widget.title, style: style, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
    );
  }

  Widget _field(ThemeData theme, SearchDesignSpec spec, MaterialLocalizations loc) {
    final cs = theme.colorScheme;
    final hint = widget.hintText ?? loc.searchFieldLabel;
    final base = widget.searchTextStyle ?? theme.textTheme.bodyLarge ?? const TextStyle();
    final style = base.copyWith(color: widget.searchTextStyle?.color ?? spec.foreground);
    final iconColor = widget.iconColor ?? spec.hint;
    final filled = spec.filledField && widget.inputDecoration == null;

    final clear = !widget.showClearButton
        ? null
        : ListenableBuilder(
            listenable: _text,
            builder: (context, _) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: ScaleTransition(scale: a, child: c),
              ),
              child: _text.text.isEmpty
                  ? const SizedBox(width: 0, height: 0, key: ValueKey('empty'))
                  : IconButton(
                      key: const ValueKey('clear'),
                      tooltip: widget.clearTooltip ?? loc.clearButtonTooltip,
                      onPressed: _clearText,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.close_rounded, size: 20, color: iconColor),
                    ),
            ),
          );

    final decoration =
        widget.inputDecoration ??
        InputDecoration(
          hintText: hint,
          hintStyle: style.copyWith(color: spec.hint),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: filled ? const EdgeInsets.symmetric(vertical: 10) : EdgeInsets.zero,
          prefixIcon: filled ? Icon(Icons.search_rounded, color: iconColor, size: 22) : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 40),
          suffixIcon: clear,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        );

    final field = TextField(
      controller: _text,
      focusNode: _focus,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      textAlignVertical: TextAlignVertical.center,
      style: style,
      cursorColor: spec.design == AppBarSearchDesign.gradient ? spec.foreground : cs.primary,
      onChanged: _changed,
      onSubmitted: _submitted,
      decoration: decoration,
    );

    if (!filled) return field;
    return ListenableBuilder(
      listenable: _focus,
      builder: (context, child) {
        final focusBorder = spec.fieldFocusBorder;
        final focused = _focus.hasFocus && focusBorder != null && focusBorder.a > 0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46,
          decoration: BoxDecoration(
            color: spec.fieldFill,
            borderRadius: BorderRadius.circular(spec.fieldRadius),
            border: Border.all(
              color: focused ? focusBorder : (spec.fieldBorder ?? Colors.transparent),
              width: focused ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: field,
    );
  }

  Widget _toggleButton(SearchTransitions tr, MaterialLocalizations loc, SearchDesignSpec spec) {
    final color = widget.iconColor ?? spec.foreground;
    return IconButton(
      tooltip: _open ? (widget.closeTooltip ?? loc.closeButtonTooltip) : (widget.searchTooltip ?? loc.searchFieldLabel),
      onPressed: () => _setOpen(!_open),
      icon: AnimatedSwitcher(
        duration: _anim.duration ?? widget.animationDuration,
        transitionBuilder: tr.icon,
        child: KeyedSubtree(
          key: ValueKey(_open),
          child: IconTheme.merge(
            data: IconThemeData(color: color),
            child: _open
                ? (widget.closeIcon ?? const Icon(Icons.close_rounded))
                : (widget.searchIcon ?? const Icon(Icons.search_rounded)),
          ),
        ),
      ),
    );
  }

  Widget _middle(ThemeData theme, SearchDesignSpec spec, SearchTransitions tr, MaterialLocalizations loc, bool wide) {
    final title = _title(theme, spec);
    final field = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxSearchWidth),
      child: _field(theme, spec, loc),
    );

    if (spec.design == AppBarSearchDesign.spotlight) return _spotlight(theme, spec, loc, title, wide);

    final fieldLayer = Offstage(
      offstage: _anim.isDismissed,
      child: _inert(
        active: _open,
        child: tr.fieldEnter(_curve, Align(alignment: AlignmentDirectional.centerStart, child: field)),
      ),
    );

    if (wide && spec.design != AppBarSearchDesign.classic) {
      // Large screens: keep the title, open search beside it.
      return Row(
        children: [
          Flexible(child: title),
          const SizedBox(width: 24),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Offstage(
                offstage: _anim.isDismissed,
                child: _inert(active: _open, child: tr.fieldEnter(_curve, field)),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        Offstage(
          offstage: _anim.isCompleted,
          child: _inert(
            active: !_open,
            child: tr.titleExit(_curve, Align(alignment: AlignmentDirectional.centerStart, child: title)),
          ),
        ),
        fieldLayer,
      ],
    );
  }

  Widget _spotlight(ThemeData theme, SearchDesignSpec spec, MaterialLocalizations loc, Widget title, bool wide) {
    final cs = theme.colorScheme;
    final apple = defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS;
    final duration = _anim.duration ?? widget.animationDuration;
    final hideTitle = _open && !wide;

    final trigger = Semantics(
      button: true,
      label: widget.searchTooltip ?? loc.searchFieldLabel,
      excludeSemantics: true,
      child: Material(
        color: spec.fieldFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spec.fieldRadius),
          side: BorderSide(color: spec.fieldBorder ?? Colors.transparent),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _setOpen(true),
          child: SizedBox(
            height: 46,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded, color: spec.hint, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.hintText ?? loc.searchFieldLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(color: spec.hint),
                  ),
                ),
                if (_shortcutsEnabled) ...[
                  _KeyCap(label: apple ? '⌘' : 'Ctrl', color: spec.hint, fill: cs.surface),
                  const SizedBox(width: 4),
                  _KeyCap(label: 'K', color: spec.hint, fill: cs.surface),
                  const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Row(
      children: [
        AnimatedSize(
          duration: duration,
          curve: Curves.easeInOutCubic,
          child: hideTitle
              ? const SizedBox(width: 0, height: 0)
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 320 : 160),
                    child: title,
                  ),
                ),
        ),
        Expanded(
          child: Align(
            alignment: wide ? Alignment.center : AlignmentDirectional.centerEnd,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxSearchWidth),
              child: AnimatedSwitcher(
                duration: duration ~/ 2,
                child: _open
                    ? KeyedSubtree(key: const ValueKey('field'), child: _field(theme, spec, loc))
                    : KeyedSubtree(key: const ValueKey('trigger'), child: trigger),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _anim.duration = reduce ? Duration.zero : widget.animationDuration;
    final spec = SearchDesignSpec.resolve(
      widget.design,
      theme,
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      gradient: widget.gradient,
      toolbarHeight: widget.toolbarHeight,
    );
    final tr = SearchTransitions(widget.animationStyle, Directionality.of(context));
    // Responsive on the bar's own width (split views, side-by-side panes and
    // resizable desktop windows), falling back to the screen width.
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.hasBoundedWidth ? box.maxWidth : (MediaQuery.maybeSizeOf(context)?.width ?? 0);
        return _buildBar(context, theme, loc, spec, tr, width >= widget.wideBreakpoint);
      },
    );
  }

  Widget _buildBar(
    BuildContext context,
    ThemeData theme,
    MaterialLocalizations loc,
    SearchDesignSpec spec,
    SearchTransitions tr,
    bool wide,
  ) {
    final middle = _middle(theme, spec, tr, loc, wide);
    final showToggle = spec.design != AppBarSearchDesign.spotlight || _open;
    final actions = <Widget>[...?widget.actions, if (showToggle) _toggleButton(tr, loc, spec)];

    Widget bar;
    if (spec.design == AppBarSearchDesign.classic) {
      bar = AppBar(
        backgroundColor: widget.backgroundColor,
        foregroundColor: widget.foregroundColor,
        leading: widget.leading,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        toolbarHeight: widget.toolbarHeight,
        centerTitle: widget.centerTitle,
        iconTheme: widget.iconColor == null ? null : IconThemeData(color: widget.iconColor),
        actionsIconTheme: widget.iconColor == null ? null : IconThemeData(color: widget.iconColor),
        title: middle,
        actions: actions,
        bottom: widget.bottom,
      );
    } else {
      bar = _DesignedBar(
        spec: spec,
        leading: _impliedLeading(context),
        middle: middle,
        actions: actions,
        bottom: widget.bottom,
        centerTitle: widget.centerTitle && !_open,
        iconColor: widget.iconColor ?? spec.foreground,
      );
    }

    if (widget.closeOnBack) {
      bar = PopScope<Object?>(
        canPop: !_open,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _open) _setOpen(false);
        },
        child: bar,
      );
    }
    return bar;
  }
}

/// Toolbar shell for the non-classic designs.
class _DesignedBar extends StatelessWidget {
  const _DesignedBar({
    required this.spec,
    required this.leading,
    required this.middle,
    required this.actions,
    required this.bottom,
    required this.centerTitle,
    required this.iconColor,
  });

  final SearchDesignSpec spec;
  final Widget? leading;
  final Widget middle;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toolbar = IconTheme.merge(
      data: IconThemeData(color: iconColor),
      child: SizedBox(
        height: spec.toolbarHeight,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: leading == null ? 4 : 4, end: 6),
          child: NavigationToolbar(
            leading: leading,
            middle: middle,
            trailing: actions.isEmpty ? null : Row(mainAxisSize: MainAxisSize.min, children: actions),
            centerMiddle: centerTitle,
            middleSpacing: leading == null ? 12 : NavigationToolbar.kMiddleSpacing,
          ),
        ),
      ),
    );

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (spec.design == AppBarSearchDesign.floating)
          Padding(
            padding: spec.margin,
            // Material elevation = a true platform shadow on every renderer.
            child: Material(
              color: spec.capsule,
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.45 : 0.30),
              surfaceTintColor: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: spec.barRadius ?? BorderRadius.zero,
                side: spec.fieldBorder == null ? BorderSide.none : BorderSide(color: spec.fieldBorder!),
              ),
              child: toolbar,
            ),
          )
        else
          toolbar,
        ?bottom,
      ],
    );
    content = SafeArea(bottom: false, child: content);

    final border = spec.bottomBorder == null ? null : Border(bottom: BorderSide(color: spec.bottomBorder!));
    Widget surface = DecoratedBox(
      decoration: BoxDecoration(color: spec.background, gradient: spec.gradient, border: border),
      child: content,
    );
    if (spec.blurSigma > 0) {
      surface = ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: spec.blurSigma, sigmaY: spec.blurSigma),
          child: surface,
        ),
      );
    }

    final bgForBrightness =
        spec.gradient?.colors.first ??
        (spec.background != null && spec.background!.a > 0.5 ? spec.background! : theme.colorScheme.surface);
    final darkBg = ThemeData.estimateBrightnessForColor(bgForBrightness) == Brightness.dark;
    final overlay = (darkBg ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
      statusBarColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Material(type: MaterialType.transparency, child: surface),
      ),
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap({required this.label, required this.color, required this.fill});
  final String label;
  final Color color;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color, height: 1.2),
      ),
    );
  }
}
