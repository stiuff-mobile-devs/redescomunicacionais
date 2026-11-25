import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Foto de perfil redonda. A foto fica guardada no aparelho depois de carregar
// uma vez (aparece sem internet); sem foto, sem internet na primeira vez ou com
// erro, mostra um ícone de pessoa (nunca quebra a tela).
class UserAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const UserAvatar({
    super.key,
    required this.url,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color background = backgroundColor ?? scheme.surfaceContainerHighest;
    final Color foreground = iconColor ?? scheme.onSurfaceVariant;
    final String imageUrl = url?.trim() ?? '';

    Widget placeholder() => CircleAvatar(
          radius: radius,
          backgroundColor: background,
          child: Icon(Icons.person_outline, size: radius, color: foreground),
        );

    if (imageUrl.isEmpty) return placeholder();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (_, image) => CircleAvatar(
        radius: radius,
        backgroundColor: background,
        backgroundImage: image,
      ),
      placeholder: (_, __) => placeholder(),
      errorWidget: (_, __, ___) => placeholder(),
    );
  }
}
