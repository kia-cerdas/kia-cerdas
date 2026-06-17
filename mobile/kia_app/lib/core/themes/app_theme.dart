import 'package:flutter/material.dart';

enum TrimesterStatus { locked, active, completed }

class TrimesterTheme {
  static const Color background = Color(0xFFF8FAFC);

  static const List<Color> t1Gradient = [Color(0xFF2196F3), Color(0xFF1976D2)];
  static const Color t1Primary = Color(0xFF2196F3);

  static const List<Color> t2Gradient = [Color(0xFF9575CD), Color(0xFF7E57C2)];
  static const Color t2Primary = Color(0xFF7E57C2);

  static const List<Color> t3Gradient = [Color(0xFF4DB6AC), Color(0xFF009688)];
  static const Color t3Primary = Color(0xFF009688);

  static Color getThemeColor(int trimester) {
    if (trimester == 1) return t1Primary;
    if (trimester == 2) return t2Primary;
    return t3Primary;
  }

  static List<Color> getGradient(int trimester) {
    if (trimester == 1) return t1Gradient;
    if (trimester == 2) return t2Gradient;
    return t3Gradient;
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: TrimesterTheme.t1Primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TrimesterTheme.t1Primary,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: TrimesterTheme.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}