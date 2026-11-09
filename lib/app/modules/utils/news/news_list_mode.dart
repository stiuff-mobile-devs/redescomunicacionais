import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_tones.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

// Filtro de matérias exibido na Home.
// - published: feed público (Home normal, sem controles de modo)
// - os demais: modos editoriais, abertos pela central da matéria
enum NewsListMode {
  published,
  revision,
  drafts,
  rejected,
  deleted;

  // Modos editoriais, na ordem dos filtros (chips) da Home editorial
  static const List<NewsListMode> editorialModes = [
    NewsListMode.revision,
    NewsListMode.drafts,
    NewsListMode.rejected,
    NewsListMode.deleted,
  ];

  bool get isEditorial => this != NewsListMode.published;

  // Título da AppBar
  String get title {
    switch (this) {
      case NewsListMode.published:
        return LocaleKeys.appShortName.tr;
      case NewsListMode.revision:
        return LocaleKeys.newsReview.tr;
      case NewsListMode.drafts:
        return LocaleKeys.myDrafts.tr;
      case NewsListMode.rejected:
        return LocaleKeys.rejectedNews.tr;
      case NewsListMode.deleted:
        return LocaleKeys.deletedNews.tr;
    }
  }

  // Rótulo curto (filtros da Home editorial)
  String get shortLabel {
    switch (this) {
      case NewsListMode.published:
        return LocaleKeys.appShortName.tr;
      case NewsListMode.revision:
        return LocaleKeys.chipRevision.tr;
      case NewsListMode.drafts:
        return LocaleKeys.chipDrafts.tr;
      case NewsListMode.rejected:
        return LocaleKeys.chipRejected.tr;
      case NewsListMode.deleted:
        return LocaleKeys.chipDeleted.tr;
    }
  }

  IconData get icon {
    switch (this) {
      case NewsListMode.published:
        return Icons.newspaper_rounded;
      case NewsListMode.revision:
        return Icons.fact_check_rounded;
      case NewsListMode.drafts:
        return Icons.drafts_outlined;
      case NewsListMode.rejected:
        return Icons.report_outlined;
      case NewsListMode.deleted:
        return Icons.delete_outline_rounded;
    }
  }

  AppTone get tone {
    switch (this) {
      case NewsListMode.published:
        return AppTone.brand;
      case NewsListMode.revision:
        return AppTone.info;
      case NewsListMode.drafts:
        return AppTone.warning;
      case NewsListMode.rejected:
        return AppTone.danger;
      case NewsListMode.deleted:
        return AppTone.deleted;
    }
  }
}
