import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TypingCursor extends HookWidget {
  const TypingCursor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final opacity = useState<double>(0.0);
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 1, end: opacity.value),
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
      builder: (_, double o, __) => Opacity(
        opacity: o,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          width: 6,
          height: 12,
          color: Colors.black,
        ),
      ),
      onEnd: () {
        opacity.value = opacity.value == 1.0 ? 0.0 : 1.0;
      },
    );
  }
}
