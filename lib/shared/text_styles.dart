import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle buildJostTextStyle({
  final FontWeight? fontWeight,
  final double? fontSize,
  final Color? color,
}) =>
    GoogleFonts.jost(
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? Colors.black87,
    );

class LuxuryTextField extends StatefulWidget {
  const LuxuryTextField({
    required this.controller,
    required this.focusNode,
    required this.labelText,
    required this.hintText,
    super.key,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLength,
    this.enabled,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.hidePrefixIcon,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final String hintText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool? enabled;
  final int? maxLines;
  final Widget? prefixIcon;
  final bool? hidePrefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<LuxuryTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  String? _errorText;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1, end: 1.03), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.03, end: 1), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1, curve: Curves.easeInOutCubic),
      ),
    );

    widget.focusNode.addListener(_handleFocusChange);
  }

  Future<void> _handleFocusChange() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
    if (_isFocused) {
      await _animationController.forward();
      if (!mounted) {
        return;
      }
      await HapticFeedback.lightImpact();
    } else {
      await _animationController.reverse();
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange); // Add this
    _animationController.dispose();
    super.dispose();
  }

  Color _getFieldColor(final ThemeData theme) {
    if (_errorText != null) {
      return theme.colorScheme.error.withOpacity(0.1);
    }
    if (_isFocused) {
      return theme.colorScheme.primary.withOpacity(0.1);
    }
    if (_isHovered) {
      return theme.colorScheme.surface.withOpacity(0.9);
    }
    return theme.colorScheme.surface;
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return MouseRegion(
      onEnter: (final _) => setState(() => _isHovered = true),
      onExit: (final _) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (final BuildContext context, final Widget? child) =>
            Transform.scale(
          scale:
              _isFocused ? _scaleAnimation.value * _pulseAnimation.value : 1.0,
          child: child,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    inputFormatters: widget.inputFormatters,
                    maxLength: widget.maxLength,
                    enabled: widget.enabled,
                    style: buildJostTextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    validator: (final String? value) {
                      final String? error = widget.validator?.call(value);
                      setState(() => _errorText = error);
                      return error;
                    },
                    maxLines: widget.maxLines,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    decoration: InputDecoration(
                      labelText: widget.labelText,
                      hintText: widget.hintText,
                      filled: true,
                      fillColor: _getFieldColor(theme),
                      border: _buildBorder(theme),
                      enabledBorder: _buildBorder(theme),
                      focusedBorder: _buildFocusedBorder(theme),
                      errorBorder: _buildErrorBorder(theme),
                      focusedErrorBorder: _buildErrorBorder(theme),
                      contentPadding:
                          widget.contentPadding ?? const EdgeInsets.all(16),
                      prefixIcon: (widget.hidePrefixIcon ?? false)
                          ? null
                          : widget.prefixIcon ?? _buildLeadingIcon(theme),
                      suffixIcon:
                          widget.suffixIcon ?? _buildTrailingIcon(theme),
                      labelStyle: buildJostTextStyle(
                        color: _isFocused
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      hintStyle: buildJostTextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.normal,
                      ),
                      errorStyle: buildJostTextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (final String value) {
                      setState(() {});
                      if (_errorText != null) {
                        widget.validator?.call(value);
                      }
                    },
                  ),
                ),
                if (_isFocused)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _buildCharacterCount(theme),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(final ThemeData theme) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 300),
          turns: _isFocused ? 0.125 : 0,
          child: Icon(
            Icons.edit_outlined,
            color: _isFocused
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.5),
            size: _isFocused ? 22 : 20,
          ),
        ),
      );

  Widget _buildTrailingIcon(final ThemeData theme) {
    if (widget.controller.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (_isFocused)
          IconButton(
            icon: Icon(
              Icons.clear,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            onPressed: () {
              widget.controller.clear();
              setState(() {});
            },
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          child: Icon(
            _errorText != null
                ? Icons.error_outline
                : Icons.check_circle_outline,
            color: _errorText != null
                ? theme.colorScheme.error
                : theme.colorScheme.primary.withOpacity(0.7),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterCount(final ThemeData theme) {
    if (widget.maxLength == null) {
      return const SizedBox.shrink();
    }

    final int count = widget.controller.text.length;
    final bool isNearLimit = count > (widget.maxLength! * 0.8);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isFocused ? 1.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isNearLimit
              ? theme.colorScheme.error.withOpacity(0.1)
              : theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count/${widget.maxLength}',
          style: buildJostTextStyle(
            color: isNearLimit
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(final ThemeData theme) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
      );

  OutlineInputBorder _buildFocusedBorder(final ThemeData theme) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      );

  OutlineInputBorder _buildErrorBorder(final ThemeData theme) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.error.withOpacity(0.5),
          width: 2,
        ),
      );
}
