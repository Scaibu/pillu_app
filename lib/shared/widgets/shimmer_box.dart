import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    required this.height,
    super.key,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.duration = const Duration(seconds: 2),
    this.interval = const Duration(milliseconds: 500),
    this.shimmerColor = Colors.grey,
    this.colorOpacity = 0.8,
  });

  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final Duration duration;
  final Duration interval;
  final Color shimmerColor;
  final double colorOpacity;

  @override
  Widget build(final BuildContext context) => Shimmer(
        duration: duration,
        interval: interval,
        color: shimmerColor,
        colorOpacity: colorOpacity,
        child: Container(
          height: height,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
          ),
        ),
      );
}
