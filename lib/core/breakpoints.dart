import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double small = 600;
  static const double medium = 900;
  static const double large = 1200;

  static bool isSmall(BuildContext context) => MediaQuery.sizeOf(context).width < small;
  static bool isMedium(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= small && w < medium;
  }
  static bool isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= medium;
  static bool isLarge(BuildContext context) => MediaQuery.sizeOf(context).width >= large;
}
