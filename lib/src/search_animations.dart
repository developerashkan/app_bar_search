import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// How the title leaves and the search field arrives.
enum SearchAnimationStyle {
  /// Title slides up and fades; the field rises in.
  fadeSlide,

  /// Gentle zoom with a soft overshoot.
  scale,

  /// Playful spin.
  rotate,

  /// Springy pop.
  elastic,

  /// Horizontal slide toward the end edge (mirrored in RTL).
  slideRight,

  /// 3D shutter flip.
  flipVertical,

  /// The field grows out of the search button (end → start).
  revealRight,

  /// Title pushes up, field slides up from below.
  slideUp,

  /// Title recedes, field lands on top.
  zoomOut,

  /// Field slides in with a bounce.
  bounce,
}

/// Builds the title-exit and field-enter transitions for a style.
///
/// Horizontal motion is mirrored for right-to-left text so every style reads
/// naturally in Arabic, Hebrew, Persian, etc.
class SearchTransitions {
  const SearchTransitions(this.style, this.textDirection);

  final SearchAnimationStyle style;
  final TextDirection textDirection;

  double get _dir => textDirection == TextDirection.rtl ? -1 : 1;

  Widget titleExit(Animation<double> a, Widget child) {
    Animation<double> fade([Interval? i]) =>
        Tween<double>(begin: 1, end: 0).animate(i == null ? a : CurvedAnimation(parent: a, curve: i));
    switch (style) {
      case SearchAnimationStyle.fadeSlide:
        return FadeTransition(
          opacity: fade(),
          child: SlideTransition(
            position: Tween(
              begin: Offset.zero,
              end: const Offset(0, -0.5),
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeIn)),
            child: child,
          ),
        );
      case SearchAnimationStyle.scale:
        return FadeTransition(
          opacity: fade(),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
            child: child,
          ),
        );
      case SearchAnimationStyle.rotate:
        return FadeTransition(
          opacity: fade(),
          child: RotationTransition(
            turns: Tween<double>(begin: 0, end: 0.1 * _dir).animate(CurvedAnimation(parent: a, curve: Curves.easeIn)),
            child: child,
          ),
        );
      case SearchAnimationStyle.elastic:
        return FadeTransition(
          opacity: fade(const Interval(0, 0.5)),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1, end: 0.5).animate(CurvedAnimation(parent: a, curve: Curves.easeInBack)),
            child: child,
          ),
        );
      case SearchAnimationStyle.slideRight:
        return FadeTransition(
          opacity: fade(),
          child: SlideTransition(
            position: Tween(begin: Offset.zero, end: Offset(0.2 * _dir, 0)).animate(a),
            child: child,
          ),
        );
      case SearchAnimationStyle.flipVertical:
        return AnimatedBuilder(
          animation: a,
          child: child,
          builder: (context, child) => Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(-a.value * math.pi / 2),
            alignment: Alignment.center,
            child: Opacity(opacity: (1 - a.value).clamp(0.0, 1.0), child: child),
          ),
        );
      case SearchAnimationStyle.revealRight:
        return FadeTransition(opacity: fade(const Interval(0, 0.4)), child: child);
      case SearchAnimationStyle.slideUp:
        return FadeTransition(
          opacity: fade(),
          child: SlideTransition(
            position: Tween(
              begin: Offset.zero,
              end: const Offset(0, -1),
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
            child: child,
          ),
        );
      case SearchAnimationStyle.zoomOut:
        return FadeTransition(
          opacity: fade(),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1, end: 0.5).animate(CurvedAnimation(parent: a, curve: Curves.easeInQuad)),
            child: child,
          ),
        );
      case SearchAnimationStyle.bounce:
        return FadeTransition(
          opacity: fade(const Interval(0, 0.5)),
          child: SlideTransition(
            position: Tween(begin: Offset.zero, end: Offset(-0.2 * _dir, 0)).animate(a),
            child: child,
          ),
        );
    }
  }

  Widget fieldEnter(Animation<double> a, Widget child) {
    switch (style) {
      case SearchAnimationStyle.fadeSlide:
        return FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
            child: child,
          ),
        );
      case SearchAnimationStyle.scale:
        return FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      case SearchAnimationStyle.rotate:
        return FadeTransition(
          opacity: a,
          child: RotationTransition(
            turns: Tween<double>(
              begin: -0.1 * _dir,
              end: 0,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      case SearchAnimationStyle.elastic:
        return FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: a, curve: Curves.elasticOut)),
            child: child,
          ),
        );
      case SearchAnimationStyle.slideRight:
        return FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(
              begin: Offset(-0.2 * _dir, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      case SearchAnimationStyle.flipVertical:
        return AnimatedBuilder(
          animation: a,
          child: child,
          builder: (context, child) => Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX((1 - a.value) * math.pi / 2),
            alignment: Alignment.center,
            child: Opacity(opacity: a.value.clamp(0.0, 1.0), child: child),
          ),
        );
      case SearchAnimationStyle.revealRight:
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: SizeTransition(
            sizeFactor: CurvedAnimation(parent: a, curve: Curves.easeOutExpo),
            axis: Axis.horizontal,
            alignment: AlignmentDirectional.centerEnd,
            child: FadeTransition(
              opacity: CurvedAnimation(parent: a, curve: const Interval(0.2, 1)),
              child: child,
            ),
          ),
        );
      case SearchAnimationStyle.slideUp:
        return FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      case SearchAnimationStyle.zoomOut:
        return FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.5, end: 1).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      case SearchAnimationStyle.bounce:
        return FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(
              begin: Offset(-0.5 * _dir, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.bounceOut)),
            child: child,
          ),
        );
    }
  }

  Widget icon(Widget child, Animation<double> a) {
    if (style == SearchAnimationStyle.rotate) return RotationTransition(turns: a, child: child);
    if (style == SearchAnimationStyle.flipVertical) {
      return AnimatedBuilder(
        animation: a,
        child: child,
        builder: (context, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(a.value * math.pi),
          child: child,
        ),
      );
    }
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: a, curve: Curves.elasticOut)),
      child: child,
    );
  }
}
