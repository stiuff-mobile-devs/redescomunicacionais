import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BlinkingLoadingIcon extends StatefulWidget {
  const BlinkingLoadingIcon({
    super.key,
    this.size = 40,
    this.color = Colors.black,
    this.assetPath = 'assets/icons/new-icon-white.svg',
    this.duration = const Duration(milliseconds: 600),
  });

  final double size;
  final Color color;
  final String assetPath;
  final Duration duration;

  @override
  State<BlinkingLoadingIcon> createState() => _BlinkingLoadingIconState();
}

class _BlinkingLoadingIconState extends State<BlinkingLoadingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FadeTransition(
        opacity: _opacity,
        child: SvgPicture.asset(
          widget.assetPath,
          width: widget.size,
          height: widget.size,
          colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
