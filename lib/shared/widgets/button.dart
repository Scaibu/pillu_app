import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTapZoomEffectButton extends StatefulWidget {
  const CustomTapZoomEffectButton({
    required this.child,
    super.key,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<CustomTapZoomEffectButton> createState() =>
      _CustomTapZoomEffectButtonState();
}

class _CustomTapZoomEffectButtonState extends State<CustomTapZoomEffectButton> {
  double _scale = 1;

  Future<void> _handleTap() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0.9); // Shrink effect
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0.8); // Shrink effect
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0.7); // Shrink effect
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0.6); // Shrink effect
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0.5); // Shrink effect
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0.4); // Shrink effect
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0.3); // Shrink effect
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0.2); // Shrink effect
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0.1); // Shrink effect
    await Future<dynamic>.delayed(const Duration(milliseconds: 50)); //
    setState(() => _scale = 0); // Shrink effect
    await HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.alert);
    widget.onTap?.call();
    setState(() => _scale = 1); // Shrink effect
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 200),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Theme.of(context).primaryColor.withAlpha(30),
              highlightColor: Theme.of(context).primaryColor.withAlpha(20),
              child: widget.child,
            ),
          ),
        ),
      );
}

class CustomSelectionTapEffectButton extends StatefulWidget {
  const CustomSelectionTapEffectButton({
    required this.child,
    super.key,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<CustomSelectionTapEffectButton> createState() =>
      _CustomSelectionTapEffectButtonState();

}

class _CustomSelectionTapEffectButtonState
    extends State<CustomSelectionTapEffectButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await HapticFeedback.heavyImpact();
    await HapticFeedback.vibrate();
    await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    await _controller.reverse();
    widget.onTap?.call();
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
    onTap: _handleTap,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (final BuildContext context, final Widget? child) =>
          Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Soft Glow
                AnimatedOpacity(
                  opacity: _controller.isAnimating ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withAlpha(30),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor.withAlpha(30),
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    onTap: _handleTap,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}