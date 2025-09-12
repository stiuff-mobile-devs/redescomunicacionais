import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class MarkdownEditor extends StatefulWidget {
  final QuillController? controller;

  const MarkdownEditor({super.key, this.controller});

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? QuillController.basic();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de ferramentas
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
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

        const SizedBox(height: 8),

        // Editor de texto
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
            color: Colors.black,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
              iconTheme: const IconThemeData(color: Colors.white),
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    onSurface: Colors.white,
                    primary: Colors.white,
                    outline: Colors.white,
                  ),
            ),
            child: QuillEditor.basic(
              controller: _controller,
              focusNode: FocusNode(),
              scrollController: ScrollController(),
              config: QuillEditorConfig(
                padding: const EdgeInsets.all(12),
                placeholder: 'Digite o corpo da matéria...',
                autoFocus: false,
                expands: false,
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    HorizontalSpacing.zero,
                    const VerticalSpacing(6, 0),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                  bold: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  italic: const TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                  quote: DefaultTextBlockStyle(
                    const TextStyle(color: Colors.white70),
                    HorizontalSpacing.zero,
                    const VerticalSpacing(6, 6),
                    const VerticalSpacing(0, 0),
                    BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.white, width: 4),
                      ),
                    ),
                  ),
                  lists: DefaultListBlockStyle(
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
                      color: Colors.white.withOpacity(0.6),
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
      ],
    );
  }

  // Método para obter o texto em formato plain text
  String getPlainText() {
    return _controller.document.toPlainText();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
