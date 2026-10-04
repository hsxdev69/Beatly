import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration pauseDuration;
  final Duration scrollDuration;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.pauseDuration = const Duration(seconds: 2),
    this.scrollDuration = const Duration(seconds: 8),
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    _isScrolling = true;
    while (_isScrolling && mounted) {
      await Future.delayed(widget.pauseDuration);
      if (!_isScrolling || !mounted || !_scrollController.hasClients) break;
      await _scrollController.animateTo(
        maxScroll,
        duration: widget.scrollDuration,
        curve: Curves.linear,
      );
      await Future.delayed(widget.pauseDuration);
      if (!_isScrolling || !mounted || !_scrollController.hasClients) break;
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      _startScrolling();
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
      ),
    );
  }
}
