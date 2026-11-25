import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

final customMarkdownStyle = MarkdownStyleSheet(
  p: const TextStyle(color: Colors.white),
  h1: const TextStyle(color: Colors.white),
  h2: const TextStyle(color: Colors.white),
  h3: const TextStyle(color: Colors.white,),
  blockquote: TextStyle(color: Colors.white),
  blockquotePadding: const EdgeInsets.all(12),
  blockquoteDecoration: BoxDecoration(
    color: const Color.fromARGB(255, 27, 27, 27),
    borderRadius: BorderRadius.circular(4),
  ),
  code: const TextStyle(color: Colors.greenAccent),
  listBullet: const TextStyle(color: Colors.white)
);
