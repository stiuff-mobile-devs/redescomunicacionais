import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/utils/translations/locale_keys.dart';

class MarkdownEditor extends StatefulWidget {
  final QuillController? controller;

  const MarkdownEditor({
    super.key,
    this.controller,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late final QuillController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ?? QuillController.basic();

    _focusNode = FocusNode();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor =
        theme.scaffoldBackgroundColor;

    final textColor =
        colors.onSurface;

    final secondaryTextColor =
        colors.onSurfaceVariant;

    final borderColor =
        colors.outline;

    final primaryColor =
        colors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ========================================================
        // TOOLBAR
        // ========================================================

        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Theme(
            data: theme.copyWith(
              brightness: theme.brightness,
              scaffoldBackgroundColor: backgroundColor,
              canvasColor: backgroundColor,
              cardColor: backgroundColor,

              colorScheme: colors.copyWith(
                surface: backgroundColor,
                onSurface: textColor,
                primary: primaryColor,
              ),

              iconTheme: IconThemeData(
                color: textColor,
              ),

              iconButtonTheme: IconButtonThemeData(
                style: IconButton.styleFrom(
                  foregroundColor: textColor,
                ),
              ),

              tooltipTheme: TooltipThemeData(
                decoration: BoxDecoration(
                  color: colors.inverseSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: TextStyle(
                  color: colors.onInverseSurface,
                ),
              ),
            ),

            child: QuillSimpleToolbar(
              controller: _controller,
              config: const QuillSimpleToolbarConfig(
                toolbarIconAlignment: WrapAlignment.start,
                multiRowsDisplay: false,

                showBoldButton: true,
                showItalicButton: true,

                showUnderLineButton: false,
                showStrikeThrough: false,

                showColorButton: false,
                showBackgroundColorButton: false,

                showClearFormat: false,

                showListNumbers: false,
                showListBullets: true,
                showListCheck: false,

                showQuote: true,
                showIndent: false,

                showLink: false,

                showUndo: true,
                showRedo: true,

                showFontFamily: false,
                showFontSize: false,
                showHeaderStyle: false,

                showCodeBlock: false,
                showInlineCode: false,

                showDirection: false,
                showSearchButton: false,

                showSubscript: false,
                showSuperscript: false,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ========================================================
        // EDITOR
        // ========================================================

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
              ),
            ),

            child: Theme(
              data: theme.copyWith(
                brightness: theme.brightness,
                scaffoldBackgroundColor: backgroundColor,
                canvasColor: backgroundColor,
                cardColor: backgroundColor,

                colorScheme: colors.copyWith(
                  surface: backgroundColor,
                  onSurface: textColor,
                  primary: primaryColor,
                ),

                textTheme: theme.textTheme.apply(
                  bodyColor: textColor,
                  displayColor: textColor,
                ),
              ),

              child: QuillEditor.basic(
                controller: _controller,
                focusNode: _focusNode,
                scrollController: _scrollController,

                config: QuillEditorConfig(
                  padding: const EdgeInsets.all(12),

                  placeholder:
                  LocaleKeys.newsBodyHint.tr,

                  autoFocus: false,
                  expands: false,

                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      TextStyle(
                        color: textColor,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      HorizontalSpacing.zero,
                      const VerticalSpacing(6, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),

                    bold: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),

                    italic: TextStyle(
                      color: textColor,
                      fontStyle: FontStyle.italic,
                    ),

                    quote: DefaultTextBlockStyle(
                      TextStyle(
                        color: secondaryTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                      HorizontalSpacing.zero,
                      const VerticalSpacing(6, 6),
                      const VerticalSpacing(0, 0),
                      BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: primaryColor,
                            width: 4,
                          ),
                        ),
                      ),
                    ),

                    lists: DefaultListBlockStyle(
                      TextStyle(
                        color: textColor,
                        fontSize: 16,
                        height: 1.4,
                      ),
                      HorizontalSpacing.zero,
                      const VerticalSpacing(6, 0),
                      const VerticalSpacing(0, 0),
                      const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      null,
                    ),

                    placeHolder: DefaultTextBlockStyle(
                      TextStyle(
                        color: secondaryTextColor.withOpacity(0.65),
                        fontSize: 16,
                      ),
                      HorizontalSpacing.zero,
                      const VerticalSpacing(6, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXTO PURO
  // ============================================================

  String getPlainText() {
    return _controller.document.toPlainText();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _focusNode.dispose();

    _scrollController.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }
}