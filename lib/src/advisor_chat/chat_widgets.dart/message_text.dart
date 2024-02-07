import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class CustomAnimatedText extends StatefulWidget {
  final String messageContent;

  const CustomAnimatedText({Key? key, required this.messageContent})
      : super(key: key);

  @override
  _CustomAnimatedTextState createState() => _CustomAnimatedTextState();
}

class _CustomAnimatedTextState extends State<CustomAnimatedText> {
  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      isRepeatingAnimation: false,
      totalRepeatCount: 0,
      animatedTexts: [
        TyperAnimatedText(
          widget.messageContent,
          speed: const Duration(milliseconds: 30),
        ),
      ],
    );
  }
}
