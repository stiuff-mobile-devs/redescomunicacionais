import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/blinking_loading_icon.dart';

// Tipo da mensagem: define ícone e cor
enum PopupType { success, error, warning, info }

// Opção de uma lista de escolha (AppPopups.choose)
class PopupOption<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;
  final Color? color;

  const PopupOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.color,
  });
}

// Ponto único para todos os pop-ups do app:
// - snackbars: success / error / warning / info
// - confirmações, escolhas, campos de texto e conteúdos livres: bottom sheet
// - avisos simples: diálogo central (alert)
// - carregamento bloqueante: showLoading / hideLoading
//
// Nunca monte AlertDialog/SnackBar/showModalBottomSheet direto nas telas.
class AppPopups {
  AppPopups._();

  static BuildContext get _context => Get.context!;

  // ===========================================================================
  // SNACKBARS
  // ===========================================================================

  static void success(String message) =>
      show(message, type: PopupType.success);

  static void error(String message) => show(message, type: PopupType.error);

  static void warning(String message) =>
      show(message, type: PopupType.warning);

  static void info(String message) => show(message, type: PopupType.info);

  // Snackbar flutuante embaixo, com ícone por tipo. Usa o ScaffoldMessenger
  // (e não o GetSnackBar) para não interferir no Get.back() das telas.
  static void show(
    String message, {
    PopupType type = PopupType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    final context = Get.context;
    final messenger =
        context == null ? null : ScaffoldMessenger.maybeOf(context);

    if (messenger == null) {
      debugPrint('AppPopups: sem ScaffoldMessenger para mostrar "$message"');
      return;
    }

    final accent = _snackAccent(type);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          backgroundColor: const Color(0xFF1F2128),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          dismissDirection: DismissDirection.horizontal,
          duration: duration ??
              (type == PopupType.error
                  ? const Duration(seconds: 4)
                  : const Duration(seconds: 3)),
          content: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon(type), color: accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: accent,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }

  // Remove snackbars visíveis (ex.: ao trocar o tema)
  static void clear() {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
  }

  // ===========================================================================
  // DIÁLOGO CENTRAL (avisos simples)
  // ===========================================================================

  // Aviso centralizado. Retorna true se o botão principal foi tocado.
  // Com `cancelText`, mostra também o botão secundário.
  static Future<bool> alert({
    required String title,
    String? message,
    Widget? content,
    IconData? icon,
    PopupType type = PopupType.info,
    String? confirmText,
    String? cancelText,
    bool dismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: _context,
      barrierDismissible: dismissible,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final accent = _accent(ctx, type);

        return PopScope(
          canPop: dismissible,
          child: AlertDialog(
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            icon: icon == null ? null : _IconBadge(icon: icon, color: accent),
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
            ),
            content: content ??
                (message == null
                    ? null
                    : Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      )),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              Row(
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(cancelText),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: _onColor(accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(confirmText ?? LocaleKeys.ok.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  // ===========================================================================
  // BOTTOM SHEETS
  // ===========================================================================

  // Bottom sheet genérico, já com cabeçalho e botões no padrão do app.
  // `actions` recebe o context da folha (use Navigator.of(ctx).pop(valor)).
  static Future<T?> sheet<T>({
    String? title,
    String? message,
    IconData? icon,
    PopupType type = PopupType.info,
    Widget? child,
    List<Widget> Function(BuildContext ctx)? actions,
    bool dismissible = true,
    double maxHeightFactor = 0.9,
  }) {
    return showModalBottomSheet<T>(
      context: _context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: dismissible,
      isDismissible: dismissible,
      enableDrag: dismissible,
      backgroundColor: Theme.of(_context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => PopScope(
        canPop: dismissible,
        child: AppSheet(
          title: title,
          message: message,
          icon: icon,
          iconColor: _accent(ctx, type),
          maxHeightFactor: maxHeightFactor,
          actions: actions?.call(ctx),
          child: child,
        ),
      ),
    );
  }

  // Bottom sheet com um widget próprio (que normalmente usa AppSheet por
  // dentro). Para devolver um valor: Navigator.of(context).pop(valor).
  static Future<T?> custom<T>(Widget child, {bool dismissible = true}) {
    return showModalBottomSheet<T>(
      context: _context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: dismissible,
      isDismissible: dismissible,
      enableDrag: dismissible,
      backgroundColor: Theme.of(_context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PopScope(canPop: dismissible, child: child),
    );
  }

  // Confirmação (sim/não). Retorna true só se o usuário confirmar.
  static Future<bool> confirm({
    required String title,
    String? message,
    IconData icon = Icons.help_outline_rounded,
    String? confirmText,
    String? cancelText,
    bool destructive = false,
    Widget? child,
  }) async {
    final result = await sheet<bool>(
      title: title,
      message: message,
      icon: icon,
      type: destructive ? PopupType.error : PopupType.info,
      child: child,
      actions: (ctx) => [
        AppSheetButton.primary(
          label: confirmText ?? LocaleKeys.confirm.tr,
          destructive: destructive,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        AppSheetButton.secondary(
          label: cancelText ?? LocaleKeys.cancel.tr,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ],
    );
    return result ?? false;
  }

  // Campo de texto. Retorna o texto (sem espaços nas pontas) ou null se
  // o usuário cancelar.
  static Future<String?> input({
    required String title,
    String? message,
    String? hint,
    String? initialValue,
    IconData icon = Icons.edit_note_rounded,
    PopupType type = PopupType.info,
    String? confirmText,
    int maxLines = 1,
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await sheet<String>(
      title: title,
      message: message,
      icon: icon,
      type: type,
      child: Builder(
        builder: (ctx) => TextField(
          controller: controller,
          autofocus: true,
          maxLines: maxLines,
          textInputAction:
              maxLines == 1 ? TextInputAction.done : TextInputAction.newline,
          onSubmitted: maxLines == 1
              ? (value) => Navigator.of(ctx).pop(value.trim())
              : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      actions: (ctx) => [
        AppSheetButton.primary(
          label: confirmText ?? LocaleKeys.confirm.tr,
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
        ),
        AppSheetButton.secondary(
          label: LocaleKeys.cancel.tr,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    );

    controller.dispose();
    return result;
  }

  // Lista de opções. Retorna o valor escolhido ou null se fechar.
  static Future<T?> choose<T>({
    required String title,
    String? message,
    IconData? icon,
    required List<PopupOption<T>> options,
    T? selected,
  }) {
    return sheet<T>(
      title: title,
      message: message,
      icon: icon,
      child: Builder(
        builder: (ctx) {
          final scheme = Theme.of(ctx).colorScheme;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = option.value == selected;
              final color = option.color ?? scheme.onSurface;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    leading: option.icon == null
                        ? null
                        : Icon(option.icon, color: color),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: option.description == null
                        ? null
                        : Text(option.description!),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded,
                            color: scheme.primary)
                        : null,
                    onTap: () => Navigator.of(ctx).pop(option.value),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // CARREGAMENTO
  // ===========================================================================

  static bool _isLoadingOpen = false;

  // Bloqueia a tela com um indicador de carregamento
  static void showLoading([String? message]) {
    if (_isLoadingOpen) return;
    _isLoadingOpen = true;

    showDialog<void>(
      context: _context,
      barrierDismissible: false,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;

        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlinkingLoadingIcon(size: 36, color: scheme.onSurface),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() => _isLoadingOpen = false);
  }

  static void hideLoading() {
    if (!_isLoadingOpen) return;
    _isLoadingOpen = false;
    Navigator.of(_context).pop();
  }

  // ===========================================================================
  // CORES E ÍCONES
  // ===========================================================================

  static IconData _icon(PopupType type) {
    switch (type) {
      case PopupType.success:
        return Icons.check_rounded;
      case PopupType.error:
        return Icons.close_rounded;
      case PopupType.warning:
        return Icons.priority_high_rounded;
      case PopupType.info:
        return Icons.info_outline_rounded;
    }
  }

  // Cores do snackbar (fundo sempre escuro)
  static Color _snackAccent(PopupType type) {
    switch (type) {
      case PopupType.success:
        return const Color(0xFF4ADE80);
      case PopupType.error:
        return const Color(0xFFF87171);
      case PopupType.warning:
        return const Color(0xFFFBBF24);
      case PopupType.info:
        return const Color(0xFF60A5FA);
    }
  }

  // Cores dos diálogos e folhas (seguem o tema)
  static Color _accent(BuildContext context, PopupType type) {
    final scheme = Theme.of(context).colorScheme;
    switch (type) {
      case PopupType.success:
        return Colors.green.shade600;
      case PopupType.error:
        return scheme.error;
      case PopupType.warning:
        return Colors.amber.shade700;
      case PopupType.info:
        return scheme.primary;
    }
  }

  static Color _onColor(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
          ? Colors.white
          : Colors.black;
}

// =============================================================================
// COMPONENTES VISUAIS (usados pelo AppPopups e por folhas personalizadas)
// =============================================================================

// Conteúdo padrão de um bottom sheet: ícone, título, mensagem, conteúdo
// rolável e botões. Use dentro de AppPopups.sheet ou em folhas próprias.
class AppSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Color? iconColor;
  final Widget? child;
  final List<Widget>? actions;
  final double maxHeightFactor;

  const AppSheet({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.child,
    this.actions,
    this.maxHeightFactor = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final media = MediaQuery.of(context);

    return Padding(
      // Sobe junto com o teclado
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * maxHeightFactor,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (icon != null) ...[
                Center(
                  child: _IconBadge(
                    icon: icon!,
                    color: iconColor ?? scheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (title != null)
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(child: child),
                ),
              ],
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 20),
                for (int i = 0; i < actions!.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  actions![i],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Botões de largura total usados nas folhas
class AppSheetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool destructive;

  const AppSheetButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  }) : primary = true;

  const AppSheetButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
  })  : primary = false,
        destructive = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    const size = Size.fromHeight(52);
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    if (primary) {
      return FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: size,
          shape: shape,
          textStyle: textStyle,
          backgroundColor: destructive ? scheme.error : scheme.primary,
          foregroundColor: destructive ? scheme.onError : scheme.onPrimary,
        ),
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: size,
        shape: shape,
        textStyle: textStyle,
        foregroundColor: scheme.onSurfaceVariant,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// Ícone dentro de um círculo colorido (cabeçalho de folhas e diálogos)
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
