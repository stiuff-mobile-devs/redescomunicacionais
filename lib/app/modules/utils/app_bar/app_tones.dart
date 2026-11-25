import 'package:flutter/material.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/color_pallete.dart';

// Tom de cor de uma tela. Define a cor do degradê da AppBar (AppBars.build)
// e deve ser reaproveitado em outros destaques da mesma tela (ex.: cards da
// central da matéria), para que tudo combine.
//
// Nunca passe cores soltas para a AppBar: escolha (ou crie) um tom aqui.
enum AppTone {
  brand,
  success,
  info,
  warning,
  danger,
  deleted;

  Color get color {
    switch (this) {
      case AppTone.brand:
        return AppColors.mediumBlue();
      case AppTone.success:
        return Colors.green;
      case AppTone.info:
        return Colors.lightBlue;
      case AppTone.warning:
        return Colors.amber.shade700;
      case AppTone.danger:
        return Colors.redAccent;
      case AppTone.deleted:
        return Colors.deepOrange;
    }
  }
}
