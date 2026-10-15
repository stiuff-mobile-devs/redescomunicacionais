
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ReleaseNotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getReleaseNotes(
      String version,
      ) async {
    try {
      final document = await _firestore
          .collection('app_updates')
          .doc(version)
          .get();

      if (!document.exists) {
        return null;
      }

      final data = document.data();

      if (data == null || data['active'] != true) {
        return null;
      }

      final notes = data['releaseNotes'];

      if (notes is! List) {
        return null;
      }

      return {
        'version': data['version']?.toString() ?? version,
        'title': data['title']?.toString() ??
            'Novidades da atualização',
        'releaseNotes': notes.whereType<String>().toList(),
      };
    } catch (e) {
      debugPrint('Erro ao buscar novidades da atualização: $e');
      return null;
    }
  }
}
