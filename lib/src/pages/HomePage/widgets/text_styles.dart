import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle title = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );

  static final TextStyle Secondtitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    foreground: Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Color(0xFF1c1c2e),
  );

  static const TextStyle subtitle = TextStyle(
    color: Color(0xFF7B7A83),
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static const TextStyle bodyText = TextStyle(
    color: Color(0xFF7B7A83),
    fontSize: 16,
  );

  static const TextStyle searchField = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  static const TextStyle infoText = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}