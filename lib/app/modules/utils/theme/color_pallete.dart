import 'package:flutter/material.dart';

///UFF Color Pallete. the alpha parameter can be customized like: ColorPallete.darkBlue(alpha=100).
class AppColors {
  static Color darkBlue({int alpha = 255}) => Color.fromARGB(alpha, 29, 50, 78);
  static Color lightBlue({int alpha = 255}) =>
      Color.fromARGB(alpha, 204, 229, 255);
  static Color mediumBlue({int alpha = 255}) =>
      Color.fromARGB(alpha, 57, 125, 198);
  static Color alternativeDarkBlue({int alpha = 255}) =>
      Color.fromARGB(alpha, 33, 59, 79);
  static Color alternativeMediumBlue({int alpha = 255}) =>
      Color.fromARGB(alpha, 42, 94, 147);

  static LinearGradient darkBlueToBlackGradient({
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: [
        AppColors.darkBlue(),
        Colors.black,
      ],
      begin: begin,
      end: end,
    );
  }

  static LinearGradient appBarTopGradient({
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [
        AppColors.mediumBlue(),
        AppColors.darkBlue(),
      ],
      begin: begin,
      end: end,
    );
  }

  static LinearGradient appBarBottomGradient({
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [
        AppColors.alternativeMediumBlue(),
        AppColors.alternativeDarkBlue(),
      ],
      begin: begin,
      end: end,
    );
  }

  static LinearGradient darkTransparentGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.2),
        Colors.black.withOpacity(0.2),
      ],
    );
  }
}
