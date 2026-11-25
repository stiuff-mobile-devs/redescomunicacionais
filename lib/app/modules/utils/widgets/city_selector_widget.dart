import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_bars.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_tones.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

// Seletor de cidade usado na Home, no Perfil (cidade favorita) e no Admin.
// - title/subtitle: cabeçalho que rola junto com a lista
// - onAllCitiesSelected: se informado, mostra o card "Todas as cidades" no topo
class CitySelectorWidget extends StatelessWidget {
  final Function(String cityName) onCitySelected;
  final VoidCallback? onAllCitiesSelected;
  final String? title;
  final String? subtitle;

  CitySelectorWidget({
    super.key,
    required this.onCitySelected,
    this.onAllCitiesSelected,
    this.title,
    this.subtitle,
  });

  static const double _cardHeight = 120;
  static const double _radius = 16;

  final Map<String, String> _cityImageAssets = {
    'São Sebastião do Alto': 'assets/images/cidades/saosebastiaodoalto.jpg',
    'Macuco': 'assets/images/cidades/macuco.jpg',
    'Rio das Flores': 'assets/images/cidades/riodasflores.jpg',
    'Comendador Levy Gasparian': 'assets/images/cidades/levygasparian.jpg',
    'Laje do Muriaé': 'assets/images/cidades/lajedomuriae.jpg',
    'São José de Ubá': 'assets/images/cidades/saojosedeuba.jpg',
    'default': 'assets/images/cidades/default_city.jpg',
  };

  @override
  Widget build(BuildContext context) {
    final cityEntries = _cityImageAssets.entries
        .where((entry) => entry.key != 'default')
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (title != null) _buildHeader(context),
        if (onAllCitiesSelected != null) _buildAllCitiesCard(context),
        for (final entry in cityEntries)
          _buildCityCard(context, entry.key, entry.value),
      ],
    );
  }

  // Cabeçalho: ícone + título + subtítulo, nas cores do tema
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = AppTone.brand.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_rounded, color: accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Moldura comum aos cards (mesmo tamanho, raio e borda)
  Widget _cardFrame(
    BuildContext context, {
    required VoidCallback onTap,
    required Widget child,
  }) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        elevation: 3,
        shadowColor: Colors.black38,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(
            color: isLight
                ? Theme.of(context).colorScheme.outlineVariant
                : Colors.white24,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(height: _cardHeight, child: child),
        ),
      ),
    );
  }

  // Nome + seta, alinhados embaixo (usado nos dois tipos de card)
  Widget _cardLabel(String name, {String? caption}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.15,
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // "Todas as cidades": degradê da marca com um globo de marca d'água
  Widget _buildAllCitiesCard(BuildContext context) {
    final colors = AppBars.gradientColors(
      AppTone.brand,
      Theme.of(context).brightness,
    );

    return _cardFrame(
      context,
      onTap: onAllCitiesSelected!,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            right: -18,
            top: -18,
            child: Icon(
              Icons.public_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          _cardLabel(
            LocaleKeys.allCities.tr,
            caption: LocaleKeys.allCitiesSubtitle.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(BuildContext context, String cityName, String imagePath) {
    return _cardFrame(
      context,
      onTap: () => onCitySelected(cityName),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.white10,
              child: const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.white54,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
          ),
          _cardLabel(cityName),
        ],
      ),
    );
  }
}
